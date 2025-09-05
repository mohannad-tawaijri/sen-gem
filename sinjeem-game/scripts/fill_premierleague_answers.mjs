import fs from 'fs';
import path from 'path';

const root = path.resolve(process.cwd(), 'sinjeem-game');
const questionsPath = path.join(root, 'public', 'questions', 'premierleague.json');

function loadJson(p) { return JSON.parse(fs.readFileSync(p, 'utf8')); }
function saveJson(p, data) { fs.writeFileSync(p, JSON.stringify(data, null, 2) + '\n', 'utf8'); }

function answerFor(q) {
  // Stadium names
  if (q.includes('ملعب مانشستر يونايتد')) return 'أولد ترافورد';
  if (q.includes('ملعب توتنهام الجديد')) return 'توتنهام هوتسبر ستاديوم';
  if (q.includes('ملعب ليفربول')) return 'آنفيلد';
  if (q.includes('ملعب ويست هام')) return 'ملعب لندن';
  if (q.includes('ملعب نيوكاسل يونايتد')) return 'سانت جيمس بارك';
  if (q.includes('ملعب إيفرتون')) return 'غوديسون بارك';
  if (q.includes('ملعب ليستر سيتي')) return 'كينغ باور ستاديوم';
  if (q.includes('ملعب أستون فيلا')) return 'فيلا بارك';
  if (q.includes('ملعب بورنموث')) return 'فيتاليتي ستاديوم';
  if (q.includes('ملعب ويست هام السابق')) return 'أبتون بارك (بولين غراوند)';

  // Cities/geography
  if (q.includes('في أي مدينة يقع ملعب الإمارات')) return 'لندن';
  if (q.includes('في أي مدينة يقع ملعب آنفيلد')) return 'ليفربول';
  if (q.includes('في أي مدينة يقع نادي برايتون')) return 'برايتون';
  if (q.includes('في أي مدينة يقع نادي شيفيلد يونايتد')) return 'شيفيلد';
  if (q.includes('كم عدد أندية لندن المشاركة')) return '7';

  // Nicknames
  if (q.includes('لقب فريق ليفربول')) return 'الريدز';
  if (q.includes('لقب فريق مانشستر سيتي')) return 'السيتزنز';
  if (q.includes('لقب فريق تشيلسي')) return 'البلوز';
  if (q.includes('لقب فريق توتنهام')) return 'السبيرز';
  if (q.includes('لقب فريق نيوكاسل')) return 'الماغبايز';
  if (q.includes('لقب فريق إيفرتون')) return 'التوفيز';
  if (q.includes('لقب وولفرهامبتون')) return 'الذئاب (وولفز)';
  if (q.includes('لقب ويست هام')) return 'المطارق';
  if (q.includes('لقب ليدز يونايتد')) return 'الوايتس';

  // Colors
  if (q.includes('لون قميص فولهام الأساسي')) return 'الأبيض';
  if (q.includes('لون قميص واتفورد الأساسي')) return 'الأصفر';

  // Seasons and structure
  if (q.includes('في أي شهر يبدأ موسم')) return 'أغسطس';
  if (q.includes('كم فريق يهبط إلى التشامبيونشيب')) return '3';

  // Titles counts
  if (q.includes('كم مرة فاز آرسنال بلقب')) return '3';
  if (q.includes('كم مرة فاز ليفربول بلقب')) return '1 (2019–20)';
  if (q.includes('كم مرة فاز مانشستر يونايتد بلقب')) return '13';
  if (q.includes('كم مرة فاز تشيلسي بلقب')) return '5';
  if (q.includes('حتى نهاية موسم') && q.includes('مانشستر سيتي بلقب')) return '8';

  // Historical seasons
  if (q.includes('الموسم المثالي بدون هزيمة')) return '2003–04';
  if (q.includes('فاز ليستر سيتي بلقب')) return '2015–16';
  if (q.includes('أول لقب للبريميرليغ') && q.includes('أي فريق')) return 'مانشستر يونايتد';
  if (q.includes('في أي عام تأسس')) return '1992';
  if (q.includes('أول لقب للبريميرليغ') && q.includes('السيتي')) return '2011–12';
  if (q.includes('في أي عام فاز مانشستر سيتي بأول لقب')) return '2011–12';
  if (q.includes('رقم 100 نقطة')) return '2017–18';

  // Players and records
  if (q.includes('أكثر لاعب تسجيلاً للأهداف في تاريخ')) return 'آلان شيرر (260)';
  if (q.includes('أصغر لاعب سجل هدفاً')) return 'جيمس فوغان';
  if (q.includes('أسرع هدف في تاريخ')) return 'شين لونغ (7.69 ثانية)';
  if (q.includes('أكبر لاعب سجل هدفاً')) return 'تيدي شيرينغهام';
  if (q.includes('حارس المرمى الذي حقق أكبر عدد من الشباك النظيفة')) return 'بيتر تشيك';
  if (q.includes('لعب أكثر عدد من المباريات')) return 'غاريث باري (653)';
  if (q.includes('أكثر عدد من تمريرات الأهداف')) return 'راين غيغز';
  if (q.includes('أكثر عدد من الكروت الحمراء')) return 'ريتشارد دون (8، مشترك)';
  if (q.includes('أكثر عدد من الأهداف من ركلات جزاء')) return 'آلان شيرر';
  if (q.includes('كم هدفاً سجل آلان شيرر')) return '260';
  if (q.includes('تييري هنري في البريميرليغ')) return '175';
  if (q.includes('كم عدد الأهداف التي سجلها تييري هنري')) return '175';
  if (q.includes('كم عدد الأهداف التي سجلها فرانك لامبارد')) return '177';
  if (q.includes('كم عدد المباريات التي لعبها فرانك لامبارد')) return '609';
  if (q.includes('أسرع لاعب وصولاً إلى 100 هدف')) return 'آلان شيرر';
  if (q.includes('أكثر لاعب سجل هاتريك')) return 'سيرخيو أغويرو';
  if (q.includes('أسرع هاتريك في تاريخ')) return 'ساديو ماني';
  if (q.includes('كم دقيقة استغرق ساديو ماني')) return '2 دقيقة و56 ثانية';
  if (q.includes('في أي دقيقة سجل سيرجيو أغويرو هدف الفوز')) return '93:20';
  if (q.includes('أكبر عدد من الأهداف بالرأس')) return 'بيتر كراوتش';
  if (q.includes('أول هاتريك في تاريخ')) return 'إريك كانتونا';
  if (q.includes('أكثر مدافع تسجيلاً للأهداف')) return 'جون تيري';
  if (q.includes('هداف موسم 2013-14')) return 'لويس سواريز';

  // Managers
  if (q.includes('المدرب الذي فاز بالبريميرليغ مع ليستر')) return 'كلاوديو رانييري';
  if (q.includes('المدرب الذي فاز بالبريميرليغ مع تشيلسي في موسمه الأول')) return 'جوزيه مورينيو (وأيضًا أنطونيو كونتي)';
  if (q.includes('أول مدرب أجنبي يفوز بلقب')) return 'آرسين فينغر';
  if (q.includes('مدرب تشيلسي البطل موسم 2009-10')) return 'كارلو أنشيلوتي';
  if (q.includes('في أي عام تولى بيب جوارديولا تدريب')) return '2016';
  if (q.includes('في أي عام تولى يورغن كلوب تدريب')) return '2015';
  if (q.includes('من كان مدرب مانشستر سيتي عند تتويج 2011-12')) return 'روبرتو مانشيني';
  if (q.includes('من كان مدرب ليستر سيتي في موسم التتويج')) return 'كلاوديو رانييري';

  // Transfers and cups
  if (q.includes('انتقل من توتنهام إلى ريال مدريد عام 2013')) return 'غاريث بيل';
  if (q.includes('غادر كريستيانو رونالدو مانشستر يونايتد لأول مرة')) return '2009';
  if (q.includes('انتقل من ليفربول إلى برشلونة مقابل 142')) return 'فيليبي كوتينيو';
  if (q.includes('من سجل هدف الفوز لتشيلسي في نهائي كأس الاتحاد الإنجليزي 2009')) return 'فرانك لامبارد';

  // Points, counts, wins
  if (q.includes('كم عدد النقاط التي حققها مانشستر سيتي في موسم 2017-18')) return '100';
  if (q.includes('ما هو أعلى انتصار في تاريخ')) return '9-0';
  if (q.includes('أي فريق سجل أكبر عدد من الأهداف في موسم 2017-18')) return 'مانشستر سيتي (106 هدفًا)';

  // Derbies and specials
  if (q.includes('ما هو اسم ديربي لندن الشمالي')) return 'ديربي شمال لندن';
  if (q.includes('أكثر الأهداف في ديربي مانشستر')) return 'واين روني';

  // Firsts
  if (q.includes('من سجل أول هدف في تاريخ البريميرليغ')) return 'براين دين';
  if (q.includes('على أي ملعب سُجل أول هدف')) return 'برامال لين';
  if (q.includes('أول لاعب إفريقي فاز بجائزة هداف البريميرليغ')) return 'ديدييه دروغبا';
  if (q.includes('أول لاعب فاز بجائزة لاعب الموسم من رابطة اللاعبين وهو إفريقي')) return 'رياض محرز';

  // Club records
  if (q.includes('هداف مانشستر سيتي التاريخي')) return 'سيرخيو أغويرو';
  if (q.includes('هداف مانشستر يونايتد التاريخي')) return 'واين روني';
  if (q.includes('هداف تشيلسي التاريخي')) return 'فرانك لامبارد';
  if (q.includes('هداف ليفربول التاريخي')) return 'محمد صلاح';
  if (q.includes('هداف آرسنال التاريخي')) return 'تييري هنري';

  // Current numbers
  if (q.includes('يرتدي القميص رقم 7 في مانشستر يونايتد موسم 2023-24')) return 'ماسون ماونت';

  // Goal tallies (seasonal)
  if (q.includes('كم عدد الأهداف التي سجلها هاري كين في موسم 2017-18')) return '30';
  if (q.includes('كم عدد الأهداف التي سجلها محمد صلاح في موسمه الأول مع ليفربول')) return '32';

  // FA Cup / non-PL but in set
  if (q.includes('المدرب الذي فاز بالدوري مع بلاكبيرن روفرز')) return 'كيني دالغليش';
  if (q.includes('في أي موسم فاز بلاكبيرن روفرز بلقب')) return '1994–95';
  if (q.includes('أنهى موسم 1994-95 بطلاً')) return 'بلاكبيرن روفرز';

  // Keeper who played for both Manchester clubs
  if (q.includes('الحارس الذي لعب لكل من مانشستر سيتي ومانشستر يونايتد')) return 'بيتر شمايكل';

  return '—';
}

function run() {
  const data = loadJson(questionsPath);
  let filled = 0, total = data.length;
  const updated = data.map(e => {
    const ans = answerFor(e.q || '');
    if (ans !== '—') filled++;
    return { ...e, a: ans };
  });
  saveJson(questionsPath, updated);
  const remaining = total - filled;
  console.log(`Filled answers: ${filled}/${total}. Remaining placeholders: ${remaining}`);
}

run();
