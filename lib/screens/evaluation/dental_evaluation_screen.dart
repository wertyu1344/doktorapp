import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/dental_evaluation.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

class DentalEvaluationScreen extends StatefulWidget {
  final String patientId;
  const DentalEvaluationScreen({super.key, required this.patientId});

  @override
  State<DentalEvaluationScreen> createState() => _DentalEvaluationScreenState();
}

class _DentalEvaluationScreenState extends State<DentalEvaluationScreen> {
  final _firestoreService = FirestoreService();
  final _authService = AuthService();
  bool _isLoading = false;

  // Diş numaraları
  final List<String> _ustDisler = [
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '21',
    '22',
    '23',
    '24',
    '25',
    '26',
    '27',
    '28',
  ];

  final List<String> _altDisler = [
    '41',
    '42',
    '43',
    '44',
    '45',
    '46',
    '47',
    '48',
    '31',
    '32',
    '33',
    '34',
    '35',
    '36',
    '37',
    '38',
  ];

  // Çocuk dişleri
  final List<String> _cocukUstDisler = [
    '51',
    '52',
    '53',
    '54',
    '55',
    '61',
    '62',
    '63',
    '64',
    '65',
  ];

  final List<String> _cocukAltDisler = [
    '81',
    '82',
    '83',
    '84',
    '85',
    '71',
    '72',
    '73',
    '74',
    '75',
  ];

  // Seçilen dişler ve bulgular
  final Map<String, List<String>> _disNotlari = {};
  final Set<String> _secilenDisler = {};
  bool _cocukDisleriGoster = false;

  final List<String> _bulguSecenekleri = [
    'Çürük',
    'Dolgulu',
    'Kırık',
    'Eksik',
    'Protez',
    'Kanal Tedavisi',
    'Kron',
    'Köprü',
    'İmplant',
    'Mobilite',
    'Hassasiyet',
    'Apse',
    'Sürmemiş',
    'Gömülü',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dental Değerlendirme'),
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
            // Diş Seçim Kartı
            _buildToothSelectionCard(),
            const SizedBox(height: 16),

            // Seçilen Diş Bulguları
            if (_secilenDisler.isNotEmpty) ...[
              _buildSelectedTeethFindings(),
              const SizedBox(height: 16),
            ],

            // Dental Muayene Özet
            _buildSummaryCard(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildToothSelectionCard() {
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
                child: const Icon(
                  Icons.grid_view,
                  color: Color(0xFFD32F2F),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Dental Değerlendirme',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFD32F2F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Toggle: Süt / Kalıcı dişler
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _toggleButton(
                'Kalıcı Dişler',
                !_cocukDisleriGoster,
                () => setState(() => _cocukDisleriGoster = false),
              ),
              const SizedBox(width: 12),
              _toggleButton(
                'Süt Dişleri',
                _cocukDisleriGoster,
                () => setState(() => _cocukDisleriGoster = true),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Üst Dişler
          Text(
            'Üst Çene',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: (_cocukDisleriGoster ? _cocukUstDisler : _ustDisler)
                .map((dis) => _toothButton(dis))
                .toList(),
          ),
          const Divider(height: 28),

          // Alt Dişler
          Text(
            'Alt Çene',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: (_cocukDisleriGoster ? _cocukAltDisler : _altDisler)
                .map((dis) => _toothButton(dis))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _toggleButton(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFD32F2F) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? const Color(0xFFD32F2F) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isActive ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _toothButton(String disNo) {
    final isSelected = _secilenDisler.contains(disNo);
    final hasFinding =
        _disNotlari.containsKey(disNo) && _disNotlari[disNo]!.isNotEmpty;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _secilenDisler.remove(disNo);
          } else {
            _secilenDisler.add(disNo);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: hasFinding
              ? const Color(0xFFD32F2F)
              : isSelected
              ? const Color(0xFFD32F2F).withValues(alpha: 0.15)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected || hasFinding
                ? const Color(0xFFD32F2F)
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
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
        child: Center(
          child: Text(
            disNo,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: hasFinding
                  ? Colors.white
                  : isSelected
                  ? const Color(0xFFD32F2F)
                  : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedTeethFindings() {
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
          Text(
            'Dental Muayene',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Seçilen dişler: ${_secilenDisler.join(", ")}',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 16),

          // Bulgu seçenekleri
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _bulguSecenekleri.map((bulgu) {
              final isAnySelected = _secilenDisler.any(
                (dis) => _disNotlari[dis]?.contains(bulgu) ?? false,
              );
              return FilterChip(
                label: Text(
                  bulgu,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isAnySelected ? Colors.white : Colors.grey.shade700,
                  ),
                ),
                selected: isAnySelected,
                selectedColor: const Color(0xFFD32F2F),
                backgroundColor: Colors.grey.shade50,
                checkmarkColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: isAnySelected
                        ? const Color(0xFFD32F2F)
                        : Colors.grey.shade300,
                  ),
                ),
                onSelected: (selected) {
                  setState(() {
                    for (final dis in _secilenDisler) {
                      if (selected) {
                        _disNotlari.putIfAbsent(dis, () => []);
                        if (!_disNotlari[dis]!.contains(bulgu)) {
                          _disNotlari[dis]!.add(bulgu);
                        }
                      } else {
                        _disNotlari[dis]?.remove(bulgu);
                      }
                    }
                  });
                },
              );
            }).toList(),
          ),

          // + Ekle butonu
          const SizedBox(height: 16),
          Center(
            child: TextButton.icon(
              onPressed: () => _showCustomFindingDialog(),
              icon: const Icon(Icons.add, color: Color(0xFFD32F2F)),
              label: Text(
                '+ Ekle',
                style: GoogleFonts.poppins(
                  color: const Color(0xFFD32F2F),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final entriesWithFindings = _disNotlari.entries
        .where((e) => e.value.isNotEmpty)
        .toList();

    if (entriesWithFindings.isEmpty) {
      return const SizedBox.shrink();
    }

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
          Text(
            'Muayene Özeti',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 12),
          ...entriesWithFindings.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD32F2F),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        entry.key,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: entry.value
                          .map(
                            (b) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFD32F2F,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                b,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: const Color(0xFFD32F2F),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCustomFindingDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Özel Bulgu Ekle',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Bulgu adı girin...'),
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
                  for (final dis in _secilenDisler) {
                    _disNotlari.putIfAbsent(dis, () => []);
                    _disNotlari[dis]!.add(controller.text.trim());
                  }
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
    if (_disNotlari.isEmpty || _disNotlari.values.every((v) => v.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Lütfen en az bir diş için bulgu ekleyin'),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final evaluation = DentalEvaluation(
        id: '',
        patientId: widget.patientId,
        doktorId: _authService.currentUser!.uid,
        disNotlari: Map.from(_disNotlari),
        olusturmaTarihi: DateTime.now(),
      );
      await _firestoreService.addEvaluation(widget.patientId, evaluation);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Dental değerlendirme kaydedildi'),
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
