# Providers/Person.ps1

$script:_FirstNameMale = @(
    'James','John','Robert','Michael','William','David','Richard','Joseph','Thomas','Charles',
    'Christopher','Daniel','Matthew','Anthony','Mark','Donald','Steven','Paul','Andrew','Joshua',
    'Kenneth','Kevin','Brian','George','Timothy','Ronald','Edward','Jason','Jeffrey','Ryan',
    'Jacob','Gary','Nicholas','Eric','Jonathan','Stephen','Larry','Justin','Scott','Brandon',
    'Frank','Benjamin','Gregory','Samuel','Raymond','Patrick','Alexander','Jack','Dennis','Jerry'
)
$script:_FirstNameFemale = @(
    'Mary','Patricia','Jennifer','Linda','Barbara','Elizabeth','Susan','Jessica','Sarah','Karen',
    'Lisa','Nancy','Betty','Margaret','Sandra','Ashley','Dorothy','Kimberly','Emily','Donna',
    'Michelle','Carol','Amanda','Melissa','Deborah','Stephanie','Rebecca','Sharon','Laura','Cynthia',
    'Kathleen','Amy','Angela','Shirley','Anna','Brenda','Pamela','Emma','Nicole','Helen',
    'Samantha','Katherine','Christine','Debra','Rachel','Carolyn','Janet','Catherine','Maria','Heather'
)
$script:_LastName = @(
    'Smith','Johnson','Williams','Brown','Jones','Garcia','Miller','Davis','Rodriguez','Martinez',
    'Hernandez','Lopez','Gonzalez','Wilson','Anderson','Thomas','Taylor','Moore','Jackson','Martin',
    'Lee','Perez','Thompson','White','Harris','Sanchez','Clark','Ramirez','Lewis','Robinson',
    'Walker','Young','Allen','King','Wright','Scott','Torres','Nguyen','Hill','Flores',
    'Green','Adams','Nelson','Baker','Hall','Rivera','Campbell','Mitchell','Carter','Roberts',
    'Cechtelar','Prosacco','Vandervort','Lebsack','Koelpin','Kiehn','Zulauf','Stroman'
)
$script:_TitleMale   = @('Mr.','Dr.','Prof.','Rev.')
$script:_TitleFemale = @('Ms.','Mrs.','Dr.','Prof.','Miss')
$script:_NameSuffix  = @('Jr.','Sr.','I','II','III','IV','V','DVM','DDS','PhD','MD')

function Get-FakeTitleMale   { [CmdletBinding()] param(); return Get-FakeRandomElement $script:_TitleMale }
function Get-FakeTitleFemale { [CmdletBinding()] param(); return Get-FakeRandomElement $script:_TitleFemale }
function Get-FakeTitle {
<#.SYNOPSIS  Title prefix, optionally by gender (male/female).#>
    [CmdletBinding()]
    param([Parameter()] [string] $Gender = '')
    if     ($Gender -eq 'male')   { return Get-FakeTitleMale }
    elseif ($Gender -eq 'female') { return Get-FakeTitleFemale }
    else {
        if ((_Rng).Next(0,2) -eq 0) { return Get-FakeTitleMale } else { return Get-FakeTitleFemale }
    }
}

function Get-FakeFirstNameMale   { [CmdletBinding()] param(); return Get-FakeRandomElement $script:_FirstNameMale }
function Get-FakeFirstNameFemale { [CmdletBinding()] param(); return Get-FakeRandomElement $script:_FirstNameFemale }
function Get-FakeFirstName {
<#.SYNOPSIS  First name, optionally by gender.#>
    [CmdletBinding()]
    param([Parameter()] [string] $Gender = '')
    if     ($Gender -eq 'male')   { return Get-FakeFirstNameMale }
    elseif ($Gender -eq 'female') { return Get-FakeFirstNameFemale }
    else {
        if ((_Rng).Next(0,2) -eq 0) { return Get-FakeFirstNameMale } else { return Get-FakeFirstNameFemale }
    }
}

function Get-FakeLastName {
<#.SYNOPSIS  Random last name.#>
    [CmdletBinding()] param()
    return Get-FakeRandomElement $script:_LastName
}

function Get-FakeNameSuffix {
<#.SYNOPSIS  Name suffix e.g. Jr. #>
    [CmdletBinding()] param()
    return Get-FakeRandomElement $script:_NameSuffix
}

function Get-FakeName {
<#.SYNOPSIS  Full name, optionally by gender.#>
    [CmdletBinding()]
    param([Parameter()] [string] $Gender = '')
    $first = Get-FakeFirstName -Gender $Gender
    $last  = Get-FakeLastName
    $r = (_Rng).Next(0, 10)
    if     ($r -lt 1) { return "$(Get-FakeTitle -Gender $Gender) $first $last $(Get-FakeNameSuffix)" }
    elseif ($r -lt 3) { return "$(Get-FakeTitle -Gender $Gender) $first $last" }
    elseif ($r -lt 5) { return "$first $last $(Get-FakeNameSuffix)" }
    else              { return "$first $last" }
}
