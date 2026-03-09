# Providers/Lorem.ps1

$script:_LoremWords = @(
    'alias','consequatur','aut','perferendis','sit','voluptatem','accusantium',
    'doloremque','aperiam','eaque','ipsa','quae','ab','illo','inventore','veritatis',
    'et','quasi','architecto','beatae','vitae','dicta','sunt','explicabo','nemo','enim',
    'ipsam','voluptatem','quia','voluptas','sit','aspernatur','aut','odit','aut','fugit',
    'sed','quia','consequuntur','magni','dolores','eos','qui','ratione','voluptatem',
    'sequi','nesciunt','neque','porro','quisquam','est','qui','dolorem','ipsum','quia',
    'dolor','sit','amet','consectetur','adipisci','velit','sed','quia','non','numquam',
    'eius','modi','tempora','incidunt','ut','labore','et','dolore','magnam','aliquam',
    'quaerat','voluptatem','ut','enim','ad','minima','veniam','quis','nostrum',
    'exercitationem','ullam','corporis','suscipit','laboriosam','nisi','ut','aliquid',
    'ex','ea','commodi','consequatur','quis','autem','vel','eum','iure','reprehenderit',
    'qui','in','ea','voluptate','velit','esse','quam','nihil','molestiae','consequatur',
    'vel','illum','qui','dolorem','eum','fugiat','quo','voluptas','nulla','pariatur'
)

function Get-FakeWord {
<#.SYNOPSIS  A single lorem word.#>
    [CmdletBinding()] param()
    return Get-FakeRandomElement $script:_LoremWords
}

function Get-FakeWords {
<#.SYNOPSIS  $Nb lorem words as array or joined string.#>
    [CmdletBinding()]
    param(
        [Parameter()] [int]  $Nb     = 3,
        [Parameter()] [bool] $AsText = $false
    )
    $arr = @(1..$Nb | ForEach-Object { Get-FakeWord })
    if ($AsText) { return $arr -join ' ' }
    return $arr
}

function Get-FakeSentence {
<#.SYNOPSIS  Sentence of approximately $NbWords words.#>
    [CmdletBinding()]
    param(
        [Parameter()] [int]  $NbWords         = 6,
        [Parameter()] [bool] $VariableNbWords = $true
    )
    $count = if ($VariableNbWords) { [Math]::Max(1, $NbWords + (_Rng).Next(-2, 3)) } else { $NbWords }
    $words = Get-FakeWords -Nb $count
    $sentence = ($words -join ' ')
    return (($sentence.Substring(0,1).ToUpper()) + $sentence.Substring(1)) + '.'
}

function Get-FakeSentences {
<#.SYNOPSIS  $Nb sentences as array or joined string.#>
    [CmdletBinding()]
    param(
        [Parameter()] [int]  $Nb     = 3,
        [Parameter()] [bool] $AsText = $false
    )
    $arr = @(1..$Nb | ForEach-Object { Get-FakeSentence })
    if ($AsText) { return $arr -join ' ' }
    return $arr
}

function Get-FakeParagraph {
<#.SYNOPSIS  Paragraph of approximately $NbSentences sentences.#>
    [CmdletBinding()]
    param(
        [Parameter()] [int]  $NbSentences         = 3,
        [Parameter()] [bool] $VariableNbSentences = $true
    )
    $count = if ($VariableNbSentences) { [Math]::Max(1, $NbSentences + (_Rng).Next(-1,2)) } else { $NbSentences }
    return Get-FakeSentences -Nb $count -AsText $true
}

function Get-FakeParagraphs {
<#.SYNOPSIS  $Nb paragraphs as array or joined string.#>
    [CmdletBinding()]
    param(
        [Parameter()] [int]  $Nb     = 3,
        [Parameter()] [bool] $AsText = $false
    )
    $arr = @(1..$Nb | ForEach-Object { Get-FakeParagraph })
    if ($AsText) { return $arr -join "`n`n" }
    return $arr
}

function Get-FakeText {
<#.SYNOPSIS  Lorem text up to $MaxNbChars characters.#>
    [CmdletBinding()]
    param([Parameter()] [int] $MaxNbChars = 200)
    $text = ''
    while ($text.Length -lt $MaxNbChars) {
        $sentence = Get-FakeSentence
        if (($text.Length + $sentence.Length + 1) -le $MaxNbChars) {
            $text += if ($text) { ' ' } else { '' }
            $text += $sentence
        } else { break }
    }
    if ($text -eq '') { $text = (Get-FakeSentence).Substring(0, [Math]::Min($MaxNbChars, (Get-FakeSentence).Length)) }
    return $text.Substring(0, [Math]::Min($MaxNbChars, $text.Length))
}
