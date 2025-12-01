function Find-CityInText {
    param([string]$text, [int]$minPrefix=3)
    $textLower = $text.ToLowerInvariant()
    foreach ($city in (Get-Content '.\indian_cities.json' -Raw | ConvertFrom-Json).places) {
        if ($textLower.Contains($city.ToLowerInvariant())) { return $city }
        # prefix fallback
        if ($city.Length -ge $minPrefix) {
            $pref = $city.Substring(0,$minPrefix).ToLowerInvariant()
            if ($textLower.Contains($pref)) { return $city }
        }
    }
    return $null
}
