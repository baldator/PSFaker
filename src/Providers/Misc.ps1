# Providers/Payment.ps1

$script:_CardTypes = @('Visa','MasterCard','American Express','Discover','JCB','Diners Club')
$script:_CardPrefixMap = @{
    'Visa'             = @('4')
    'MasterCard'       = @('51','52','53','54','55')
    'American Express' = @('34','37')
    'Discover'         = @('6011','622','64','65')
    'JCB'              = @('3528','3589')
    'Diners Club'      = @('300','301','302','303','36','38')
}
$script:_CardLengthMap = @{
    'Visa'='16';'MasterCard'='16';'American Express'='15';
    'Discover'='16';'JCB'='16';'Diners Club'='14'
}

function _LuhnComplete([string]$partial,[int]$totalLen) {
    $sb = [System.Text.StringBuilder]::new($partial)
    while ($sb.Length -lt $totalLen - 1) { [void]$sb.Append((_Rng).Next(0,10)) }
    # compute check digit
    $digits = $sb.ToString().ToCharArray() | ForEach-Object { [int]::Parse($_) }
    $sum = 0; $alt = $false
    for ($i = $digits.Count-1; $i -ge 0; $i--) {
        $d = $digits[$i]
        if ($alt) { $d *= 2; if ($d -gt 9) { $d -= 9 } }
        $sum += $d; $alt = !$alt
    }
    $check = (10 - ($sum % 10)) % 10
    [void]$sb.Append($check)
    return $sb.ToString()
}

function Get-FakeCreditCardType {
<#.SYNOPSIS  Credit card brand.#>
    [CmdletBinding()] param()
    return Get-FakeRandomElement $script:_CardTypes
}

function Get-FakeCreditCardNumber {
<#.SYNOPSIS  Credit card number (Luhn-valid).#>
    [CmdletBinding()]
    param([Parameter()] [string] $Type = '')
    if (-not $Type) { $Type = Get-FakeCreditCardType }
    $prefix = Get-FakeRandomElement $script:_CardPrefixMap[$Type]
    $len    = [int]$script:_CardLengthMap[$Type]
    return _LuhnComplete $prefix $len
}

function Get-FakeCreditCardExpirationDate {
<#.SYNOPSIS  Expiry DateTime (future date within 5 years).#>
    [CmdletBinding()] param()
    $m = (_Rng).Next(1,13); $y = [datetime]::Now.Year + (_Rng).Next(1,6)
    return [datetime]::new($y,$m,1)
}

function Get-FakeCreditCardDetails {
<#.SYNOPSIS  Hashtable with Type, Number, Name, Expiry.#>
    [CmdletBinding()] param()
    $type = Get-FakeCreditCardType
    return @{
        Type   = $type
        Number = Get-FakeCreditCardNumber -Type $type
        Name   = Get-FakeName
        Expiry = (Get-FakeCreditCardExpirationDate).ToString('MM/yy')
    }
}

function Get-FakeIban {
<#.SYNOPSIS  IBAN number. Pass $CountryCode or get random.#>
    [CmdletBinding()]
    param([Parameter()] [string] $CountryCode = '')
    $codes = @('DE','FR','GB','IT','ES','NL','BE','AT','CH','PL','SE','NO','DK','FI','PT')
    if (-not $CountryCode) { $CountryCode = Get-FakeRandomElement $codes }
    $bban = Format-FakeNumerify ('#'*18)
    $check = ((_Rng).Next(10,99)).ToString()
    return "$CountryCode${check}${bban}"
}

function Get-FakeSwiftBic {
<#.SYNOPSIS  SWIFT/BIC code.#>
    [CmdletBinding()] param()
    $bank    = -join (1..4 | ForEach-Object { [char]((_Rng).Next([int][char]'A',[int][char]'Z'+1)) })
    $country = Get-FakeRandomElement @('DE','FR','GB','US','IT','ES','NL','CH','AT','PL')
    $loc     = -join (1..2 | ForEach-Object { [char]((_Rng).Next([int][char]'A',[int][char]'Z'+1)) })
    $branch  = -join (1..3 | ForEach-Object { if((_Rng).Next(0,2)-eq 0){[char]((_Rng).Next([int][char]'A',[int][char]'Z'+1))} else{(_Rng).Next(0,10)} })
    return "${bank}${country}${loc}${branch}"
}

# ─── Color ───────────────────────────────────────────────────────────────────
$script:_SafeColorNames = @('aqua','black','blue','fuchsia','gray','green','lime','maroon',
    'navy','olive','orange','purple','red','silver','teal','white','yellow')
$script:_ColorNames = @('AliceBlue','AntiqueWhite','Aqua','Aquamarine','Azure','Beige','Bisque',
    'Black','BlanchedAlmond','Blue','BlueViolet','Brown','BurlyWood','CadetBlue',
    'Chartreuse','Chocolate','Coral','CornflowerBlue','Cornsilk','Crimson','Cyan',
    'DarkBlue','DarkCyan','DarkGoldenrod','DarkGray','DarkGreen','DarkKhaki',
    'DarkMagenta','DarkOliveGreen','DarkOrange','DarkOrchid','DarkRed','DarkSalmon',
    'DarkSeaGreen','DarkSlateBlue','DarkSlateGray','DarkTurquoise','DarkViolet',
    'DeepPink','DeepSkyBlue','DimGray','DodgerBlue','Firebrick','FloralWhite',
    'ForestGreen','Fuchsia','Gainsboro','GhostWhite','Gold','Goldenrod','Gray',
    'Green','GreenYellow','Honeydew','HotPink','IndianRed','Indigo','Ivory',
    'Khaki','Lavender','LavenderBlush','LawnGreen','LemonChiffon','LightBlue',
    'LightCoral','LightCyan','LightGoldenrodYellow','LightGray','LightGreen',
    'LightPink','LightSalmon','LightSeaGreen','LightSkyBlue','LightSlateGray',
    'LightSteelBlue','LightYellow','Lime','LimeGreen','Linen','Magenta','Maroon',
    'MediumAquamarine','MediumBlue','MediumOrchid','MediumPurple','MediumSeaGreen',
    'MediumSlateBlue','MediumSpringGreen','MediumTurquoise','MediumVioletRed',
    'MidnightBlue','MintCream','MistyRose','Moccasin','NavajoWhite','Navy',
    'OldLace','Olive','OliveDrab','Orange','OrangeRed','Orchid','PaleGoldenrod',
    'PaleGreen','PaleTurquoise','PaleVioletRed','PapayaWhip','PeachPuff','Peru',
    'Pink','Plum','PowderBlue','Purple','Red','RosyBrown','RoyalBlue','SaddleBrown',
    'Salmon','SandyBrown','SeaGreen','Seashell','Sienna','Silver','SkyBlue',
    'SlateBlue','SlateGray','Snow','SpringGreen','SteelBlue','Tan','Teal',
    'Thistle','Tomato','Turquoise','Violet','Wheat','White','WhiteSmoke','Yellow',
    'YellowGreen')

function Get-FakeHexColor {
<#.SYNOPSIS  Hex color e.g. '#fa3cc2'.#>
    [CmdletBinding()] param()
    return '#{0:x6}' -f (_Rng).Next(0,16777216)
}
function Get-FakeRgbColor {
<#.SYNOPSIS  RGB string e.g. '0,255,122'.#>
    [CmdletBinding()] param()
    return "$((_Rng).Next(0,256)),$((_Rng).Next(0,256)),$((_Rng).Next(0,256))"
}
function Get-FakeRgbColorAsArray {
<#.SYNOPSIS  RGB as int array.#>
    [CmdletBinding()] param()
    return @((_Rng).Next(0,256),(_Rng).Next(0,256),(_Rng).Next(0,256))
}
function Get-FakeRgbCssColor {
<#.SYNOPSIS  CSS rgb() string.#>
    [CmdletBinding()] param()
    return "rgb($(Get-FakeRgbColor))"
}
function Get-FakeSafeColorName {
<#.SYNOPSIS  CSS safe color name.#>
    [CmdletBinding()] param()
    return Get-FakeRandomElement $script:_SafeColorNames
}
function Get-FakeColorName {
<#.SYNOPSIS  Named color.#>
    [CmdletBinding()] param()
    return Get-FakeRandomElement $script:_ColorNames
}
function Get-FakeHslColor {
<#.SYNOPSIS  HSL string e.g. '340,50,20'.#>
    [CmdletBinding()] param()
    return "$((_Rng).Next(0,360)),$((_Rng).Next(0,101)),$((_Rng).Next(0,101))"
}
function Get-FakeHslColorAsArray {
<#.SYNOPSIS  HSL as int array [H, S, L].#>
    [CmdletBinding()] param()
    return @((_Rng).Next(0,360),(_Rng).Next(0,101),(_Rng).Next(0,101))
}

# ─── File ─────────────────────────────────────────────────────────────────
$script:_MimeTypes = @{
    'jpg'='image/jpeg';'jpeg'='image/jpeg';'png'='image/png';'gif'='image/gif';
    'bmp'='image/bmp';'svg'='image/svg+xml';'webp'='image/webp';
    'mp4'='video/mp4';'avi'='video/x-msvideo';'mov'='video/quicktime';
    'mp3'='audio/mpeg';'wav'='audio/wav';'ogg'='audio/ogg';
    'pdf'='application/pdf';'zip'='application/zip';'tar'='application/x-tar';
    'gz'='application/gzip';'json'='application/json';'xml'='application/xml';
    'html'='text/html';'css'='text/css';'js'='text/javascript';'txt'='text/plain';
    'csv'='text/csv';'xlsx'='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    'docx'='application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    'pptx'='application/vnd.openxmlformats-officedocument.presentationml.presentation'
}

function Get-FakeFileExtension {
<#.SYNOPSIS  File extension (without dot).#>
    [CmdletBinding()] param()
    return Get-FakeRandomElement ([array]$script:_MimeTypes.Keys)
}
function Get-FakeMimeType {
<#.SYNOPSIS  MIME type string.#>
    [CmdletBinding()] param()
    return Get-FakeRandomElement ([array]$script:_MimeTypes.Values)
}

# ─── UUID ────────────────────────────────────────────────────────────────────
function Get-FakeUuid {
<#.SYNOPSIS  RFC 4122 v4 UUID.#>
    [CmdletBinding()] param()
    $b = [byte[]]::new(16)
    ((_Rng)).NextBytes($b)
    $b[6] = ($b[6] -band 0x0F) -bor 0x40  # version 4
    $b[8] = ($b[8] -band 0x3F) -bor 0x80  # variant
    return '{0:x2}{1:x2}{2:x2}{3:x2}-{4:x2}{5:x2}-{6:x2}{7:x2}-{8:x2}{9:x2}-{10:x2}{11:x2}{12:x2}{13:x2}{14:x2}{15:x2}' -f `
        $b[0],$b[1],$b[2],$b[3],$b[4],$b[5],$b[6],$b[7],$b[8],$b[9],$b[10],$b[11],$b[12],$b[13],$b[14],$b[15]
}

# ─── Barcode ─────────────────────────────────────────────────────────────────
function _EanCheckDigit([string]$digits) {
    $sum = 0
    for ($i = 0; $i -lt $digits.Length; $i++) {
        $w = if ($i % 2 -eq 0) { 1 } else { 3 }
        $sum += [int]::Parse($digits[$i]) * $w
    }
    return ((10 - ($sum % 10)) % 10).ToString()
}
function Get-FakeEan13 {
<#.SYNOPSIS  EAN-13 barcode number.#>
    [CmdletBinding()] param()
    $d = Format-FakeNumerify '############'
    return $d + (_EanCheckDigit $d)
}
function Get-FakeEan8  {
<#.SYNOPSIS  EAN-8 barcode number.#>
    [CmdletBinding()] param()
    $d = Format-FakeNumerify '#######'
    return $d + (_EanCheckDigit $d)
}
function _Isbn10Check([string]$digits) {
    $sum = 0
    for ($i = 0; $i -lt 9; $i++) { $sum += [int]::Parse($digits[$i]) * (10 - $i) }
    $r = 11 - ($sum % 11)
    if ($r -eq 11) { return '0' } elseif ($r -eq 10) { return 'X' } else { return $r.ToString() }
}
function Get-FakeIsbn13 {
<#.SYNOPSIS  ISBN-13.#>
    [CmdletBinding()] param()
    $prefix = Get-FakeRandomElement @('978','979')
    $d = $prefix + (Format-FakeNumerify '#########')
    return $d + (_EanCheckDigit $d)
}
function Get-FakeIsbn10 {
<#.SYNOPSIS  ISBN-10.#>
    [CmdletBinding()] param()
    $d = Format-FakeNumerify '#########'
    return $d + (_Isbn10Check $d)
}

# ─── Miscellaneous ────────────────────────────────────────────────────────────
$script:_Locales = @('en_US','en_GB','fr_FR','de_DE','es_ES','it_IT','pt_BR','ru_RU',
    'ja_JP','zh_CN','ko_KR','ar_SA','nl_NL','sv_SE','pl_PL','cs_CZ','tr_TR')
$script:_CountryCodes = @('US','GB','FR','DE','ES','IT','BR','RU','JP','CN','KR','SA',
    'AU','CA','MX','IN','AR','ZA','NG','EG','NL','SE','NO','DK','FI','PL','CZ','TR')
$script:_LanguageCodes = @('en','fr','de','es','it','pt','ru','ja','zh','ko','ar',
    'nl','sv','no','da','fi','pl','cs','tr','hu','ro','uk','he','th','vi','id')
$script:_CurrencyCodes = @('USD','EUR','GBP','JPY','CHF','CAD','AUD','CNY','INR',
    'BRL','RUB','KRW','MXN','SGD','HKD','NOK','SEK','DKK','NZD','ZAR')
$script:_Emojis = @(
    [char]::ConvertFromUtf32(0x1F600), [char]::ConvertFromUtf32(0x1F601), [char]::ConvertFromUtf32(0x1F602), [char]::ConvertFromUtf32(0x1F923), [char]::ConvertFromUtf32(0x1F603), 
    [char]::ConvertFromUtf32(0x1F604), [char]::ConvertFromUtf32(0x1F605), [char]::ConvertFromUtf32(0x1F606), [char]::ConvertFromUtf32(0x1F609), [char]::ConvertFromUtf32(0x1F60A), 
    [char]::ConvertFromUtf32(0x1F60B), [char]::ConvertFromUtf32(0x1F60E), [char]::ConvertFromUtf32(0x1F60D), [char]::ConvertFromUtf32(0x1F618), [char]::ConvertFromUtf32(0x1F970), 
    [char]::ConvertFromUtf32(0x1F917), [char]::ConvertFromUtf32(0x1F92A), [char]::ConvertFromUtf32(0x1F914), [char]::ConvertFromUtf32(0x1F928), [char]::ConvertFromUtf32(0x1F610), 
    [char]::ConvertFromUtf32(0x1F611), [char]::ConvertFromUtf32(0x1F636), [char]::ConvertFromUtf32(0x1F644), [char]::ConvertFromUtf32(0x1F60F), [char]::ConvertFromUtf32(0x1F62C), 
    [char]::ConvertFromUtf32(0x1F62E), [char]::ConvertFromUtf32(0x1F913), [char]::ConvertFromUtf32(0x1F62A), [char]::ConvertFromUtf32(0x1F629), [char]::ConvertFromUtf32(0x1F62D), 
    [char]::ConvertFromUtf32(0x1F622), [char]::ConvertFromUtf32(0x1F62D), [char]::ConvertFromUtf32(0x1F613), [char]::ConvertFromUtf32(0x1F629), [char]::ConvertFromUtf32(0x1F634), 
    [char]::ConvertFromUtf32(0x1F60C), [char]::ConvertFromUtf32(0x1F61B), [char]::ConvertFromUtf32(0x1F61C), [char]::ConvertFromUtf32(0x1F61D), [char]::ConvertFromUtf32(0x1F612), 
    [char]::ConvertFromUtf32(0x1F605), [char]::ConvertFromUtf32(0x1F92F), [char]::ConvertFromUtf32(0x1F92C), [char]::ConvertFromUtf32(0x1F621), [char]::ConvertFromUtf32(0x1F620), 
    [char]::ConvertFromUtf32(0x1F92C), [char]::ConvertFromUtf32(0x1F637), [char]::ConvertFromUtf32(0x1F912), [char]::ConvertFromUtf32(0x1F915)
)

function Get-FakeBoolean {
<#.SYNOPSIS  Random boolean.#>
    [CmdletBinding()]
    param([int]$ChanceOfTrue=50)
    return ((_Rng).Next(0,100) -lt $ChanceOfTrue)
}
function Get-FakeMd5    { [CmdletBinding()] param(); return (Get-FakeUuid).Replace('-','').Substring(0,32) }
function Get-FakeSha1   { [CmdletBinding()] param(); return -join (1..40 | ForEach-Object { '{0:x}' -f (_Rng).Next(0,16) }) }
function Get-FakeSha256 { [CmdletBinding()] param(); return -join (1..64 | ForEach-Object { '{0:x}' -f (_Rng).Next(0,16) }) }
function Get-FakeLocale       { [CmdletBinding()] param(); return Get-FakeRandomElement $script:_Locales }
function Get-FakeCountryCode  { [CmdletBinding()] param(); return Get-FakeRandomElement $script:_CountryCodes }
function Get-FakeLanguageCode { [CmdletBinding()] param(); return Get-FakeRandomElement $script:_LanguageCodes }
function Get-FakeCurrencyCode { [CmdletBinding()] param(); return Get-FakeRandomElement $script:_CurrencyCodes }
function Get-FakeEmoji        { [CmdletBinding()] param(); return Get-FakeRandomElement $script:_Emojis }

# ─── UserAgent ───────────────────────────────────────────────────────────────
function Get-FakeChromeAgent {
    [CmdletBinding()] param()
    $v = "$((_Rng).Next(60,120)).0.$((_Rng).Next(1000,9999)).$((_Rng).Next(10,200))"
    $wk= "$((_Rng).Next(530,540)).$((_Rng).Next(1,50))"
    return "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/$wk (KHTML, like Gecko) Chrome/$v Safari/$wk"
}
function Get-FakeFirefoxAgent {
    [CmdletBinding()] param()
    $v = "$((_Rng).Next(80,120)).0"
    return "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:$v) Gecko/20100101 Firefox/$v"
}
function Get-FakeSafariAgent {
    [CmdletBinding()] param()
    $wk = "$((_Rng).Next(530,540)).$((_Rng).Next(1,50))"
    $v  = "$((_Rng).Next(13,17)).$((_Rng).Next(0,10))"
    return "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/$wk (KHTML, like Gecko) Version/$v Safari/$wk"
}
function Get-FakeOperaAgent {
    [CmdletBinding()] param()
    $v = "$((_Rng).Next(70,100)).0.$((_Rng).Next(1000,5000)).$((_Rng).Next(10,200))"
    return "Opera/$v (Windows NT 10.0; Win64; x64)"
}
function Get-FakeIEAgent {
    [CmdletBinding()] param()
    $v = (Get-FakeRandomElement @('7.0','8.0','9.0','10.0','11.0'))
    return "Mozilla/5.0 (compatible; MSIE $v; Windows NT 10.0; Trident/7.0)"
}
function Get-FakeUserAgent {
<#.SYNOPSIS  Random user agent string.#>
    [CmdletBinding()] param()
    $fn = Get-FakeRandomElement @('Get-FakeChromeAgent','Get-FakeFirefoxAgent','Get-FakeSafariAgent','Get-FakeOperaAgent','Get-FakeIEAgent')
    return & $fn
}

# ─── Biased ───────────────────────────────────────────────────────────────────
function Get-FakeBiasedNumberBetween {
<#
.SYNOPSIS  Biased random number toward one end of the range.
.PARAMETER Min  Lower bound.
.PARAMETER Max  Upper bound.
.PARAMETER Function  'sqrt' (toward max) or 'log' (toward min).
#>
    [CmdletBinding()]
    param(
        [int]    $Min      = 0,
        [int]    $Max      = 100,
        [string] $Function = 'sqrt'
    )
    $raw = ((_Rng).NextDouble())
    $biased = switch ($Function) {
        'sqrt' { [Math]::Sqrt($raw) }
        'log'  { 1 - [Math]::Sqrt(1 - $raw) }
        default{ $raw }
    }
    return [int]($Min + $biased * ($Max - $Min))
}

# ─── HtmlLorem ────────────────────────────────────────────────────────────────
function Get-FakeHtmlLorem {
<#
.SYNOPSIS  Generate a random HTML document.
.PARAMETER MaxDepth   Max nesting depth (default 2).
.PARAMETER MaxWidth   Max sibling elements per level (default 3).
#>
    [CmdletBinding()]
    param([int]$MaxDepth=2,[int]$MaxWidth=3)

    function _HtmlNode([int]$depth) {
        if ($depth -le 0) { return "<p>$(Get-FakeSentence)</p>" }
        $tag = Get-FakeRandomElement @('div','section','article','aside')
        $count = (_Rng).Next(1,$MaxWidth+1)
        $inner = (1..$count | ForEach-Object {
            if ((_Rng).Next(0,2)-eq 0) { "<p>$(Get-FakeSentence)</p>" }
            else { _HtmlNode ($depth-1) }
        }) -join ''
        return "<$tag>$inner</$tag>"
    }
    $title = Get-FakeSentence
    $body  = _HtmlNode $MaxDepth
    return "<!DOCTYPE html><html><head><title>$title</title></head><body>$body</body></html>"
}

# ─── RealText ─────────────────────────────────────────────────────────────────
# Markov chain on a small corpus (Alice in Wonderland excerpt)
$script:_RealTextCorpus = @"
Alice was beginning to get very tired of sitting by her sister on the bank and of having nothing to do
once or twice she had peeped into the book her sister was reading but it had no pictures or conversations in it
and what is the use of a book thought Alice without pictures or conversations
so she was considering in her own mind as well as she could for the hot day made her feel very sleepy and stupid
whether the pleasure of making a daisy chain would be worth the trouble of getting up and picking the daisies
when suddenly a White Rabbit with pink eyes ran close by her
there was nothing so very remarkable in that nor did Alice think it so very much out of the way to hear the Rabbit say to itself
oh dear oh dear I shall be too late
but when the Rabbit actually took a watch out of its waistcoat pocket and looked at it and then hurried on
Alice started to her feet for it flashed across her mind that she had never before seen a rabbit with either a waistcoat pocket or a watch to take out of it
"@

function Get-FakeRealText {
<#
.SYNOPSIS  Markov-chain generated text (Alice in Wonderland style).
.PARAMETER MaxNbChars  Maximum character count (default 200).
.PARAMETER IndexSize   Markov chain order / key length in words (default 2).
#>
    [CmdletBinding()]
    param([int]$MaxNbChars=200,[int]$IndexSize=2)

    # Build chain
    $words = ($script:_RealTextCorpus -split '\s+' | Where-Object { $_ })
    $chain = @{}
    for ($i = 0; $i -lt $words.Count - $IndexSize; $i++) {
        $key  = ($words[$i..($i+$IndexSize-1)]) -join ' '
        $next = $words[$i+$IndexSize]
        if (-not $chain.ContainsKey($key)) { $chain[$key] = @() }
        $chain[$key] += $next
    }

    # Generate
    $keys    = [array]$chain.Keys
    $current = ($words[0..($IndexSize-1)]) -join ' '
    $out     = $current

    while ($out.Length -lt $MaxNbChars) {
        if (-not $chain.ContainsKey($current)) {
            $current = Get-FakeRandomElement $keys
        }
        $next = Get-FakeRandomElement $chain[$current]
        if (($out.Length + 1 + $next.Length) -gt $MaxNbChars) { break }
        $out    += " $next"
        $parts   = $out -split ' '
        $current = ($parts[($parts.Count-$IndexSize)..($parts.Count-1)]) -join ' '
    }
    # Capitalise first letter
    return $out.Substring(0,1).ToUpper() + $out.Substring(1)
}
