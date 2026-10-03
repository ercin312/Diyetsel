import 'package:flutter/foundation.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../features/documents/domain/vault_io.dart';
import '../constants/app_constants.dart';
import '../models/enums.dart';
import '../models/models.dart';
import 'app_store.dart';

class SeedData {
  static const adminId = 'admin-demo';
  static const clientId = 'client-demo';
  static const client2Id = 'client-elif';

  static Future<void> seed(AppStore store) async {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));

    final admin = UserProfile(
      id: adminId,
      email: AppConstants.demoAdminEmail,
      displayName: 'Zühre',
      role: UserRole.admin,
      createdAt: now.subtract(const Duration(days: 120)),
      phone: '+90 532 000 00 01',
      notes: 'Kurucu diyetisyen',
    );
    final client = UserProfile(
      id: clientId,
      email: AppConstants.demoClientEmail,
      displayName: 'Mehmet Yılmaz',
      role: UserRole.client,
      createdAt: now.subtract(const Duration(days: 40)),
      heightCm: 178,
      targetWeightKg: 82,
      phone: '+90 533 000 00 02',
      lastActiveAt: now,
    );
    final elif = UserProfile(
      id: client2Id,
      email: 'elif@diyetsel.app',
      displayName: 'Elif Demir',
      role: UserRole.client,
      createdAt: now.subtract(const Duration(days: 20)),
      heightCm: 165,
      targetWeightKg: 58,
      isActive: true,
      lastActiveAt: now.subtract(const Duration(days: 5)),
    );
    await store.saveUser(admin);
    await store.saveUser(client);
    await store.saveUser(elif);
    await store.saveCredential(admin.email, hashPassword(AppConstants.demoAdminPassword));
    await store.saveCredential(client.email, hashPassword(AppConstants.demoPassword));
    await store.saveCredential(elif.email, hashPassword(AppConstants.demoPassword));

    for (var weekday = 1; weekday <= 5; weekday++) {
      await store.saveAvailability(
        AvailabilityRule(
          id: 'av-$weekday',
          dietitianId: adminId,
          weekday: weekday,
          start: '09:00',
          end: '17:00',
          slotMinutes: 45,
        ),
      );
    }

    await store.saveAppointment(
      Appointment(
        id: 'apt-upcoming',
        dietitianId: adminId,
        clientId: clientId,
        clientName: client.displayName,
        startAt: now.add(const Duration(hours: 26)),
        endAt: now.add(const Duration(hours: 27)),
        status: AppointmentStatus.approved,
        serviceTitle: 'Yüz Yüze Klinik Seansı',
        clinicalNotes: null,
      ),
    );
    await store.saveAppointment(
      Appointment(
        id: 'apt-past',
        dietitianId: adminId,
        clientId: clientId,
        clientName: client.displayName,
        startAt: now.subtract(const Duration(days: 7)),
        endAt: now.subtract(const Duration(days: 7)).add(const Duration(minutes: 45)),
        status: AppointmentStatus.completed,
        serviceTitle: 'Yüz Yüze Klinik Seansı',
        clinicalNotes: 'Bel çevresi 2 cm azaldı. Uyku düzeni iyileşmiş.',
        recommendations: 'Akşam karbonhidratını öne çek, yürüyüşü 8.000 adıma çıkar.',
      ),
    );
    await store.saveAppointment(
      Appointment(
        id: 'apt-pending',
        dietitianId: adminId,
        clientId: client2Id,
        clientName: elif.displayName,
        startAt: now.add(const Duration(days: 2, hours: 3)),
        endAt: now.add(const Duration(days: 2, hours: 4)),
        status: AppointmentStatus.pending,
        serviceTitle: '1 Aylık Online Takip',
      ),
    );

    await store.saveService(
      const ServicePackage(
        id: 'svc-online',
        title: '1 Aylık Online Takip',
        tagline: 'Evinizden, haftalık ritimle',
        description:
            'Haftalık check-in, mesajlaşma ve dinamik diyet revizyonu. Hedeflerinize göre makrolar ve öğünler güncellenir.',
        price: 4500,
        durationMinutes: 30,
        category: 'Online',
        imageUrl: 'assets/images/character_woman.png',
        tags: ['Online', 'Aylık', 'Mesaj'],
        bullets: [
          '4 görüntülü seans (30 dk)',
          '7/24 uygulama içi mesaj',
          'Alışveriş listesi + tarif önerileri',
          'Makro ve öğün revizyonu',
          'Haftalık ilerleme özeti',
        ],
      ),
    );
    await store.saveService(
      const ServicePackage(
        id: 'svc-clinic',
        title: 'Yüz Yüze Klinik Seansı',
        tagline: 'Ölçüm, analiz, net plan',
        description:
            'Klinik ortamında ölçüm ve vücut analizi; ardından kişiselleştirilmiş planlama ve yazılı öneriler.',
        price: 1800,
        durationMinutes: 45,
        category: 'Klinik',
        imageUrl: 'assets/images/character_boy.png',
        tags: ['Yüz yüze', 'Analiz', 'Plan'],
        bullets: [
          'InBody / antropometrik ölçüm',
          'Seans notları ve hedef belirleme',
          'PDF rapor (e-posta / uygulama)',
          'İlk 7 gün menü çerçevesi',
        ],
      ),
    );
    await store.saveService(
      const ServicePackage(
        id: 'svc-detox',
        title: 'Detoks Programı',
        tagline: '7 günde yumuşak sıfırlama',
        description:
            'Şok kür değil; 7 günlük dengeli menü, bitki çayı protokolü ve su hedefiyle sürdürülebilir bir reset.',
        price: 2200,
        durationMinutes: 20,
        category: 'Program',
        imageUrl: 'assets/images/food_green_smoothie.png',
        tags: ['7 gün', 'Detoks', 'Menü'],
        bullets: [
          '7 günlük menü + alışveriş listesi',
          'Bitki çayı / hidrasyon protokolü',
          'Günlük su hedefi takibi',
          'Kapanış check-in seansı (20 dk)',
        ],
      ),
    );
    await store.saveService(
      const ServicePackage(
        id: 'svc-sport',
        title: 'Sporcu Beslenme Paketi',
        tagline: 'Antrenman günü odaklı makro',
        description:
            'Performans ve toparlanma için antrenman öncesi/sonrası beslenme planı; protein zamanlaması ve hidrasyon.',
        price: 3200,
        durationMinutes: 40,
        category: 'Spor',
        imageUrl: 'assets/images/character_active_boy.png',
        tags: ['Spor', 'Performans', 'Protein'],
        bullets: [
          'Antrenman günü / dinlenme günü menüleri',
          'Protein ve karbonhidrat zamanlaması',
          '2 check-in seansı (40 dk)',
          'Maç / yarış haftası özel notlar',
        ],
      ),
    );

    DietMeal meal(String id, MealType type, String name, String desc, int c, int p, int k, int f, List<Ingredient> ing) =>
        DietMeal(id: id, type: type, name: name, description: desc, calories: c, protein: p, carbs: k, fat: f, ingredients: ing);

    final days = List.generate(7, (i) {
      final date = monday.add(Duration(days: i));
      return DietDay(
        date: date,
        meals: [
          meal('m-$i-b', MealType.breakfast, 'Kremsi yaban mersinli yulaf',
              'Sabah enerjisi: yulaf, süzme yoğurt ve chia ile tok tutan kase.', 420, 28, 48, 12, [
            const Ingredient(name: 'Yulaf', amount: '50 g', category: 'grain'),
            const Ingredient(name: 'Süzme yoğurt', amount: '150 g', category: 'dairy'),
            const Ingredient(name: 'Yaban mersini', amount: '80 g', category: 'vegetable'),
            const Ingredient(name: 'Chia', amount: '1 tatlı kaşığı', category: 'grain'),
          ]),
          meal('m-$i-s1', MealType.morningSnack, 'Çıtır badem molası',
              'Bir avuç çiğ badem — pratik protein ve sağlıklı yağ.', 160, 6, 6, 14, [
            const Ingredient(name: 'Badem', amount: '20 g', category: 'protein'),
          ]),
          meal('m-$i-l', MealType.lunch, 'Izgara tavuklu yeşil kase',
              'Roka, quinoa ve zeytinyağı ile protein dolu öğle tabağı.', 540, 42, 38, 18, [
            const Ingredient(name: 'Tavuk göğsü', amount: '150 g', category: 'protein'),
            const Ingredient(name: 'Quinoa', amount: '60 g', category: 'grain'),
            const Ingredient(name: 'Roka', amount: '1 kase', category: 'vegetable'),
            const Ingredient(name: 'Zeytinyağı', amount: '1 tatlı kaşığı', category: 'other'),
          ]),
          meal('m-$i-s2', MealType.afternoonSnack, 'Fermente kefir bardağı',
              'Sade kefir — bağırsak dostu ikindi molası.', 110, 8, 9, 3, [
            const Ingredient(name: 'Kefir', amount: '200 ml', category: 'dairy'),
          ]),
          meal('m-$i-d', MealType.dinner, 'Fırında somon & sebze',
              'Somon, brokoli ve tatlı patates — omega-3’lü sakin akşam.', 610, 38, 32, 28, [
            const Ingredient(name: 'Somon', amount: '160 g', category: 'protein'),
            const Ingredient(name: 'Brokoli', amount: '150 g', category: 'vegetable'),
            const Ingredient(name: 'Tatlı patates', amount: '120 g', category: 'vegetable'),
          ]),
        ],
      );
    });

    await store.saveDietPlan(
      DietPlan(
        id: 'plan-mehmet',
        clientId: clientId,
        clientName: client.displayName,
        dietitianId: adminId,
        title: 'Yaz Dengesi – Haftalık Plan',
        weekStart: monday,
        days: days,
      ),
    );

    await store.saveWater(
      WaterLog(userId: clientId, day: dayKey(now), amountMl: 1250, goalMl: 2500),
    );

    await store.saveMeasurement(
      BodyMeasurement(
        id: 'ms-1',
        userId: clientId,
        date: now.subtract(const Duration(days: 28)),
        weight: 91.4,
        waist: 102,
        hip: 108,
        bodyFat: 28.2,
        muscle: 34.1,
      ),
    );
    await store.saveMeasurement(
      BodyMeasurement(
        id: 'ms-2',
        userId: clientId,
        date: now.subtract(const Duration(days: 14)),
        weight: 88.9,
        waist: 99,
        hip: 106,
        bodyFat: 26.8,
        muscle: 34.6,
      ),
    );
    await store.saveMeasurement(
      BodyMeasurement(
        id: 'ms-3',
        userId: clientId,
        date: now,
        weight: 86.7,
        waist: 97,
        hip: 105,
        bodyFat: 25.4,
        muscle: 35.1,
      ),
    );

    await store.saveBlog(
      BlogPost(
        id: 'blog-keto',
        title: 'Keto’ya yumuşak geçiş',
        subtitle: 'İlk 14 günde enerji dipini nasıl yönetirsiniz?',
        authorId: adminId,
        authorName: admin.displayName,
        category: 'Keto',
        tags: const ['keto', 'makro', 'enerji', 'elektrolit'],
        published: true,
        likes: 12,
        coverUrl: 'assets/images/food_green_smoothie.png',
        createdAt: now.subtract(const Duration(days: 4)),
        updatedAt: now.subtract(const Duration(days: 4)),
        body: const [
          RichBlock(type: 'heading', text: 'Neden yumuşak geçiş?', bold: true),
          RichBlock(
            type: 'paragraph',
            text:
                'Ani karbonhidrat kesmek “keto grip” denen yorgunluk, baş ağrısı ve odak dağınıklığını tetikleyebilir. İlk iki hafta hedefiniz performans değil, ritmi oturtmak.',
          ),
          RichBlock(type: 'heading', text: 'Elektrolitleri unutmayın', bold: true),
          RichBlock(
            type: 'paragraph',
            text:
                'Sodyum, potasyum ve magnezyum takviyesi keto grip belirtilerini azaltır. Günde en az 2.5 litre su hedefleyin; terliyorsanız bir tutam ekstra tuz ekleyin.',
          ),
          RichBlock(type: 'quote', text: 'Yağ yakımı bir sprint değil, metabolik bir ritimdir.', italic: true),
          RichBlock(type: 'list', text: 'Avokado, zeytinyağı ve yağlı balığı tabakta tut'),
          RichBlock(type: 'list', text: 'İşlenmiş “keto atıştırmalık” yerine tam gıda seç'),
          RichBlock(type: 'list', text: 'Uyku ve adım sayısını karbonhidrat kadar ciddiye al'),
          RichBlock(
            type: 'paragraph',
            text: 'Diyetisyeninle makroları birlikte gözden geçir; özellikle protein hedefini düşürme.',
          ),
        ],
      ),
    );
    await store.saveBlog(
      BlogPost(
        id: 'blog-if',
        title: 'Aralıklı oruç: 16:8 gerçekten size uygun mu?',
        subtitle: 'Kadın hormonları ve antrenman günleri için nüanslar',
        authorId: adminId,
        authorName: admin.displayName,
        category: 'Aralıklı Oruç',
        tags: const ['if', '16:8', 'hormon', 'antrenman'],
        published: true,
        likes: 7,
        coverUrl: 'assets/images/mascot_avocado.png',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
        body: const [
          RichBlock(type: 'heading', text: '16:8 ne vaat eder?', bold: true),
          RichBlock(
            type: 'paragraph',
            text:
                '16:8 penceresi birçok danışanda işe yarar; ancak yoğun antrenman günlerinde öğle öğününü öne almak daha sürdürülebilirdir.',
          ),
          RichBlock(
            type: 'paragraph',
            text:
                'Kadınlarda aşırı agresif pencereler (örn. 20:4) stres hormonunu yükseltebilir. Belirti: uyku bozulması, döngü düzensizliği, sürekli soğuk hissetmek.',
          ),
          RichBlock(type: 'quote', text: 'Oruç bir ceza değil; yemek ritmine nazik bir çerçeve.', italic: true),
          RichBlock(type: 'list', text: 'Antrenman gününde pencereyi 14:10’a çekmeyi dene'),
          RichBlock(type: 'list', text: 'İlk öğünde protein + sebze öncelikli olsun'),
          RichBlock(type: 'list', text: 'Kafeini aç karnına abartma'),
        ],
      ),
    );
    await store.saveBlog(
      BlogPost(
        id: 'blog-med',
        title: 'Akdeniz tabağı: renkli ve sürdürülebilir',
        subtitle: 'Haftalık menüye zeytinyağı, baklagil ve deniz ürünü nasıl girer?',
        authorId: adminId,
        authorName: admin.displayName,
        category: 'Akdeniz',
        tags: const ['akdeniz', 'kalp', 'zeytinyağı', 'lif'],
        published: true,
        likes: 18,
        coverUrl: 'assets/images/food_salad_bowl.png',
        createdAt: now.subtract(const Duration(days: 6)),
        updatedAt: now.subtract(const Duration(days: 6)),
        body: const [
          RichBlock(
            type: 'paragraph',
            text:
                'Akdeniz tarzı; yasak listesi değil, bolluk listesidir. Zeytinyağı, baklagiller, balık, yoğurt ve bol sebze haftanın omurgası olur.',
          ),
          RichBlock(type: 'heading', text: 'Pratik plaka kuralı', bold: true),
          RichBlock(type: 'list', text: 'Yarım tabak sebze / yeşillik'),
          RichBlock(type: 'list', text: 'Çeyrek tabak protein (balık, baklagil, yumurta)'),
          RichBlock(type: 'list', text: 'Çeyrek tabak kompleks karbonhidrat'),
          RichBlock(type: 'quote', text: 'En iyi diyet, sofrada kalabilen diyettir.', italic: true),
        ],
      ),
    );
    await store.saveBlog(
      BlogPost(
        id: 'blog-detox',
        title: 'Detoks mitleri vs gerçekler',
        subtitle: '3 günlük sıvı kürleri neden çoğu zaman geri teper?',
        authorId: adminId,
        authorName: admin.displayName,
        category: 'Detoks',
        tags: const ['detoks', 'karaciğer', 'su', 'mit'],
        published: true,
        likes: 9,
        coverUrl: 'assets/images/food_lentil_soup.png',
        createdAt: now.subtract(const Duration(days: 9)),
        updatedAt: now.subtract(const Duration(days: 9)),
        body: const [
          RichBlock(
            type: 'paragraph',
            text:
                'Karaciğer ve böbrekler zaten detoks organlarıdır. Aşırı kısıtlı “şok kürleri” kas kaybı ve rebound açlık yaratabilir.',
          ),
          RichBlock(type: 'heading', text: 'Gerçekçi sıfırlama', bold: true),
          RichBlock(type: 'list', text: 'İşlenmiş şekeri 7 gün azalt'),
          RichBlock(type: 'list', text: 'Su hedefini görünür kıl (şişe / uygulama)'),
          RichBlock(type: 'list', text: 'Lif: sebze + baklagil + yoğurt'),
          RichBlock(type: 'quote', text: 'Detoks bir ürün değil; uyku, su ve tabak dengesi.', italic: true),
        ],
      ),
    );
    await store.saveBlog(
      BlogPost(
        id: 'blog-sport',
        title: 'Antrenman günü beslenmesi',
        subtitle: 'Öncesi-sonrası protein ve karbonhidrat zamanlaması',
        authorId: adminId,
        authorName: admin.displayName,
        category: 'Spor',
        tags: const ['spor', 'protein', 'performans', 'toparlanma'],
        published: true,
        likes: 15,
        coverUrl: 'assets/images/character_active_boy.png',
        createdAt: now.subtract(const Duration(hours: 18)),
        updatedAt: now.subtract(const Duration(hours: 18)),
        body: const [
          RichBlock(
            type: 'paragraph',
            text:
                'Ağır antrenman gününde karbonhidratı tamamen kesmek performansı düşürür. Hedef: seans öncesi hafif enerji, sonrası protein + karbonhidrat.',
          ),
          RichBlock(type: 'list', text: 'Seans öncesi: muz + yoğurt veya yulaf'),
          RichBlock(type: 'list', text: 'Seans sonrası: 20–40 g protein + kompleks karb'),
          RichBlock(type: 'list', text: 'Uyku gecikirse ertesi gün antrenmanı kıs'),
          RichBlock(type: 'quote', text: 'Kas mutfakta değil, toparlanmada büyür.', italic: true),
        ],
      ),
    );

    await store.savePayment(
      PaymentRecord(
        id: 'pay-1',
        clientId: clientId,
        clientName: client.displayName,
        amount: 1800,
        status: PaymentStatus.paid,
        date: now.subtract(const Duration(days: 7)),
        note: 'Klinik seansı',
      ),
    );
    await store.savePayment(
      PaymentRecord(
        id: 'pay-2',
        clientId: clientId,
        clientName: client.displayName,
        amount: 4500,
        status: PaymentStatus.due,
        date: now.add(const Duration(days: 5)),
        note: 'Online takip paketi',
      ),
    );
    await store.savePayment(
      PaymentRecord(
        id: 'pay-3',
        clientId: client2Id,
        clientName: elif.displayName,
        amount: 1800,
        status: PaymentStatus.overdue,
        date: now.subtract(const Duration(days: 3)),
        note: 'İlk seans',
      ),
    );

    final thread = await store.ensureThread(admin, client);
    await store.sendMessage(
      ChatMessage(
        id: newId(),
        threadId: thread.id,
        senderId: adminId,
        type: ChatMediaType.text,
        content: 'Merhaba Mehmet, bu haftaki su hedefini 2.5L’de tutalım.',
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      thread,
    );

    await store.saveShoppingList(clientId, [
      const ShoppingItem(
        id: 'shop-oats',
        name: 'Yulaf ezmesi',
        amount: '500 g',
        category: 'grain',
        tip: 'Şekersiz, tam tahıl etiketini tercih et.',
        aisle: 'Kahvaltılık',
        imageUrl: 'assets/images/food_salad_bowl.png',
      ),
      const ShoppingItem(
        id: 'shop-chicken',
        name: 'Tavuk göğsü',
        amount: '1 kg',
        category: 'protein',
        tip: 'Derisiz, porsiyonluk dilimletmek pişirmeyi hızlandırır.',
        aisle: 'Şarküteri / et',
        priority: true,
      ),
      const ShoppingItem(
        id: 'shop-salmon',
        name: 'Somon fileto',
        amount: '700 g',
        category: 'protein',
        tip: 'Omega-3 için haftada 1–2 porsiyon ideal.',
        aisle: 'Balık tezgâhı',
        priority: true,
      ),
      const ShoppingItem(
        id: 'shop-broccoli',
        name: 'Brokoli',
        amount: '2 baş',
        category: 'vegetable',
        tip: 'Sıkı çiçekli, koyu yeşil olanları seç.',
        aisle: 'Sebze',
        imageUrl: 'assets/images/food_green_smoothie.png',
      ),
      const ShoppingItem(
        id: 'shop-spinach',
        name: 'Taze ıspanak',
        amount: '300 g',
        category: 'vegetable',
        tip: 'Omlet ve salata için; yıkayıp kurut, buzdolabında sakla.',
        aisle: 'Sebze',
      ),
      const ShoppingItem(
        id: 'shop-yogurt',
        name: 'Süzme yoğurt',
        amount: '1 kg',
        category: 'dairy',
        tip: 'Yağsız veya %5 — protein atıştırmalıkları için.',
        aisle: 'Süt ürünleri',
      ),
      const ShoppingItem(
        id: 'shop-eggs',
        name: 'Yumurta',
        amount: '10’lu paket',
        category: 'protein',
        tip: 'Kahvaltı ve omlet yedekleri için.',
        aisle: 'Süt ürünleri',
      ),
      const ShoppingItem(
        id: 'shop-quinoa',
        name: 'Quinoa',
        amount: '400 g',
        category: 'grain',
        tip: 'Pilav yerine; 1 su bardağı kuru ≈ 3 kişilik.',
        aisle: 'Bakliyat / tahıl',
      ),
      const ShoppingItem(
        id: 'shop-olive',
        name: 'Zeytinyağı (sızma)',
        amount: '500 ml',
        category: 'other',
        tip: 'Salata için soğuk sıkım tercih et.',
        aisle: 'Yağlar',
        note: 'Cam şişe daha uzun dayanır',
      ),
      const ShoppingItem(
        id: 'shop-lentil',
        name: 'Kırmızı mercimek',
        amount: '500 g',
        category: 'protein',
        tip: 'Çorba ve kase tarifleri için stokta tut.',
        aisle: 'Bakliyat',
        imageUrl: 'assets/images/food_lentil_soup.png',
      ),
      const ShoppingItem(
        id: 'shop-berry',
        name: 'Yaban mersini (dondurulmuş)',
        amount: '400 g',
        category: 'vegetable',
        tip: 'Smoothie ve yulaf için pratik antioksidan.',
        aisle: 'Dondurulmuş',
      ),
      const ShoppingItem(
        id: 'shop-almond',
        name: 'Çiğ badem',
        amount: '200 g',
        category: 'protein',
        tip: 'Porsiyon: bir avuç (~20 g).',
        aisle: 'Kuruyemiş',
      ),
    ]);

    Future<void> seedVaultPdf({
      required String id,
      required String fileName,
      required String title,
      required List<String> lines,
      required String category,
      required String note,
      required int daysAgo,
    }) async {
      final doc = pw.Document();
      doc.addPage(
        pw.MultiPage(
          build: (_) => [
            pw.Text(title, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 12),
            for (final line in lines)
              pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 6),
                child: pw.Text(line),
              ),
          ],
        ),
      );
      final bytes = await doc.save();
      final out = await VaultIO.writeSeedBytes(id: id, fileName: fileName, bytes: bytes);
      await store.saveDocument(
        VaultFile(
          id: id,
          userId: clientId,
          name: fileName,
          path: out.path,
          mime: 'pdf',
          uploadedAt: now.subtract(Duration(days: daysAgo)),
          category: category,
          note: note,
          sizeBytes: bytes.length,
          ownerName: client.displayName,
        ),
      );
    }

    // path_provider / dart:io vault is not available on web preview.
    if (!kIsWeb) {
      await seedVaultPdf(
        id: 'doc-lab-demo',
        fileName: 'Kan_tahlili_ozet.pdf',
        title: 'Kan tahlili özeti (örnek)',
        category: 'lab',
        note: 'Mart kontrol — D vitamini ve demir',
        daysAgo: 12,
        lines: const [
          'Bu örnek PDF belge kasasını denemek içindir.',
          'Gerçek lab sonuçlarını buraya yükleyebilirsin.',
          'D vitamini, ferritin ve B12 değerlerini diyetisyeninle paylaş.',
        ],
      );
      await seedVaultPdf(
        id: 'doc-plan-demo',
        fileName: 'Haftalik_menu_notu.pdf',
        title: 'Haftalık menü notu (örnek)',
        category: 'plan',
        note: 'Ev için pratik menü özeti',
        daysAgo: 5,
        lines: const [
          'Kahvaltı: protein + sebze ağırlıklı.',
          'Öğle: kase veya ızgara protein.',
          'Akşam: hafif çorba veya balık + sebze.',
        ],
      );
      await seedVaultPdf(
        id: 'doc-form-demo',
        fileName: 'Onam_formu_ornek.pdf',
        title: 'Danışan onam formu (örnek)',
        category: 'form',
        note: 'İlk seans evrakı',
        daysAgo: 20,
        lines: const [
          'Kişisel verilerin diyet takibi amacıyla işlenmesine onay.',
          'Bu dosya yalnızca demo amaçlıdır.',
        ],
      );
    }

    await store.saveCheckIn(
      WeeklyCheckIn(
        id: 'ci-1',
        userId: clientId,
        userName: client.displayName,
        createdAt: now.subtract(const Duration(days: 21)),
        weight: 86.4,
        waist: 98,
        mood: 3,
        energy: 3,
        adherence: 3,
        sleepHours: 6.5,
        note: 'İlk hafta alışma süreci. Akşam atıştırmaları zorladı.',
        tags: const ['Stresli hafta'],
      ),
    );
    await store.saveCheckIn(
      WeeklyCheckIn(
        id: 'ci-2',
        userId: clientId,
        userName: client.displayName,
        createdAt: now.subtract(const Duration(days: 14)),
        weight: 85.1,
        waist: 96.5,
        mood: 4,
        energy: 4,
        adherence: 4,
        sleepHours: 7.0,
        note: 'Öğle salataları oturdu. 2 gün yürüyüş yaptım.',
        tags: const ['Spor yaptım', 'Motivasyon yüksek'],
        dietitianNote: 'Harika tempo — akşam proteinini 20 g artıralım.',
        dietitianNoteAt: now.subtract(const Duration(days: 13)),
      ),
    );
    await store.saveCheckIn(
      WeeklyCheckIn(
        id: 'ci-3',
        userId: clientId,
        userName: client.displayName,
        createdAt: now.subtract(const Duration(days: 7)),
        weight: 84.6,
        waist: 95.5,
        mood: 4,
        energy: 3,
        adherence: 4,
        sleepHours: 7.5,
        note: 'Düğün vardı; bir öğünde esnedim ama ertesi gün dengeledim.',
        tags: const ['Sosyal yemek'],
      ),
    );
  }
}
