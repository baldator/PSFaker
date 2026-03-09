# PSFaker.psm1 – root loader
$script:PSFakerSeed   = $null          # $null = random
$script:PSFakerRng    = $null          # System.Random instance
$script:UniqueCache   = @{}            # formatter-name -> [System.Collections.Generic.HashSet[string]]

function _Rng {
    if ($null -eq $script:PSFakerRng) { $script:PSFakerRng = [System.Random]::new() }
    return $script:PSFakerRng
}

$providerOrder = @('Base','Lorem','Person','Address','Company','Internet','DateTime','Misc')
foreach ($name in $providerOrder) {
    $p = Join-Path $PSScriptRoot "src\Providers\$name.ps1"
    if (Test-Path $p) { . $p }
}

$locales   = Get-ChildItem -Path "$PSScriptRoot\src\Locales\*.ps1"   -ErrorAction SilentlyContinue
foreach ($l in $locales)   { . $l.FullName }

# ─── Factory ────────────────────────────────────────────────────────────────
function New-Faker {
<#
.SYNOPSIS  Initialise (or re-initialise) the PSFaker generator.
.PARAMETER Seed  Optional integer seed for reproducible output.
.PARAMETER Locale  IETF locale tag (default 'en_US').
#>
    [CmdletBinding()]
    param(
        [Parameter()] [Nullable[int]] $Seed   = $null,
        [Parameter()] [string]        $Locale = 'en_US'
    )
    # Ensure script variables are initialized
    if (-not (Test-Path variable:script:PSFakerSeed)) { $script:PSFakerSeed = $null }
    if (-not (Test-Path variable:script:PSFakerRng)) { $script:PSFakerRng = $null }
    if (-not (Test-Path variable:script:UniqueCache)) { $script:UniqueCache = @{} }
    
    $script:PSFakerSeed = $Seed
    if ($null -ne $Seed) {
        $script:PSFakerRng = [System.Random]::new($Seed)
    } else {
        $script:PSFakerRng = [System.Random]::new()
    }
    $script:UniqueCache = @{}
    # locale overrides would be dot-sourced here in a full implementation
}

# ─── Modifier: unique ───────────────────────────────────────────────────────
function Get-FakeUnique {
<#
.SYNOPSIS  Calls a scriptblock and retries until a unique (never-seen) value is returned.
.PARAMETER Generator  A scriptblock that calls a PSFaker function.
.PARAMETER MaxAttempts  Safety ceiling (default 10000).
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [scriptblock] $Generator,
        [Parameter()] [int] $MaxAttempts = 10000
    )
    $key = $Generator.ToString().Trim()
    $uniqueCache = (Get-Variable -Scope 1 -Name 'UniqueCache' -ErrorAction SilentlyContinue).Value
    if (-not $uniqueCache.ContainsKey($key)) {
        $uniqueCache[$key] = [System.Collections.Generic.HashSet[string]]::new()
    }
    $seen = $uniqueCache[$key]
    for ($i = 0; $i -lt $MaxAttempts; $i++) {
        $val = & $Generator
        $str = [string]$val
        if ($seen.Add($str)) { return $val }
    }
    throw [System.OverflowException]::new("PSFaker: unique() exhausted after $MaxAttempts attempts for: $key")
}

function Reset-FakeUnique {
<#.SYNOPSIS  Clear all unique-value caches.#>
    [CmdletBinding()] param()
    Set-Variable -Scope 1 -Name 'UniqueCache' -Value @{}
}

# ─── Modifier: optional ─────────────────────────────────────────────────────
function Get-FakeOptional {
<#
.SYNOPSIS  With probability (1-Weight) returns $Default; otherwise calls Generator.
.PARAMETER Weight   0.0–1.0, probability of returning real value (default 0.5).
.PARAMETER Default  Value to return when skipping (default $null).
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [scriptblock] $Generator,
        [Parameter()] [double] $Weight  = 0.5,
        [Parameter()] $Default          = $null
    )
    if ((_Rng).NextDouble() -lt $Weight) { return & $Generator }
    return $Default
}

# ─── Modifier: valid ────────────────────────────────────────────────────────
function Get-FakeValid {
<#
.SYNOPSIS  Calls Generator until Validator returns $true.
.PARAMETER Generator  Scriptblock generating a value.
.PARAMETER Validator  Scriptblock accepting a value and returning bool.
.PARAMETER MaxAttempts  Safety ceiling (default 10000).
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [scriptblock] $Generator,
        [Parameter(Mandatory)] [scriptblock] $Validator,
        [Parameter()] [int] $MaxAttempts = 10000
    )
    for ($i = 0; $i -lt $MaxAttempts; $i++) {
        $val = & $Generator
        if (& $Validator $val) { return $val }
    }
    throw [System.OverflowException]::new("PSFaker: valid() exhausted after $MaxAttempts attempts.")
}
