# PSFaker

A PowerShell port of [fzaninotto/Faker](https://github.com/fzaninotto/Faker) — generates realistic fake data for testing, database seeding, and data anonymisation.

## Installation

```powershell
Import-Module ./PSFaker/PSFaker.psm1
```

## Quick Start

```powershell
# Initialise (optional — seeds the RNG for reproducibility)
New-Faker -Seed 1234

# Generate data
Get-FakeName             # 'Dr. Zane Stroman'
Get-FakeEmail            # 'wade55@wolff.net'
Get-FakeAddress          # '439 Karley Loaf, West Judge, OH 45577'
Get-FakePhoneNumber      # '201-886-0269 x3767'
Get-FakeCompany          # 'Bogan-Treutel'
Get-FakeCreditCardNumber # '4485480221084675'
Get-FakeUuid             # '7e57d004-2b97-4e7a-b45f-5387367791cd'
```

## Providers

| Provider        | Key Functions |
|-----------------|---------------|
| **Base**        | `Get-FakeRandomDigit`, `Get-FakeNumberBetween`, `Format-FakeNumerify`, `Format-FakeRegexify`, … |
| **Lorem**       | `Get-FakeWord`, `Get-FakeSentence`, `Get-FakeParagraph`, `Get-FakeText` |
| **Person**      | `Get-FakeName`, `Get-FakeFirstName`, `Get-FakeLastName`, `Get-FakeTitle` |
| **Address**     | `Get-FakeAddress`, `Get-FakeCity`, `Get-FakeState`, `Get-FakeLatitude` |
| **PhoneNumber** | `Get-FakePhoneNumber`, `Get-FakeTollFreePhoneNumber`, `Get-FakeE164PhoneNumber` |
| **Company**     | `Get-FakeCompany`, `Get-FakeCatchPhrase`, `Get-FakeBS`, `Get-FakeJobTitle` |
| **Internet**    | `Get-FakeEmail`, `Get-FakeUrl`, `Get-FakeIPv4`, `Get-FakeMacAddress` |
| **DateTime**    | `Get-FakeDateTime`, `Get-FakeDate`, `Get-FakeDateTimeBetween` |
| **Payment**     | `Get-FakeCreditCardNumber`, `Get-FakeIban`, `Get-FakeSwiftBic` |
| **Color**       | `Get-FakeHexColor`, `Get-FakeRgbColor`, `Get-FakeColorName` |
| **UUID**        | `Get-FakeUuid` |
| **Barcode**     | `Get-FakeEan13`, `Get-FakeEan8`, `Get-FakeIsbn13`, `Get-FakeIsbn10` |
| **Misc**        | `Get-FakeBoolean`, `Get-FakeMd5`, `Get-FakeSha256`, `Get-FakeEmoji` |
| **UserAgent**   | `Get-FakeUserAgent`, `Get-FakeChromeAgent`, `Get-FakeFirefoxAgent` |
| **Biased**      | `Get-FakeBiasedNumberBetween` |
| **HtmlLorem**   | `Get-FakeHtmlLorem` |
| **RealText**    | `Get-FakeRealText` |

## Modifiers

```powershell
# unique() — never repeats values
0..8 | ForEach-Object { Get-FakeUnique -Generator { Get-FakeRandomDigit } }
# → [4, 1, 8, 5, 0, 2, 6, 9, 7]

# optional() — sometimes returns $null (or a custom default)
Get-FakeOptional -Generator { Get-FakeRandomDigit } -Weight 0.7
# 30% chance of $null

Get-FakeOptional -Generator { Get-FakeWord } -Weight 0.5 -Default 'N/A'

# valid() — only accepts values passing a predicate
Get-FakeValid -Generator { Get-FakeRandomDigit } -Validator { param($n) $n % 2 -eq 0 }
# → always even

# Reset unique cache
Reset-FakeUnique
```

## Seeding

```powershell
New-Faker -Seed 1234
Get-FakeName   # Same result every run with seed 1234
```

## Running Tests

```powershell
Install-Module Pester -Force
Invoke-Pester -Path ./tests/PSFaker.Tests.ps1 -Output Detailed
```

## License

MIT
