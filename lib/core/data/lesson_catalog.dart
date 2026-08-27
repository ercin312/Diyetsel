class LessonQuiz {
  const LessonQuiz({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
}

class LessonDay {
  const LessonDay({
    required this.day,
    required this.title,
    required this.emoji,
    required this.lead,
    required this.paragraphs,
    required this.tip,
    required this.quiz,
  });

  final int day;
  final String title;
  final String emoji;
  final String lead;
  final List<String> paragraphs;
  final String tip;
  final LessonQuiz quiz;
}

class LessonSeries {
  const LessonSeries({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.gradient,
    required this.badgeId,
    required this.days,
  });

  final String id;
  final String title;
  final String subtitle;
  final String emoji;
  final List<int> gradient;
  final String badgeId;
  final List<LessonDay> days;
}

class LessonCatalog {
  LessonCatalog._();

  static const labelReading = LessonSeries(
    id: 'label_reading',
    title: 'Etiket Okuma',
    subtitle: '7 günde markette bilinçli seçim',
    emoji: '🔍',
    gradient: [0xFFE85D04, 0xFF0F766E],
    badgeId: 'lesson_labels',
    days: [
      LessonDay(
        day: 1,
        title: 'İlk bakış: içindekiler',
        emoji: '📋',
        lead: 'Etiket okumaya en uzun listeden değil, en kısa cümleden başla.',
        paragraphs: [
          'Ürünün arkasındaki “içindekiler” listesi, miktar sırasına göre yazılır. Listenin ilk 3 maddesi ürünün asıl karakterini belirler.',
          'Şeker, glukoz şurubu veya invert şeker farklı isimlerle aynı şeye işaret edebilir. İlk sırada görürsen o ürün aslında bir “tatlandırıcı taşıyıcı” olabilir.',
        ],
        tip: 'Bugün alışverişte 1 ürünün ilk 3 maddesini oku ve fotoğrafla.',
        quiz: LessonQuiz(
          question: 'İçindekiler listesinde ilk sırada ne olması en çok dikkat çekmelidir?',
          options: ['Su', 'En yüksek miktardaki madde', 'Vitaminler', 'Renklendirici'],
          correctIndex: 1,
          explanation: 'Liste azalan miktara göre sıralanır; ilk madde ürünün baskın bileşenidir.',
        ),
      ),
      LessonDay(
        day: 2,
        title: 'Gizli şeker avcısı',
        emoji: '🍬',
        lead: '“Şekersiz” yazması her zaman masum olmadığı anlamına gelmez.',
        paragraphs: [
          'Dekstroz, fruktoz, malto dekstrin, pekmez, bal — hepsi kan şekerini etkiler. “Light” veya “fit” etiketli atıştırmalıklarda bile olabilir.',
          '100 g’da 5 g altı şeker genelde makul kabul edilir; bar ve yoğurtlarda 15–20 g görmek sık rastlanır.',
        ],
        tip: 'Yoğurt veya bar alırken 100 g’da kaç gram şeker var bak.',
        quiz: LessonQuiz(
          question: 'Hangisi gizli şeker adı sayılabilir?',
          options: ['Dekstroz', 'Tuz', 'Lif', 'Potasyum'],
          correctIndex: 0,
          explanation: 'Dekstroz glukoz türevidir; etikette şeker olarak sayılır.',
        ),
      ),
      LessonDay(
        day: 3,
        title: 'Yağ kalitesi',
        emoji: '🫒',
        lead: 'Toplam yağ değil, yağın türü önemlidir.',
        paragraphs: [
          '“Hidrojene” bitkisel yağlar ve palm yağı sık işlenmiş ürünlerde görülür. Zeytinyağı, ayçiçek veya kakao yağı genelde daha nötr tercihlerdir.',
          'Trans yağ içeren ürünlerden kaçın; etikette “0 g trans yağ” yazsa bile kısmi hidrojenasyon ipucu olabilir.',
        ],
        tip: 'Bisküvi veya kraker alırken yağ türüne bak.',
        quiz: LessonQuiz(
          question: 'Hangi ifade daha iyi bir yağ profiline işaret eder?',
          options: ['Hidrojene palm yağı', 'Zeytinyağı', 'Katı margarin', 'Kısmi hidrojenasyon'],
          correctIndex: 1,
          explanation: 'Zeytinyağı doymamış yağ açısından daha dengeli bir seçimdir.',
        ),
      ),
      LessonDay(
        day: 4,
        title: 'Tuz tuzağı',
        emoji: '🧂',
        lead: 'Günlük 5 g tuzu aşmamak kalp ve ödem için kritik.',
        paragraphs: [
          'Hazır çorba, sos, turşu ve salam sodyum deposudur. 100 g’da 1,2 g sodyum ≈ 3 g tuz demektir.',
          '“Az tuzlu” ibaresi her zaman düşük sodyum anlamına gelmez; porsiyon küçükse toplam yine yüksek olabilir.',
        ],
        tip: 'Hazır sos veya çorbada sodyum mg değerini karşılaştır.',
        quiz: LessonQuiz(
          question: '100 g üründe 1,5 g sodyum yaklaşık kaç gram tuza denk gelir?',
          options: ['1 g', '2 g', '3,75 g', '10 g'],
          correctIndex: 2,
          explanation: 'Sodyum × 2,5 ile tuz gramına kabaca çevrilir.',
        ),
      ),
      LessonDay(
        day: 5,
        title: 'Lif ve tok tutma',
        emoji: '🌾',
        lead: 'Lif hem sindirimi hem tokluk hissini destekler.',
        paragraphs: [
          'Tam tahıl, baklagil ve sebze lif kaynağıdır. “Tam buğday” ibaresi unun tam olması gerekir; sadece renk koyu olması yetmez.',
          '100 g’da 3 g üzeri lif, atıştırmalık için iyi bir hedeftir.',
        ],
        tip: 'Ekmek veya krakerde “tam tahıl” ve lif gramını kontrol et.',
        quiz: LessonQuiz(
          question: 'Tok tutma için etikette neye bakmalısın?',
          options: ['Sadece kalori', 'Lif miktarı', 'Renk', 'Ambalaj boyutu'],
          correctIndex: 1,
          explanation: 'Lif sindirimi yavaşlatır ve tokluk süresini uzatır.',
        ),
      ),
      LessonDay(
        day: 6,
        title: 'Porsiyon vs paket',
        emoji: '📦',
        lead: 'Paket tek porsiyon değildir — besin değerleri genelde 100 g içindir.',
        paragraphs: [
          '“Porsiyon başına” satırını mutlaka oku. Küçük paketli cips 2–3 porsiyon içerebilir.',
          'Kalori tablosunda enerji kJ/kcal ikilisini görürsen kcal satırına odaklan.',
        ],
        tip: 'Atıştırmalık alırken porsiyon sayısını hesapla.',
        quiz: LessonQuiz(
          question: 'Besin değerleri tablosu genelde hangi birime göre verilir?',
          options: ['100 g / ml', 'Tüm paket', '1 kaşık', '1 dilim (her zaman)'],
          correctIndex: 0,
          explanation: 'Türkiye’de tablo çoğunlukla 100 g veya 100 ml bazlıdır.',
        ),
      ),
      LessonDay(
        day: 7,
        title: 'Alışveriş ritüelin',
        emoji: '✅',
        lead: '7 gün sonunda etiket okumak refleks haline gelmeli.',
        paragraphs: [
          'Listeni 3 kurala indir: (1) İlk 3 madde temiz mi? (2) Şeker/tuz sınırda mı? (3) Porsiyon gerçekçi mi?',
          'Diyetisyenin planına uymak için etiket okumak tek başına yetmez ama yanlış seçimleri %70 azaltır.',
        ],
        tip: 'Bu hafta öğrendiklerini bir arkadaşına 1 cümleyle anlat.',
        quiz: LessonQuiz(
          question: 'Bilinçli alışverişte en pratik kontrol hangisi?',
          options: ['Sadece marka', 'İlk 3 madde + porsiyon', 'Sadece fiyat', 'Renkli ambalaj'],
          correctIndex: 1,
          explanation: 'Kısa liste + porsiyon hesabı en hızlı filtredir.',
        ),
      ),
    ],
  );

  static const portionArt = LessonSeries(
    id: 'portion_art',
    title: 'Porsiyon Sanatı',
    subtitle: '7 günde tabağı gözünle ölç',
    emoji: '🥄',
    gradient: [0xFFFF8A4C, 0xFFFFC56D],
    badgeId: 'lesson_portions',
    days: [
      LessonDay(
        day: 1,
        title: 'Avuç içi kuralı',
        emoji: '✋',
        lead: 'Protein porsiyonunu avuç için kadar düşün.',
        paragraphs: [
          'Tavuk, balık veya baklagil porsiyonu avuç içi genişliğinde ve kalınlığında olabilir. Bu yaklaşık 80–120 g et/protein kaynağı demektir.',
          'Tabakta proteinin yarısından az kaplaması genelde yeterlidir.',
        ],
        tip: 'Bugünkü öğünde protein kaynağını avuç içinle kıyasla.',
        quiz: LessonQuiz(
          question: 'Avuç içi kuralı hangi makro için kullanılır?',
          options: ['Protein', 'Sadece sebze', 'Su', 'Tuz'],
          correctIndex: 0,
          explanation: 'Avuç içi pratik protein porsiyon rehberidir.',
        ),
      ),
      LessonDay(
        day: 2,
        title: 'Yumruk = sebze',
        emoji: '👊',
        lead: 'Her ana öğünde en az bir yumruk hacmi sebze hedefle.',
        paragraphs: [
          'Pişmiş sebze veya salata için kapalı yumruk hacmi iyi bir referanstır. Lif ve hacim tokluk sağlar.',
          'Sebze tabağın protein ve karbonhidrat arasında “denge köprüsü”dür.',
        ],
        tip: 'Öğle yemeğine bir yumruk hacmi salata ekle.',
        quiz: LessonQuiz(
          question: 'Yumruk kuralı neyi temsil eder?',
          options: ['Sebze porsiyonu', 'Tatlı', 'İçecek', 'Yağ'],
          correctIndex: 0,
          explanation: 'Kapalı yumruk ≈ 1 sebze porsiyonu.',
        ),
      ),
      LessonDay(
        day: 3,
        title: 'Kapalı avuç karbonhidrat',
        emoji: '🍚',
        lead: 'Pirinç, bulgur, makarna için kapalı avuç kullan.',
        paragraphs: [
          'Pişmiş halde kapalı avuç ≈ ½–1 porsiyon karbonhidrat. Aktivite düşükse küçük uç, antrenman günü büyük uç tercih edilir.',
          'Tam tahıl seçimi porsiyon kadar önemlidir.',
        ],
        tip: 'Akşam karbonhidratını kapalı avuçla ölç.',
        quiz: LessonQuiz(
          question: 'Kapalı avuç hangi gruba rehberlik eder?',
          options: ['Karbonhidrat', 'Protein', 'Alkol', 'Baharat'],
          correctIndex: 0,
          explanation: 'Tahıl ve nişastalı gıdalar için pratik ölçüdür.',
        ),
      ),
      LessonDay(
        day: 4,
        title: 'Başparmak yağ',
        emoji: '👍',
        lead: 'Yağ kaliteli olsa bile miktarı küçük tutulmalı.',
        paragraphs: [
          'Zeytinyağı, tereyağı veya fındık ezmesi için başparmak ucu kadar (≈1 tatlı kaşığı) porsiyon düşün.',
          'Restoranda soslar genelde porsiyonun 2–3 katı yağ içerir.',
        ],
        tip: 'Salataya yağı kaşıkla, göz kararı değil.',
        quiz: LessonQuiz(
          question: 'Başparmak kuralı ne için?',
          options: ['Yağ / kuruyemiş', 'Su', 'Et', 'Ekmek'],
          correctIndex: 0,
          explanation: 'Kaliteli yağlar bile yoğun kalorilidir; ölçü şart.',
        ),
      ),
      LessonDay(
        day: 5,
        title: 'Tabak modeli',
        emoji: '🍽️',
        lead: '½ sebze, ¼ protein, ¼ karbonhidrat — klasik ama işe yarar.',
        paragraphs: [
          'Tabağı ikiye böl: yarısı sebze/salata. Kalan yarıyı protein ve karbonhidrat paylaşır.',
          'Bu model ev yemeğinde ve restoranda aynı mantıkla uygulanabilir.',
        ],
        tip: 'Bugün tabağını fotoğrafla ve oranları kontrol et.',
        quiz: LessonQuiz(
          question: 'Tabak modelinde sebze oranı yaklaşık ne kadar?',
          options: ['½', '¼', '⅛', 'Tamamı'],
          correctIndex: 0,
          explanation: 'Yarım tabak sebze lif ve hacim sağlar.',
        ),
      ),
      LessonDay(
        day: 6,
        title: 'Dışarıda porsiyon',
        emoji: '🍽️',
        lead: 'Restoran porsiyonu genelde 1,5–2 kişilik gelir.',
        paragraphs: [
          'Yarısını isteyebilir veya kutuya aldırabilirsin. Sos ayrı gelsin — kontrol sende olsun.',
          'Ekmek sepeti ve içecek kalorilerini unutma; ana yemekten bağımsız hesapla.',
        ],
        tip: 'Dışarıda yemekten yarısını paket yaptır.',
        quiz: LessonQuiz(
          question: 'Restoranda en pratik porsiyon kontrolü?',
          options: ['Hepsini bitir', 'Yarısını paket', 'Sadece ekmek ye', 'Sosları karıştır'],
          correctIndex: 1,
          explanation: 'Yarı porsiyon veya paket hem bütçe hem kalori dostudur.',
        ),
      ),
      LessonDay(
        day: 7,
        title: 'Porsiyon ustası',
        emoji: '🏆',
        lead: 'Artık terazi olmadan da dengeli tabak kurabilirsin.',
        paragraphs: [
          'Avuç, yumruk, kapalı avuç ve başparmak kurallarını birleştir. Zamanla gözün kalibre olur.',
          'Diyetisyeninin planı varsa onu esas al; bu kurallar pratik tamamlayıcıdır.',
        ],
        tip: 'Haftalık check-in’de porsiyon fark ettiğin anı not et.',
        quiz: LessonQuiz(
          question: '7 gün sonunda en önemli alışkanlık hangisi?',
          options: ['Göz kararı devam', 'El ölçüleriyle tutarlı tabak', 'Sadece tartı', 'Hiç ölçme'],
          correctIndex: 1,
          explanation: 'El ölçüleri sürdürülebilir porsiyon alışkanlığı oluşturur.',
        ),
      ),
    ],
  );

  static const all = [labelReading, portionArt];

  static LessonSeries? byId(String id) {
    for (final s in all) {
      if (s.id == id) return s;
    }
    return null;
  }
}
