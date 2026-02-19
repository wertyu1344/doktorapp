import 'package:cloud_firestore/cloud_firestore.dart';

class DentalEvaluation {
  final String id;
  final String patientId;
  final String doktorId;
  final Map<String, List<String>> disNotlari; // diş no -> bulgular listesi
  final String disEtiMuayenesi;
  final String periodontalMuayene;
  final String genelNotlar;
  final DateTime olusturmaTarihi;

  DentalEvaluation({
    required this.id,
    required this.patientId,
    required this.doktorId,
    this.disNotlari = const {},
    this.disEtiMuayenesi = '',
    this.periodontalMuayene = '',
    this.genelNotlar = '',
    required this.olusturmaTarihi,
  });

  factory DentalEvaluation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final rawNotlar = data['disNotlari'] as Map<String, dynamic>? ?? {};
    final Map<String, List<String>> parsedNotlar = {};
    rawNotlar.forEach((key, value) {
      parsedNotlar[key] = List<String>.from(value);
    });

    return DentalEvaluation(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      doktorId: data['doktorId'] ?? '',
      disNotlari: parsedNotlar,
      disEtiMuayenesi: data['disEtiMuayenesi'] ?? '',
      periodontalMuayene: data['periodontalMuayene'] ?? '',
      genelNotlar: data['genelNotlar'] ?? '',
      olusturmaTarihi: (data['olusturmaTarihi'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'patientId': patientId,
      'doktorId': doktorId,
      'disNotlari': disNotlari,
      'disEtiMuayenesi': disEtiMuayenesi,
      'periodontalMuayene': periodontalMuayene,
      'genelNotlar': genelNotlar,
      'olusturmaTarihi': Timestamp.fromDate(olusturmaTarihi),
    };
  }
}
