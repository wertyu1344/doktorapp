import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/dental_evaluation.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

class GeneralEvaluationScreen extends StatefulWidget {
  final String patientId;
  const GeneralEvaluationScreen({super.key, required this.patientId});

  @override
  State<GeneralEvaluationScreen> createState() =>
      _GeneralEvaluationScreenState();
}

class _GeneralEvaluationScreenState extends State<GeneralEvaluationScreen> {
  final _firestoreService = FirestoreService();
  final _authService = AuthService();
  bool _isLoading = false;

  // Diş Eti Muayenesi
  String _disEtiDurumu = '';
  final List<String> _disEtiSecenekleri = [
    'Kanama Yok',
    'Hafif Kanama',
    'Orta Kanama',
    'Şiddetli Kanama',
    'Hiperplazi',
    'Çekilme',
    'Renk Değişikliği',
    'Ödem',
    'Normal',
  ];

  // Periodontal Muayene
  String _periodontalDurum = '';
  final List<String> _periodontalSecenekleri = [
    'Hafif Plak',
    'Orta Plak',
    'Yoğun Plak',
    'Diştaşı Yok',
    'Hafif Diştaşı',
    'Yoğun Diştaşı',
    'Cep Derinliği Normal',
    'Cep Derinliği Artmış',
    'Mobilite',
    'Furkasyon',
    'Normal',
  ];

  // Genel Notlar
  final _notlarController = TextEditingController();

  // Ek muayene alanları
  final List<Map<String, dynamic>> _ekMuayeneler = [];

  @override
  void dispose() {
    _notlarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Genel Değerlendirme'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton.icon(
            onPressed: _isLoading ? null : _saveEvaluation,
            icon: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.save, color: Colors.white),
            label: Text(
              'Kaydet',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Diş Eti Muayenesi
            _buildSectionCard(
              title: 'Diş Eti Muayenesi',
              icon: Icons.health_and_safety_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _disEtiSecenekleri
                        .map(
                          (secenek) => _selectionChip(
                            label: secenek,
                            isSelected: _disEtiDurumu == secenek,
                            onSelected: () =>
                                setState(() => _disEtiDurumu = secenek),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Periodontal Muayene
            _buildSectionCard(
              title: 'Periodontal Muayene',
              icon: Icons.biotech_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _periodontalSecenekleri
                        .map(
                          (secenek) => _selectionChip(
                            label: secenek,
                            isSelected: _periodontalDurum == secenek,
                            onSelected: () =>
                                setState(() => _periodontalDurum = secenek),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Ek muayeneler
            ..._ekMuayeneler.asMap().entries.map((entry) {
              final index = entry.key;
              final muayene = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildSectionCard(
                  title: muayene['baslik'] ?? 'Ek Muayene',
                  icon: Icons.add_circle_outline,
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _ekMuayeneler.removeAt(index)),
                  ),
                  child: TextField(
                    controller: muayene['controller'] as TextEditingController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Notlarınızı girin...',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey.shade400,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              );
            }),

            // + Ekle butonu
            Center(
              child: OutlinedButton.icon(
                onPressed: _showAddFieldDialog,
                icon: const Icon(Icons.add, color: Color(0xFFD32F2F)),
                label: Text(
                  '+ Ekle',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFD32F2F),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFD32F2F)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Genel Notlar
            _buildSectionCard(
              title: 'Genel Notlar',
              icon: Icons.note_outlined,
              child: TextField(
                controller: _notlarController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Ek notlarınızı buraya yazın...',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey.shade400,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
    Widget? trailing,
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
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFD32F2F),
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _selectionChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return GestureDetector(
      onTap: onSelected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD32F2F) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFD32F2F) : Colors.grey.shade300,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFD32F2F).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  void _showAddFieldDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Yeni Alan Ekle',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Alan adı girin...',
            labelText: 'Alan Başlığı',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  _ekMuayeneler.add({
                    'baslik': controller.text.trim(),
                    'controller': TextEditingController(),
                  });
                });
                Navigator.pop(context);
              }
            },
            child: Text('Ekle', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  Future<void> _saveEvaluation() async {
    if (_disEtiDurumu.isEmpty && _periodontalDurum.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Lütfen en az bir değerlendirme seçin'),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Ek notları birleştir
      final ekNotlar = _ekMuayeneler
          .map(
            (m) =>
                '${m['baslik']}: ${(m['controller'] as TextEditingController).text}',
          )
          .where((s) => s.isNotEmpty)
          .join('\n');

      final genelNotlar = [
        _notlarController.text.trim(),
        ekNotlar,
      ].where((s) => s.isNotEmpty).join('\n\n');

      final evaluation = DentalEvaluation(
        id: '',
        patientId: widget.patientId,
        doktorId: _authService.currentUser!.uid,
        disEtiMuayenesi: _disEtiDurumu,
        periodontalMuayene: _periodontalDurum,
        genelNotlar: genelNotlar,
        olusturmaTarihi: DateTime.now(),
      );
      await _firestoreService.addEvaluation(widget.patientId, evaluation);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Genel değerlendirme kaydedildi'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Değerlendirme kaydedilemedi'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
