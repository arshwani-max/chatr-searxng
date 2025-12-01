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
      s += i < full ? "â˜…" : "â˜†";
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
      const cat = state.category ? ` Â· ${capitalize(state.category)}` : "";
      const q = state.query ? `â€œ${state.query}â€` : "Results";
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
              ${reviewsText ? `<span>Â· ${escapeHtml(reviewsText)}</span>` : ""}
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
                â­ ${escapeHtml(packageLabel)}
              </div>` : ""}
          </div>
          <div class="card-right">
            ${distText ? `<div class="card-distance-pill">${distText}</div>` : `<div style="height:18px"></div>`}
            <button class="card-cta">View details â†’</button>
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
