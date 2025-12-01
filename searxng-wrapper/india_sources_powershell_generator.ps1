# ====================================================================
# INDIA SOURCES POWERFUL GENERATOR (v1.0)
# Creates 15+ category JSON files + merged india_registry.json
# ====================================================================

Write-Host "🚀 India Sources Generator Started..." -ForegroundColor Cyan

$base = $PWD
$sourcesDir = Join-Path $base "sources"

if (-not (Test-Path $sourcesDir)) {
    New-Item -ItemType Directory -Path $sourcesDir | Out-Null
    Write-Host "📁 Created: sources/" -ForegroundColor Yellow
}

# -------------------------
# CATEGORY DEFINITIONS
# -------------------------
$categories = @{
    "local_services" = @(
        "JustDial","IndiaMART","UrbanCompany","Sulekha",
        "NearMeTrade","Grotal","YellowPages.in","AskLaila"
    )
    "ecommerce" = @(
        "Amazon India","Flipkart","Meesho","Snapdeal","TataCliq",
        "Nykaa","AJIO","Myntra","ShopClues","BigBasket","Blinkit"
    )
    "food_delivery" = @(
        "Zomato","Swiggy","Dominos","PizzaHut","McDonalds","BurgerKing",
        "EatSure","FreshMenu"
    )
    "news" = @(
        "Times of India","Hindustan Times","Indian Express","NDTV",
        "ABP News","Zee News","AajTak","Economic Times","Mint"
    )
    "jobs" = @(
        "Naukri","LinkedIn Jobs","Indeed India","Monster India",
        "FreshersWorld","Hirist","Foundit","Glassdoor India"
    )
    "gov_portals" = @(
        "India.gov.in","UIDAI","DigiLocker","UMANG",
        "Transport Parivahan","Income Tax Portal","NPCI","eSewa"
    )
    "real_estate" = @(
        "NoBroker","MagicBricks","99acres","Housing.com","Makaan",
        "SquareYards","CommonFloor"
    )
    "finance" = @(
        "Paytm","PhonePe","Google Pay","BHIM UPI",
        "SBI","HDFC Bank","ICICI Bank","Axis Bank","Kotak Bank"
    )
    "travel" = @(
        "IRCTC","MakeMyTrip","Goibibo","RedBus","AbhiBus",
        "Yatra","ClearTrip","Ola","Uber","Rapido"
    )
    "healthcare" = @(
        "Practo","1mg","NetMeds","Apollo 24x7",
        "PharmEasy","MedPlus","Cure.fit"
    )
}

# -------------------------
# WRITE PER-CATEGORY FILES
# -------------------------
foreach ($cat in $categories.Keys) {
    $path = Join-Path $sourcesDir "$cat.json"
    $payload = [pscustomobject]@{
        category = $cat
        sources  = $categories[$cat]
        count    = $categories[$cat].Count
    }
    $payload | ConvertTo-Json -Depth 5 | Out-File $path -Encoding utf8
    Write-Host "✔ Saved $cat.json" -ForegroundColor Green
}

# -------------------------
# MERGE ALL INTO REGISTRY
# -------------------------
Write-Host "`n🔄 Merging all sources..." -ForegroundColor Cyan

$all = @()

foreach ($file in Get-ChildItem $sourcesDir -Filter *.json) {
    $json = Get-Content $file.FullName -Raw | ConvertFrom-Json
    $all += $json.sources
}

# remove duplicates (case-insensitive)
$unique = $all | Sort-Object { $_.ToLower() } -Unique

# create final registry
$registry = [pscustomobject]@{
    meta = [pscustomobject]@{
        created_at = (Get-Date).ToString("u")
        categories = $categories.Keys.Count
        total_sources = $unique.Count
    }
    sources = $unique
}

$target = Join-Path $base "india_registry.json"
$registry | ConvertTo-Json -Depth 5 | Out-File $target -Encoding utf8

Write-Host "`n🎉 india_registry.json READY!" -ForegroundColor Green
Write-Host "Total sources: $($unique.Count)" -ForegroundColor Green

Write-Host "`nDone." -ForegroundColor Cyan
