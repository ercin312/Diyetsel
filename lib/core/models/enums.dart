enum UserRole { admin, client }

enum VisualStyle { modern, cartoon }

enum AppointmentStatus { pending, approved, rejected, rescheduled, completed }

enum MealType { breakfast, morningSnack, lunch, afternoonSnack, dinner }

enum ChatMediaType { text, image, audio, file, mealPhoto }

enum PaymentStatus { paid, due, overdue }

extension UserRoleX on UserRole {
  String get storage => name;
  static UserRole from(String? value) =>
      UserRole.values.firstWhere((e) => e.name == value, orElse: () => UserRole.client);
}

extension MealTypeX on MealType {
  String get tr {
    switch (this) {
      case MealType.breakfast:
        return 'Kahvaltı';
      case MealType.morningSnack:
        return 'Ara Öğün';
      case MealType.lunch:
        return 'Öğle';
      case MealType.afternoonSnack:
        return 'İkindi';
      case MealType.dinner:
        return 'Akşam';
    }
  }

  String get emoji {
    switch (this) {
      case MealType.breakfast:
        return '🍳';
      case MealType.morningSnack:
        return '🍎';
      case MealType.lunch:
        return '🥗';
      case MealType.afternoonSnack:
        return '🥛';
      case MealType.dinner:
        return '🍽️';
    }
  }

  String get en {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.morningSnack:
        return 'Snack';
      case MealType.lunch:
        return 'Lunch';
      case MealType.afternoonSnack:
        return 'Afternoon snack';
      case MealType.dinner:
        return 'Dinner';
    }
  }
}
