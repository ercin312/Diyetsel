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
      displayName: 'Dyt. Ayşe Kalorist',
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
    await store.saveCredential(admin.email, hashPassword(AppConstants.demoPassword));
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
        description: 'Haftalık check-in, mesajlaşma ve dinamik diyet revizyonu.',
        price: 4500,
        durationMinutes: 30,
        bullets: ['4 görüntülü seans', '7/24 mesaj', 'Alışveriş listesi', 'Makro revizyonu'],
      ),
    );
    await store.saveService(
      const ServicePackage(
        id: 'svc-clinic',
        title: 'Yüz Yüze Klinik Seansı',
        description: 'Ölçüm, analiz ve kişiselleştirilmiş planlama.',
        price: 1800,
        durationMinutes: 45,
        bullets: ['InBody analizi', 'Seans notları', 'PDF rapor'],
      ),
    );
    await store.saveService(
      const ServicePackage(
        id: 'svc-detox',
        title: 'Detoks Programı',
        description: '7 günlük sıfırlama protokolü ve tarif rehberi.',
        price: 2200,
        durationMinutes: 20,
        bullets: ['7 günlük menü', 'Bitki çayı protokolü', 'Su hedefi'],
      ),
    );

    DietMeal meal(String id, MealType type, String name, String desc, int c, int p, int k, int f, List<Ingredient> ing) =>
        DietMeal(id: id, type: type, name: name, description: desc, calories: c, protein: p, carbs: k, fat: f, ingredients: ing);

    final days = List.generate(7, (i) {
      final date = monday.add(Duration(days: i));
      return DietDay(
        date: date,
        meals: [
          meal('m-$i-b', MealType.breakfast, 'Yoğurtlu yulaf', 'Yulaf, yaban mersini, chia', 420, 28, 48, 12, [
            const Ingredient(name: 'Yulaf', amount: '50 g', category: 'grain'),
            const Ingredient(name: 'Yoğurt', amount: '150 g', category: 'dairy'),
            const Ingredient(name: 'Yaban mersini', amount: '80 g', category: 'vegetable'),
          ]),
          meal('m-$i-s1', MealType.morningSnack, 'Badem', 'Bir avuç badem', 160, 6, 6, 14, [
            const Ingredient(name: 'Badem', amount: '20 g', category: 'protein'),
          ]),
          meal('m-$i-l', MealType.lunch, 'Izgara tavuk salata', 'Roka, quinoa, zeytinyağı', 540, 42, 38, 18, [
            const Ingredient(name: 'Tavuk göğsü', amount: '150 g', category: 'protein'),
            const Ingredient(name: 'Quinoa', amount: '60 g', category: 'grain'),
            const Ingredient(name: 'Roka', amount: '1 kase', category: 'vegetable'),
          ]),
          meal('m-$i-s2', MealType.afternoonSnack, 'Kefir', 'Sade kefir', 110, 8, 9, 3, [
            const Ingredient(name: 'Kefir', amount: '200 ml', category: 'dairy'),
          ]),
          meal('m-$i-d', MealType.dinner, 'Fırın somon', 'Somon, brokoli, tatlı patates', 610, 38, 32, 28, [
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
        tags: const ['keto', 'makro', 'enerji'],
        published: true,
        likes: 12,
        createdAt: now.subtract(const Duration(days: 4)),
        updatedAt: now.subtract(const Duration(days: 4)),
        body: const [
          RichBlock(type: 'heading', text: 'Elektrolitleri unutmayın', bold: true),
          RichBlock(
            type: 'paragraph',
            text: 'Sodyum, potasyum ve magnezyum takviyesi keto grip belirtilerini azaltır. Günde en az 2.5 litre su hedefleyin.',
          ),
          RichBlock(type: 'quote', text: 'Yağ yakımı bir sprint değil, metabolik bir ritimdir.', italic: true),
          RichBlock(type: 'list', text: 'Avokado • Zeytinyağı • Yağlı balık • Yapraklı yeşillikler'),
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
        tags: const ['if', '16:8', 'hormon'],
        published: true,
        likes: 7,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
        body: const [
          RichBlock(
            type: 'paragraph',
            text: '16:8 penceresi birçok danışanda işe yarar; ancak yoğun antrenman günlerinde öğle öğününü öne almak daha sürdürülebilirdir.',
          ),
        ],
      ),
    );

    await store.saveRecipe(
      const Recipe(
        id: 'rcp-bowl',
        title: 'Akdeniz protein kasesi',
        description: 'Nohut, quinoa ve bol yeşillik.',
        calories: 480,
        prepMinutes: 25,
        proteinGrams: 28,
        allergens: ['gluten (opsiyonel)'],
        category: 'Öğle',
        steps: [
          'Quinoyu haşla.',
          'Nohutu zeytinyağı ve baharatla kavur.',
          'Roka, salatalık ve nar ile birleştir.',
        ],
        ingredients: [
          Ingredient(name: 'Quinoa', amount: '70 g', category: 'grain'),
          Ingredient(name: 'Nohut', amount: '120 g', category: 'protein'),
          Ingredient(name: 'Roka', amount: '1 kase', category: 'vegetable'),
        ],
      ),
    );
    await store.saveRecipe(
      const Recipe(
        id: 'rcp-soup',
        title: 'Mercimek çorbası',
        description: 'Demir deposu, tok tutan klasik.',
        calories: 310,
        prepMinutes: 35,
        proteinGrams: 18,
        allergens: [],
        category: 'Akşam',
        steps: ['Soğanı kavur', 'Mercimeği ekle', 'Blenderdan geçir'],
        ingredients: [
          Ingredient(name: 'Kırmızı mercimek', amount: '100 g', category: 'protein'),
          Ingredient(name: 'Soğan', amount: '1 adet', category: 'vegetable'),
        ],
      ),
    );
    await store.saveRecipe(
      const Recipe(
        id: 'rcp-yogurt',
        title: 'Cevizli yoğurt kasesi',
        description: 'Hızlı kahvaltı, yüksek protein.',
        calories: 290,
        prepMinutes: 5,
        proteinGrams: 22,
        allergens: ['süt', 'kuruyemiş'],
        category: 'Kahvaltı',
        steps: ['Yoğurdu kaseye al', 'Ceviz ve tarçın ekle'],
        ingredients: [
          Ingredient(name: 'Yoğurt', amount: '200 g', category: 'dairy'),
          Ingredient(name: 'Ceviz', amount: '15 g', category: 'protein'),
        ],
      ),
    );
    await store.saveRecipe(
      const Recipe(
        id: 'rcp-salmon',
        title: 'Fırında somon & brokoli',
        description: 'Omega-3 ve yüksek proteinli akşam tabağı.',
        calories: 420,
        prepMinutes: 30,
        proteinGrams: 34,
        allergens: ['balık'],
        category: 'Akşam',
        steps: ['Somonu baharatla', 'Brokoliyi buharda pişir', 'Limonla servis et'],
        ingredients: [
          Ingredient(name: 'Somon fileto', amount: '160 g', category: 'protein'),
          Ingredient(name: 'Brokoli', amount: '200 g', category: 'vegetable'),
        ],
      ),
    );
    await store.saveRecipe(
      const Recipe(
        id: 'rcp-omlet',
        title: 'Sebzeli protein omlet',
        description: 'Ispanak ve mantarlı tok tutan kahvaltı.',
        calories: 340,
        prepMinutes: 12,
        proteinGrams: 26,
        allergens: ['yumurta', 'süt'],
        category: 'Kahvaltı',
        steps: ['Sebzeleri sotele', 'Yumurtaları çırp', 'Kısık ateşte pişir'],
        ingredients: [
          Ingredient(name: 'Yumurta', amount: '3 adet', category: 'protein'),
          Ingredient(name: 'Ispanak', amount: '1 avuç', category: 'vegetable'),
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
      const ShoppingItem(name: 'Yulaf', amount: '350 g', category: 'grain'),
      const ShoppingItem(name: 'Tavuk göğsü', amount: '1 kg', category: 'protein'),
      const ShoppingItem(name: 'Somon', amount: '700 g', category: 'protein'),
      const ShoppingItem(name: 'Brokoli', amount: '5 adet', category: 'vegetable'),
      const ShoppingItem(name: 'Yoğurt', amount: '1 kg', category: 'dairy'),
    ]);
  }
}
