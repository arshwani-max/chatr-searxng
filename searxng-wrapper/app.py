# app.py
import os
import re
import time
from typing import Dict, List, Tuple, Optional
from fastapi import FastAPI, Query, Header, HTTPException, Request
from pydantic import BaseModel
import psycopg2
from psycopg2 import sql
import requests
from cachetools import TTLCache, cached

# ---------- CONFIG (edit env vars or set in Docker run) ----------
DB_HOST = os.getenv("DB_HOST", "YOUR_SUPABASE_HOST.supabase.co")
DB_NAME = os.getenv("DB_NAME", "postgres")
DB_USER = os.getenv("DB_USER", "postgres")
DB_PASSWORD = os.getenv("DB_PASSWORD", "YOUR_SUPABASE_PASSWORD")

SEARXNG_URL = os.getenv("SEARXNG_URL", "http://host.docker.internal:8080")  # fallback engine
SUBSCRIPTION_API_KEY = os.getenv("SUBSCRIPTION_API_KEY", "changeme")  # simple subscription check
RESULTS_LIMIT = int(os.getenv("RESULTS_LIMIT", "10"))

# ---------- INTENT MAP (21 industries) ----------
INTENT_MAP = {
    'local': {
        'keywords': ['plumber', 'electrician', 'carpenter', 'ac repair', 'salon at home', 'cleaning', 'pest control', 'ro service', 'painter', 'geyser repair'],
        'table': 'local_services',
        'category': 'local'
    },
    'food': {
        'keywords': ['restaurant', 'cafe', 'bakery', 'fast food', 'street food', 'tiffin', 'food delivery', 'biriyani', 'pizza'],
        'table': 'food_restaurants',
        'category': 'food'
    },
    'jobs': {
        'keywords': ['job', 'hiring', 'internship', 'freelancer', 'part-time', 'delivery job', 'local gig', 'sales job'],
        'table': 'jobs_listings',
        'category': 'jobs'
    },
    'health': {
        'keywords': ['hospital', 'clinic', 'doctor', 'dentist', 'lab', 'pharmacy', 'ambulance', 'pathology'],
        'table': 'healthcare_providers',
        'category': 'health'
    },
    'shopping': {
        'keywords': ['iphone', 'shoes', 'fridge', 'electronics', 'fashion', 'grocery', 'mobile price'],
        'table': 'e_commerce_products',
        'category': 'shopping'
    },
    'education': {
        'keywords': ['school', 'college', 'coaching', 'tuition', 'upsc', 'ssc', 'language class'],
        'table': 'education_centers',
        'category': 'education'
    },
    'realestate': {
        'keywords': ['buy home', 'rent home', 'commercial space', 'pg', 'hostel', '99acres', 'nobroker'],
        'table': 'real_estate_listings',
        'category': 'realestate'
    },
    'auto': {
        'keywords': ['car repair', 'bike repair', 'tow', 'mechanic', 'spare parts', 'car wash'],
        'table': 'auto_services',
        'category': 'auto'
    },
    'local_shops': {
        'keywords': ['kirana', 'stationery', 'mobile shop', 'hardware store'],
        'table': 'local_business_listings',
        'category': 'local'
    },
    'travel': {
        'keywords': ['taxi', 'auto', 'metro', 'bus timing', 'train schedule', 'travel agent'],
        'table': 'travel_transport',
        'category': 'travel'
    },
    'entertainment': {
        'keywords': ['movies', 'events', 'park', 'gaming zone', 'stand-up'],
        'table': 'entertainment_listings',
        'category': 'entertainment'
    },
    'gov': {
        'keywords': ['aadhar', 'passport', 'rto', 'police station', 'property registration'],
        'table': 'gov_services',
        'category': 'gov'
    },
    'finance': {
        'keywords': ['atm', 'bank branch', 'loan agent', 'insurance office', 'credit card'],
        'table': 'finance_banking',
        'category': 'finance'
    },
    'fitness': {
        'keywords': ['gym', 'yoga', 'dietician', 'sports coach', 'zumba'],
        'table': 'fitness_wellness',
        'category': 'fitness'
    },
    'rentals': {
        'keywords': ['furniture rental', 'appliance rental', 'laptop rental', 'mobile rental'],
        'table': 'home_rentals',
        'category': 'rentals'
    },
    'pets': {
        'keywords': ['pet shop', 'grooming', 'vet', 'pet food'],
        'table': 'pets_services',
        'category': 'pets'
    },
    'legal': {
        'keywords': ['lawyer', 'ca', 'chartered accountant', 'business registration', 'gst'],
        'table': 'legal_consultants',
        'category': 'legal'
    },
    'events': {
        'keywords': ['caterer', 'photographer', 'decorator', 'banquet hall', 'wedding'],
        'table': 'events_wedding',
        'category': 'events'
    },
    'repair_install': {
        'keywords': ['ac installation', 'fridge repair', 'washing machine repair', 'tv repair'],
        'table': 'repair_installation',
        'category': 'local'
    },
    'b2b': {
        'keywords': ['machinery', 'raw material', 'tools', 'safety equipment', 'indiamart', 'tradeindia'],
        'table': 'b2b_industrial',
        'category': 'b2b'
    },
    'freelancer': {
        'keywords': ['designer', 'developer', 'digital marketer', 'accountant', 'editor', 'freelancer'],
        'table': 'freelance_creators',
        'category': 'freelancer'
    },
    'default': {
        'table': 'all_listings',
        'category': 'general'
    }
}

# Allowed table set (prevents table-name injection)
ALLOWED_TABLES = {v['table'] for v in INTENT_MAP.values() if 'table' in v}

# ---------- CACHE ----------
CACHE = TTLCache(maxsize=1024, ttl=30)  # 30s cache

app = FastAPI(title="CHATR Hybrid Wrapper")

# ---------- UTIL: intent detection ----------
def get_intent_and_table(query: str) -> Tuple[str, str]:
    q = query.lower()
    for intent, data in INTENT_MAP.items():
        if 'keywords' in data:
            for kw in data['keywords']:
                if kw in q:
                    return data['table'], data['category']
    return INTENT_MAP['default']['table'], INTENT_MAP['default']['category']

# ---------- UTIL: subscription check ----------
def is_subscriber(api_key_header: Optional[str]) -> bool:
    # simple header-based check; replace with real DB or payment provider check later
    if not SUBSCRIPTION_API_KEY:
        return False
    return api_key_header == SUBSCRIPTION_API_KEY

# ---------- DATABASE QUERY (secure) ----------
def fetch_from_db(table_name: str, search_term: str, limit: int = RESULTS_LIMIT) -> List[Dict]:
    if table_name not in ALLOWED_TABLES:
        return []
    conn = None
    try:
        conn = psycopg2.connect(host=DB_HOST, database=DB_NAME, user=DB_USER, password=DB_PASSWORD, connect_timeout=5)
        cur = conn.cursor()
        # Use Identifier for table name and parameterized args for values
        query = sql.SQL("""
            SELECT name, address, specialty
            FROM {table}
            WHERE name ILIKE %s OR address ILIKE %s
            LIMIT %s;
        """).format(table=sql.Identifier(table_name))
        cur.execute(query, (f"%{search_term}%", f"%{search_term}%", limit))
        rows = cur.fetchall()
        cur.close()
        return [{"name": r[0], "address": r[1], "specialty": r[2] if len(r) > 2 else None} for r in rows]
    except Exception as e:
        # Log error — keep simple print for now
        print("DB error:", e)
        return []
    finally:
        if conn:
            conn.close()

# ---------- FALLBACK: call SearXNG backend ----------
def fallback_to_searxng(q: str, num: int = RESULTS_LIMIT) -> List[Dict]:
    try:
        r = requests.get(f"{SEARXNG_URL}/search", params={"q": q, "format": "json", "num": num}, timeout=6)
        if r.status_code == 200:
            data = r.json()
            results = []
            for hit in data.get("results", [])[:num]:
                results.append({
                    "url": hit.get("url"),
                    "title": hit.get("title"),
                    "content": hit.get("content"),
                    "engine": hit.get("engine"),
                    "category": hit.get("category", "general")
                })
            return results
    except Exception as e:
        print("searxng fallback error:", e)
    return []

# ---------- RESPONSE model ----------
class ResultItem(BaseModel):
    url: str
    title: str
    content: str
    engine: str
    category: str

class SearchResponse(BaseModel):
    query: str
    category: str
    results: List[ResultItem]

# ---------- CACHED search handler ----------
@cached(CACHE)
def run_local_search(query: str) -> Tuple[str, List[Dict]]:
    table, category = get_intent_and_table(query)
    rows = fetch_from_db(table, query)
    return category, rows

# ---------- API endpoint ----------
@app.get("/search", response_model=SearchResponse)
async def search(q: str = Query(..., min_length=1), x_subscriber_key: Optional[str] = Header(None, alias="X-Subscriber-Key")):
    """
    Hybrid search endpoint:
      1) Intent classification -> choose table
      2) Query local DB
      3) If no results, fallback to SearXNG
    """
    # 1) subscription check (example usage — e.g., paid users could see boosted results)
    subscriber = is_subscriber(x_subscriber_key)

    # 2) run local search (cached)
    category, rows = run_local_search(q)

    results = []
    if rows:
        for r in rows:
            results.append({
                "url": f"/listing/{r['name'].replace(' ', '_')}",
                "title": f"[{category.upper()}] {r['name']} - {r.get('specialty') or ''}".strip(),
                "content": f"📍 {r['address']}",
                "engine": "chatrhybrid",
                "category": category
            })
    else:
        # fallback to searxng
        searx_results = fallback_to_searxng(q)
        if searx_results:
            for r in searx_results:
                results.append(r)

    # if subscriber, tag results or order differently (placeholder)
    if subscriber and results:
        # simple boost: move local results first (they already are)
        pass

    # if still empty, return a helpful message
    if not results:
        results = [{
            "url": "/",
            "title": f"No results for '{q}'",
            "content": "Try different keywords or check connection to Supabase.",
            "engine": "chatrhybrid",
            "category": "general"
        }]

    return {"query": q, "category": category, "results": results}
