# Providers/Base.ps1

function Get-FakeRandomDigit {
<#.SYNOPSIS Random integer 0-9.#>
    [CmdletBinding()] param()
    return (_Rng).Next(0, 10)
}

function Get-FakeRandomDigitNotNull {
<#.SYNOPSIS Random integer 1-9.#>
    [CmdletBinding()] param()
    return (_Rng).Next(1, 10)
}

function Get-FakeRandomDigitNot {
<#.SYNOPSIS Random digit 0-9 that is NOT $Excluded.#>
    [CmdletBinding()]
    param([Parameter(Mandatory)][ValidateRange(0,9)][int]$Excluded)
    do { $d = (_Rng).Next(0,10) } while ($d -eq $Excluded)
    return $d
}

function Get-FakeRandomNumber {
<#
.SYNOPSIS  Random integer with optional digit count.
.PARAMETER NbDigits  Number of digits (1-18). $null = fully random.
.PARAMETER Strict    If $true, first digit is never 0.
#>
    [CmdletBinding()]
    param(
        [Parameter()] [Nullable[int]] $NbDigits = $null,
        [Parameter()] [bool]          $Strict   = $false
    )
    if ($null -eq $NbDigits) { return (_Rng).Next(0, [int]::MaxValue) }
    if ($NbDigits -lt 1 -or $NbDigits -gt 9) { $NbDigits = [Math]::Max(1, [Math]::Min($NbDigits, 9)) }
    $min = if ($Strict) { [Math]::Pow(10, $NbDigits-1) -as [int] } else { 0 }
    $max = [Math]::Pow(10, $NbDigits) -as [int]
    return (_Rng).Next($min, $max)
}

function Get-FakeRandomFloat {
<#
.SYNOPSIS  Random float.
.PARAMETER NbMaxDecimals  Max decimal places ($null = any).
.PARAMETER Min  Lower bound (default 0).
.PARAMETER Max  Upper bound ($null = unbounded small value).
#>
    [CmdletBinding()]
    param(
        [Parameter()] [Nullable[int]]    $NbMaxDecimals = $null,
        [Parameter()] [double]           $Min           = 0,
        [Parameter()] [Nullable[double]] $Max           = $null
    )
    $hi = if ($null -eq $Max) { $Min + 1000 } else { $Max }
    $raw = $Min + ((_Rng).NextDouble() * ($hi - $Min))
    if ($null -ne $NbMaxDecimals) {
        $raw = [Math]::Round($raw, $NbMaxDecimals)
    }
    return $raw
}

function Get-FakeNumberBetween {
<#.SYNOPSIS  Random integer in [$Min..$Max].#>
    [CmdletBinding()]
    param(
        [Parameter()] [int] $Min = 1000,
        [Parameter()] [int] $Max = 9000
    )
    return (_Rng).Next($Min, $Max + 1)
}

function Get-FakeRandomLetter {
<#.SYNOPSIS  Random lowercase ASCII letter a-z.#>
    [CmdletBinding()] param()
    return [char]((_Rng).Next([int][char]'a', [int][char]'z' + 1))
}

function Get-FakeRandomElement {
<#.SYNOPSIS  Pick one random element from an array.#>
    [CmdletBinding()]
    param([Parameter(Mandatory)][array]$Array)
    return $Array[(_Rng).Next(0, $Array.Count)]
}

function Get-FakeRandomElements {
<#.SYNOPSIS  Pick $Count random elements (with replacement) from an array.#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][array]$Array,
        [Parameter()][int]$Count = 1
    )
    $result = @()
    for ($i = 0; $i -lt $Count; $i++) {
        $result += $Array[(_Rng).Next(0, $Array.Count)]
    }
    return $result
}

function Invoke-FakeShuffle {
<#.SYNOPSIS  Shuffle a string or array (Fisher-Yates).#>
    [CmdletBinding()]
    param([Parameter(Mandatory)]$Value)
    if ($Value -is [string]) {
        $chars = $Value.ToCharArray()
        for ($i = $chars.Count - 1; $i -gt 0; $i--) {
            $j = (_Rng).Next(0, $i + 1)
            $tmp = $chars[$i]; $chars[$i] = $chars[$j]; $chars[$j] = $tmp
        }
        return -join $chars
    }
    $arr = @($Value)
    for ($i = $arr.Count - 1; $i -gt 0; $i--) {
        $j = (_Rng).Next(0, $i + 1)
        $tmp = $arr[$i]; $arr[$i] = $arr[$j]; $arr[$j] = $tmp
    }
    return $arr
}

function Format-FakeNumerify {
<#.SYNOPSIS  Replace every '#' with a random digit.#>
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Template)
    $sb = [System.Text.StringBuilder]::new()
    foreach ($c in $Template.ToCharArray()) {
        if ($c -eq '#') { [void]$sb.Append((_Rng).Next(0,10)) }
        else            { [void]$sb.Append($c) }
    }
    return $sb.ToString()
}

function Format-FakeLexify {
<#.SYNOPSIS  Replace every '?' with a random lowercase letter.#>
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Template)
    $sb = [System.Text.StringBuilder]::new()
    foreach ($c in $Template.ToCharArray()) {
        if ($c -eq '?') { [void]$sb.Append([char]((_Rng).Next([int][char]'a', [int][char]'z'+1))) }
        else            { [void]$sb.Append($c) }
    }
    return $sb.ToString()
}

function Format-FakeBothify {
<#.SYNOPSIS  Replace '#' with digit and '?' with letter.#>
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Template)
    return Format-FakeLexify (Format-FakeNumerify $Template)
}

function Format-FakeAsciify {
<#.SYNOPSIS  Replace every '*' with a random printable ASCII character (33-126).#>
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Template)
    $sb = [System.Text.StringBuilder]::new()
    foreach ($c in $Template.ToCharArray()) {
        if ($c -eq '*') { [void]$sb.Append([char]((_Rng).Next(33, 127))) }
        else            { [void]$sb.Append($c) }
    }
    return $sb.ToString()
}

function Format-FakeRegexify {
<#
.SYNOPSIS  Generate a string matching a simplified regex pattern.
.DESCRIPTION  Supports: literal chars, [abc] classes, [a-z] ranges,
              (a|b|c) alternation, ?, *, + quantifiers, {n} {n,m} quantifiers.
#>
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Pattern)

    function _ExpandClass([string]$cls) {
        $chars = New-Object System.Collections.Generic.List[char]
        $i = 0
        while ($i -lt $cls.Length) {
            if ($i+2 -lt $cls.Length -and $cls[$i+1] -eq '-') {
                $from=[int][char]$cls[$i]; $to=[int][char]$cls[$i+2]
                for($k=$from;$k -le $to;$k++){$chars.Add([char]$k)}
                $i+=3
            } else { $chars.Add($cls[$i]); $i++ }
        }
        return $chars
    }

    # Simple recursive-descent generator
    $posRef = @(0)  # Use array to allow reference modification across scopes
    function _Parse {
        $result = ''
        while ($posRef[0] -lt $Pattern.Length) {
            $c = $Pattern[$posRef[0]]
            switch ($c) {
                '(' {
                    $posRef[0]++
                    $alts = [System.Collections.Generic.List[string]]::new()
                    $cur  = ''
                    $depth = 1
                    while ($posRef[0] -lt $Pattern.Length -and $depth -gt 0) {
                        $ch = $Pattern[$posRef[0]]
                        if     ($ch -eq '(') { $depth++; $cur += $ch; $posRef[0]++ }
                        elseif ($ch -eq ')') { $depth--; if($depth -gt 0){$cur+=$ch} else{$posRef[0]++} }
                        elseif ($ch -eq '|' -and $depth -eq 1) { $alts.Add($cur); $cur=''; $posRef[0]++ }
                        else   { $cur += $ch; $posRef[0]++ }
                    }
                    $alts.Add($cur)
                    $chosen = $alts[((_Rng).Next(0,$alts.Count))]
                    $result += $chosen  # flat alternation
                }
                '[' {
                    $posRef[0]++
                    $cls = ''
                    while ($posRef[0] -lt $Pattern.Length -and $Pattern[$posRef[0]] -ne ']') {
                        $cls += $Pattern[$posRef[0]]; $posRef[0]++
                    }
                    $posRef[0]++ # consume ]
                    $chars = _ExpandClass $cls
                    $picked = [string]$chars[((_Rng).Next(0,$chars.Count))]
                    # check quantifier
                    $picked = _Quantify $picked
                    $result += $picked
                    continue
                }
                '{' {
                    # handled by _Quantify, skip stray {
                    $posRef[0]++; continue
                }
                default {
                    $atom = [string]$c
                    $posRef[0]++
                    if ($posRef[0] -lt $Pattern.Length -and $Pattern[$posRef[0]] -match '[?*+{]') {
                        $atom = _Quantify $atom
                    }
                    if ($atom -ne '') { $result += $atom }
                    continue
                }
            }
        }
        return $result
    }

    function _Quantify([string]$atom) {
        if ($posRef[0] -ge $Pattern.Length) { return $atom }
        $q = $Pattern[$posRef[0]]
        switch ($q) {
            '?' { $posRef[0]++; if((_Rng).Next(0,2) -eq 0){return ''} else{return $atom} }
            '*' { $posRef[0]++; $n=(_Rng).Next(0,5); return $atom*$n }
            '+' { $posRef[0]++; $n=(_Rng).Next(1,5); return $atom*$n }
            '{' {
                $posRef[0]++
                $nums=''; while($posRef[0] -lt $Pattern.Length -and $Pattern[$posRef[0]] -ne '}'){$nums+=$Pattern[$posRef[0]];$posRef[0]++}
                $posRef[0]++ # consume }
                if ($nums -match '^(\d+),(\d+)$') {
                    $n = (_Rng).Next([int]$Matches[1],[int]$Matches[2]+1)
                } else { $n = [int]$nums }
                return $atom*$n
            }
            default { return $atom }
        }
    }

    return _Parse
}
