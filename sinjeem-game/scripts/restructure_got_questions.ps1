# PowerShell script to restructure GOT questions for proper image placement
$questionsFile = "C:\Users\Admin\Desktop\sen-gem\sinjeem-game\public\questions\got.json"

Write-Host "Restructuring Game of Thrones questions..."

# Read current questions
$questions = Get-Content $questionsFile -Raw | ConvertFrom-Json

# Create new question structure
$newQuestions = @()

# Visual identification questions (image in question)
$visualQuestions = @(
    @{
        id = "got-200-001"
        difficulty = 200
        q = "من هذا الشخص؟"
        a = "تيريون لانيستر"
        question_media = @(@{
            type = "image"
            src = "./media/questions/got/tyrion.png"
            alt = "شخصية من صراع العروش"
        })
        answer_media = $null
        tags = @("got", "characters", "visual")
    }
    @{
        id = "got-200-002"
        difficulty = 200
        q = "من هذا الشخص؟"
        a = "نيد ستارك"
        question_media = @(@{
            type = "image"
            src = "./media/questions/got/ned_stark.png"
            alt = "شخصية من صراع العروش"
        })
        answer_media = $null
        tags = @("got", "characters", "visual")
    }
)

# Regular questions (image in answer only)
$regularQuestions = @(
    @{
        id = "got-200-003"
        difficulty = 200
        q = "ما اسم الأسرة الحاكمة في بداية المسلسل؟"
        a = "آل باراثيون"
        question_media = $null
        answer_media = @(@{
            type = "image"
            src = "./media/questions/got/baratheon.png"
            alt = "شعار آل باراثيون"
        })
        tags = @("got", "houses")
    }
    @{
        id = "got-200-004"
        difficulty = 200
        q = "ما اسم العرش الذي يحكم الممالك السبع؟"
        a = "العرش الحديدي"
        question_media = $null
        answer_media = @(@{
            type = "image"
            src = "./media/questions/got/iron_throne.png"
            alt = "العرش الحديدي"
        })
        tags = @("got", "throne")
    }
    @{
        id = "got-200-005"
        difficulty = 200
        q = "ما أسماء التنانين الثلاثة لدينيريس تارغيريان؟"
        a = "دروجون، ريغال، فيسيريون"
        question_media = $null
        answer_media = @(@{
            type = "image"
            src = "./media/questions/got/dragons.png"
            alt = "التنانين الثلاثة"
        })
        tags = @("got", "dragons")
    }
    @{
        id = "got-200-006"
        difficulty = 200
        q = "ما اسم عاصمة الممالك السبع؟"
        a = "كينغز لاندينغ (الهبوط الملكي)"
        question_media = $null
        answer_media = @(@{
            type = "image"
            src = "./media/questions/got/kings_landing.png"
            alt = "كينغز لاندينغ"
        })
        tags = @("got", "cities")
    }
    @{
        id = "got-200-007"
        difficulty = 200
        q = "ما شعار آل ستارك؟"
        a = "الذئب الرمادي"
        question_media = $null
        answer_media = @(@{
            type = "image"
            src = "./media/questions/got/stark_wolf.png"
            alt = "ذئب آل ستارك"
        })
        tags = @("got", "houses")
    }
    @{
        id = "got-200-008"
        difficulty = 200
        q = "ما العبارة الشهيرة لآل ستارك؟"
        a = "الشتاء قادم"
        question_media = $null
        answer_media = @(@{
            type = "image"
            src = "./media/questions/got/winter_coming.png"
            alt = "الشتاء قادم"
        })
        tags = @("got", "houses", "mottos")
    }
    @{
        id = "got-200-009"
        difficulty = 200
        q = "ما اسم قلعة آل ستارك؟"
        a = "وينترفيل"
        question_media = $null
        answer_media = @(@{
            type = "image"
            src = "./media/questions/got/winterfell.png"
            alt = "قلعة وينترفيل"
        })
        tags = @("got", "castles")
    }
    @{
        id = "got-200-010"
        difficulty = 200
        q = "ما اسم السور العملاق في الشمال؟"
        a = "الجدار"
        question_media = $null
        answer_media = @(@{
            type = "image"
            src = "./media/questions/got/the_wall.png"
            alt = "الجدار"
        })
        tags = @("got", "locations")
    }
    @{
        id = "got-200-011"
        difficulty = 200
        q = "ما اسم الملك الليلي؟"
        a = "ملك الليل"
        question_media = $null
        answer_media = @(@{
            type = "image"
            src = "./media/questions/got/night_king.png"
            alt = "ملك الليل"
        })
        tags = @("got", "white_walkers")
    }
    @{
        id = "got-200-012"
        difficulty = 200
        q = "ما اسم سيف جون سنو؟"
        a = "لونغكلو"
        question_media = $null
        answer_media = @(@{
            type = "image"
            src = "./media/questions/got/longclaw.png"
            alt = "سيف لونغكلو"
        })
        tags = @("got", "weapons")
    }
    @{
        id = "got-200-013"
        difficulty = 200
        q = "ما شعار آل لانيستر؟"
        a = "الأسد الذهبي"
        question_media = $null
        answer_media = @(@{
            type = "image"
            src = "./media/questions/got/lannister_lion.png"
            alt = "أسد آل لانيستر"
        })
        tags = @("got", "houses")
    }
    @{
        id = "got-200-014"
        difficulty = 200
        q = "ما العبارة الشهيرة لآل لانيستر؟"
        a = "اسمعني زأر"
        question_media = $null
        answer_media = @(@{
            type = "image"
            src = "./media/questions/got/lannister_lion.png"
            alt = "شعار آل لانيستر"
        })
        tags = @("got", "houses", "mottos")
    }
)

# Medium difficulty questions (400 points)
$mediumQuestions = @(
    @{
        id = "got-400-001"
        difficulty = 400
        q = "ما اسم إله النور الذي تؤمن به ميليساندر؟"
        a = "رهلور"
        question_media = $null
        answer_media = @(@{
            type = "image"
            src = "./media/questions/got/rhllorr.png"
            alt = "رهلور - إله النور"
        })
        tags = @("got", "religion")
    }
    @{
        id = "got-400-002"
        difficulty = 400
        q = "ما اسم المنظمة السرية في براآفوس؟"
        a = "الرجال بلا وجوه"
        question_media = $null
        answer_media = @(@{
            type = "image"
            src = "./media/questions/got/faceless_men.png"
            alt = "الرجال بلا وجوه"
        })
        tags = @("got", "organizations")
    }
    @{
        id = "got-400-003"
        difficulty = 400
        q = "ما اسم القارة الشرقية؟"
        a = "إيسوس"
        question_media = $null
        answer_media = @(@{
            type = "image"
            src = "./media/questions/got/essos_map.png"
            alt = "خريطة إيسوس"
        })
        tags = @("got", "geography")
    }
    @{
        id = "got-400-004"
        difficulty = 400
        q = "ما اسم شعب الفرسان البدو؟"
        a = "الدوثراكي"
        question_media = $null
        answer_media = @(@{
            type = "image"
            src = "./media/questions/got/dothraki_horse.png"
            alt = "فارس دوثراكي"
        })
        tags = @("got", "cultures")
    }
    @{
        id = "got-400-005"
        difficulty = 400
        q = "ما اسم الجيش الذي لا يهزم؟"
        a = "الأنصوليد"
        question_media = $null
        answer_media = @(@{
            type = "image"
            src = "./media/questions/got/unsullied.png"
            alt = "جيش الأنصوليد"
        })
        tags = @("got", "military")
    }
    @{
        id = "got-400-006"
        difficulty = 400
        q = "ما اسم المعدن السحري النادر؟"
        a = "الصلب الفاليري"
        question_media = $null
        answer_media = @(@{
            type = "image"
            src = "./media/questions/got/valyrian_steel.png"
            alt = "الصلب الفاليري"
        })
        tags = @("got", "materials")
    }
    @{
        id = "got-400-007"
        difficulty = 400
        q = "ما اسم الحضارة القديمة المدمرة؟"
        a = "فاليريا القديمة"
        question_media = $null
        answer_media = @(@{
            type = "image"
            src = "./media/questions/got/old_valyria.png"
            alt = "فاليريا القديمة"
        })
        tags = @("got", "history")
    }
    @{
        id = "got-400-008"
        difficulty = 400
        q = "ما اسم سيف بريين أوف تارث؟"
        a = "حافظة القسم"
        question_media = $null
        answer_media = @(@{
            type = "image"
            src = "./media/questions/got/oathkeeper.png"
            alt = "سيف حافظة القسم"
        })
        tags = @("got", "weapons")
    }
    @{
        id = "got-400-009"
        difficulty = 400
        q = "ما اسم المؤسسة المصرفية في براآفوس؟"
        a = "البنك الحديدي"
        question_media = $null
        answer_media = @(@{
            type = "image"
            src = "./media/questions/got/iron_bank.png"
            alt = "البنك الحديدي"
        })
        tags = @("got", "economics")
    }
    @{
        id = "got-400-010"
        difficulty = 400
        q = "ما اسم مدينة ليس الحرة؟"
        a = "ليس"
        question_media = $null
        answer_media = @(@{
            type = "image"
            src = "./media/questions/got/lys.png"
            alt = "مدينة ليس"
        })
        tags = @("got", "cities")
    }
    @{
        id = "got-400-011"
        difficulty = 400
        q = "ما اسم مدينة بينتوس؟"
        a = "بينتوس"
        question_media = $null
        answer_media = @(@{
            type = "image"
            src = "./media/questions/got/pentos.png"
            alt = "مدينة بينتوس"
        })
        tags = @("got", "cities")
    }
    @{
        id = "got-400-012"
        difficulty = 400
        q = "ما اسم السم الذي قتل جوفري؟"
        a = "الخانق"
        question_media = $null
        answer_media = @(@{
            type = "image"
            src = "./media/questions/got/poison.png"
            alt = "سم الخانق"
        })
        tags = @("got", "poisons")
    }
    @{
        id = "got-400-013"
        difficulty = 400
        q = "ما شعار آل تايريل؟"
        a = "الوردة الذهبية"
        question_media = $null
        answer_media = @(@{
            type = "image"
            src = "./media/questions/got/tyrell_rose.png"
            alt = "وردة آل تايريل"
        })
        tags = @("got", "houses")
    }
    @{
        id = "got-400-014"
        difficulty = 400
        q = "ما اسم سيف نيد ستارك العملاق؟"
        a = "آيس"
        question_media = $null
        answer_media = @(@{
            type = "image"
            src = "./media/questions/got/ice_sword.png"
            alt = "سيف آيس"
        })
        tags = @("got", "weapons")
    }
)

# Hard difficulty questions (600 points)
$hardQuestions = @(
    @{
        id = "got-600-001"
        difficulty = 600
        q = "ما اسم النبي المنتظر حسب النبوءة؟"
        a = "آزور آهاي"
        question_media = $null
        answer_media = @(@{
            type = "image"
            src = "./media/questions/got/azor_ahai.png"
            alt = "آزور آهاي"
        })
        tags = @("got", "prophecy")
    }
    @{
        id = "got-600-002"
        difficulty = 600
        q = "ما اسم أكبر تنين في التاريخ؟"
        a = "باليريون الرعب الأسود"
        question_media = $null
        answer_media = @(@{
            type = "image"
            src = "./media/questions/got/balerion.png"
            alt = "باليريون الرعب الأسود"
        })
        tags = @("got", "dragons", "history")
    }
    @{
        id = "got-600-003"
        difficulty = 600
        q = "من هو أول ملك موحد للممالك السبع؟"
        a = "إيجون الفاتح"
        question_media = $null
        answer_media = @(@{
            type = "image"
            src = "./media/questions/got/aegon_conqueror.png"
            alt = "إيجون الفاتح"
        })
        tags = @("got", "history", "kings")
    }
    @{
        id = "got-600-004"
        difficulty = 600
        q = "ما اسم مايستر الحرس الليلي العجوز؟"
        a = "مايستر إيمون"
        question_media = $null
        answer_media = @(@{
            type = "image"
            src = "./media/questions/got/maester_aemon.png"
            alt = "مايستر إيمون"
        })
        tags = @("got", "characters", "nights_watch")
    }
    @{
        id = "got-600-005"
        difficulty = 600
        q = "ما اسم إله الموت عند الرجال بلا وجوه؟"
        a = "الإله متعدد الوجوه"
        question_media = $null
        answer_media = @(@{
            type = "image"
            src = "./media/questions/got/many_faced_god.png"
            alt = "الإله متعدد الوجوه"
        })
        tags = @("got", "religion", "braavos")
    }
    @{
        id = "got-600-006"
        difficulty = 600
        q = "ما اسم كتاب تاريخ الحرس الملكي؟"
        a = "الكتاب الأبيض"
        question_media = $null
        answer_media = @(@{
            type = "image"
            src = "./media/questions/got/white_book.png"
            alt = "الكتاب الأبيض"
        })
        tags = @("got", "kingsguard", "books")
    }
    @{
        id = "got-600-007"
        difficulty = 600
        q = "ما اسم المعركة التي أطاحت بالملك إيريس؟"
        a = "ثورة روبرت"
        question_media = $null
        answer_media = @(@{
            type = "image"
            src = "./media/questions/got/roberts_rebellion.png"
            alt = "ثورة روبرت"
        })
        tags = @("got", "history", "wars")
    }
    @{
        id = "got-600-008"
        difficulty = 600
        q = "ما اسم الغابة التي نصب فيها روب ستارك كمينه؟"
        a = "غابة الهمسات"
        question_media = $null
        answer_media = @(@{
            type = "image"
            src = "./media/questions/got/whispering_woods.png"
            alt = "غابة الهمسات"
        })
        tags = @("got", "battles", "locations")
    }
    @{
        id = "got-600-009"
        difficulty = 600
        q = "ما اسم شجرة عائلة تارغيريان؟"
        a = "شجرة التنين"
        question_media = $null
        answer_media = @(@{
            type = "image"
            src = "./media/questions/got/targaryen_tree.png"
            alt = "شجرة عائلة تارغيريان"
        })
        tags = @("got", "genealogy", "targaryens")
    }
    @{
        id = "got-600-010"
        difficulty = 600
        q = "ما اسم إله الحديد المغرق؟"
        a = "الإله المغرق"
        question_media = $null
        answer_media = @(@{
            type = "image"
            src = "./media/questions/got/drowned_god.png"
            alt = "الإله المغرق"
        })
        tags = @("got", "religion", "iron_islands")
    }
    @{
        id = "got-600-011"
        difficulty = 600
        q = "ما اسم القلعة الرئيسية لآل تولي؟"
        a = "ريفر رن"
        question_media = $null
        answer_media = @(@{
            type = "image"
            src = "./media/questions/got/riverrun.png"
            alt = "قلعة ريفر رن"
        })
        tags = @("got", "castles", "riverlands")
    }
    @{
        id = "got-600-012"
        difficulty = 600
        q = "ما اسم السلسلة العظيمة في معركة بلاك ووتر؟"
        a = "السلسلة العظيمة"
        question_media = $null
        answer_media = @(@{
            type = "image"
            src = "./media/questions/got/great_chain.png"
            alt = "السلسلة العظيمة"
        })
        tags = @("got", "battles", "tactics")
    }
    @{
        id = "got-600-013"
        difficulty = 600
        q = "ما اسم جزر الحديد؟"
        a = "الجزر الحديدية"
        question_media = $null
        answer_media = @(@{
            type = "image"
            src = "./media/questions/got/iron_islands.png"
            alt = "الجزر الحديدية"
        })
        tags = @("got", "geography", "greyjoy")
    }
    @{
        id = "got-600-014"
        difficulty = 600
        q = "ما لقب ساندور كليغين؟"
        a = "الكلب"
        question_media = $null
        answer_media = @(@{
            type = "image"
            src = "./media/questions/got/the_hound.png"
            alt = "الكلب (ساندور كليغين)"
        })
        tags = @("got", "characters", "nicknames")
    }
)

# Combine all questions
$allQuestions = $visualQuestions + $regularQuestions + $mediumQuestions + $hardQuestions

Write-Host "Created $($allQuestions.Count) questions:"
Write-Host "- Visual ID questions: $($visualQuestions.Count)"
Write-Host "- Regular 200pt: $($regularQuestions.Count)"
Write-Host "- Medium 400pt: $($mediumQuestions.Count)"  
Write-Host "- Hard 600pt: $($hardQuestions.Count)"

# Convert to proper JSON format for the Vue app
$jsonQuestions = @()
foreach ($q in $allQuestions) {
    $jsonQ = @{
        id = $q.id
        difficulty = $q.difficulty
        q = $q.q
        a = $q.a
        tags = $q.tags
    }
    
    # Add media to appropriate field
    if ($q.question_media) {
        $jsonQ.media = $q.question_media
    } elseif ($q.answer_media) {
        $jsonQ.media = $q.answer_media
    }
    
    $jsonQuestions += $jsonQ
}

# Save new questions
$jsonContent = $jsonQuestions | ConvertTo-Json -Depth 10
$jsonContent | Out-File -FilePath $questionsFile -Encoding UTF8

Write-Host "`n✅ Successfully updated GOT questions!"
Write-Host "💡 Visual questions show images in the question"
Write-Host "💡 Regular questions show images in the answer"
Write-Host "📁 File saved: $questionsFile"
