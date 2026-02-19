import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/patient.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hastaNoController = TextEditingController();
  final _adiController = TextEditingController();
  final _soyadiController = TextEditingController();
  final _bolgeController = TextEditingController();
  final _anamnezController = TextEditingController();
  final _firestoreService = FirestoreService();
  final _authService = AuthService();

  String _cinsiyet = 'Erkek';
  DateTime _dogumTarihi = DateTime(2000, 1, 1);
  bool _isLoading = false;

  @override
  void dispose() {
    _hastaNoController.dispose();
    _adiController.dispose();
    _soyadiController.dispose();
    _bolgeController.dispose();
    _anamnezController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dogumTarihi,
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      locale: const Locale('tr', 'TR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFD32F2F),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF212121),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _dogumTarihi = picked);
    }
  }

  Future<void> _savePatient() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final patient = Patient(
        id: '',
        hastaNo: _hastaNoController.text.trim(),
        adi: _adiController.text.trim(),
        soyadi: _soyadiController.text.trim(),
        cinsiyet: _cinsiyet,
        dogumTarihi: _dogumTarihi,
        bolge: _bolgeController.text.trim(),
        anamnez: _anamnezController.text.trim(),
        doktorId: _authService.currentUser!.uid,
        olusturmaTarihi: DateTime.now(),
        guncellemeTarihi: DateTime.now(),
      );
      await _firestoreService.addPatient(patient);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${patient.tamAd} başarıyla eklendi'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Hasta eklenirken bir hata oluştu'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Hasta Ekle'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hasta Bilgileri Card
              _buildSectionCard(
                title: 'Hasta Bilgileri',
                icon: Icons.person_outline,
                children: [
                  TextFormField(
                    controller: _hastaNoController,
                    decoration: const InputDecoration(
                      labelText: 'Hasta No',
                      prefixIcon: Icon(Icons.tag),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Hasta No gerekli' : null,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _adiController,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Adı',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Ad gerekli' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _soyadiController,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Soyadı',
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Soyad gerekli' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Cinsiyet
                  // ignore: deprecated_member_use
                  DropdownButtonFormField<String>(
                    value: _cinsiyet,
                    decoration: const InputDecoration(
                      labelText: 'Cinsiyet',
                      prefixIcon: Icon(Icons.wc),
                    ),
                    items: ['Erkek', 'Kadın']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _cinsiyet = v!),
                  ),
                  const SizedBox(height: 14),
                  // Doğum Tarihi
                  InkWell(
                    onTap: _selectDate,
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Doğum Tarihi',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        DateFormat('dd.MM.yyyy').format(_dogumTarihi),
                        style: GoogleFonts.poppins(fontSize: 15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _bolgeController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Bölge / Köy',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Bölge gerekli' : null,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Anamnez Card
              _buildSectionCard(
                title: 'Anamnez',
                icon: Icons.description_outlined,
                children: [
                  TextFormField(
                    controller: _anamnezController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText:
                          'Hastanın herhangi bir sistemik rahatsızlığı, kullandığı ilaçlar, alerji hikayesi, başvuru sebebi...',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey.shade400,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Kaydet butonu
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _savePatient,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(
                    _isLoading ? 'Kaydediliyor...' : 'Hastayı Kaydet',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFD32F2F).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFFD32F2F), size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFD32F2F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }
}
