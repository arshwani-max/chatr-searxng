import requests # We now use the requests library for API calls
from searx.engines import categories
import json

# --- 1. CONFIGURATION ---
EDGE_FUNCTION_URL = "https://sbayuqgomlflmxgicplz.supabase.co/functions/v1/chatr-search" 
API_KEY = "YOUR_SUPABASE_ANON_KEY_GOES_HERE" # Using the Supabase Anon Key for access
API_HEADERS = {} 

# Base configuration
categories = ['general', 'health', 'jobs', 'food', 'local', 'finance', 'auto', 'realestate', 'travel', 'gov', 'b2b', 'shopping', 'education', 'entertainment', 'fitness', 'legal', 'freelancer']
paging = False
base_url = "https://chatr.chat"

# --- INTENT RECOGNITION MAPPING (Used to structure the search request) ---
INTENT_MAP = {
    'local': {'keywords': ['plumber', 'electrician', 'carpenter', 'ac repair', 'salon at home'], 'table': 'local_services', 'category': 'local'},
    'food': {'keywords': ['restaurant', 'cafe', 'bakery', 'fast food', 'street food', 'tiffin', 'food delivery', 'biriyani', 'pizza'], 'table': 'food_restaurants', 'category': 'food'},
    'jobs': {'keywords': ['job', 'hiring', 'internship', 'freelancer', 'part-time', 'delivery job', 'local gig', 'sales job'], 'table': 'jobs_listings', 'category': 'jobs'},
    'health': {'keywords': ['hospital', 'clinic', 'doctor', 'dentist', 'lab', 'pharmacy', 'ambulance', 'pathology'], 'table': 'healthcare_providers', 'category': 'health'},
    'default': {'table': 'all_listings', 'category': 'general'}
}

def get_intent_and_table(query):
    """Determines the user's intent and returns the best table name and category."""
    normalized_query = query.lower()
    
    for intent, data in INTENT_MAP.items():
        if 'keywords' in data:
            for keyword in data['keywords']:
                if keyword in normalized_query:
                    return data['table'], data['category']
    
    return INTENT_MAP['default']['table'], INTENT_MAP['default']['category']


def request(query, params):
    """Stores the user's raw query and determined intent for the response function."""
    
    table_name, category = get_intent_and_table(query)
    
    # Package the data required for the API call
    params['chatr_api_payload'] = {
        'query': query,
        'table': table_name,
        'category': category
    }
    params['chatr_category'] = category
    
    return params

def response(resp):
    """Calls the secure Lovable Cloud Edge Function and formats the JSON results."""
    results = []
    
    payload = resp.context.get('chatr_api_payload', {})
    query = payload.get('query', '')
    table_name = payload.get('table', 'all_listings')
    category = resp.context.get('chatr_category', 'general')

    # --- 2. EXECUTE QUERY AGAINST EDGE FUNCTION (SECURE API CALL) ---
    try:
        http_response = requests.post(
            EDGE_FUNCTION_URL,
            json=payload,
            headers=API_HEADERS,
            timeout=10 
        )
        http_response.raise_for_status() 
        
        data = http_response.json()
        
        if 'error' in data:
            raise Exception(data['error'])

        # --- 3. FORMAT RESULTS ---
        if not data.get('listings'):
            results.append({
                'url': base_url,
                'title': f"Chatr Search: No Matches Found in '{table_name}'",
                'content': f"Your search for '{query}' found no results via the Edge Function.",
                'engine': 'chatr_hybrid_api',
                'category': category
            })
            return results

        for listing in data['listings']:
            # Assuming the Edge Function returns 'name', 'address', 'specialty', and 'category'
            results.append({
                'url': f"{base_url}/listing/{listing['name'].replace(' ', '_')}",
                'title': f"[{listing['category'].upper()}] {listing['name']} - {listing['specialty']}",
                'content': f"📍 {listing['address']}",
                'engine': 'chatr_hybrid_api',
                'category': listing['category']
            })
            
    except requests.exceptions.RequestException as e:
        results.append({
            'url': base_url + "/troubleshoot",
            'title': "🔴 Chatr API Network Error",
            'content': "Failed to connect to Edge Function. Check URL/Network. Check Docker DNS. Error: ",
            'engine': 'chatr_hybrid_api',
            'category': 'general'
        })
    except Exception as e:
        results.append({
            'url': base_url + "/troubleshoot",
            'title': "⚠️ Chatr API Logic Error",
            'content': "Edge Function returned failure or bad data. Error: ",
            'engine': 'chatr_hybrid_api',
            'category': 'general'
        })
        
    return results
