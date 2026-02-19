import 'package:cloud_firestore/cloud_firestore.dart';

class Patient {
  final String id;
  final String hastaNo;
  final String adi;
  final String soyadi;
  final String cinsiyet;
  final DateTime dogumTarihi;
  final String bolge;
  final String anamnez;
  final List<String> fotograflar;
  final String doktorId;
  final DateTime olusturmaTarihi;
  final DateTime guncellemeTarihi;

  Patient({
    required this.id,
    required this.hastaNo,
    required this.adi,
    required this.soyadi,
    required this.cinsiyet,
    required this.dogumTarihi,
    required this.bolge,
    this.anamnez = '',
    this.fotograflar = const [],
    required this.doktorId,
    required this.olusturmaTarihi,
    required this.guncellemeTarihi,
  });

  String get tamAd => '$adi $soyadi';

  int get yas {
    final now = DateTime.now();
    int age = now.year - dogumTarihi.year;
    if (now.month < dogumTarihi.month ||
        (now.month == dogumTarihi.month && now.day < dogumTarihi.day)) {
      age--;
    }
    return age;
  }

  factory Patient.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Patient(
      id: doc.id,
      hastaNo: data['hastaNo'] ?? '',
      adi: data['adi'] ?? '',
      soyadi: data['soyadi'] ?? '',
      cinsiyet: data['cinsiyet'] ?? '',
      dogumTarihi: (data['dogumTarihi'] as Timestamp).toDate(),
      bolge: data['bolge'] ?? '',
      anamnez: data['anamnez'] ?? '',
      fotograflar: List<String>.from(data['fotograflar'] ?? []),
      doktorId: data['doktorId'] ?? '',
      olusturmaTarihi: (data['olusturmaTarihi'] as Timestamp).toDate(),
      guncellemeTarihi: (data['guncellemeTarihi'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'hastaNo': hastaNo,
      'adi': adi,
      'soyadi': soyadi,
      'cinsiyet': cinsiyet,
      'dogumTarihi': Timestamp.fromDate(dogumTarihi),
      'bolge': bolge,
      'anamnez': anamnez,
      'fotograflar': fotograflar,
      'doktorId': doktorId,
      'olusturmaTarihi': Timestamp.fromDate(olusturmaTarihi),
      'guncellemeTarihi': Timestamp.fromDate(guncellemeTarihi),
    };
  }

  Patient copyWith({
    String? id,
    String? hastaNo,
    String? adi,
    String? soyadi,
    String? cinsiyet,
    DateTime? dogumTarihi,
    String? bolge,
    String? anamnez,
    List<String>? fotograflar,
    String? doktorId,
    DateTime? olusturmaTarihi,
    DateTime? guncellemeTarihi,
  }) {
    return Patient(
      id: id ?? this.id,
      hastaNo: hastaNo ?? this.hastaNo,
      adi: adi ?? this.adi,
      soyadi: soyadi ?? this.soyadi,
      cinsiyet: cinsiyet ?? this.cinsiyet,
      dogumTarihi: dogumTarihi ?? this.dogumTarihi,
      bolge: bolge ?? this.bolge,
      anamnez: anamnez ?? this.anamnez,
      fotograflar: fotograflar ?? this.fotograflar,
      doktorId: doktorId ?? this.doktorId,
      olusturmaTarihi: olusturmaTarihi ?? this.olusturmaTarihi,
      guncellemeTarihi: guncellemeTarihi ?? this.guncellemeTarihi,
    );
  }
}
