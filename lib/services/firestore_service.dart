import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/patient.dart';
import '../models/dental_evaluation.dart';
import 'auth_service.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  String get _uid => _authService.currentUser!.uid;

  // ============ HASTA İŞLEMLERİ ============

  CollectionReference get _patientsRef => _db.collection('patients');

  Stream<List<Patient>> getPatientsStream() {
    return _patientsRef
        .where('doktorId', isEqualTo: _uid)
        .orderBy('olusturmaTarihi', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Patient.fromFirestore(doc)).toList(),
        );
  }

  Future<Patient> getPatient(String patientId) async {
    final doc = await _patientsRef.doc(patientId).get();
    return Patient.fromFirestore(doc);
  }

  Future<String> addPatient(Patient patient) async {
    final docRef = await _patientsRef.add(patient.toFirestore());
    return docRef.id;
  }

  Future<void> updatePatient(Patient patient) async {
    await _patientsRef.doc(patient.id).update(patient.toFirestore());
  }

  Future<void> deletePatient(String patientId) async {
    // Alt koleksiyonları da sil
    final evaluations = await _patientsRef
        .doc(patientId)
        .collection('evaluations')
        .get();
    for (var doc in evaluations.docs) {
      await doc.reference.delete();
    }
    await _patientsRef.doc(patientId).delete();
  }

  Future<void> addPhotoToPatient(String patientId, PatientPhoto photo) async {
    await _patientsRef.doc(patientId).update({
      'fotograflar': FieldValue.arrayUnion([photo.toMap()]),
      'guncellemeTarihi': Timestamp.now(),
    });
  }

  Future<void> removePhotoFromPatient(
    String patientId,
    PatientPhoto photo,
  ) async {
    await _patientsRef.doc(patientId).update({
      'fotograflar': FieldValue.arrayRemove([photo.toMap()]),
      'guncellemeTarihi': Timestamp.now(),
    });
  }

  Future<void> updatePhotoLabel(
    String patientId,
    String photoUrl,
    String newLabel,
  ) async {
    final doc = await _patientsRef.doc(patientId).get();
    final patient = Patient.fromFirestore(doc);

    final updatedPhotos = patient.fotograflar.map((p) {
      if (p.url == photoUrl) {
        return PatientPhoto(url: p.url, label: newLabel);
      }
      return p;
    }).toList();

    await _patientsRef.doc(patientId).update({
      'fotograflar': updatedPhotos.map((p) => p.toMap()).toList(),
      'guncellemeTarihi': Timestamp.now(),
    });
  }

  Future<void> updateAnamnez(String patientId, String anamnez) async {
    await _patientsRef.doc(patientId).update({
      'anamnez': anamnez,
      'guncellemeTarihi': Timestamp.now(),
    });
  }

  // ============ DEĞERLENDİRME İŞLEMLERİ ============

  CollectionReference _evaluationsRef(String patientId) =>
      _patientsRef.doc(patientId).collection('evaluations');

  Stream<List<DentalEvaluation>> getEvaluationsStream(String patientId) {
    return _evaluationsRef(patientId)
        .orderBy('olusturmaTarihi', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => DentalEvaluation.fromFirestore(doc))
              .toList(),
        );
  }

  Future<String> addEvaluation(
    String patientId,
    DentalEvaluation evaluation,
  ) async {
    final docRef = await _evaluationsRef(
      patientId,
    ).add(evaluation.toFirestore());
    return docRef.id;
  }

  Future<void> updateEvaluation(
    String patientId,
    DentalEvaluation evaluation,
  ) async {
    await _evaluationsRef(
      patientId,
    ).doc(evaluation.id).update(evaluation.toFirestore());
  }

  Future<void> deleteEvaluation(String patientId, String evaluationId) async {
    await _evaluationsRef(patientId).doc(evaluationId).delete();
  }

  // ============ İSTATİSTİKLER ============

  Future<int> getPatientCount() async {
    final snapshot = await _patientsRef
        .where('doktorId', isEqualTo: _uid)
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  Future<int> getTodayPatientCount() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await _patientsRef
        .where('doktorId', isEqualTo: _uid)
        .where(
          'olusturmaTarihi',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .where('olusturmaTarihi', isLessThan: Timestamp.fromDate(endOfDay))
        .count()
        .get();
    return snapshot.count ?? 0;
  }
}
