@{
    ModuleVersion     = '1.0.0'
    GUID              = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'
    Author            = 'PSFaker Contributors'
    Description       = 'A PowerShell port of fzaninotto/Faker – generates realistic fake data for testing, seeding, and anonymisation.'
    PowerShellVersion = '5.1'
    RootModule        = 'PSFaker.psm1'
    FunctionsToExport = @(
        # Factory
        'New-Faker'
        # Base
        'Get-FakeRandomDigit','Get-FakeRandomDigitNotNull','Get-FakeRandomDigitNot',
        'Get-FakeRandomNumber','Get-FakeRandomFloat','Get-FakeNumberBetween',
        'Get-FakeRandomLetter','Get-FakeRandomElement','Get-FakeRandomElements',
        'Invoke-FakeShuffle','Format-FakeNumerify','Format-FakeLexify',
        'Format-FakeBothify','Format-FakeAsciify','Format-FakeRegexify',
        # Lorem
        'Get-FakeWord','Get-FakeWords','Get-FakeSentence','Get-FakeSentences',
        'Get-FakeParagraph','Get-FakeParagraphs','Get-FakeText',
        # Person
        'Get-FakeName','Get-FakeFirstName','Get-FakeFirstNameMale',
        'Get-FakeFirstNameFemale','Get-FakeLastName','Get-FakeTitle',
        'Get-FakeTitleMale','Get-FakeTitleFemale','Get-FakeNameSuffix',
        # Address
        'Get-FakeAddress','Get-FakeStreetAddress','Get-FakeStreetName',
        'Get-FakeBuildingNumber','Get-FakeCity','Get-FakeCityPrefix',
        'Get-FakeCitySuffix','Get-FakeState','Get-FakeStateAbbr',
        'Get-FakePostcode','Get-FakeCountry','Get-FakeLatitude','Get-FakeLongitude',
        'Get-FakeSecondaryAddress',
        # Phone
        'Get-FakePhoneNumber','Get-FakeTollFreePhoneNumber','Get-FakeE164PhoneNumber',
        # Company
        'Get-FakeCompany','Get-FakeCompanySuffix','Get-FakeCatchPhrase',
        'Get-FakeBS','Get-FakeJobTitle',
        # Internet
        'Get-FakeEmail','Get-FakeSafeEmail','Get-FakeFreeEmail',
        'Get-FakeCompanyEmail','Get-FakeUserName','Get-FakePassword',
        'Get-FakeDomainName','Get-FakeDomainWord','Get-FakeTld',
        'Get-FakeUrl','Get-FakeSlug','Get-FakeIPv4','Get-FakeLocalIPv4',
        'Get-FakeIPv6','Get-FakeMacAddress',
        # DateTime
        'Get-FakeUnixTime','Get-FakeDateTime','Get-FakeDateTimeAD',
        'Get-FakeISO8601','Get-FakeDate','Get-FakeTime',
        'Get-FakeDateTimeBetween','Get-FakeDateTimeThisCentury',
        'Get-FakeDateTimeThisDecade','Get-FakeDateTimeThisYear',
        'Get-FakeDateTimeThisMonth','Get-FakeAmPm','Get-FakeDayOfMonth',
        'Get-FakeDayOfWeek','Get-FakeMonth','Get-FakeMonthName',
        'Get-FakeYear','Get-FakeCentury','Get-FakeTimezone',
        # Payment
        'Get-FakeCreditCardType','Get-FakeCreditCardNumber',
        'Get-FakeCreditCardExpirationDate','Get-FakeCreditCardDetails',
        'Get-FakeIban','Get-FakeSwiftBic',
        # Color
        'Get-FakeHexColor','Get-FakeRgbColor','Get-FakeRgbColorAsArray',
        'Get-FakeRgbCssColor','Get-FakeSafeColorName','Get-FakeColorName',
        'Get-FakeHslColor','Get-FakeHslColorAsArray',
        # File
        'Get-FakeFileExtension','Get-FakeMimeType',
        # UUID
        'Get-FakeUuid',
        # Barcode
        'Get-FakeEan13','Get-FakeEan8','Get-FakeIsbn13','Get-FakeIsbn10',
        # Miscellaneous
        'Get-FakeBoolean','Get-FakeMd5','Get-FakeSha1','Get-FakeSha256',
        'Get-FakeLocale','Get-FakeCountryCode','Get-FakeLanguageCode',
        'Get-FakeCurrencyCode','Get-FakeEmoji',
        # UserAgent
        'Get-FakeUserAgent','Get-FakeChromeAgent','Get-FakeFirefoxAgent',
        'Get-FakeSafariAgent','Get-FakeOperaAgent','Get-FakeIEAgent',
        # Biased
        'Get-FakeBiasedNumberBetween',
        # HtmlLorem
        'Get-FakeHtmlLorem',
        # RealText
        'Get-FakeRealText',
        # Modifiers
        'Get-FakeUnique','Get-FakeOptional','Get-FakeValid',
        'Reset-FakeUnique'
    )
    PrivateData = @{ PSData = @{ Tags = @('Faker','Testing','DataGeneration','Mock') } }
}
