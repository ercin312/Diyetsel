import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/enums.dart';
import '../models/models.dart';
import 'report_logic.dart';
import '../l10n/ui_string.dart';

class PdfReport {
  static final _orange = PdfColor.fromHex('#FF6B00');
  static final _muted = PdfColor.fromHex('#57534E');

  static pw.Widget _sectionTitle(String text) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 8, top: 4),
        child: pw.Text((text).ui, style: pw.TextStyle(color: _orange, fontWeight: pw.FontWeight.bold, fontSize: 13)),
      );

  static pw.Widget _metricRow(String label, String value) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 6),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text((label).ui, style: pw.TextStyle(color: _muted)),
            pw.Text((value).ui, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ],
        ),
      );

  static Future<void> sharePeriodReport(PeriodReportData report) async {
    final doc = pw.Document();
    final title = report.periodLabel;
    final range =
        '${DateFormat('d MMMM yyyy', 'tr').format(report.start)} – ${DateFormat('d MMMM yyyy', 'tr').format(report.end)}';
    final compliance = (report.dietCompliance * 100).round();

    doc.addPage(
      pw.MultiPage(
        pageTheme: const pw.PageTheme(margin: pw.EdgeInsets.all(32)),
        header: (_) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(('E-DIYET').ui, style: pw.TextStyle(color: _orange, fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.Text((DateFormat('d MMM yyyy', 'tr').format(DateTime.now())).ui, style: pw.TextStyle(color: _muted, fontSize: 10)),
          ],
        ),
        footer: (_) => pw.Center(
          child: pw.Text(('e-Diyet • $title').ui, style: pw.TextStyle(color: _muted, fontSize: 9)),
        ),
        build: (ctx) => [
          pw.Text((title).ui, style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text((report.user.displayName).ui, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.Text((range).ui, style: pw.TextStyle(color: _muted)),
          pw.SizedBox(height: 18),
          pw.Container(
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#FFF4EB'),
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Column(
              children: [
                _metricRow('Su ortalaması', report.waterDays == 0 ? 'Veri yok' : '${(report.avgWaterMl / 1000).toStringAsFixed(1)} L / gün'),
                _metricRow('Su hedefi tutulan gün', '${report.waterGoalDays} / ${report.waterDays}'),
                _metricRow('Diyet uyumu', report.dietMealsTotal == 0 ? 'Plan yok' : '%$compliance (${report.dietMealsConsumed}/${report.dietMealsTotal} öğün)'),
                _metricRow('Aktif seri', '${report.streakCurrent} gün (en iyi ${report.streakBest})'),
                if (report.weightDelta != null)
                  _metricRow(
                    'Kilo değişimi',
                    '${report.weightDelta! <= 0 ? '' : '+'}${report.weightDelta!.toStringAsFixed(1)} kg',
                  ),
                _metricRow('Check-in', '${report.checkIns} kayıt'),
                _metricRow('Seans / randevu', '${report.appointments}'),
                _metricRow('Öğün fotoğrafı', '${report.mealPhotos}'),
              ],
            ),
          ),
          if (report.dailyWater.isNotEmpty) ...[
            _sectionTitle('Günlük su takibi'),
            pw.TableHelper.fromTextArray(
              headers: const ['Gün', 'İçilen', 'Hedef', 'Durum'],
              data: [
                for (final log in report.dailyWater)
                  [
                    DateFormat('d MMM EEE', 'tr').format(_parseDayKey(log.day)),
                    '${log.amountMl} ml',
                    '${log.goalMl} ml',
                    log.progress >= 1 ? 'Tamam' : '%${(log.progress * 100).round()}',
                  ],
              ],
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: _orange, fontSize: 10),
              cellStyle: const pw.TextStyle(fontSize: 10),
            ),
          ],
          if (report.measurements.isNotEmpty) ...[
            _sectionTitle('Ölçümler'),
            pw.TableHelper.fromTextArray(
              headers: const ['Tarih', 'Kilo', 'Bel', 'Yağ %'],
              data: [
                for (final m in report.measurements)
                  [
                    DateFormat('d.MM.yyyy').format(m.date),
                    m.weight?.toStringAsFixed(1) ?? '-',
                    m.waist?.toStringAsFixed(0) ?? '-',
                    m.bodyFat?.toStringAsFixed(0) ?? '-',
                  ],
              ],
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: _orange, fontSize: 10),
              cellStyle: const pw.TextStyle(fontSize: 10),
            ),
          ],
          pw.SizedBox(height: 8),
          pw.Text(('Bu rapor e-Diyet uygulamasındaki kayıtlardan otomatik üretilmiştir.').ui,
            style: pw.TextStyle(color: _muted, fontSize: 9),
          ),
        ],
      ),
    );
    await Printing.layoutPdf(onLayout: (_) => doc.save());
  }

  static DateTime _parseDayKey(String key) {
    final parts = key.split('-');
    return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  }

  static Future<void> shareClientReport({
    required UserProfile user,
    DietPlan? plan,
    required List<BodyMeasurement> measurements,
    required List<Appointment> appointments,
  }) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageTheme: const pw.PageTheme(margin: pw.EdgeInsets.all(32)),
        header: (_) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(('E-DIYET').ui, style: pw.TextStyle(color: _orange, fontSize: 22, fontWeight: pw.FontWeight.bold)),
            pw.Text((DateFormat('d MMMM yyyy', 'tr').format(DateTime.now())).ui),
          ],
        ),
        build: (ctx) => [
          pw.Text(('Tam geçmiş raporu').ui, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.Text((user.displayName).ui, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.Text((user.email).ui),
          pw.SizedBox(height: 16),
          _sectionTitle('Diyet planı'),
          if (plan == null)
            pw.Text(('Atanmış plan yok.').ui)
          else
            ...plan.days.map(
              (day) => pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(height: 8),
                  pw.Text((DateFormat('EEEE d MMM', 'tr').format(day.date)).ui, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ...day.meals.map((m) => pw.Bullet(
                        text: '${m.type.tr} — ${m.name} (${m.calories} kcal)${m.consumed ? ' ✓' : ''}',
                      )),
                ],
              ),
            ),
          pw.SizedBox(height: 16),
          _sectionTitle('Ölçüm geçmişi'),
          if (measurements.isEmpty)
            pw.Text(('Kayıt yok.').ui)
          else
            pw.TableHelper.fromTextArray(
              headers: const ['Tarih', 'Kilo', 'Bel', 'Yağ'],
              data: [
                for (final m in measurements)
                  [
                    DateFormat('d.MM.yyyy').format(m.date),
                    '${m.weight ?? '-'}',
                    '${m.waist ?? '-'}',
                    '${m.bodyFat ?? '-'}',
                  ],
              ],
            ),
          pw.SizedBox(height: 16),
          _sectionTitle('Klinik notlar'),
          if (appointments.where((a) => a.clinicalNotes != null).isEmpty)
            pw.Text(('Not yok.').ui)
          else
            ...appointments.where((a) => a.clinicalNotes != null).map(
                  (a) => pw.Paragraph(
                    text: '${DateFormat('d.MM.yyyy').format(a.startAt)}: ${a.clinicalNotes} ${a.recommendations ?? ''}',
                  ),
                ),
        ],
      ),
    );
    await Printing.layoutPdf(onLayout: (_) => doc.save());
  }

  static Future<void> sharePracticeSummary({
    required List<UserProfile> clients,
    required List<Appointment> appointments,
    required List<PaymentRecord> payments,
  }) async {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(('e-Diyet Klinik Özeti').ui, style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 12),
            pw.Text(('Danışan sayısı: ${clients.length}').ui),
            pw.Text(('Randevu sayısı: ${appointments.length}').ui),
            pw.Text(('Ciro (tahsil): ₺${payments.where((p) => p.status == PaymentStatus.paid).fold<double>(0, (s, p) => s + p.amount).toStringAsFixed(0)}').ui,
            ),
          ],
        ),
      ),
    );
    await Printing.layoutPdf(onLayout: (_) => doc.save());
  }
}
