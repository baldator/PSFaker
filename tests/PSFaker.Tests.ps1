#Requires -Module Pester
<#
.SYNOPSIS
    PSFaker full test suite – targets 100% function coverage.
    Run with: Invoke-Pester -Path ./tests/PSFaker.Tests.ps1 -Output Detailed
#>

BeforeAll {
    $modulePath = Join-Path $PSScriptRoot '..' 
    $modulePath = Join-Path $modulePath 'PSFaker.psm1'
    Import-Module $modulePath -Force
    # Seed for reproducibility in assertions that need it
    New-Faker -Seed 42
}

# ═══════════════════════════════════════════════════════════════════════════════
Describe 'New-Faker / Factory' {

    It 'creates a seeded generator without error' {
        { New-Faker -Seed 1234 } | Should -Not -Throw
    }

    It 'creates an unseeded generator without error' {
        { New-Faker } | Should -Not -Throw
    }

    It 'creates generator with locale parameter' {
        { New-Faker -Locale 'en_US' } | Should -Not -Throw
    }

    It 'produces same output when same seed is used twice' {
        New-Faker -Seed 99
        $a = Get-FakeFirstName
        New-Faker -Seed 99
        $b = Get-FakeFirstName
        $a | Should -Be $b
    }

    It 'resets unique cache on New-Faker call' {
        New-Faker -Seed 1
        Reset-FakeUnique
        New-Faker -Seed 1
        $script:UniqueCache.Count | Should -Be 0
    }
}

# ═══════════════════════════════════════════════════════════════════════════════
Describe 'Base – random primitives' {

    BeforeAll { New-Faker -Seed 1 }

    It 'Get-FakeRandomDigit returns 0-9' {
        1..20 | ForEach-Object { Get-FakeRandomDigit } | ForEach-Object { $_ | Should -BeIn (0..9) }
    }

    It 'Get-FakeRandomDigitNotNull returns 1-9' {
        1..20 | ForEach-Object { Get-FakeRandomDigitNotNull } | ForEach-Object { $_ | Should -BeIn (1..9) }
    }

    It 'Get-FakeRandomDigitNot never returns the excluded digit' {
        1..30 | ForEach-Object { Get-FakeRandomDigitNot -Excluded 5 } | ForEach-Object { $_ | Should -Not -Be 5 }
    }

    It 'Get-FakeRandomDigitNot returns valid digits' {
        1..20 | ForEach-Object { Get-FakeRandomDigitNot -Excluded 0 } | ForEach-Object { $_ | Should -BeIn (1..9) }
    }

    It 'Get-FakeRandomNumber returns an integer' {
        $n = Get-FakeRandomNumber
        $n | Should -BeOfType [int]
    }

    It 'Get-FakeRandomNumber with NbDigits returns correct digit count' {
        $n = Get-FakeRandomNumber -NbDigits 4
        $n.ToString().Length | Should -BeLessOrEqual 4
    }

    It 'Get-FakeRandomNumber with Strict=true has no leading zero for NbDigits=3' {
        1..10 | ForEach-Object { Get-FakeRandomNumber -NbDigits 3 -Strict $true } |
            ForEach-Object { $_ | Should -BeGreaterOrEqual 100 }
    }

    It 'Get-FakeRandomFloat returns a float' {
        $f = Get-FakeRandomFloat
        $f | Should -BeOfType [double]
    }

    It 'Get-FakeRandomFloat respects Min and Max' {
        1..20 | ForEach-Object { Get-FakeRandomFloat -Min 10 -Max 20 } |
            ForEach-Object { $_ | Should -BeGreaterOrEqual 10; $_ | Should -BeLessOrEqual 20 }
    }

    It 'Get-FakeRandomFloat respects NbMaxDecimals' {
        $f = Get-FakeRandomFloat -NbMaxDecimals 2 -Min 0 -Max 100
        $str = $f.ToString()
        if ($str -match '\.') { ($str -split '\.')[1].Length | Should -BeLessOrEqual 2 }
        $true | Should -Be $true  # no exception
    }

    It 'Get-FakeNumberBetween returns in range' {
        1..20 | ForEach-Object { Get-FakeNumberBetween -Min 5 -Max 10 } |
            ForEach-Object { $_ | Should -BeGreaterOrEqual 5; $_ | Should -BeLessOrEqual 10 }
    }

    It 'Get-FakeNumberBetween defaults work' {
        $n = Get-FakeNumberBetween
        $n | Should -BeGreaterOrEqual 1000
        $n | Should -BeLessOrEqual 9000
    }

    It 'Get-FakeRandomLetter returns lowercase a-z' {
        1..20 | ForEach-Object { Get-FakeRandomLetter } |
            ForEach-Object { $_ | Should -Match '^[a-z]$' }
    }

    It 'Get-FakeRandomElement picks from array' {
        $arr = @(1,2,3,4,5)
        1..20 | ForEach-Object { Get-FakeRandomElement $arr } | ForEach-Object { $_ | Should -BeIn $arr }
    }

    It 'Get-FakeRandomElements returns correct count' {
        $arr = @('a','b','c','d','e')
        $result = Get-FakeRandomElements -Array $arr -Count 3
        $result.Count | Should -Be 3
    }

    It 'Get-FakeRandomElements picks from source array' {
        $arr = @('x','y','z')
        Get-FakeRandomElements -Array $arr -Count 5 | ForEach-Object { $_ | Should -BeIn $arr }
    }

    It 'Invoke-FakeShuffle shuffles a string' {
        $orig = 'hello'
        $shuf = Invoke-FakeShuffle 'hello'
        $shuf.Length | Should -Be 5
        $source = ($shuf.ToCharArray() | Sort-Object) -join '' 
        $dest = ($orig.ToCharArray() | Sort-Object) -join ''
        $source | Should -Be $dest
    }

    It 'Invoke-FakeShuffle shuffles an array' {
        $arr = @(1,2,3,4,5)
        $shuf = Invoke-FakeShuffle $arr
        $shuf.Count | Should -Be 5
        $shuf | Sort-Object | Should -Be ($arr | Sort-Object)
    }

    It 'Format-FakeNumerify replaces # with digits' {
        $result = Format-FakeNumerify 'ABC-###-XY'
        $result | Should -Match '^ABC-\d{3}-XY$'
    }

    It 'Format-FakeLexify replaces ? with letters' {
        $result = Format-FakeLexify 'Hi-???'
        $result | Should -Match '^Hi-[a-z]{3}$'
    }

    It 'Format-FakeBothify replaces both # and ?' {
        $result = Format-FakeBothify '##??'
        $result | Should -Match '^\d{2}[a-z]{2}$'
    }

    It 'Format-FakeAsciify replaces * with printable ASCII' {
        $result = Format-FakeAsciify '***'
        $result.Length | Should -Be 3
        $result.ToCharArray() | ForEach-Object {
            [int]$_ | Should -BeGreaterOrEqual 33
            [int]$_ | Should -BeLessOrEqual 126
        }
    }

    It 'Format-FakeRegexify produces a string' {
        $result = Format-FakeRegexify '[A-Z]{3}\d{2}'
        $result | Should -Not -BeNullOrEmpty
        $result | Should -BeOfType [string]
    }

    It 'Format-FakeRegexify with alternation produces one of the options' {
        1..10 | ForEach-Object { Format-FakeRegexify '(yes|no)' } |
            ForEach-Object { $_ | Should -BeIn @('yes','no') }
    }

    It 'Format-FakeRegexify ? quantifier produces 0 or 1 char' {
        1..10 | ForEach-Object {
            $r = Format-FakeRegexify 'a?'
            $r.Length | Should -BeIn (0,1)
        }
    }
}

# ═══════════════════════════════════════════════════════════════════════════════
Describe 'Lorem' {

    BeforeAll { New-Faker -Seed 2 }

    It 'Get-FakeWord returns a non-empty string' {
        Get-FakeWord | Should -Not -BeNullOrEmpty
    }

    It 'Get-FakeWords returns array of correct size' {
        (Get-FakeWords -Nb 5).Count | Should -Be 5
    }

    It 'Get-FakeWords with AsText returns a string' {
        Get-FakeWords -Nb 3 -AsText $true | Should -BeOfType [string]
    }

    It 'Get-FakeSentence ends with a period' {
        Get-FakeSentence | Should -Match '\.$'
    }

    It 'Get-FakeSentence starts with uppercase' {
        Get-FakeSentence | Should -Match '^[A-Z]'
    }

    It 'Get-FakeSentences returns array of correct size' {
        (Get-FakeSentences -Nb 4).Count | Should -Be 4
    }

    It 'Get-FakeSentences AsText joins with space' {
        $t = Get-FakeSentences -Nb 2 -AsText $true
        $t | Should -BeOfType [string]
        $t | Should -Match '\. '
    }

    It 'Get-FakeParagraph is a non-empty string' {
        Get-FakeParagraph | Should -Not -BeNullOrEmpty
    }

    It 'Get-FakeParagraph with VariableNbSentences=false has fixed count' {
        $p = Get-FakeParagraph -NbSentences 2 -VariableNbSentences $false
        $sentences = ($p -split '(?<=\.) ' | Where-Object { $_ })
        $sentences.Count | Should -Be 2
    }

    It 'Get-FakeParagraphs returns array of correct size' {
        (Get-FakeParagraphs -Nb 3).Count | Should -Be 3
    }

    It 'Get-FakeParagraphs AsText joins with double newline' {
        $t = Get-FakeParagraphs -Nb 2 -AsText $true
        $t | Should -Match "`n`n"
    }

    It 'Get-FakeText respects MaxNbChars' {
        1..5 | ForEach-Object { Get-FakeText -MaxNbChars 100 } |
            ForEach-Object { $_.Length | Should -BeLessOrEqual 100 }
    }

    It 'Get-FakeText default is 200 chars max' {
        Get-FakeText | Should -Not -BeNullOrEmpty
        (Get-FakeText).Length | Should -BeLessOrEqual 200
    }
}

# ═══════════════════════════════════════════════════════════════════════════════
Describe 'Person' {

    BeforeAll { New-Faker -Seed 3 }

    It 'Get-FakeTitleMale returns a male title' {
        Get-FakeTitleMale | Should -BeIn @('Mr.','Dr.','Prof.','Rev.')
    }

    It 'Get-FakeTitleFemale returns a female title' {
        Get-FakeTitleFemale | Should -BeIn @('Ms.','Mrs.','Dr.','Prof.','Miss')
    }

    It 'Get-FakeTitle with no gender returns a string' {
        Get-FakeTitle | Should -Not -BeNullOrEmpty
    }

    It 'Get-FakeTitle male returns male title' {
        1..10 | ForEach-Object { Get-FakeTitle -Gender 'male' } | ForEach-Object {
            $_ | Should -BeIn @('Mr.','Dr.','Prof.','Rev.')
        }
    }

    It 'Get-FakeTitle female returns female title' {
        1..10 | ForEach-Object { Get-FakeTitle -Gender 'female' } | ForEach-Object {
            $_ | Should -BeIn @('Ms.','Mrs.','Dr.','Prof.','Miss')
        }
    }

    It 'Get-FakeFirstNameMale returns a string' {
        Get-FakeFirstNameMale | Should -Not -BeNullOrEmpty
    }

    It 'Get-FakeFirstNameFemale returns a string' {
        Get-FakeFirstNameFemale | Should -Not -BeNullOrEmpty
    }

    It 'Get-FakeFirstName with no gender returns a string' {
        Get-FakeFirstName | Should -Not -BeNullOrEmpty
    }

    It 'Get-FakeFirstName with gender male returns from male list' {
        $males = @('James','John','Robert','Michael','William','David','Richard','Joseph',
            'Thomas','Charles','Christopher','Daniel','Matthew','Anthony','Mark','Donald',
            'Steven','Paul','Andrew','Joshua','Kenneth','Kevin','Brian','George','Timothy',
            'Ronald','Edward','Jason','Jeffrey','Ryan','Jacob','Gary','Nicholas','Eric',
            'Jonathan','Stephen','Larry','Justin','Scott','Brandon','Frank','Benjamin',
            'Gregory','Samuel','Raymond','Patrick','Alexander','Jack','Dennis','Jerry')
        1..10 | ForEach-Object { Get-FakeFirstName -Gender 'male' } | ForEach-Object {
            $_ | Should -BeIn $males
        }
    }

    It 'Get-FakeLastName returns a string' {
        Get-FakeLastName | Should -Not -BeNullOrEmpty
    }

    It 'Get-FakeNameSuffix returns a suffix' {
        Get-FakeNameSuffix | Should -BeIn @('Jr.','Sr.','I','II','III','IV','V','DVM','DDS','PhD','MD')
    }

    It 'Get-FakeName returns a non-empty string' {
        Get-FakeName | Should -Not -BeNullOrEmpty
    }

    It 'Get-FakeName with gender male does not throw' {
        { Get-FakeName -Gender 'male' } | Should -Not -Throw
    }

    It 'Get-FakeName with gender female does not throw' {
        { Get-FakeName -Gender 'female' } | Should -Not -Throw
    }
}

# ═══════════════════════════════════════════════════════════════════════════════
Describe 'Address' {

    BeforeAll { New-Faker -Seed 4 }

    It 'Get-FakeCityPrefix returns a prefix' {
        Get-FakeCityPrefix | Should -Not -BeNullOrEmpty
    }

    It 'Get-FakeCitySuffix returns a suffix' {
        Get-FakeCitySuffix | Should -Not -BeNullOrEmpty
    }

    It 'Get-FakeCity returns a string' {
        Get-FakeCity | Should -Not -BeNullOrEmpty
    }

    It 'Get-FakeState returns a US state name' {
        $state = Get-FakeState
        $state | Should -Not -BeNullOrEmpty
        $state | Should -BeOfType [string]
    }

    It 'Get-FakeStateAbbr returns a 2-letter abbreviation' {
        Get-FakeStateAbbr | Should -Match '^[A-Z]{2}$'
    }

    It 'Get-FakeCountry returns a country name' {
        Get-FakeCountry | Should -Not -BeNullOrEmpty
    }

    It 'Get-FakeBuildingNumber returns a numeric string' {
        Get-FakeBuildingNumber | Should -Match '^\d+$'
    }

    It 'Get-FakeStreetName returns a string' {
        Get-FakeStreetName | Should -Not -BeNullOrEmpty
    }

    It 'Get-FakeSecondaryAddress returns Suite or Apt' {
        Get-FakeSecondaryAddress | Should -Match '^(Suite|Apt\.) \d+$'
    }

    It 'Get-FakeStreetAddress returns a string' {
        Get-FakeStreetAddress | Should -Not -BeNullOrEmpty
    }

    It 'Get-FakePostcode returns a valid US zip format' {
        Get-FakePostcode | Should -Match '^\d{5}(-\d{4})?$'
    }

    It 'Get-FakeAddress returns a formatted address' {
        $addr = Get-FakeAddress
        $addr | Should -Not -BeNullOrEmpty
        $addr | Should -Match ','
    }

    It 'Get-FakeLatitude is in -90..90' {
        1..10 | ForEach-Object { Get-FakeLatitude } | ForEach-Object {
            $_ | Should -BeGreaterOrEqual -90
            $_ | Should -BeLessOrEqual 90
        }
    }

    It 'Get-FakeLatitude respects custom min/max' {
        1..10 | ForEach-Object { Get-FakeLatitude -Min 40 -Max 50 } | ForEach-Object {
            $_ | Should -BeGreaterOrEqual 40
            $_ | Should -BeLessOrEqual 50
        }
    }

    It 'Get-FakeLongitude is in -180..180' {
        1..10 | ForEach-Object { Get-FakeLongitude } | ForEach-Object {
            $_ | Should -BeGreaterOrEqual -180
            $_ | Should -BeLessOrEqual 180
        }
    }

    It 'Get-FakeLongitude respects custom min/max' {
        1..10 | ForEach-Object { Get-FakeLongitude -Min 0 -Max 10 } | ForEach-Object {
            $_ | Should -BeGreaterOrEqual 0
            $_ | Should -BeLessOrEqual 10
        }
    }
}

# ═══════════════════════════════════════════════════════════════════════════════
Describe 'PhoneNumber' {

    BeforeAll { New-Faker -Seed 5 }

    It 'Get-FakePhoneNumber returns digits and separators' {
        Get-FakePhoneNumber | Should -Match '[\d\s\-\.\(\)x]+'
    }

    It 'Get-FakeTollFreePhoneNumber starts with toll-free area code' {
        Get-FakeTollFreePhoneNumber | Should -Match '^\((800|888|877|866|855|844|833)\)'
    }

    It 'Get-FakeE164PhoneNumber starts with +' {
        Get-FakeE164PhoneNumber | Should -Match '^\+'
    }
}

# ═══════════════════════════════════════════════════════════════════════════════
Describe 'Company' {

    BeforeAll { New-Faker -Seed 6 }

    It 'Get-FakeCompanySuffix returns a known suffix' {
        Get-FakeCompanySuffix | Should -BeIn @('LLC','Inc.','Ltd.','Corp.','and Sons','Group','Partners','Associates')
    }

    It 'Get-FakeCompany returns a non-empty string' {
        Get-FakeCompany | Should -Not -BeNullOrEmpty
    }

    It 'Get-FakeCatchPhrase returns a non-empty string' {
        Get-FakeCatchPhrase | Should -Not -BeNullOrEmpty
    }

    It 'Get-FakeBS returns a non-empty string' {
        Get-FakeBS | Should -Not -BeNullOrEmpty
    }

    It 'Get-FakeJobTitle returns a non-empty string' {
        Get-FakeJobTitle | Should -Not -BeNullOrEmpty
    }
}

# ═══════════════════════════════════════════════════════════════════════════════
Describe 'Internet' {

    BeforeAll { New-Faker -Seed 7 }

    It 'Get-FakeTld returns a common TLD' {
        Get-FakeTld | Should -BeIn @('com','net','org','info','biz','io','co','dev','app','me','us','uk')
    }

    It 'Get-FakeDomainWord returns a string' {
        Get-FakeDomainWord | Should -Not -BeNullOrEmpty
    }

    It 'Get-FakeDomainName contains a dot' {
        Get-FakeDomainName | Should -Match '\.'
    }

    It 'Get-FakeUserName is non-empty and lowercase-ish' {
        $u = Get-FakeUserName
        $u | Should -Not -BeNullOrEmpty
    }

    It 'Get-FakeEmail contains @ and .' {
        $e = Get-FakeEmail
        $e | Should -Match '@'
        $e | Should -Match '\.'
    }

    It 'Get-FakeSafeEmail uses example domain' {
        Get-FakeSafeEmail | Should -Match '@example\.(com|org|net)$'
    }

    It 'Get-FakeFreeEmail uses free provider' {
        $e = Get-FakeFreeEmail
        $e | Should -Match '@(gmail|yahoo|hotmail|outlook|aol|icloud)\.com$'
    }

    It 'Get-FakeCompanyEmail contains @ and .' {
        Get-FakeCompanyEmail | Should -Match '@.+\..+'
    }

    It 'Get-FakePassword is at least 8 chars' {
        Get-FakePassword | Should -Not -BeNullOrEmpty
        (Get-FakePassword).Length | Should -BeGreaterOrEqual 8
    }

    It 'Get-FakePassword respects custom min/max' {
        $p = Get-FakePassword -MinLength 12 -MaxLength 12
        $p.Length | Should -Be 12
    }

    It 'Get-FakeUrl starts with http' {
        Get-FakeUrl | Should -Match '^https?://'
    }

    It 'Get-FakeSlug contains only lowercase and dashes' {
        Get-FakeSlug | Should -Match '^[a-z][a-z\-]+[a-z]$'
    }

    It 'Get-FakeIPv4 matches IPv4 pattern' {
        Get-FakeIPv4 | Should -Match '^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$'
    }

    It 'Get-FakeLocalIPv4 starts with 10.' {
        Get-FakeLocalIPv4 | Should -Match '^10\.'
    }

    It 'Get-FakeIPv6 contains colons' {
        Get-FakeIPv6 | Should -Match '^[0-9a-f]{4}(:[0-9a-f]{4}){7}$'
    }

    It 'Get-FakeMacAddress matches MAC pattern' {
        Get-FakeMacAddress | Should -Match '^([0-9A-F]{2}:){5}[0-9A-F]{2}$'
    }
}

# ═══════════════════════════════════════════════════════════════════════════════
Describe 'DateTime' {

    BeforeAll { New-Faker -Seed 8 }

    It 'Get-FakeUnixTime returns a positive long' {
        $u = Get-FakeUnixTime
        $u | Should -BeGreaterOrEqual 0
    }

    It 'Get-FakeUnixTime respects Max' {
        $max = [datetime]::new(2000,1,1)
        $u = Get-FakeUnixTime -Max $max
        $u | Should -BeLessOrEqual 946684800  # epoch seconds for 2000-01-01
    }

    It 'Get-FakeDateTime returns a DateTime' {
        Get-FakeDateTime | Should -BeOfType [datetime]
    }

    It 'Get-FakeDateTime is not in the future by default' {
        (Get-FakeDateTime) | Should -BeLessOrEqual ([datetime]::Now)
    }

    It 'Get-FakeDateTimeAD returns a DateTime' {
        Get-FakeDateTimeAD | Should -BeOfType [datetime]
    }

    It 'Get-FakeISO8601 matches ISO format' {
        Get-FakeISO8601 | Should -Match '^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}'
    }

    It 'Get-FakeDate returns a formatted string' {
        Get-FakeDate | Should -Match '^\d{4}-\d{2}-\d{2}$'
    }

    It 'Get-FakeDate with custom format works' {
        Get-FakeDate -Format 'MM/dd/yyyy' | Should -Match '^\d{2}/\d{2}/\d{4}$'
    }

    It 'Get-FakeTime returns HH:mm:ss' {
        Get-FakeTime | Should -Match '^\d{2}:\d{2}:\d{2}$'
    }

    It 'Get-FakeDateTimeBetween returns DateTime in range' {
        $start = [datetime]::new(2020,1,1)
        $end   = [datetime]::new(2021,1,1)
        $d = Get-FakeDateTimeBetween -StartDate $start -EndDate $end
        $d | Should -BeGreaterOrEqual $start
        $d | Should -BeLessOrEqual $end
    }

    It 'Get-FakeDateTimeThisCentury is >= 2000' {
        (Get-FakeDateTimeThisCentury).Year | Should -BeGreaterOrEqual 2000
    }

    It 'Get-FakeDateTimeThisDecade is in current decade' {
        $decade = [datetime]::Now.Year - ([datetime]::Now.Year % 10)
        (Get-FakeDateTimeThisDecade).Year | Should -BeGreaterOrEqual $decade
    }

    It 'Get-FakeDateTimeThisYear is in current year' {
        (Get-FakeDateTimeThisYear).Year | Should -Be ([datetime]::Now.Year)
    }

    It 'Get-FakeDateTimeThisMonth is in current month' {
        $d = Get-FakeDateTimeThisMonth
        $d.Year  | Should -Be ([datetime]::Now.Year)
        $d.Month | Should -Be ([datetime]::Now.Month)
    }

    It 'Get-FakeAmPm returns am or pm' {
        Get-FakeAmPm | Should -BeIn @('am','pm')
    }

    It 'Get-FakeDayOfMonth returns 01-31' {
        Get-FakeDayOfMonth | Should -Match '^(0[1-9]|[12]\d|3[01])$'
    }

    It 'Get-FakeDayOfWeek returns a day name' {
        Get-FakeDayOfWeek | Should -BeIn @('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday')
    }

    It 'Get-FakeMonth returns 01-12' {
        Get-FakeMonth | Should -Match '^(0[1-9]|1[0-2])$'
    }

    It 'Get-FakeMonthName returns a month name' {
        Get-FakeMonthName | Should -BeIn @('January','February','March','April','May','June',
            'July','August','September','October','November','December')
    }

    It 'Get-FakeYear returns a 4-digit year' {
        Get-FakeYear | Should -Match '^\d{4}$'
    }

    It 'Get-FakeCentury returns a Roman numeral' {
        Get-FakeCentury | Should -Match '^[IVX]+'
    }

    It 'Get-FakeTimezone returns a known timezone string' {
        Get-FakeTimezone | Should -Match '/'
    }
}

# ═══════════════════════════════════════════════════════════════════════════════
Describe 'Payment' {

    BeforeAll { New-Faker -Seed 9 }

    It 'Get-FakeCreditCardType returns a known type' {
        Get-FakeCreditCardType | Should -BeIn @('Visa','MasterCard','American Express','Discover','JCB','Diners Club')
    }

    It 'Get-FakeCreditCardNumber returns digits only' {
        Get-FakeCreditCardNumber | Should -Match '^\d+$'
    }

    It 'Get-FakeCreditCardNumber for Visa starts with 4 and is 16 digits' {
        $n = Get-FakeCreditCardNumber -Type 'Visa'
        $n | Should -Match '^4\d{15}$'
    }

    It 'Get-FakeCreditCardNumber for AmEx is 15 digits starting 34 or 37' {
        $n = Get-FakeCreditCardNumber -Type 'American Express'
        $n | Should -Match '^(34|37)\d{13}$'
    }

    It 'Get-FakeCreditCardNumber passes Luhn check' {
        $n = Get-FakeCreditCardNumber -Type 'Visa'
        $digits = $n.ToCharArray() | ForEach-Object { [int]::Parse($_) }
        $sum = 0; $alt = $false
        for ($i = $digits.Count - 1; $i -ge 0; $i--) {
            $d = $digits[$i]
            if ($alt) { $d *= 2; if ($d -gt 9) { $d -= 9 } }
            $sum += $d; $alt = !$alt
        }
        $sum % 10 | Should -Be 0
    }

    It 'Get-FakeCreditCardExpirationDate returns a future DateTime' {
        (Get-FakeCreditCardExpirationDate) | Should -BeGreaterThan ([datetime]::Now)
    }

    It 'Get-FakeCreditCardDetails returns hashtable with required keys' {
        $d = Get-FakeCreditCardDetails
        $d.Keys | Should -Contain 'Type'
        $d.Keys | Should -Contain 'Number'
        $d.Keys | Should -Contain 'Name'
        $d.Keys | Should -Contain 'Expiry'
    }

    It 'Get-FakeIban returns string starting with 2 letters and 2 digits' {
        Get-FakeIban | Should -Match '^[A-Z]{2}\d{2}'
    }

    It 'Get-FakeIban with CountryCode uses that code' {
        Get-FakeIban -CountryCode 'DE' | Should -Match '^DE\d'
    }

    It 'Get-FakeSwiftBic returns 8-11 character string' {
        $s = Get-FakeSwiftBic
        $s.Length | Should -BeGreaterOrEqual 8
        $s.Length | Should -BeLessOrEqual 11
    }
}

# ═══════════════════════════════════════════════════════════════════════════════
Describe 'Color' {

    BeforeAll { New-Faker -Seed 10 }

    It 'Get-FakeHexColor returns #RRGGBB format' {
        Get-FakeHexColor | Should -Match '^#[0-9a-f]{6}$'
    }

    It 'Get-FakeRgbColor returns R,G,B string' {
        Get-FakeRgbColor | Should -Match '^\d{1,3},\d{1,3},\d{1,3}$'
    }

    It 'Get-FakeRgbColorAsArray returns 3-element int array' {
        $a = Get-FakeRgbColorAsArray
        $a.Count | Should -Be 3
        $a | ForEach-Object { $_ | Should -BeGreaterOrEqual 0; $_ | Should -BeLessOrEqual 255 }
    }

    It 'Get-FakeRgbCssColor returns rgb(...) string' {
        Get-FakeRgbCssColor | Should -Match '^rgb\(\d{1,3},\d{1,3},\d{1,3}\)$'
    }

    It 'Get-FakeSafeColorName returns a CSS safe name' {
        Get-FakeSafeColorName | Should -BeIn @('aqua','black','blue','fuchsia','gray','green',
            'lime','maroon','navy','olive','orange','purple','red','silver','teal','white','yellow')
    }

    It 'Get-FakeColorName returns a string' {
        Get-FakeColorName | Should -Not -BeNullOrEmpty
    }

    It 'Get-FakeHslColor returns H,S,L string' {
        Get-FakeHslColor | Should -Match '^\d{1,3},\d{1,3},\d{1,3}$'
    }

    It 'Get-FakeHslColorAsArray returns 3-element array with valid ranges' {
        $a = Get-FakeHslColorAsArray
        $a.Count | Should -Be 3
        $a[0] | Should -BeGreaterOrEqual 0; $a[0] | Should -BeLessOrEqual 360
        $a[1] | Should -BeGreaterOrEqual 0; $a[1] | Should -BeLessOrEqual 100
        $a[2] | Should -BeGreaterOrEqual 0; $a[2] | Should -BeLessOrEqual 100
    }
}

# ═══════════════════════════════════════════════════════════════════════════════
Describe 'File' {

    BeforeAll { New-Faker -Seed 11 }

    It 'Get-FakeFileExtension returns a string without dot' {
        $e = Get-FakeFileExtension
        $e | Should -Not -BeNullOrEmpty
        $e | Should -Not -Match '^\.'  # no leading dot
    }

    It 'Get-FakeMimeType returns a valid MIME type' {
        Get-FakeMimeType | Should -Match '^[a-z]+/[a-z0-9\.\-\+]+'
    }
}

# ═══════════════════════════════════════════════════════════════════════════════
Describe 'UUID' {

    BeforeAll { New-Faker -Seed 12 }

    It 'Get-FakeUuid returns RFC 4122 format' {
        Get-FakeUuid | Should -Match '^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$'
    }

    It 'Get-FakeUuid generates unique values' {
        $uuids = 1..20 | ForEach-Object { Get-FakeUuid }
        ($uuids | Sort-Object -Unique).Count | Should -Be 20
    }
}

# ═══════════════════════════════════════════════════════════════════════════════
Describe 'Barcode' {

    BeforeAll { New-Faker -Seed 13 }

    It 'Get-FakeEan13 returns 13 digits' {
        Get-FakeEan13 | Should -Match '^\d{13}$'
    }

    It 'Get-FakeEan13 passes EAN checksum' {
        $code = Get-FakeEan13
        $digits = $code.ToCharArray() | ForEach-Object { [int]::Parse($_) }
        $sum = 0
        for ($i = 0; $i -lt 13; $i++) {
            $w = if ($i % 2 -eq 0) { 1 } else { 3 }
            $sum += $digits[$i] * $w
        }
        $sum % 10 | Should -Be 0
    }

    It 'Get-FakeEan8 returns 8 digits' {
        Get-FakeEan8 | Should -Match '^\d{8}$'
    }

    It 'Get-FakeEan8 passes EAN checksum' {
        $code = Get-FakeEan8
        $digits = $code.ToCharArray() | ForEach-Object { [int]::Parse($_) }
        $sum = 0
        for ($i = 0; $i -lt 8; $i++) {
            $w = if ($i % 2 -eq 0) { 1 } else { 3 }
            $sum += $digits[$i] * $w
        }
        $sum % 10 | Should -Be 0
    }

    It 'Get-FakeIsbn13 starts with 978 or 979 and is 13 digits' {
        Get-FakeIsbn13 | Should -Match '^(978|979)\d{10}$'
    }

    It 'Get-FakeIsbn10 is 9 digits plus check char' {
        Get-FakeIsbn10 | Should -Match '^\d{9}[\dX]$'
    }
}

# ═══════════════════════════════════════════════════════════════════════════════
Describe 'Miscellaneous' {

    BeforeAll { New-Faker -Seed 14 }

    It 'Get-FakeBoolean returns a bool' {
        Get-FakeBoolean | Should -BeOfType [bool]
    }

    It 'Get-FakeBoolean with ChanceOfTrue=100 always returns true' {
        1..10 | ForEach-Object { Get-FakeBoolean -ChanceOfTrue 100 } | ForEach-Object { $_ | Should -Be $true }
    }

    It 'Get-FakeBoolean with ChanceOfTrue=0 always returns false' {
        1..10 | ForEach-Object { Get-FakeBoolean -ChanceOfTrue 0 } | ForEach-Object { $_ | Should -Be $false }
    }

    It 'Get-FakeMd5 returns 32 hex chars' {
        Get-FakeMd5 | Should -Match '^[0-9a-f]{32}$'
    }

    It 'Get-FakeSha1 returns 40 hex chars' {
        Get-FakeSha1 | Should -Match '^[0-9a-f]{40}$'
    }

    It 'Get-FakeSha256 returns 64 hex chars' {
        Get-FakeSha256 | Should -Match '^[0-9a-f]{64}$'
    }

    It 'Get-FakeLocale returns a locale string' {
        Get-FakeLocale | Should -Match '^[a-z]{2}_[A-Z]{2}$'
    }

    It 'Get-FakeCountryCode returns a 2-letter code' {
        Get-FakeCountryCode | Should -Match '^[A-Z]{2}$'
    }

    It 'Get-FakeLanguageCode returns a 2-letter code' {
        Get-FakeLanguageCode | Should -Match '^[a-z]{2}$'
    }

    It 'Get-FakeCurrencyCode returns a 3-letter code' {
        Get-FakeCurrencyCode | Should -Match '^[A-Z]{3}$'
    }

    It 'Get-FakeEmoji returns a non-empty string' {
        Get-FakeEmoji | Should -Not -BeNullOrEmpty
    }
}

# ═══════════════════════════════════════════════════════════════════════════════
Describe 'UserAgent' {

    BeforeAll { New-Faker -Seed 15 }

    It 'Get-FakeChromeAgent contains Chrome' {
        Get-FakeChromeAgent | Should -Match 'Chrome'
    }

    It 'Get-FakeFirefoxAgent contains Firefox' {
        Get-FakeFirefoxAgent | Should -Match 'Firefox'
    }

    It 'Get-FakeSafariAgent contains Safari' {
        Get-FakeSafariAgent | Should -Match 'Safari'
    }

    It 'Get-FakeOperaAgent contains Opera' {
        Get-FakeOperaAgent | Should -Match 'Opera'
    }

    It 'Get-FakeIEAgent contains MSIE or Trident' {
        Get-FakeIEAgent | Should -Match '(MSIE|Trident)'
    }

    It 'Get-FakeUserAgent returns a non-empty string' {
        Get-FakeUserAgent | Should -Not -BeNullOrEmpty
    }

    It 'Get-FakeUserAgent returns Mozilla-prefixed string' {
        Get-FakeUserAgent | Should -Match '^Mozilla/'
    }
}

# ═══════════════════════════════════════════════════════════════════════════════
Describe 'Biased' {

    BeforeAll { New-Faker -Seed 16 }

    It 'Get-FakeBiasedNumberBetween returns value in range' {
        1..20 | ForEach-Object { Get-FakeBiasedNumberBetween -Min 10 -Max 20 } | ForEach-Object {
            $_ | Should -BeGreaterOrEqual 10
            $_ | Should -BeLessOrEqual 20
        }
    }

    It 'Get-FakeBiasedNumberBetween with sqrt skews toward max' {
        $vals = 1..100 | ForEach-Object { Get-FakeBiasedNumberBetween -Min 0 -Max 100 -Function 'sqrt' }
        $avg = ($vals | Measure-Object -Average).Average
        $avg | Should -BeGreaterThan 50  # sqrt bias toward max
    }

    It 'Get-FakeBiasedNumberBetween with log skews toward min' {
        $vals = 1..100 | ForEach-Object { Get-FakeBiasedNumberBetween -Min 0 -Max 100 -Function 'log' }
        $avg = ($vals | Measure-Object -Average).Average
        $avg | Should -BeLessThan 50
    }

    It 'Get-FakeBiasedNumberBetween with unknown function returns in range' {
        $v = Get-FakeBiasedNumberBetween -Min 5 -Max 10 -Function 'linear'
        $v | Should -BeGreaterOrEqual 5
        $v | Should -BeLessOrEqual 10
    }
}

# ═══════════════════════════════════════════════════════════════════════════════
Describe 'HtmlLorem' {

    BeforeAll { New-Faker -Seed 17 }

    It 'Get-FakeHtmlLorem returns valid HTML string' {
        $html = Get-FakeHtmlLorem
        $html | Should -Match '<html>'
        $html | Should -Match '</html>'
    }

    It 'Get-FakeHtmlLorem contains head and body' {
        $html = Get-FakeHtmlLorem
        $html | Should -Match '<head>'
        $html | Should -Match '<body>'
    }

    It 'Get-FakeHtmlLorem with custom depth does not throw' {
        { Get-FakeHtmlLorem -MaxDepth 1 -MaxWidth 2 } | Should -Not -Throw
    }

    It 'Get-FakeHtmlLorem with MaxDepth=0 returns minimal HTML' {
        $html = Get-FakeHtmlLorem -MaxDepth 0
        $html | Should -Match '<html>'
    }
}

# ═══════════════════════════════════════════════════════════════════════════════
Describe 'RealText' {

    BeforeAll { New-Faker -Seed 18 }

    It 'Get-FakeRealText returns a string' {
        Get-FakeRealText | Should -Not -BeNullOrEmpty
    }

    It 'Get-FakeRealText respects MaxNbChars' {
        1..5 | ForEach-Object { Get-FakeRealText -MaxNbChars 100 } |
            ForEach-Object { $_.Length | Should -BeLessOrEqual 100 }
    }

    It 'Get-FakeRealText starts with uppercase' {
        Get-FakeRealText | Should -Match '^[A-Z]'
    }

    It 'Get-FakeRealText with IndexSize=1 does not throw' {
        { Get-FakeRealText -MaxNbChars 50 -IndexSize 1 } | Should -Not -Throw
    }
}

# ═══════════════════════════════════════════════════════════════════════════════
Describe 'Modifiers – unique()' {

    BeforeAll { New-Faker -Seed 19 }

    It 'Get-FakeUnique returns a value' {
        $val = Get-FakeUnique -Generator { Get-FakeRandomDigit }
        $val | Should -Not -BeNullOrEmpty -Because 'should produce a digit'
    }

    It 'Get-FakeUnique never repeats values for same generator' {
        $seen = @{}
        0..8 | ForEach-Object {
            $v = Get-FakeUnique -Generator { Get-FakeRandomDigit }
            $seen.ContainsKey($v.ToString()) | Should -Be $false
            $seen[$v.ToString()] = $true
        }
    }

    It 'Get-FakeUnique throws OverflowException when pool exhausted' {
        Reset-FakeUnique
        { 0..10 | ForEach-Object { Get-FakeUnique -Generator { Get-FakeRandomDigit } -MaxAttempts 5000 } } |
            Should -Throw
    }

    It 'Reset-FakeUnique clears the cache' {
        # fill digits 0-8
        try { 0..10 | ForEach-Object { Get-FakeUnique -Generator { Get-FakeRandomDigit } -MaxAttempts 5000 } } catch {}
        Reset-FakeUnique
        # should now succeed again
        { Get-FakeUnique -Generator { Get-FakeRandomDigit } } | Should -Not -Throw
    }
}

# ═══════════════════════════════════════════════════════════════════════════════
Describe 'Modifiers – optional()' {

    BeforeAll { New-Faker -Seed 20 }

    It 'Get-FakeOptional with Weight=1 always returns generator value' {
        1..10 | ForEach-Object { Get-FakeOptional -Generator { 42 } -Weight 1 } |
            ForEach-Object { $_ | Should -Be 42 }
    }

    It 'Get-FakeOptional with Weight=0 always returns default' {
        1..10 | ForEach-Object { Get-FakeOptional -Generator { 42 } -Weight 0 } |
            ForEach-Object { $_ | Should -BeNullOrEmpty }
    }

    It 'Get-FakeOptional with custom default returns it sometimes' {
        $results = 1..50 | ForEach-Object { Get-FakeOptional -Generator { 99 } -Weight 0.5 -Default 'N/A' }
        $results | Should -Contain 'N/A'
        $results | Should -Contain 99
    }

    It 'Get-FakeOptional default weight is 0.5 (roughly)' {
        New-Faker -Seed 42
        $nulls = (1..100 | ForEach-Object { Get-FakeOptional -Generator { 1 } } | Where-Object { $null -eq $_ }).Count
        $nulls | Should -BeGreaterThan 20
        $nulls | Should -BeLessThan 80
    }
}

# ═══════════════════════════════════════════════════════════════════════════════
Describe 'Modifiers – valid()' {

    BeforeAll { New-Faker -Seed 21 }

    It 'Get-FakeValid only returns values passing the validator' {
        1..20 | ForEach-Object {
            Get-FakeValid -Generator { Get-FakeRandomDigit } -Validator { param($n) $n % 2 -eq 0 }
        } | ForEach-Object { $_ % 2 | Should -Be 0 }
    }

    It 'Get-FakeValid throws OverflowException when no valid value exists' {
        {
            Get-FakeValid -Generator { Get-FakeRandomElement @(1,3,5) } -Validator { param($n) $n % 2 -eq 0 } -MaxAttempts 20
        } | Should -Throw
    }

    It 'Get-FakeValid returns string values correctly' {
        $val = Get-FakeValid -Generator { Get-FakeTld } -Validator { param($s) $s -eq 'com' } -MaxAttempts 5000
        $val | Should -Be 'com'
    }
}

# ═══════════════════════════════════════════════════════════════════════════════
Describe 'Seeding / Reproducibility' {

    It 'Same seed produces same sequence of names' {
        New-Faker -Seed 777
        $seq1 = 1..5 | ForEach-Object { Get-FakeName }
        New-Faker -Seed 777
        $seq2 = 1..5 | ForEach-Object { Get-FakeName }
        $seq1 | Should -Be $seq2
    }

    It 'Same seed produces same sequence of floats' {
        New-Faker -Seed 888
        $seq1 = 1..5 | ForEach-Object { Get-FakeRandomFloat -Min 0 -Max 1 }
        New-Faker -Seed 888
        $seq2 = 1..5 | ForEach-Object { Get-FakeRandomFloat -Min 0 -Max 1 }
        $seq1 | Should -Be $seq2
    }

    It 'Different seeds produce different sequences' {
        New-Faker -Seed 1
        $seq1 = 1..5 | ForEach-Object { Get-FakeRandomDigit }
        New-Faker -Seed 2
        $seq2 = 1..5 | ForEach-Object { Get-FakeRandomDigit }
        ($seq1 -join '') | Should -Not -Be ($seq2 -join '')
    }
}

# ═══════════════════════════════════════════════════════════════════════════════
Describe 'Integration – combined data generation' {

    BeforeAll { New-Faker -Seed 100 }

    It 'Can generate a contact record' {
        $contact = @{
            Name    = Get-FakeName
            Email   = Get-FakeEmail
            Phone   = Get-FakePhoneNumber
            Address = Get-FakeAddress
            Company = Get-FakeCompany
        }
        $contact.Name    | Should -Not -BeNullOrEmpty
        $contact.Email   | Should -Match '@'
        $contact.Phone   | Should -Match '\d'
        $contact.Address | Should -Match ','
        $contact.Company | Should -Not -BeNullOrEmpty
    }

    It 'Can generate 10 unique email addresses' {
        Reset-FakeUnique
        $emails = 1..10 | ForEach-Object { Get-FakeUnique -Generator { Get-FakeEmail } }
        ($emails | Sort-Object -Unique).Count | Should -Be 10
    }

    It 'Can generate a payment record with valid card' {
        $card = Get-FakeCreditCardDetails
        $card.Type   | Should -Not -BeNullOrEmpty
        $card.Number | Should -Match '^\d+'
        $card.Expiry | Should -Match '^\d{2}/\d{2}$'
    }

    It 'Can build XML-like content using multiple providers' {
        $xml = "<contact firstName=`"$(Get-FakeFirstName)`" lastName=`"$(Get-FakeLastName)`" email=`"$(Get-FakeEmail)`">"
        $xml | Should -Match 'firstName="[A-Za-z]+'
        $xml | Should -Match 'email="[^"]+@[^"]+"'
    }

    It 'optional() and valid() can be combined' {
        $result = Get-FakeOptional -Generator {
            Get-FakeValid -Generator { Get-FakeRandomDigit } -Validator { param($n) $n -gt 5 }
        } -Weight 0.8
        if ($null -ne $result) { $result | Should -BeGreaterThan 5 }
        $true | Should -Be $true
    }
}
