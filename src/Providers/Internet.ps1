# Providers/Internet.ps1

$script:_FreeDomains   = @('gmail.com','yahoo.com','hotmail.com','outlook.com','aol.com','icloud.com')
$script:_SafeDomains   = @('example.com','example.org','example.net')
$script:_Tlds          = @('com','net','org','info','biz','io','co','dev','app','me','us','uk')
$script:_DomainWords   = @('alpha','beta','delta','gamma','sigma','omega','nova','apex','core',
    'prime','peak','swift','spark','bright','cloud','wave','node','link','hub','net',
    'data','code','tech','soft','sys','bit','byte','web','site','host','domain')

function Get-FakeTld         { [CmdletBinding()] param(); return Get-FakeRandomElement $script:_Tlds }
function Get-FakeDomainWord  { [CmdletBinding()] param(); return Get-FakeRandomElement $script:_DomainWords }
function Get-FakeDomainName  {
<#.SYNOPSIS  Full domain name.#>
    [CmdletBinding()] param()
    return "$(Get-FakeDomainWord).$(Get-FakeTld)"
}
function Get-FakeFreeEmailDomain   { return Get-FakeRandomElement $script:_FreeDomains }
function Get-FakeSafeEmailDomain   { return Get-FakeRandomElement $script:_SafeDomains }

function Get-FakeUserName {
<#.SYNOPSIS  Username.#>
    [CmdletBinding()] param()
    $first = (Get-FakeFirstName).ToLower()
    $last  = (Get-FakeLastName).ToLower()
    $r = (_Rng).Next(0,5)
    switch ($r) {
        0 { return "${first}.${last}" }
        1 { return "${first}${last}$((_Rng).Next(10,99))" }
        2 { return "$first$((_Rng).Next(10,99))" }
        3 { return "${last}$((_Rng).Next(1,100))" }
        4 { return $first.Substring(0,1) + $last }
    }
}

function Get-FakeEmail {
<#.SYNOPSIS  Email address.#>
    [CmdletBinding()] param()
    return "$(Get-FakeUserName)@$(Get-FakeDomainName)"
}

function Get-FakeSafeEmail {
<#.SYNOPSIS  Email at a safe example domain.#>
    [CmdletBinding()] param()
    return "$(Get-FakeUserName)@$(Get-FakeSafeEmailDomain)"
}

function Get-FakeFreeEmail {
<#.SYNOPSIS  Email at a free provider.#>
    [CmdletBinding()] param()
    return "$(Get-FakeUserName)@$(Get-FakeFreeEmailDomain)"
}

function Get-FakeCompanyEmail {
<#.SYNOPSIS  Company email address.#>
    [CmdletBinding()] param()
    $first = (Get-FakeFirstName).ToLower()
    $last  = (Get-FakeLastName).ToLower()
    return "${first}.${last}@$(Get-FakeDomainName)"
}

function Get-FakePassword {
<#.SYNOPSIS  Random password string (8-20 characters).#>
    [CmdletBinding()]
    param([int]$MinLength=8,[int]$MaxLength=20)
    $chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()-_=+[]{}|;:,.<>?'.ToCharArray()
    $len = (_Rng).Next($MinLength,$MaxLength+1)
    return -join (1..$len | ForEach-Object { $chars[(_Rng).Next(0,$chars.Count)] })
}

function Get-FakeUrl {
<#.SYNOPSIS  Full URL.#>
    [CmdletBinding()] param()
    $scheme = if ((_Rng).Next(0,2) -eq 0) { 'https' } else { 'http' }
    $slug = Get-FakeSlug
    return "${scheme}://www.$(Get-FakeDomainName)/${slug}.html"
}

function Get-FakeSlug {
<#.SYNOPSIS  URL-friendly slug (3-6 dash-separated words).#>
    [CmdletBinding()] param()
    $count = (_Rng).Next(3,7)
    $words = 1..$count | ForEach-Object { Get-FakeWord }
    return $words -join '-'
}

function Get-FakeIPv4 {
<#.SYNOPSIS  Public IPv4 address.#>
    [CmdletBinding()] param()
    return "$((_Rng).Next(1,224)).$((_Rng).Next(0,256)).$((_Rng).Next(0,256)).$((_Rng).Next(1,255))"
}

function Get-FakeLocalIPv4 {
<#.SYNOPSIS  Private IPv4 address (10.x.x.x).#>
    [CmdletBinding()] param()
    return "10.$((_Rng).Next(0,256)).$((_Rng).Next(0,256)).$((_Rng).Next(1,255))"
}

function Get-FakeIPv6 {
<#.SYNOPSIS  IPv6 address.#>
    [CmdletBinding()] param()
    $groups = 1..8 | ForEach-Object { '{0:x4}' -f (_Rng).Next(0,65536) }
    return $groups -join ':'
}

function Get-FakeMacAddress {
<#.SYNOPSIS  MAC address.#>
    [CmdletBinding()] param()
    $octets = 1..6 | ForEach-Object { '{0:X2}' -f (_Rng).Next(0,256) }
    return $octets -join ':'
}
