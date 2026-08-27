import 'package:intl/intl.dart';

class DateFormatters {
  static String short(DateTime date) => DateFormat('d MMM yyyy', 'tr').format(date);
  static String dayKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);
  static String time(DateTime date) => DateFormat('HH:mm').format(date);
}
