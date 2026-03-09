# Providers/Address.ps1

$script:_CityPrefix  = @('North','East','West','South','New','Lake','Port','Fort','Mount','Saint')
$script:_CitySuffix  = @('ville','berg','burgh','borough','bury','view','port','mouth','stad','furt','chester','ton','fort','haven','side','shire')
$script:_StreetSuffix= @('Alley','Avenue','Branch','Bridge','Brook','Brooks','Burg','Burgs','Bypass',
    'Camp','Canyon','Cape','Causeway','Center','Circle','Cliff','Club','Common','Corner',
    'Court','Cove','Creek','Crescent','Drive','Estate','Expressway','Extension','Fall',
    'Falls','Ferry','Field','Fields','Flat','Flats','Ford','Forge','Fork','Forks',
    'Fort','Freeway','Garden','Gardens','Gateway','Glen','Green','Grove','Harbor',
    'Haven','Heights','Highway','Hill','Hills','Hollow','Inlet','Island','Junction',
    'Key','Knoll','Lake','Lane','Light','Loaf','Lock','Lodge','Loop','Mall',
    'Manor','Meadow','Mill','Mission','Mount','Mountain','Neck','Orchard','Oval',
    'Park','Parkway','Pass','Path','Pike','Pine','Place','Plain','Plaza','Point',
    'Port','Prairie','Radial','Ramp','Ranch','Rapid','Rest','Ridge','River','Road',
    'Row','Run','Shoal','Shore','Skyway','Spring','Springs','Square','Station',
    'Stravenue','Stream','Street','Summit','Terrace','Throughway','Trace','Track',
    'Trail','Tunnel','Turnpike','Underpass','Union','Valley','Via','Viaduct','View',
    'Village','Vista','Walk','Wall','Way','Well','Wells')
$script:_State = @(
    'Alabama','Alaska','Arizona','Arkansas','California','Colorado','Connecticut',
    'Delaware','Florida','Georgia','Hawaii','Idaho','Illinois','Indiana','Iowa',
    'Kansas','Kentucky','Louisiana','Maine','Maryland','Massachusetts','Michigan',
    'Minnesota','Mississippi','Missouri','Montana','Nebraska','Nevada','New Hampshire',
    'New Jersey','New Mexico','New York','North Carolina','North Dakota','Ohio',
    'Oklahoma','Oregon','Pennsylvania','Rhode Island','South Carolina','South Dakota',
    'Tennessee','Texas','Utah','Vermont','Virginia','Washington','West Virginia',
    'Wisconsin','Wyoming'
)
$script:_StateAbbr = @(
    'AL','AK','AZ','AR','CA','CO','CT','DE','FL','GA','HI','ID','IL','IN','IA',
    'KS','KY','LA','ME','MD','MA','MI','MN','MS','MO','MT','NE','NV','NH','NJ',
    'NM','NY','NC','ND','OH','OK','OR','PA','RI','SC','SD','TN','TX','UT','VT',
    'VA','WA','WV','WI','WY'
)
$script:_Country = @(
    'Afghanistan','Albania','Algeria','Andorra','Angola','Argentina','Armenia','Australia',
    'Austria','Azerbaijan','Bahamas','Bangladesh','Belarus','Belgium','Belize','Benin',
    'Bolivia','Bosnia','Botswana','Brazil','Bulgaria','Burkina Faso','Cambodia','Cameroon',
    'Canada','Chad','Chile','China','Colombia','Congo','Costa Rica','Croatia','Cuba',
    'Cyprus','Czech Republic','Denmark','Ecuador','Egypt','Estonia','Ethiopia','Finland',
    'France','Germany','Ghana','Greece','Guatemala','Honduras','Hungary','Iceland','India',
    'Indonesia','Iran','Iraq','Ireland','Israel','Italy','Jamaica','Japan','Jordan',
    'Kenya','Latvia','Lebanon','Libya','Lithuania','Luxembourg','Madagascar','Malaysia',
    'Mali','Malta','Mexico','Moldova','Morocco','Mozambique','Nepal','Netherlands',
    'New Zealand','Nigeria','Norway','Pakistan','Panama','Paraguay','Peru','Philippines',
    'Poland','Portugal','Romania','Russia','Rwanda','Saudi Arabia','Senegal','Serbia',
    'Singapore','Slovakia','Slovenia','Somalia','South Africa','Spain','Sri Lanka','Sudan',
    'Sweden','Switzerland','Syria','Taiwan','Tanzania','Thailand','Tunisia','Turkey',
    'Uganda','Ukraine','United Kingdom','United States','Uruguay','Uzbekistan','Venezuela',
    'Vietnam','Yemen','Zimbabwe'
)
$script:_AddressFirstNames = @(
    'James','John','Robert','Michael','William','David','Richard','Joseph','Thomas','Charles',
    'Mary','Patricia','Jennifer','Linda','Barbara','Elizabeth','Susan','Jessica','Sarah','Karen',
    'Christopher','Daniel','Matthew','Anthony','Mark','Donald','Steven','Paul','Andrew','Joshua',
    'Lisa','Nancy','Betty','Margaret','Sandra','Ashley','Dorothy','Kimberly','Emily','Donna'
)

function Get-FakeCityPrefix  { [CmdletBinding()] param(); return Get-FakeRandomElement $script:_CityPrefix }
function Get-FakeCitySuffix  { [CmdletBinding()] param(); return Get-FakeRandomElement $script:_CitySuffix }
function Get-FakeCity {
<#.SYNOPSIS  Random city name.#>
    [CmdletBinding()] param()
    $r = (_Rng).Next(0,4)
    switch ($r) {
        0 { return (Get-FakeCityPrefix) + ' ' + (Get-FakeRandomElement $script:_AddressFirstNames) + (Get-FakeCitySuffix) }
        1 { return (Get-FakeCityPrefix) + ' ' + (Get-FakeLastName) }
        2 { return (Get-FakeRandomElement $script:_AddressFirstNames) + (Get-FakeCitySuffix) }
        3 { return (Get-FakeLastName) + (Get-FakeCitySuffix) }
    }
}

function Get-FakeState      { [CmdletBinding()] param(); return Get-FakeRandomElement $script:_State }
function Get-FakeStateAbbr  { [CmdletBinding()] param(); return Get-FakeRandomElement $script:_StateAbbr }
function Get-FakeCountry    { [CmdletBinding()] param(); return Get-FakeRandomElement $script:_Country }

function Get-FakeBuildingNumber {
<#.SYNOPSIS  Building number (1-9999).#>
    [CmdletBinding()] param()
    return ((_Rng).Next(1, 10000)).ToString()
}

function Get-FakeStreetSuffix { return Get-FakeRandomElement $script:_StreetSuffix }

function Get-FakeStreetName {
<#.SYNOPSIS  Street name.#>
    [CmdletBinding()] param()
    $name = if ((_Rng).Next(0,2) -eq 0) { Get-FakeLastName } else { Get-FakeFirstName }
    return "$name $(Get-FakeStreetSuffix)"
}

function Get-FakeSecondaryAddress {
<#.SYNOPSIS  Secondary address e.g. 'Suite 961'.#>
    [CmdletBinding()] param()
    $type = if ((_Rng).Next(0,2) -eq 0) { 'Suite' } else { 'Apt.' }
    return "$type $((_Rng).Next(1,1000))"
}

function Get-FakeStreetAddress {
<#.SYNOPSIS  Full street address line.#>
    [CmdletBinding()] param()
    $base = "$(Get-FakeBuildingNumber) $(Get-FakeStreetName)"
    if ((_Rng).Next(0,4) -eq 0) { return "$base $(Get-FakeSecondaryAddress)" }
    return $base
}

function Get-FakePostcode {
<#.SYNOPSIS  US-style postcode.#>
    [CmdletBinding()] param()
    $zip = ((_Rng).Next(10000,99999)).ToString()
    if ((_Rng).Next(0,4) -eq 0) { $zip += '-' + ((_Rng).Next(1000,9999)).ToString() }
    return $zip
}

function Get-FakeAddress {
<#.SYNOPSIS  Full postal address.#>
    [CmdletBinding()] param()
    return "$(Get-FakeStreetAddress), $(Get-FakeCity), $(Get-FakeStateAbbr) $(Get-FakePostcode)"
}

function Get-FakeLatitude {
<#.SYNOPSIS  Decimal latitude.#>
    [CmdletBinding()]
    param([double]$Min=-90,[double]$Max=90)
    return [Math]::Round($Min + ((_Rng).NextDouble() * ($Max-$Min)), 6)
}

function Get-FakeLongitude {
<#.SYNOPSIS  Decimal longitude.#>
    [CmdletBinding()]
    param([double]$Min=-180,[double]$Max=180)
    return [Math]::Round($Min + ((_Rng).NextDouble() * ($Max-$Min)), 6)
}
