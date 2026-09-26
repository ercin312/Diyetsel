import 'ui_en.dart';

/// Current UI language. Set from the app builder whenever the locale changes.
class UiLang {
  static String code = 'tr';
  static bool get isEnglish => code == 'en';
}

/// Translates a user-visible string when English is selected.
/// Turkish stays as written. Unknown strings (names, notes) are left unchanged.
extension UiString on String {
  String get ui {
    if (!UiLang.isEnglish || isEmpty) return this;
    final exact = uiEn[this];
    if (exact != null) return exact;
    final rules = [..._patterns]..sort((a, b) => b.pattern.pattern.length.compareTo(a.pattern.pattern.length));
    for (final rule in rules) {
      final match = rule.pattern.firstMatch(this);
      if (match == null) continue;
      var out = rule.english;
      for (var i = 1; i <= match.groupCount; i++) {
        out = out.replaceFirst('{$i}', match.group(i) ?? '');
      }
      return out;
    }
    return this;
  }
}

class _Rule {
  const _Rule(this.pattern, this.english);
  final RegExp pattern;
  final String english;
}

final List<_Rule> _patterns = [
  _Rule(RegExp(r'^(.+)/7 gün$'), '{1}/7 days'),
  _Rule(RegExp(r'^Bugün %(.+)$'), 'Today {1}%'),
  _Rule(RegExp(r'^(.+) gün$'), '{1} days'),
  _Rule(RegExp(r'^(.+) kapalı$'), '{1} off'),
  _Rule(RegExp(r'^(.+) gün seri$'), '{1} day streak'),
  _Rule(RegExp(r'^Kayıt hatası: (.+)$'), 'Save error: {1}'),
  _Rule(RegExp(r'^JSON geçersiz: (.+)$'), 'Invalid JSON: {1}'),
  _Rule(RegExp(r'^Gönderilemedi: (.+)$'), 'Could not send: {1}'),
  _Rule(RegExp(r'^Gün (.+)$'), 'Day {1}'),
  _Rule(RegExp(r'^Yağ %(.+)$'), 'Fat {1}%'),
  _Rule(RegExp(r'^(.+) kayıt$'), '{1} saved'),
  _Rule(RegExp(r'^(.+) belge hazır$'), '{1} documents ready'),
  _Rule(RegExp(r'^🔥 (.+) gün seri$'), '🔥 {1} day streak'),
  _Rule(RegExp(r'^(.+) beğeni$'), '{1} likes'),
  _Rule(RegExp(r'^(.+) kcal kaldı$'), '{1} kcal left'),
  _Rule(RegExp(r'^(.+) aktif danışan$'), '{1} active clients'),
  _Rule(RegExp(r'^(.+) / (.+) alındı$'), '{1} / {2} taken'),
  _Rule(RegExp(r'^Bugün (.+) L kaldı 💧$'), '{1} L left today 💧'),
  _Rule(RegExp(r'^(.+) rozet kazandın$'), 'You earned {1} badges'),
  _Rule(RegExp(r'^Fotoğraf yüklenemedi: (.+)$'), 'Could not upload photo: {1}'),
  _Rule(RegExp(r'^Rekor (.+) gün$'), 'Record {1} days'),
  _Rule(RegExp(r'^(.+) kaldı$'), '{1} left'),
  _Rule(RegExp(r'^Mini ders • Gün (.+)$'), 'Mini lesson • Day {1}'),
  _Rule(RegExp(r'^En iyi (.+) gün$'), 'Best {1} days'),
  _Rule(RegExp(r'^(.+) / (.+) öğün tamam$'), '{1} / {2} meals done'),
  _Rule(RegExp(r'^(.+) kısayol · ara ve aç$'), '{1} shortcuts · search and open'),
  _Rule(RegExp(r"^Günün ipucu · (.+)$"), "Tip of the day · {1}"),
  _Rule(RegExp(r'^Önerilen · (.+)$'), 'Suggested · {1}'),
  _Rule(RegExp(r'^Öne çıkan · (.+)$'), 'Featured · {1}'),
  _Rule(RegExp(r'^(.+) aktif · (.+) kayıt$'), '{1} active · {2} saved'),
  _Rule(RegExp(r'^(.+) günlük seri$'), '{1} day streak'),
  _Rule(RegExp(r'^(.+) klinik aracı tek yerde$'), '{1} clinic tools in one place'),
  _Rule(RegExp(r'^(.+) öğün kaldı$'), '{1} meals left'),
  _Rule(RegExp(r'^(.+) danışan$'), '{1} clients'),
  _Rule(RegExp(r'^rekor (.+) gün$'), 'record {1} days'),
  _Rule(RegExp(r'^2\. Alınacaklar \((.+)\)$'), '2. To buy ({1})'),
  _Rule(RegExp(r'^\+(.+) öğün daha$'), '+{1} more meals'),
  _Rule(RegExp(r'^(.+) sessiz danışan ⚠️$'), '{1} quiet clients ⚠️'),
  _Rule(RegExp(r'^Rozeti açmak için (.+) adım daha\.$'), '{1} more steps to unlock the badge.'),
  _Rule(RegExp(r'^Ürün bulunamadı \((.+)\)\.$'), 'Product not found ({1}).'),
  _Rule(RegExp(r'^(.+)/(.+) gün$'), '{1}/{2} days'),
  _Rule(RegExp(r'^(.+) fotoğraf · (.+) bekleyen not$'), '{1} photos · {2} pending notes'),
  _Rule(RegExp(r'^Merhaba (.+) — keşfet, takip et, geliş$'), 'Hello {1} — explore, track, improve'),
  _Rule(RegExp(r"^Diyetsel’de (.+) rozet kazandım 🏆$"), 'I earned {1} badges on Diyetsel 🏆'),
  _Rule(RegExp(r'^Bugün (.+) / (.+) ml$'), 'Today {1} / {2} ml'),
  _Rule(RegExp(r'^(.+) zamanı (.+)$'), '{1} time {2}'),
  _Rule(RegExp(r'^(.+) için plan kaydedildi$'), 'Plan saved for {1}'),
  _Rule(RegExp(r'^(.+) kg düşüş$'), '{1} kg down'),
  _Rule(RegExp(r'^(.+) — planına göz at ve işaretle\.$'), '{1} — review your plan and check it off.'),
  _Rule(RegExp(r'^(.+)/7 · ateşin yanmaya devam ediyor$'), '{1}/7 · keep the streak going'),
  _Rule(RegExp(r'^(.+) aktif sohbet · yanıtlar burada$'), '{1} active chats · replies are here'),
  _Rule(RegExp(r'^(.+) — 3\+ gündür uygulamaya girmedi\.$'), '{1} — has not opened the app for 3+ days.'),
  _Rule(RegExp(r'^Tüm danışanlar · (.+) kişi$'), 'All clients · {1} people'),
  _Rule(RegExp(r'^Merhaba (.+) — randevu, içerik ve danışanlar$'), 'Hello {1} — appointments, content and clients'),
  _Rule(RegExp(r'^Toplam (.+) kişi klinik kaydında$'), '{1} people in the clinic'),
  _Rule(RegExp(r'^Planına uygun, dengeli bir (.+) önerisi$'), 'A balanced {1} suggestion that fits your plan'),
  _Rule(RegExp(r'^(.+) ürün diyetten eklendi$'), '{1} items added from the diet'),
  _Rule(RegExp(r'^(.+) seçenek · sos ayrı, pilavı çıkar$'), '{1} options · sauce on the side, skip the rice'),
  _Rule(RegExp(r'^(.+) yönetim aracı — içerik, plan ve sistem\.$'), '{1} admin tools — content, plans and system.'),
  _Rule(RegExp(r'^(.+) adım kaldı · (.+)/(.+)$'), '{1} steps left · {2}/{3}'),
  _Rule(RegExp(r'^₺(.+)’dan başlayan$'), 'From ₺{1}'),
  _Rule(RegExp(r'^(.+) seçenek · kalan (.+) kcal$'), '{1} options · {2} kcal left'),
  _Rule(RegExp(r'^(.+) kısayol · ara, grupla, tek dokunuşla aç\.$'), '{1} shortcuts · search, group, open in one tap.'),
  _Rule(RegExp(r'^(.+) gündür Diyetsel ritmimdeyim 🔥$'), 'I have been on my Diyetsel rhythm for {1} days 🔥'),
  _Rule(RegExp(r'^(.+) yazı · diyetisyen notları, pratik ipuçları$'), '{1} posts · dietitian notes, practical tips'),
  _Rule(RegExp(r'^Hızlı eklemek için \+(.+) ml$'), 'Quick add +{1} ml'),
  _Rule(RegExp(r'^Diyetisyenin bugün senin için bir not bıraktı: (.+)$'), 'Your dietitian left you a note today: {1}'),
  _Rule(RegExp(r'^Bugün ~(.+) g protein eksik — (.+) için ideal$'), 'About {1} g protein short today — ideal for {2}'),
  _Rule(RegExp(r'^(.+) danışana kuyruğa alındı$'), 'Queued for {1} clients'),
  _Rule(RegExp(r'^(.+) paket · online, klinik ve program seçenekleri$'), '{1} packages · online, clinic and program options'),
  _Rule(RegExp(r'^(.+) yazı · (.+) kategori · pratik ipuçları$'), '{1} posts · {2} categories · practical tips'),
  _Rule(RegExp(r'^(.+) hatırlatıcısı (.+) olarak ayarlandı$'), '{1} reminder set for {2}'),
  _Rule(RegExp(r'^(.+) — planına uygun mu kontrol et\.$'), '{1} — check whether it fits your plan.'),
  _Rule(RegExp(r'^Her saat başı 150–200 ml hedefle\. Kalan: (.+) ml\.$'), 'Aim for 150–200 ml each hour. Left: {1} ml.'),
  _Rule(RegExp(r'^(.+) mini ders tamamlandı · her gün 3 dakika yeter$'), '{1} mini lessons done · 3 minutes a day is enough'),
  _Rule(RegExp(r'^(.+)/(.+) öğün$'), '{1}/{2} meals'),
  _Rule(RegExp(r'^(.+) tarif · (.+) kategori · adım adım & makro net$'), '{1} recipes · {2} categories · steps and macros'),
  _Rule(RegExp(r'^(.+) danışana bildirim kuyruğa alındı$'), 'Notification queued for {1} clients'),
  _Rule(RegExp(r'^Sıradaki: (.+)  ·  Ara$'), 'Next: {1}  ·  Search'),
  _Rule(RegExp(r'^Sıradaki: (.+) · %(.+)$'), 'Next: {1} · {2}%'),
  _Rule(RegExp(r'^(.+) beğeni · (.+) kayıtlı · mutfakta yanındayız$'), '{1} likes · {2} saved · with you in the kitchen'),
  _Rule(RegExp(r'^Tüm danışanların su hedefi (.+) L oldu\.$'), 'Every client’s water goal is now {1} L.'),
  _Rule(RegExp(r'^%(.+) tamamlandı — bir bardak daha$'), '{1}% done — one more glass'),
  _Rule(RegExp(r'^(.+) / (.+) bölüm açık$'), '{1} / {2} sections visible'),
  _Rule(RegExp(r'^Bel \+(.+) cm; ölçümü sabah aç karnına tekrarla\.$'), 'Waist +{1} cm; measure again in the morning before eating.'),
  _Rule(RegExp(r'^(.+)/(.+) öğün bu hafta$'), '{1}/{2} meals this week'),
  _Rule(RegExp(r'^Kısayol açık — buradan \+(.+) ml ekleyebilirsin$'), 'Shortcut is on — add +{1} ml from here'),
  _Rule(RegExp(r'^(.+) bekleyen talep var — hızlı onay danışan bağlılığını artırır\.$'), '{1} pending requests — a quick approval keeps clients engaged.'),
  _Rule(RegExp(r'^Kalan yaklaşık (.+) kcal\. Proteini önce bitir, akşamı hafif tut\.$'), 'About {1} kcal left. Finish protein first and keep dinner light.'),
  _Rule(RegExp(r'^Ortalama ruh hali (.+)/5 — enerji yüksek görünüyor\.$'), 'Average mood {1}/5 — energy looks high.'),
  _Rule(RegExp(r'^Son ölçüme göre (.+) kg — sabır işe yarıyor$'), '{1} kg since the last measurement — patience is working'),
  _Rule(RegExp(r'^Bu hafta (.+) seans\. Sessiz danışanlara kısa bir kontrol mesajı at\.$'), '{1} sessions this week. Send a short check-in to quiet clients.'),
  _Rule(RegExp(r'^Diyet uyumu %(.+)\. Eksik kalan öğünleri yarın için yeniden planla\.$'), 'Diet adherence {1}%. Replan missed meals for tomorrow.'),
  _Rule(RegExp(r'^(.+) seans/randevu bu dönemde tamamlandı veya planlandı\.$'), '{1} sessions were completed or scheduled in this period.'),
  _Rule(RegExp(r'^Seri sıfırlandı ama rekorun (.+) gün — yarın yeniden başlat\.$'), 'Streak reset, but your record is {1} days — start again tomorrow.'),
  _Rule(RegExp(r'^Bugün (.+) L su — hidrasyon check ✓$'), '{1} L of water today — hydration check ✓'),
  _Rule(RegExp(r'^100 g kalorisine bak; porsiyonu kendi tabağınla kıyasla\. Bütçen ~(.+) kcal\.$'), 'Check calories per 100 g and compare with your plate. Budget ~{1} kcal.'),
  _Rule(RegExp(r'^(.+) öğün yorum bekliyor — kısa ve net geri bildirim danışanı motive eder\.$'), '{1} meal notes are waiting — short, clear feedback motivates clients.'),
  _Rule(RegExp(r'^(.+) aktif hatırlatıcı var\. Sessiz saatlerini ayarlardan kişiselleştir\.$'), '{1} reminders are on. Set quiet hours in Settings.'),
  _Rule(RegExp(r'^(.+) öğün fotoğrafı paylaştın — diyetisyenin için değerli geri bildirim\.$'), 'You shared {1} meal photos — useful feedback for your dietitian.'),
  _Rule(RegExp(r'^Öğün işaretleme %(.+)\. En kolay öğünden başla; tutarlılık mükemmellikten önemli\.$'), 'Meals checked {1}%. Start with the easiest meal; consistency beats perfection.'),
  _Rule(RegExp(r'^Bildirimden veya buradan \+(.+) ml ekle\. Hedefe (.+) ml kaldı\.$'), 'Add +{1} ml from the notification or here. {2} ml left to the goal.'),
  _Rule(RegExp(r'^(.+) günlük aktif serin var \(rekor (.+)\)\. Zinciri kırma!$'), 'Your active streak is {1} days (record {2}). Don’t break the chain!'),
  _Rule(RegExp(r'^Bel çevresi (.+) cm inceldi — iyi bir vücut kompozisyonu sinyali\.$'), 'Waist is down {1} cm — a good body-composition signal.'),
  _Rule(RegExp(r'^Su hedefini günlerin %(.+)’inde tuttun — hidrasyon süper\.$'), 'You hit your water goal on {1}% of days — great hydration.'),
  _Rule(RegExp(r'^Kilo \+(.+) kg\. Su tutulması veya kas artışı da olabilir; bel çevresine bak\.$'), 'Weight +{1} kg. It may be water or muscle; check your waist.'),
  _Rule(RegExp(r'^(.+) plan hazır\. Sessiz danışanlara yeni haftalık plan atamak bağlılığı güçlendirir\.$'), '{1} plans are ready. Assigning a new weekly plan to quiet clients improves follow-through.'),
  _Rule(RegExp(r'^Toplam (.+) L · hedef gün (.+)$'), 'Total {1} L · goal days {2}'),
  _Rule(RegExp(r'^Ruh hali ortalaması düşük \((.+)/5\)\. Uyku ve öğün zamanlamasını gözden geçir\.$'), 'Average mood is low ({1}/5). Review sleep and meal timing.'),
  _Rule(RegExp(r'^Her öğünde 1 bardak pratik bir ritüel\. Kalan: (.+) ml\.$'), 'One glass with each meal is an easy ritual. Left: {1} ml.'),
  _Rule(RegExp(r'^Dönem içinde (.+) kg düşüş kaydedildi\. Trend için haftalık aynı saatte tartıl\.$'), '{1} kg lost in this period. Weigh at the same time each week to see the trend.'),
  _Rule(RegExp(r'^Sıradaki hedefin yakın: (.+)\. Bugün bir check-in, su veya ders tamamlamak seni öne taşır\.$'), 'Your next goal is close: {1}. A check-in, water, or lesson today moves you forward.'),
  _Rule(RegExp(r'^Diyet uyumu %(.+) — planındaki (.+)/(.+) öğünü tamamladın\.$'), 'Diet adherence {1}% — you finished {2}/{3} planned meals.'),
  _Rule(RegExp(r'^Windows’ta widget yok; bildirim Android’de çalışır\. Buradan \+(.+) ml ekleyebilirsin$'), 'No widget on Windows; notifications work on Android. You can add +{1} ml here'),
  _Rule(RegExp(r'^(.+) pasif danışan var\. Sessiz kalanlara kısa bir check-in mesajı dönüşü hızlandırır\.$'), '{1} inactive clients. A short check-in brings quiet clients back sooner.'),
  _Rule(RegExp(r'^Ortalama (.+) L su — hedefe yaklaşmak için öğleden sonra hatırlatıcı kur\.$'), 'Average {1} L of water — set an afternoon reminder to get closer to the goal.'),
];
