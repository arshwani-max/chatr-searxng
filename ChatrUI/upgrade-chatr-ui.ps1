# ================================
# CHATR LOCAL ULTRA UI INSTALLER
# Overwrites: index.html, category.html, place.html, style.css, script.js
# Path: C:\Users\Arshid.Wani\searxng_v11\ChatrUI
# ================================

$root = "C:\Users\Arshid.Wani\searxng_v11\ChatrUI"
Set-Location $root

# ---------- index.html ----------
@'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>CHATR Local · Find Anything Near You</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <link rel="stylesheet" href="style.css" />
</head>
<body class="chatr-body">
<header class="chatr-header">
  <div class="chatr-logo-area">
    <div class="chatr-logo">CHATR<span>Local</span></div>
    <div class="chatr-location-pill" id="location-pill">
      Detecting location…
    </div>
  </div>
  <div class="chatr-search-bar">
    <input id="main-search-input" type="text" placeholder="Search: salons, doctors, biryani, gyms…" />
    <button id="main-search-btn">Search</button>
  </div>
  <div class="chatr-category-strip" id="home-category-strip">
    <button data-category="food">Food</button>
    <button data-category="salon">Salons</button>
    <button data-category="doctor">Doctors</button>
    <button data-category="services">Services</button>
    <button data-category="shops">Shops</button>
    <button data-category="travel">Travel</button>
    <button data-category="other">More</button>
  </div>
</header>

<main class="chatr-main">
  <section class="chatr-map-section">
    <canvas id="map-canvas"></canvas>
    <div class="map-overlay">
      <div class="map-title">Live Nearby Map</div>
      <div class="map-sub">Pins show results around you</div>
    </div>
  </section>

  <section class="chatr-results">
    <div class="chatr-results-header">
      <h2 id="results-title">Popular near you</h2>
      <span id="results-count" class="results-count"></span>
    </div>
    <div id="results-grid" class="chatr-card-grid">
      <!-- cards injected by JS -->
    </div>
  </section>
</main>

<footer class="chatr-footer">
  <div>CHATR Local · Ultra Search for your city</div>
</footer>

<script src="script.js"></script>
<script>
  // Home page boot
  document.addEventListener("DOMContentLoaded", function () {
    window.chatrLocal.initPage("home");
  });
</script>
</body>
</html>
'@ | Set-Content -Path "$root\index.html" -Encoding UTF8

# ---------- category.html ----------
@'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>CHATR Local · Category</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <link rel="stylesheet" href="style.css" />
</head>
<body class="chatr-body">
<header class="chatr-header">
  <div class="chatr-logo-area">
    <div class="chatr-logo">CHATR<span>Local</span></div>
    <div class="chatr-location-pill" id="location-pill">
      Detecting location…
    </div>
  </div>
  <div class="chatr-search-bar">
    <input id="category-search-input" type="text" placeholder="Refine: e.g. 'hair cut', 'dentist'…" />
    <button id="category-search-btn">Search</button>
  </div>
  <div class="chatr-category-strip" id="category-strip">
    <button data-category="food">Food</button>
    <button data-category="salon">Salons</button>
    <button data-category="doctor">Doctors</button>
    <button data-category="services">Services</button>
    <button data-category="shops">Shops</button>
    <button data-category="travel">Travel</button>
    <button data-category="other">More</button>
  </div>
</header>

<main class="chatr-main">
  <section class="chatr-map-section">
    <canvas id="map-canvas"></canvas>
    <div class="map-overlay">
      <div class="map-title" id="map-category-title">Category Map</div>
      <div class="map-sub">You are here · Pins are results</div>
    </div>
  </section>

  <section class="chatr-results">
    <div class="chatr-results-header">
      <h2 id="results-title">Category results</h2>
      <span id="results-count" class="results-count"></span>
    </div>
    <div id="results-grid" class="chatr-card-grid">
      <!-- cards injected by JS -->
    </div>
  </section>
</main>

<footer class="chatr-footer">
  <a href="index.html">← Back to Home</a>
</footer>

<script src="script.js"></script>
<script>
  document.addEventListener("DOMContentLoaded", function () {
    window.chatrLocal.initPage("category");
  });
</script>
</body>
</html>
'@ | Set-Content -Path "$root\category.html" -Encoding UTF8

# ---------- place.html ----------
@'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>CHATR Local · Place Profile</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <link rel="stylesheet" href="style.css" />
</head>
<body class="chatr-body">
<header class="chatr-header">
  <div class="chatr-logo-area">
    <div class="chatr-logo">CHATR<span>Local</span></div>
    <div class="chatr-location-pill" id="location-pill">
      Detecting location…
    </div>
  </div>
</header>

<main class="chatr-main">
  <section class="place-hero">
    <div class="place-hero-info">
      <div class="place-chip-row">
        <span id="place-category-chip" class="chip chip-soft"></span>
        <span id="partner-chip" class="chip chip-partner" style="display:none;">CHATR Partner</span>
      </div>
      <h1 id="place-name">Loading…</h1>
      <div class="place-rating-row" id="place-rating-row">
        <!-- rating stars injected -->
      </div>
      <div id="place-address" class="place-address"></div>
      <div id="place-distance" class="place-distance"></div>
    </div>
    <div class="place-actions">
      <button id="call-btn" class="primary-action" disabled>Call</button>
      <button id="whatsapp-btn" class="secondary-action" disabled>WhatsApp</button>
      <button id="navigate-btn" class="secondary-action" disabled>Navigate</button>
    </div>
  </section>

  <section class="place-layout">
    <div class="place-main-col">
      <section class="card-block" id="packages-section" style="display:none;">
        <div class="card-block-header">
          <h2>Popular Packages</h2>
        </div>
        <div id="packages-list" class="packages-list"></div>
      </section>

      <section class="card-block" id="about-section">
        <div class="card-block-header">
          <h2>About</h2>
        </div>
        <p id="place-about">No description provided. This is a verified listing from CHATR Local search.</p>
      </section>

      <section class="card-block" id="tags-section" style="display:none;">
        <div class="card-block-header">
          <h2>Highlights</h2>
        </div>
        <div id="tags-container" class="tags-container"></div>
      </section>
    </div>

    <aside class="place-side-col">
      <section class="card-block small-card">
        <div class="card-block-header">
          <h3>Live Map</h3>
        </div>
        <canvas id="place-map-canvas"></canvas>
        <div class="map-sub tiny">Blue = you, Purple = this place</div>
      </section>

      <section class="card-block small-card" id="hours-section" style="display:none;">
        <div class="card-block-header">
          <h3>Opening Hours</h3>
        </div>
        <div id="hours-list" class="hours-list"></div>
      </section>
    </aside>
  </section>
</main>

<footer class="chatr-footer">
  <a href="index.html">← Back to Home</a>
</footer>

<script src="script.js"></script>
<script>
  document.addEventListener("DOMContentLoaded", function () {
    window.chatrLocal.initPage("place");
  });
</script>
</body>
</html>
'@ | Set-Content -Path "$root\place.html" -Encoding UTF8

# ---------- style.css ----------
@'
:root {
  --bg: #050510;
  --bg-elevated: #09091a;
  --bg-elevated-soft: #0f0f23;
  --accent: #8f5bff;
  --accent-soft: rgba(143, 91, 255, 0.12);
  --accent-strong: #b58dff;
  --accent-secondary: #00e0ff;
  --text: #fcfcff;
  --text-soft: #b1b3c7;
  --border-soft: rgba(255, 255, 255, 0.08);
  --danger: #ff4b81;
  --success: #22c55e;
  --radius-lg: 18px;
  --radius-md: 12px;
  --radius-sm: 999px;
  --shadow-soft: 0 18px 45px rgba(0, 0, 0, 0.7);
  --shadow-chip: 0 2px 8px rgba(0, 0, 0, 0.5);
}

*,
*::before,
*::after {
  box-sizing: border-box;
}

html, body {
  margin: 0;
  padding: 0;
  font-family: system-ui, -apple-system, BlinkMacSystemFont, "SF Pro Text", sans-serif;
  background: radial-gradient(circle at top, #16162b 0, #050510 50%, #030308 100%);
  color: var(--text);
}

.chatr-body {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

/* Header */

.chatr-header {
  position: sticky;
  top: 0;
  z-index: 40;
  padding: 16px clamp(16px, 5vw, 36px) 10px;
  backdrop-filter: blur(16px);
  background: radial-gradient(circle at top left, rgba(149, 114, 252, 0.12), transparent 45%) ,
              radial-gradient(circle at top right, rgba(45, 212, 191, 0.1), transparent 50%) ,
              rgba(5, 5, 16, 0.95);
  border-bottom: 1px solid var(--border-soft);
}

.chatr-logo-area {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  margin-bottom: 12px;
}

.chatr-logo {
  font-weight: 800;
  letter-spacing: 0.04em;
  text-transform: uppercase;
  font-size: 20px;
}

.chatr-logo span {
  background: linear-gradient(120deg, var(--accent-secondary), var(--accent-strong));
  -webkit-background-clip: text;
  background-clip: text;
  color: transparent;
}

.chatr-location-pill {
  padding: 6px 12px;
  border-radius: var(--radius-sm);
  background: radial-gradient(circle at top, rgba(143, 91, 255, 0.25), rgba(18, 18, 40, 0.9));
  border: 1px solid rgba(143, 91, 255, 0.4);
  font-size: 12px;
  color: var(--text-soft);
  display: inline-flex;
  align-items: center;
  gap: 6px;
  box-shadow: var(--shadow-chip);
  white-space: nowrap;
  max-width: 50vw;
  overflow: hidden;
  text-overflow: ellipsis;
}

.chatr-search-bar {
  display: grid;
  grid-template-columns: minmax(0, 1fr) auto;
  gap: 10px;
  margin-bottom: 10px;
}

.chatr-search-bar input {
  border-radius: var(--radius-lg);
  border: 1px solid rgba(255, 255, 255, 0.08);
  padding: 10px 14px;
  background: radial-gradient(circle at top left, rgba(255, 255, 255, 0.02), rgba(5, 5, 16, 0.95));
  color: var(--text);
  font-size: 14px;
  outline: none;
}

.chatr-search-bar input::placeholder {
  color: var(--text-soft);
}

.chatr-search-bar button {
  border-radius: var(--radius-lg);
  border: none;
  padding: 10px 18px;
  background: linear-gradient(120deg, var(--accent-secondary), var(--accent));
  color: #050510;
  font-weight: 600;
  cursor: pointer;
  box-shadow: var(--shadow-soft);
  white-space: nowrap;
}

.chatr-category-strip {
  display: flex;
  flex-wrap: nowrap;
  overflow-x: auto;
  gap: 8px;
  padding-top: 8px;
  padding-bottom: 2px;
  scrollbar-width: thin;
}

.chatr-category-strip button {
  border-radius: 999px;
  border: 1px solid rgba(255, 255, 255, 0.08);
  padding: 6px 12px;
  background: rgba(9, 9, 26, 0.95);
  color: var(--text-soft);
  font-size: 12px;
  white-space: nowrap;
  cursor: pointer;
}

.chatr-category-strip button.active {
  background: radial-gradient(circle at top, rgba(143, 91, 255, 0.4), rgba(9, 9, 26, 0.95));
  color: var(--text);
  border-color: rgba(143, 91, 255, 0.7);
}

/* Main layout */

.chatr-main {
  flex: 1;
  padding: 12px clamp(16px, 5vw, 36px) 24px;
  display: grid;
  grid-template-columns: minmax(0, 3fr) minmax(0, 4fr);
  gap: 18px;
}

@media (max-width: 900px) {
  .chatr-main {
    grid-template-columns: minmax(0, 1fr);
  }
}

/* Map */

.chatr-map-section {
  background: radial-gradient(circle at top, rgba(143, 91, 255, 0.25), rgba(3, 3, 8, 0.95));
  border-radius: var(--radius-lg);
  border: 1px solid rgba(143, 91, 255, 0.4);
  box-shadow: var(--shadow-soft);
  position: relative;
  overflow: hidden;
  min-height: 260px;
}

#map-canvas,
#place-map-canvas {
  width: 100%;
  height: 100%;
  display: block;
}

.map-overlay {
  position: absolute;
  bottom: 14px;
  left: 14px;
  padding: 10px 12px;
  border-radius: 14px;
  background: rgba(5, 5, 12, 0.88);
  border: 1px solid rgba(255, 255, 255, 0.18);
  backdrop-filter: blur(12px);
  max-width: 66%;
}

.map-title {
  font-size: 13px;
  font-weight: 600;
}

.map-sub {
  font-size: 11px;
  color: var(--text-soft);
}

.map-sub.tiny {
  font-size: 10px;
}

/* Results */

.chatr-results {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.chatr-results-header {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
}

.chatr-results-header h2 {
  margin: 0;
  font-size: 18px;
}

.results-count {
  font-size: 12px;
  color: var(--text-soft);
}

.chatr-card-grid {
  display: grid;
  grid-template-columns: minmax(0, 1fr);
  gap: 10px;
  max-height: 72vh;
  overflow-y: auto;
  padding-right: 4px;
  scrollbar-width: thin;
}

@media (min-width: 1100px) {
  .chatr-card-grid {
    grid-template-columns: minmax(0, 1fr) minmax(0, 1fr);
  }
}

.chatr-card {
  background: radial-gradient(circle at top left, rgba(143, 91, 255, 0.16), rgba(9, 9, 24, 0.96));
  border-radius: 16px;
  border: 1px solid rgba(255, 255, 255, 0.08);
  padding: 10px 12px;
  position: relative;
  cursor: pointer;
  overflow: hidden;
}

.chatr-card:hover {
  border-color: rgba(143, 91, 255, 0.7);
  box-shadow: 0 14px 30px rgba(0, 0, 0, 0.7);
}

.card-main-row {
  display: flex;
  gap: 10px;
}

.card-left {
  flex: 1;
  min-width: 0;
}

.card-title-row {
  display: flex;
  align-items: center;
  gap: 6px;
  margin-bottom: 4px;
}

.card-title {
  font-size: 14px;
  font-weight: 600;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.chip {
  border-radius: var(--radius-sm);
  padding: 2px 8px;
  font-size: 10px;
  border: 1px solid rgba(255, 255, 255, 0.16);
  color: var(--text-soft);
  background: radial-gradient(circle at top, rgba(255, 255, 255, 0.03), rgba(9, 9, 24, 0.95));
}

.chip-soft {
  border-style: dashed;
}

.chip-partner {
  border-color: rgba(143, 91, 255, 0.9);
  background: linear-gradient(120deg, rgba(143, 91, 255, 0.2), rgba(0, 224, 255, 0.22));
  color: var(--accent-strong);
  box-shadow: var(--shadow-chip);
}

.card-rating-row {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 11px;
  color: var(--text-soft);
  margin-bottom: 4px;
}

.card-stars {
  font-size: 11px;
}

.card-meta-row {
  font-size: 11px;
  color: var(--text-soft);
  margin-bottom: 4px;
}

.card-meta-row span + span::before {
  content: "·";
  margin: 0 4px;
  opacity: 0.7;
}

.card-tags-row {
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
  margin-bottom: 4px;
}

.card-tag {
  font-size: 10px;
  padding: 2px 7px;
  border-radius: 999px;
  background: rgba(15, 23, 42, 0.9);
  border: 1px solid rgba(148, 163, 184, 0.4);
}

.card-packages-row {
  font-size: 11px;
  color: var(--accent-secondary);
}

.card-right {
  width: 90px;
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 6px;
}

.card-distance-pill {
  font-size: 10px;
  padding: 3px 8px;
  border-radius: 999px;
  background: rgba(15, 23, 42, 0.9);
  border: 1px solid rgba(148, 163, 184, 0.4);
}

.card-cta {
  font-size: 11px;
  padding: 4px 8px;
  border-radius: 999px;
  border: none;
  background: linear-gradient(120deg, var(--accent-secondary), var(--accent));
  color: #050510;
  cursor: pointer;
}

/* Place page */

.place-hero {
  display: flex;
  flex-wrap: wrap;
  gap: 16px;
  margin-bottom: 14px;
}

.place-hero-info {
  flex: 1;
  min-width: 220px;
}

.place-chip-row {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  margin-bottom: 4px;
}

.place-hero h1 {
  margin: 0 0 4px;
  font-size: 22px;
}

.place-rating-row {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 13px;
  color: var(--text-soft);
  margin-bottom: 4px;
}

.place-address {
  font-size: 13px;
  color: var(--text-soft);
}

.place-distance {
  font-size: 12px;
  color: var(--accent-secondary);
}

.place-actions {
  display: flex;
  flex-direction: column;
  gap: 8px;
  min-width: 150px;
}

.place-actions button {
  width: 100%;
}

.primary-action {
  padding: 9px 12px;
  border-radius: var(--radius-lg);
  border: none;
  background: linear-gradient(120deg, var(--accent-secondary), var(--accent));
  color: #050510;
  font-weight: 600;
  cursor: pointer;
}

.secondary-action {
  padding: 8px 12px;
  border-radius: var(--radius-lg);
  border: 1px solid var(--border-soft);
  background: rgba(9, 9, 24, 0.96);
  color: var(--text-soft);
  cursor: pointer;
}

.place-layout {
  display: grid;
  grid-template-columns: minmax(0, 3fr) minmax(0, 2fr);
  gap: 14px;
}

@media (max-width: 980px) {
  .place-layout {
    grid-template-columns: minmax(0, 1fr);
  }
  .place-actions {
    flex-direction: row;
    flex-wrap: wrap;
  }
}

.card-block {
  background: radial-gradient(circle at top left, rgba(148, 163, 184, 0.16), rgba(9, 9, 24, 0.96));
  border-radius: var(--radius-lg);
  border: 1px solid rgba(148, 163, 184, 0.4);
  padding: 10px 12px;
}

.card-block.small-card {
  padding: 8px 10px;
}

.card-block-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 6px;
  margin-bottom: 6px;
}

.card-block-header h2,
.card-block-header h3 {
  margin: 0;
  font-size: 15px;
}

.packages-list {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.package-pill {
  padding: 6px 8px;
  border-radius: 12px;
  border: 1px dashed rgba(148, 163, 184, 0.6);
  font-size: 12px;
  display: flex;
  justify-content: space-between;
  gap: 8px;
}

.package-pill-title {
  font-weight: 500;
}

.package-pill-meta {
  text-align: right;
  font-size: 11px;
  color: var(--accent-strong);
}

.tags-container {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}

.tag-pill {
  border-radius: 999px;
  padding: 4px 10px;
  font-size: 11px;
  border: 1px solid rgba(148, 163, 184, 0.5);
  background: rgba(15, 23, 42, 0.98);
}

.hours-list {
  font-size: 12px;
  color: var(--text-soft);
}

/* Footer */

.chatr-footer {
  border-top: 1px solid var(--border-soft);
  padding: 10px clamp(16px, 5vw, 36px) 16px;
  font-size: 12px;
  color: var(--text-soft);
  display: flex;
  justify-content: space-between;
  gap: 10px;
}

.chatr-footer a {
  color: var(--accent-secondary);
  text-decoration: none;
}
'@ | Set-Content -Path "$root\style.css" -Encoding UTF8

# ---------- script.js ----------
@'
window.chatrLocal = (function () {
  const API_URL = "http://localhost:4300/local/search";

  const defaultLocation = {
    lat: 28.6279, // Noida-ish default
    lon: 77.3683,
    label: "Using default location (Noida)"
  };

  const state = {
    page: "home",
    lat: null,
    lon: null,
    locationLabel: "",
    category: null,
    query: "",
    results: []
  };

  // ===============================
  // Utils
  // ===============================
  function $(id) {
    return document.getElementById(id);
  }

  function getQueryParams() {
    const params = {};
    const q = window.location.search.substring(1).split("&");
    for (const kv of q) {
      if (!kv) continue;
      const [k, v] = kv.split("=");
      params[decodeURIComponent(k)] = decodeURIComponent(v || "");
    }
    return params;
  }

  function updateLocationPill(text) {
    const el = $("location-pill");
    if (el) el.textContent = text;
  }

  function toFixedMaybe(value, digits) {
    if (value === null || value === undefined || isNaN(Number(value))) return null;
    return Number(value).toFixed(digits);
  }

  function buildStars(rating) {
    if (!rating) return "";
    const full = Math.round(rating);
    let s = "";
    for (let i = 0; i < 5; i++) {
      s += i < full ? "★" : "☆";
    }
    return s;
  }

  // ===============================
  // Backend integration
  // ===============================
  async function searchLocal({ query = "", category = "", lat, lon } = {}) {
    const payload = {
      query,
      category,
      lat,
      lon
    };

    try {
      const resp = await fetch(API_URL, {
        method: "POST",
        headers: {
          "Content-Type": "application/json"
        },
        body: JSON.stringify(payload)
      });

      if (!resp.ok) {
        console.error("CHATR Local API error:", resp.status, resp.statusText);
        return [];
      }

      const data = await resp.json();
      const rawList = Array.isArray(data)
        ? data
        : (data.results || data.places || data.items || []);

      return rawList.map((item, idx) => normalizePlace(item, idx));
    } catch (err) {
      console.error("CHATR Local API fetch failed:", err);
      return [];
    }
  }

  // Normalize whatever backend sends into a unified "place" shape
  function normalizePlace(raw, index) {
    const loc = raw.location || raw.geo || {};
    const lat = parseFloat(
      raw.lat ??
      raw.latitude ??
      loc.lat ??
      loc.latitude
    );
    const lon = parseFloat(
      raw.lon ??
      raw.lng ??
      raw.longitude ??
      loc.lon ??
      loc.lng ??
      loc.longitude
    );

    const rating = parseFloat(raw.rating ?? raw.stars ?? raw.score);
    const distance =
      raw.distance_km ??
      raw.distance ??
      raw.dist_km ??
      null;

    const id =
      raw.id ??
      raw._id ??
      raw.place_id ??
      raw.slug ??
      raw.uuid ??
      `place-${index}`;

    const tags =
      raw.tags ??
      raw.highlights ??
      raw.features ??
      [];

    const packages =
      raw.packages ??
      raw.deals ??
      raw.offers ??
      [];

    return {
      id,
      name: raw.name ?? raw.title ?? raw.business_name ?? "Unnamed place",
      category:
        raw.category ??
        raw.type ??
        raw.vertical ??
        "Other",
      rating: isNaN(rating) ? null : rating,
      reviewsCount:
        raw.reviews_count ??
        raw.reviewCount ??
        raw.total_reviews ??
        null,
      address:
        raw.address ??
        raw.full_address ??
        raw.addr ??
        [raw.area, raw.city].filter(Boolean).join(", "),
      distanceKm: distance ? Number(distance) : null,
      lat: isNaN(lat) ? null : lat,
      lon: isNaN(lon) ? null : lon,
      phone:
        raw.phone ??
        raw.phone_number ??
        raw.mobile ??
        raw.whatsapp ??
        null,
      whatsapp: raw.whatsapp ?? null,
      website: raw.website ?? raw.url ?? null,
      isPartner: Boolean(raw.is_partner ?? raw.partner ?? raw.chatr_partner),
      priceLevel: raw.price_level ?? raw.pricing ?? null,
      about: raw.about ?? raw.description ?? null,
      tags: Array.isArray(tags)
        ? tags
        : (typeof tags === "string" ? tags.split(",").map(t => t.trim()).filter(Boolean) : []),
      packages: Array.isArray(packages)
        ? packages
        : [],
      openingHours: raw.opening_hours ?? raw.hours ?? null
    };
  }

  // ===============================
  // Location handling
  // ===============================
  function detectLocation() {
    return new Promise((resolve) => {
      if (!navigator.geolocation) {
        state.lat = defaultLocation.lat;
        state.lon = defaultLocation.lon;
        state.locationLabel = defaultLocation.label;
        updateLocationPill(defaultLocation.label);
        return resolve();
      }

      navigator.geolocation.getCurrentPosition(
        (pos) => {
          state.lat = pos.coords.latitude;
          state.lon = pos.coords.longitude;
          state.locationLabel = "Near you";
          updateLocationPill("Near you (" +
            toFixedMaybe(state.lat, 3) + ", " +
            toFixedMaybe(state.lon, 3) + ")");
          resolve();
        },
        (err) => {
          console.warn("Geo failed:", err);
          state.lat = defaultLocation.lat;
          state.lon = defaultLocation.lon;
          state.locationLabel = defaultLocation.label;
          updateLocationPill(defaultLocation.label);
          resolve();
        },
        { enableHighAccuracy: true, timeout: 6000 }
      );
    });
  }

  // ===============================
  // Map drawing (canvas)
  // ===============================
  function drawMap(canvasId, userLat, userLon, places, focusPlaceId) {
    const canvas = $(canvasId);
    if (!canvas) return;

    const rect = canvas.getBoundingClientRect();
    const width = rect.width || canvas.clientWidth || 400;
    const height = rect.height || 260;

    canvas.width = width * window.devicePixelRatio;
    canvas.height = height * window.devicePixelRatio;
    const ctx = canvas.getContext("2d");
    ctx.scale(window.devicePixelRatio, window.devicePixelRatio);

    // Background
    const grd = ctx.createLinearGradient(0, 0, width, height);
    grd.addColorStop(0, "#050516");
    grd.addColorStop(1, "#12122b");
    ctx.fillStyle = grd;
    ctx.fillRect(0, 0, width, height);

    // If no coords, bail
    const all = [];
    if (userLat != null && userLon != null) {
      all.push({ lat: userLat, lon: userLon });
    }
    for (const p of places || []) {
      if (p.lat != null && p.lon != null) {
        all.push({ lat: p.lat, lon: p.lon });
      }
    }
    if (!all.length) return;

    const lats = all.map(p => p.lat);
    const lons = all.map(p => p.lon);
    const minLat = Math.min(...lats);
    const maxLat = Math.max(...lats);
    const minLon = Math.min(...lons);
    const maxLon = Math.max(...lons);

    const pad = 20;
    const spanLat = maxLat - minLat || 0.01;
    const spanLon = maxLon - minLon || 0.01;

    function project(lat, lon) {
      const x = pad + ( (lon - minLon) / spanLon ) * (width - pad * 2);
      const y = pad + ( 1 - (lat - minLat) / spanLat ) * (height - pad * 2);
      return { x, y };
    }

    // Draw grid
    ctx.strokeStyle = "rgba(148,163,184,0.25)";
    ctx.lineWidth = 1;
    const steps = 4;
    for (let i = 1; i < steps; i++) {
      const x = (width / steps) * i;
      const y = (height / steps) * i;
      ctx.beginPath();
      ctx.moveTo(x, 0);
      ctx.lineTo(x, height);
      ctx.stroke();
      ctx.beginPath();
      ctx.moveTo(0, y);
      ctx.lineTo(width, y);
      ctx.stroke();
    }

    // Places
    for (const p of places || []) {
      if (p.lat == null || p.lon == null) continue;
      const { x, y } = project(p.lat, p.lon);
      const isFocus = focusPlaceId && p.id === focusPlaceId;
      ctx.beginPath();
      ctx.arc(x, y, isFocus ? 6 : 4, 0, Math.PI * 2);
      ctx.fillStyle = isFocus ? "#b58dff" : "#8f5bff";
      ctx.fill();

      // tiny vertical glow
      const grad = ctx.createLinearGradient(x, y - 10, x, y + 10);
      grad.addColorStop(0, "rgba(143,91,255,0.0)");
      grad.addColorStop(0.5, "rgba(143,91,255,0.55)");
      grad.addColorStop(1, "rgba(143,91,255,0.0)");
      ctx.strokeStyle = grad;
      ctx.beginPath();
      ctx.moveTo(x, y - 10);
      ctx.lineTo(x, y + 10);
      ctx.stroke();
    }

    // User marker
    if (userLat != null && userLon != null) {
      const { x, y } = project(userLat, userLon);
      ctx.beginPath();
      ctx.arc(x, y, 5, 0, Math.PI * 2);
      ctx.fillStyle = "#00e0ff";
      ctx.fill();
      ctx.strokeStyle = "rgba(0,224,255,0.65)";
      ctx.lineWidth = 2;
      ctx.beginPath();
      ctx.arc(x, y, 9, 0, Math.PI * 2);
      ctx.stroke();
    }
  }

  // ===============================
  // Cards rendering
  // ===============================
  function renderCards(containerId, places) {
    const grid = $(containerId);
    const countEl = $("results-count");
    const titleEl = $("results-title");

    if (!grid) return;
    grid.innerHTML = "";

    if (countEl) {
      countEl.textContent = places.length
        ? `${places.length} result${places.length === 1 ? "" : "s"}`
        : "No results";
    }

    if (titleEl && state.page === "home" && !state.query && !state.category) {
      titleEl.textContent = "Popular near you";
    } else if (titleEl) {
      const cat = state.category ? ` · ${capitalize(state.category)}` : "";
      const q = state.query ? `“${state.query}”` : "Results";
      titleEl.textContent = `${q}${cat}`;
    }

    // Store in localStorage so place.html can load full profile
    try {
      localStorage.setItem("chatr:lastResults", JSON.stringify(places));
    } catch (e) {
      console.warn("Failed to store results:", e);
    }

    for (const place of places) {
      const card = document.createElement("article");
      card.className = "chatr-card";
      card.dataset.placeId = place.id;

      const tags = (place.tags || []).slice(0, 3);
      const packageLabel = (place.packages || [])[0]
        ? (place.packages[0].title || place.packages[0].name || "Popular package")
        : null;

      const distText = place.distanceKm != null
        ? `${toFixedMaybe(place.distanceKm, 1)} km`
        : "";

      const ratingText = place.rating
        ? `${place.rating.toFixed(1)}`
        : "New";

      const reviewsText = place.reviewsCount
        ? `${place.reviewsCount}+ ratings`
        : "";

      const priceText = place.priceLevel
        ? String(place.priceLevel)
        : "";

      const metaParts = [];
      if (reviewsText) metaParts.push(reviewsText);
      if (priceText) metaParts.push(priceText);

      card.innerHTML = `
        <div class="card-main-row">
          <div class="card-left">
            <div class="card-title-row">
              <div class="card-title" title="${escapeHtml(place.name)}">
                ${escapeHtml(place.name)}
              </div>
              <span class="chip chip-soft">${escapeHtml(place.category || "Other")}</span>
              ${place.isPartner ? `<span class="chip chip-partner">CHATR Partner</span>` : ""}
            </div>
            <div class="card-rating-row">
              <span class="card-stars">${buildStars(place.rating)}</span>
              <span>${ratingText}</span>
              ${reviewsText ? `<span>· ${escapeHtml(reviewsText)}</span>` : ""}
            </div>
            <div class="card-meta-row">
              ${place.address ? `<span>${escapeHtml(place.address)}</span>` : ""}
              ${priceText ? `<span>${escapeHtml(priceText)}</span>` : ""}
            </div>
            <div class="card-tags-row">
              ${tags.map(tag => `<span class="card-tag">${escapeHtml(tag)}</span>`).join("")}
            </div>
            ${packageLabel ? `
              <div class="card-packages-row">
                ⭐ ${escapeHtml(packageLabel)}
              </div>` : ""}
          </div>
          <div class="card-right">
            ${distText ? `<div class="card-distance-pill">${distText}</div>` : `<div style="height:18px"></div>`}
            <button class="card-cta">View details →</button>
          </div>
        </div>
      `;

      card.addEventListener("click", () => openPlaceProfile(place));
      grid.appendChild(card);
    }
  }

  function escapeHtml(str) {
    if (!str && str !== 0) return "";
    return String(str)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;");
  }

  function openPlaceProfile(place) {
    try {
      localStorage.setItem("chatr:selectedPlace", JSON.stringify(place));
    } catch (e) {
      console.warn("Failed to store selected place:", e);
    }

    const url = new URL("place.html", window.location.href);
    url.searchParams.set("id", place.id);
    if (state.lat != null) {
      url.searchParams.set("userLat", state.lat);
      url.searchParams.set("userLon", state.lon);
    }
    window.location.href = url.toString();
  }

  function capitalize(str) {
    if (!str) return "";
    return str.charAt(0).toUpperCase() + str.slice(1);
  }

  // ===============================
  // Page initializers
  // ===============================
  async function initHome() {
    state.page = "home";
    await detectLocation();
    attachCategoryStrip("home-category-strip");
    attachSearchBar("main-search-input", "main-search-btn");

    state.query = "";
    state.category = "";

    const places = await searchLocal({
      query: "",
      category: "",
      lat: state.lat,
      lon: state.lon
    });
    state.results = places;
    renderCards("results-grid", places);
    drawMap("map-canvas", state.lat, state.lon, places);
  }

  async function initCategory() {
    state.page = "category";
    const params = getQueryParams();
    state.category = params.category || "";
    state.query = params.q || "";

    await detectLocation();
    attachCategoryStrip("category-strip");
    attachSearchBar("category-search-input", "category-search-btn");

    const catTitle = $("map-category-title");
    if (catTitle && state.category) {
      catTitle.textContent = `${capitalize(state.category)} near you`;
    }

    const input = $("category-search-input");
    if (input && state.query) {
      input.value = state.query;
    }

    const places = await searchLocal({
      query: state.query,
      category: state.category,
      lat: state.lat,
      lon: state.lon
    });
    state.results = places;
    renderCards("results-grid", places);
    drawMap("map-canvas", state.lat, state.lon, places);
  }

  function initPlace() {
    state.page = "place";
    const params = getQueryParams();
    const placeId = params.id;
    const userLat = parseFloat(params.userLat);
    const userLon = parseFloat(params.userLon);
    if (!isNaN(userLat) && !isNaN(userLon)) {
      state.lat = userLat;
      state.lon = userLon;
      updateLocationPill("From your search");
    } else {
      detectLocation();
    }

    let place = null;
    try {
      const stored = localStorage.getItem("chatr:selectedPlace");
      if (stored) {
        const p = JSON.parse(stored);
        if (p && (!placeId || placeId === p.id)) {
          place = p;
        }
      }
      if (!place) {
        const last = JSON.parse(localStorage.getItem("chatr:lastResults") || "[]");
        place = last.find((p) => p.id === placeId) || null;
      }
    } catch (e) {
      console.warn("Failed to parse stored place:", e);
    }

    if (!place) {
      $("place-name").textContent = "Listing not found";
      return;
    }

    renderPlaceProfile(place);
  }

  function attachSearchBar(inputId, buttonId) {
    const input = $(inputId);
    const btn = $(buttonId);
    if (!input || !btn) return;

    function triggerSearch() {
      const q = input.value.trim();
      state.query = q;

      if (state.page === "home") {
        // Redirect to category page with query only
        const url = new URL("category.html", window.location.href);
        if (q) url.searchParams.set("q", q);
        if (state.lat != null) {
          url.searchParams.set("lat", state.lat);
          url.searchParams.set("lon", state.lon);
        }
        window.location.href = url.toString();
      } else if (state.page === "category") {
        // Reload same page with updated query + category
        const url = new URL("category.html", window.location.href);
        if (state.category) url.searchParams.set("category", state.category);
        if (q) url.searchParams.set("q", q);
        if (state.lat != null) {
          url.searchParams.set("lat", state.lat);
          url.searchParams.set("lon", state.lon);
        }
        window.location.href = url.toString();
      }
    }

    btn.addEventListener("click", triggerSearch);
    input.addEventListener("keydown", (e) => {
      if (e.key === "Enter") triggerSearch();
    });
  }

  function attachCategoryStrip(stripId) {
    const strip = $(stripId);
    if (!strip) return;
    const buttons = strip.querySelectorAll("button[data-category]");
    buttons.forEach((btn) => {
      const cat = btn.getAttribute("data-category");
      if (cat === (state.category || "").toLowerCase()) {
        btn.classList.add("active");
      }
      btn.addEventListener("click", () => {
        state.category = cat;
        const url = new URL("category.html", window.location.href);
        url.searchParams.set("category", cat);
        if (state.query) url.searchParams.set("q", state.query);
        if (state.lat != null) {
          url.searchParams.set("lat", state.lat);
          url.searchParams.set("lon", state.lon);
        }
        window.location.href = url.toString();
      });
    });
  }

  // ===============================
  // Place profile rendering
  // ===============================
  function renderPlaceProfile(place) {
    $("place-name").textContent = place.name || "Unnamed place";
    const catChip = $("place-category-chip");
    if (catChip) {
      catChip.textContent = place.category || "Other";
    }

    if (place.isPartner) {
      const partnerChip = $("partner-chip");
      if (partnerChip) partnerChip.style.display = "inline-flex";
    }

    const ratingRow = $("place-rating-row");
    if (ratingRow) {
      ratingRow.innerHTML = "";
      const rating = place.rating;
      const ratingSpan = document.createElement("span");
      ratingSpan.textContent = rating ? rating.toFixed(1) : "New";
      const starsSpan = document.createElement("span");
      starsSpan.textContent = buildStars(rating);
      const reviewsSpan = document.createElement("span");
      reviewsSpan.textContent = place.reviewsCount
        ? `${place.reviewsCount}+ ratings`
        : "No ratings yet";

      ratingRow.appendChild(ratingSpan);
      ratingRow.appendChild(starsSpan);
      ratingRow.appendChild(reviewsSpan);
    }

    if (place.address) {
      $("place-address").textContent = place.address;
    }
    if (place.distanceKm != null) {
      $("place-distance").textContent =
        toFixedMaybe(place.distanceKm, 2) + " km from you";
    }

    // Actions
    const callBtn = $("call-btn");
    if (callBtn) {
      if (place.phone) {
        callBtn.disabled = false;
        callBtn.addEventListener("click", (e) => {
          e.stopPropagation();
          window.location.href = "tel:" + place.phone;
        });
      } else {
        callBtn.textContent = "Phone not available";
      }
    }

    const waBtn = $("whatsapp-btn");
    if (waBtn) {
      const waNum = place.whatsapp || place.phone;
      if (waNum) {
        waBtn.disabled = false;
        waBtn.addEventListener("click", (e) => {
          e.stopPropagation();
          const numClean = waNum.replace(/\D/g, "");
          const url = "https://wa.me/" + numClean;
          window.open(url, "_blank");
        });
      } else {
        waBtn.textContent = "WhatsApp not available";
      }
    }

    const navBtn = $("navigate-btn");
    if (navBtn) {
      if (place.lat != null && place.lon != null) {
        navBtn.disabled = false;
        navBtn.addEventListener("click", (e) => {
          e.stopPropagation();
          const url =
            "https://www.google.com/maps/search/?api=1&query=" +
            encodeURIComponent(place.lat + "," + place.lon);
          window.open(url, "_blank");
        });
      } else {
        navBtn.textContent = "Location not available";
      }
    }

    if (place.about) {
      $("place-about").textContent = place.about;
    }

    // Packages
    if (place.packages && place.packages.length) {
      const section = $("packages-section");
      const list = $("packages-list");
      if (section && list) {
        section.style.display = "block";
        list.innerHTML = "";
        place.packages.forEach((pkg) => {
          const pill = document.createElement("div");
          pill.className = "package-pill";
          const title = pkg.title || pkg.name || "Package";
          const price =
            pkg.price ||
            pkg.amount ||
            pkg.mrp ||
            null;
          const duration = pkg.duration || pkg.time || null;

          pill.innerHTML = `
            <div class="package-pill-title">${escapeHtml(title)}</div>
            <div class="package-pill-meta">
              ${price ? `<div>${escapeHtml(String(price))}</div>` : ""}
              ${duration ? `<div>${escapeHtml(String(duration))}</div>` : ""}
            </div>
          `;
          list.appendChild(pill);
        });
      }
    }

    // Tags
    if (place.tags && place.tags.length) {
      const tagsSection = $("tags-section");
      const tagsContainer = $("tags-container");
      if (tagsSection && tagsContainer) {
        tagsSection.style.display = "block";
        tagsContainer.innerHTML = "";
        place.tags.slice(0, 12).forEach((tag) => {
          const pill = document.createElement("span");
          pill.className = "tag-pill";
          pill.textContent = tag;
          tagsContainer.appendChild(pill);
        });
      }
    }

    // Hours
    if (place.openingHours) {
      const hoursSection = $("hours-section");
      const hoursList = $("hours-list");
      if (hoursSection && hoursList) {
        hoursSection.style.display = "block";
        hoursList.innerHTML = "";

        if (Array.isArray(place.openingHours)) {
          place.openingHours.forEach((line) => {
            const div = document.createElement("div");
            div.textContent = line;
            hoursList.appendChild(div);
          });
        } else if (typeof place.openingHours === "object") {
          Object.keys(place.openingHours).forEach((day) => {
            const div = document.createElement("div");
            div.textContent = `${day}: ${place.openingHours[day]}`;
            hoursList.appendChild(div);
          });
        } else if (typeof place.openingHours === "string") {
          const div = document.createElement("div");
          div.textContent = place.openingHours;
          hoursList.appendChild(div);
        }
      }
    }

    // Mini map
    const userLat = state.lat;
    const userLon = state.lon;
    drawMap("place-map-canvas", userLat, userLon, [place], place.id);
  }

  // ===============================
  // Public API
  // ===============================
  async function initPage(page) {
    if (page === "home") {
      await initHome();
    } else if (page === "category") {
      await initCategory();
    } else if (page === "place") {
      initPlace();
    }
  }

  return {
    initPage
  };
})();
'@ | Set-Content -Path "$root\script.js" -Encoding UTF8

Write-Host "✅ CHATR Local Ultra UI files have been written to $root" -ForegroundColor Green
Write-Host "Now load index.html through your SearXNG / Chatr UI and test local search." -ForegroundColor Green
