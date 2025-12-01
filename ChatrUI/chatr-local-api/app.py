import math
from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

PLACES = [
    {
        "id": "food-royal-biryani-62",
        "name": "Royal Biryani Corner",
        "category": "food",
        "rating": 4.6,
        "reviews_count": 189,
        "lat": 28.6208,
        "lon": 77.3664,
        "address": "G Block, Sector 62, Noida",
        "is_partner": True,
        "price_level": "₹₹ · Biryani · Mughlai",
        "tags": ["Chicken Biryani", "Mutton Biryani", "Late Night"],
        "packages": [
            {"title": "Student Bucket (2 plates)", "price": "₹249", "duration": "All day"},
            {"title": "Office Combo (3 plates + 3 Coke)", "price": "₹499", "duration": "12pm–4pm"}
        ],
        "opening_hours": {"Mon-Sun": "11:00 AM – 11:30 PM"},
        "about": "Popular biryani joint in Sector 62, known for heavy portions and consistent taste."
    },
    {
        "id": "doctor-care-clinic-62",
        "name": "Care & Cure Multispeciality Clinic",
        "category": "doctor",
        "rating": 4.8,
        "reviews_count": 210,
        "lat": 28.6233,
        "lon": 77.3688,
        "address": "Shop 12, Market Complex, Sector 62, Noida",
        "is_partner": True,
        "price_level": "₹₹ · General Physician · Pediatrician",
        "tags": ["General Physician", "Child Specialist", "Pathology"],
        "packages": [
            {"title": "Basic Health Checkup", "price": "₹799", "duration": "Mon–Sat"},
            {"title": "Diabetes Care Plan (3 visits)", "price": "₹1999", "duration": "Valid 3 months"}
        ],
        "opening_hours": {
            "Mon-Sat": "9:00 AM – 1:00 PM, 5:00 PM – 9:00 PM",
            "Sun": "10:00 AM – 1:00 PM"
        },
        "about": "Neighbourhood clinic with in-house lab and pharmacy, ideal for families in Sector 62."
    }
]

def haversine_km(lat1, lon1, lat2, lon2):
    R = 6371.0
    lat1, lon1, lat2, lon2 = map(math.radians, [lat1, lon1, lat2, lon2])
    dlat = lat2 - lat1
    dlon = lon2 - lon1
    a = math.sin(dlat/2)**2 + math.cos(lat1)*math.cos(lat2)*math.sin(dlon/2)**2
    return R * 2 * math.asin(math.sqrt(a))

def match_text(haystack, needle):
    if not needle:
        return True
    if not haystack:
        return False
    return needle.lower() in haystack.lower()

@app.route("/local/search", methods=["POST"])
def local_search():
    data = request.get_json(force=True, silent=True) or {}

    query = (data.get("query") or "").strip()
    category = (data.get("category") or "").strip().lower()
    lat = data.get("lat")
    lon = data.get("lon")

    results = []
    for place in PLACES:
        if category and place.get("category", "").lower() != category:
            continue

        if query:
            fields = [
                place.get("name", ""),
                place.get("category", ""),
                place.get("address", ""),
                place.get("about", ""),
                " ".join(place.get("tags", [])),
            ]
            if not any(match_text(f, query) for f in fields):
                continue

        item = dict(place)
        try:
            if lat is not None and lon is not None:
                dist = haversine_km(float(lat), float(lon), float(place["lat"]), float(place["lon"]))
                item["distance_km"] = round(dist, 2)
        except:
            item["distance_km"] = None

        results.append(item)

    if results and "distance_km" in results[0]:
        results.sort(key=lambda r: r.get("distance_km") or 999999)
    else:
        results.sort(key=lambda r: r.get("rating", 0), reverse=True)

    return jsonify({"results": results})

@app.route("/")
def health():
    return jsonify({"status": "ok", "service": "chatr-local-api"})

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=4300, debug=True)
