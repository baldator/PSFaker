# Providers/DateTime.ps1

$script:_Timezones = @(
    'Africa/Abidjan','Africa/Accra','Africa/Lagos','Africa/Nairobi','America/Anchorage',
    'America/Chicago','America/Denver','America/Los_Angeles','America/New_York',
    'America/Sao_Paulo','America/Toronto','Antarctica/Vostok','Asia/Bangkok',
    'Asia/Dubai','Asia/Hong_Kong','Asia/Jakarta','Asia/Karachi','Asia/Kolkata',
    'Asia/Seoul','Asia/Shanghai','Asia/Singapore','Asia/Tokyo','Atlantic/Bermuda',
    'Australia/Melbourne','Australia/Sydney','Europe/Amsterdam','Europe/Athens',
    'Europe/Berlin','Europe/Brussels','Europe/Budapest','Europe/Copenhagen',
    'Europe/Dublin','Europe/Helsinki','Europe/Lisbon','Europe/London','Europe/Madrid',
    'Europe/Moscow','Europe/Oslo','Europe/Paris','Europe/Rome','Europe/Stockholm',
    'Europe/Vienna','Europe/Warsaw','Europe/Zurich','Pacific/Auckland',
    'Pacific/Honolulu','Pacific/Sydney','UTC'
)

$script:_MonthNames = @('January','February','March','April','May','June',
    'July','August','September','October','November','December')
$script:_DayNames   = @('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday')
$script:_Centuries  = @('I','II','III','IV','V','VI','VII','VIII','IX','X',
    'XI','XII','XIII','XIV','XV','XVI','XVII','XVIII','XIX','XX','XXI')

function _RandDate([datetime]$Min,[datetime]$Max) {
    $span = $Max - $Min
    $secs = [long]($span.TotalSeconds * ((_Rng).NextDouble()))
    return $Min.AddSeconds($secs)
}

function Get-FakeUnixTime {
<#.SYNOPSIS  Unix timestamp up to $Max (default now).#>
    [CmdletBinding()]
    param([Parameter()] [datetime] $Max = [datetime]::Now)
    $epoch = [datetime]::new(1970,1,1,0,0,0,[System.DateTimeKind]::Utc)
    $d = _RandDate $epoch $Max
    return [long]($d - $epoch).TotalSeconds
}

function Get-FakeDateTime {
<#.SYNOPSIS  DateTime object up to $Max.#>
    [CmdletBinding()]
    param([Parameter()] [datetime] $Max = [datetime]::Now)
    return _RandDate ([datetime]::new(1970,1,1)) $Max
}

function Get-FakeDateTimeAD {
<#.SYNOPSIS  DateTime from year 1 AD up to $Max.#>
    [CmdletBinding()]
    param([Parameter()] [datetime] $Max = [datetime]::Now)
    return _RandDate ([datetime]::new(1,1,1)) $Max
}

function Get-FakeISO8601 {
<#.SYNOPSIS  ISO 8601 string up to $Max.#>
    [CmdletBinding()]
    param([Parameter()] [datetime] $Max = [datetime]::Now)
    return (Get-FakeDateTime -Max $Max).ToString('yyyy-MM-ddTHH:mm:sszzz')
}

function Get-FakeDate {
<#.SYNOPSIS  Formatted date string.#>
    [CmdletBinding()]
    param(
        [Parameter()] [string]   $Format = 'yyyy-MM-dd',
        [Parameter()] [datetime] $Max    = [datetime]::Now
    )
    return (Get-FakeDateTime -Max $Max).ToString($Format)
}

function Get-FakeTime {
<#.SYNOPSIS  Formatted time string.#>
    [CmdletBinding()]
    param(
        [Parameter()] [string]   $Format = 'HH:mm:ss',
        [Parameter()] [datetime] $Max    = [datetime]::Now
    )
    return (Get-FakeDateTime -Max $Max).ToString($Format)
}

function Get-FakeDateTimeBetween {
<#.SYNOPSIS  DateTime between $StartDate and $EndDate.#>
    [CmdletBinding()]
    param(
        [Parameter()] [datetime] $StartDate = ([datetime]::Now.AddYears(-30)),
        [Parameter()] [datetime] $EndDate   = [datetime]::Now
    )
    return _RandDate $StartDate $EndDate
}

function Get-FakeDateTimeThisCentury {
<#.SYNOPSIS  DateTime this century (since 2000).#>
    [CmdletBinding()]
    param([Parameter()] [datetime] $Max = [datetime]::Now)
    return _RandDate ([datetime]::new(2000,1,1)) $Max
}

function Get-FakeDateTimeThisDecade {
<#.SYNOPSIS  DateTime this decade.#>
    [CmdletBinding()]
    param([Parameter()] [datetime] $Max = [datetime]::Now)
    $decade = [datetime]::new(([datetime]::Now.Year / 10 * 10),1,1)
    return _RandDate $decade $Max
}

function Get-FakeDateTimeThisYear {
<#.SYNOPSIS  DateTime this year.#>
    [CmdletBinding()]
    param([Parameter()] [datetime] $Max = [datetime]::Now)
    return _RandDate ([datetime]::new([datetime]::Now.Year,1,1)) $Max
}

function Get-FakeDateTimeThisMonth {
<#.SYNOPSIS  DateTime this month.#>
    [CmdletBinding()]
    param([Parameter()] [datetime] $Max = [datetime]::Now)
    $d = [datetime]::Now
    return _RandDate ([datetime]::new($d.Year,$d.Month,1)) $Max
}

function Get-FakeAmPm {
<#.SYNOPSIS  'am' or 'pm'.#>
    [CmdletBinding()]
    param([Parameter()] [datetime] $Max = [datetime]::Now)
    return (Get-FakeDateTime -Max $Max).ToString('tt').ToLower()
}

function Get-FakeDayOfMonth {
<#.SYNOPSIS  Day of month as zero-padded string.#>
    [CmdletBinding()]
    param([Parameter()] [datetime] $Max = [datetime]::Now)
    return (Get-FakeDateTime -Max $Max).ToString('dd')
}

function Get-FakeDayOfWeek {
<#.SYNOPSIS  Day of week name.#>
    [CmdletBinding()]
    param([Parameter()] [datetime] $Max = [datetime]::Now)
    return (Get-FakeDateTime -Max $Max).DayOfWeek.ToString()
}

function Get-FakeMonth {
<#.SYNOPSIS  Month number as zero-padded string.#>
    [CmdletBinding()]
    param([Parameter()] [datetime] $Max = [datetime]::Now)
    return (Get-FakeDateTime -Max $Max).ToString('MM')
}

function Get-FakeMonthName {
<#.SYNOPSIS  Month name.#>
    [CmdletBinding()]
    param([Parameter()] [datetime] $Max = [datetime]::Now)
    return (Get-FakeDateTime -Max $Max).ToString('MMMM')
}

function Get-FakeYear {
<#.SYNOPSIS  Year as 4-digit string.#>
    [CmdletBinding()]
    param([Parameter()] [datetime] $Max = [datetime]::Now)
    return (Get-FakeDateTime -Max $Max).ToString('yyyy')
}

function Get-FakeCentury {
<#.SYNOPSIS  Roman numeral century.#>
    [CmdletBinding()] param()
    return Get-FakeRandomElement $script:_Centuries
}

function Get-FakeTimezone {
<#.SYNOPSIS  Timezone string.#>
    [CmdletBinding()] param()
    return Get-FakeRandomElement $script:_Timezones
}
