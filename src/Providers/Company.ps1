# Providers/PhoneNumber.ps1

$script:_PhoneFormats = @(
    '###-###-####','(###) ###-####','###.###.####',
    '###-###-#### x####','(###) ###-#### x###',
    '1-###-###-####','###-###-####'
)

function Get-FakePhoneNumber {
<#.SYNOPSIS  US phone number.#>
    [CmdletBinding()] param()
    return Format-FakeNumerify (Get-FakeRandomElement $script:_PhoneFormats)
}

function Get-FakeTollFreePhoneNumber {
<#.SYNOPSIS  Toll-free US phone number.#>
    [CmdletBinding()] param()
    $prefix = Get-FakeRandomElement @('800','888','877','866','855','844','833')
    return "(${prefix}) $(Format-FakeNumerify '###-####')"
}

function Get-FakeE164PhoneNumber {
<#.SYNOPSIS  E.164 format phone number.#>
    [CmdletBinding()] param()
    $cc = Get-FakeRandomElement @('+1','+44','+49','+33','+81','+86','+55','+27','+61','+34')
    return "$cc$(Format-FakeNumerify '##########')"
}

# ─── Company ────────────────────────────────────────────────────────────────
$script:_CompanyNames1 = @('Bogan','Treutel','Smith','Johnson','Anderson','Garcia','Miller','Davis',
    'Stroman','Lebsack','Koelpin','Cechtelar','Prosacco','Sipes','Hartmann','Howe')
$script:_CompanyNames2 = @('LLC','Inc','Ltd','Corp','Group','Partners','Solutions','Systems',
    'Technologies','Services','Consulting')
$script:_CompanySuffix = @('LLC','Inc.','Ltd.','Corp.','and Sons','Group','Partners','Associates')
$script:_CatchPhraseAdj= @('Adaptive','Advanced','Ameliorated','Assimilated','Automated','Balanced',
    'Business-focused','Centralized','Cloned','Compatible','Configurable','Cross-group',
    'Cross-platform','Customer-focused','Customizable','Decentralized','De-engineered',
    'Devolved','Digitized','Distributed','Diverse','Down-sized','Enhanced','Enterprise-wide',
    'Ergonomic','Exclusive','Expanded','Extended','Face-to-face','Focused','Front-line',
    'Fully-configurable','Function-based','Fundamental','Future-proofed','Grass-roots',
    'Horizontal','Implemented','Innovative','Integrated','Intuitive','Inverse','Managed',
    'Mandatory','Monitored','Multi-channeled','Multi-lateral','Multi-layered','Multi-tiered',
    'Networked','Object-based','Open-architected','Open-source','Operative','Optimized',
    'Optional','Organic','Organized','Persevering','Persistent','Phased','Polarized',
    'Pre-emptive','Proactive','Profit-focused','Profound','Programmable','Progressive',
    'Public-key','Quality-focused','Reactive','Realigned','Re-contextualized',
    'Re-engineered','Reduced','Reverse-engineered','Right-sized','Robust','Seamless',
    'Secured','Self-enabling','Sharable','Stand-alone','Streamlined','Switchable',
    'Synchronized','Synergistic','Synergized','Team-oriented','Total','Triple-buffered',
    'Universal','Up-sized','Upgradable','User-centric','User-friendly','Versatile',
    'Virtual','Visionary','Vision-oriented')
$script:_CatchPhraseNoun=@('ability','access','adapter','algorithm','alliance','analyzer','application',
    'approach','architecture','archive','artificial intelligence','array','attitude',
    'benchmark','budgetary management','capability','capacity','challenge','circuit',
    'collaboration','complexity','concept','contingency','core competency','customer loyalty',
    'database','data-warehouse','definition','emulation','encoding','encryption',
    'extranet','firmware','flexibility','focus group','forecast','frame','framework',
    'function','functionalities','implementation','info-mediaries','infrastructure',
    'initiative','installation','instruction set','interface','internet solution',
    'intranet','knowledge user','knowledge base','local area network','leverage',
    'matrices','matrix','middleware','migration','model','moderator','monitoring',
    'moratorium','neural-net','open system','orchestration','paradigm','parallelism',
    'policy','portal','pricing structure','process improvement','product','productivity',
    'project','projection','protocol','secured line','service-desk','software',
    'solution','standardization','strategy','structure','success','superstructure',
    'support','synergy','system engine','task-force','throughput','time-frame','toolset',
    'utilization','website','workforce')

function Get-FakeCompanySuffix {
<#.SYNOPSIS  Company suffix.#>
    [CmdletBinding()] param()
    return Get-FakeRandomElement $script:_CompanySuffix
}

function Get-FakeCompany {
<#.SYNOPSIS  Company name.#>
    [CmdletBinding()] param()
    $n1 = Get-FakeRandomElement $script:_CompanyNames1
    $n2 = Get-FakeRandomElement $script:_CompanyNames1
    $r = (_Rng).Next(0,4)
    switch ($r) {
        0 { return "$n1-$n2" }
        1 { return "$n1, $n2 $(Get-FakeCompanySuffix)" }
        2 { return "$n1 $(Get-FakeCompanySuffix)" }
        3 { return "$(Get-FakeLastName) $(Get-FakeCompanySuffix)" }
    }
}

function Get-FakeCatchPhrase {
<#.SYNOPSIS  Corporate catch phrase.#>
    [CmdletBinding()] param()
    $adj  = Get-FakeRandomElement $script:_CatchPhraseAdj
    $noun = Get-FakeRandomElement $script:_CatchPhraseNoun
    return "$adj $noun"
}

$script:_BSVerbs = @('implement','utilize','integrate','streamline','optimize','evolve','transform',
    'embrace','enable','orchestrate','leverage','reinvent','aggregate','architect',
    'enhance','incentivize','morph','empower','envisioneer','monetize','harness',
    'facilitate','seize','disintermediate','synergize','strategize','deploy',
    'brand','grow','target','syndicate','synthesize','deliver','mesh','incubate',
    'engage','maximize','benchmark','expedite','reintermediate','whiteboard',
    'visualize','repurpose','innovate','scale','unleash','drive','extend','engineer',
    'revolutionize','generate','exploit','transition','e-enable','iterate',
    'cultivate','matrix','productize','redefine','recontextualize')
$script:_BSAdj = @('clicks-and-mortar','value-added','vertical','proactive','robust','revolutionary',
    'scalable','leading-edge','innovative','intuitive','strategic','e-business',
    'mission-critical','disruptive','visionary','customized','ubiquitous','plug-and-play',
    'collaborative','compelling','holistic','rich','cross-media','best-of-breed',
    'frictionless','virtual','sticky','one-to-one','24/7','end-to-end','global',
    'B2B','B2C','granular','multi-channel','viral','dynamic','24/365','best-in-class',
    'bleeding-edge','web-enabled','interactive','dot-com','sexy','back-end',
    'real-time','efficient','front-end','distributed','seamless','extensible','turnkey',
    'world-class','open-source','cross-platform','out-of-the-box','enterprise',
    'integrated','impactful','wireless','transparent','next-generation','cutting-edge',
    'user-centric','visionary','customized','ubiquitous','plug-and-play')
$script:_BSNoun = @('synergies','web-readiness','paradigms','markets','partnerships','infrastructures',
    'platforms','initiatives','channels','eyeballs','communities','ROI','solutions',
    'e-tailers','e-services','action-items','portals','niches','technologies',
    'content','vortals','supply-chains','convergence','relationships','architectures',
    'interfaces','e-markets','e-commerce','bandwidth','infomediaries','models',
    'mindshare','deliverables','users','schemas','networks','applications',
    'metrics','e-business','functionalities','experiences','web services','methodologies')

function Get-FakeBS {
<#.SYNOPSIS  Corporate BS buzzword string.#>
    [CmdletBinding()] param()
    $v = Get-FakeRandomElement $script:_BSVerbs
    $a = Get-FakeRandomElement $script:_BSAdj
    $n = Get-FakeRandomElement $script:_BSNoun
    return "$v $a $n"
}

$script:_JobTitles = @(
    'Accountant','Account Executive','Administrative Assistant','Analyst','Architect',
    'Art Director','Auditor','Business Analyst','Cashier','CEO','CFO','COO','CTO',
    'Civil Engineer','Clerk','Consultant','Content Writer','Customer Service Rep',
    'Data Analyst','Data Scientist','Designer','Developer','Director','Doctor',
    'Driver','Economist','Editor','Electrician','Engineer','Executive',
    'Financial Advisor','Graphic Designer','HR Manager','IT Manager','IT Specialist',
    'Journalist','Lawyer','Logistics Manager','Manager','Marketing Manager',
    'Mechanical Engineer','Network Engineer','Nurse','Officer','Operations Manager',
    'Pharmacist','Plumber','Product Manager','Professor','Project Manager',
    'Quality Assurance','Receptionist','Sales Manager','Sales Rep','Security Guard',
    'Software Developer','Software Engineer','Supervisor','Systems Administrator',
    'Teacher','Technician','UI/UX Designer','VP of Engineering','Web Developer'
)

function Get-FakeJobTitle {
<#.SYNOPSIS  Job title.#>
    [CmdletBinding()] param()
    return Get-FakeRandomElement $script:_JobTitles
}
