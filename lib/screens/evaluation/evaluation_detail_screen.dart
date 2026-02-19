import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/dental_evaluation.dart';
import '../../models/patient.dart';

class EvaluationDetailScreen extends StatelessWidget {
  final DentalEvaluation evaluation;
  final Patient patient;

  const EvaluationDetailScreen({
    super.key,
    required this.evaluation,
    required this.patient,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Muayene Detayı'),
        backgroundColor: const Color(0xFFD32F2F),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hasta Künyesi
            _buildSectionHeader(Icons.person_outline, 'Hasta Bilgileri'),
            _buildInfoTile('Ad Soyad', patient.tamAd),
            _buildInfoTile(
              'Muayene Tarihi',
              DateFormat(
                'dd MMMM yyyy HH:mm',
                'tr_TR',
              ).format(evaluation.olusturmaTarihi),
            ),
            const SizedBox(height: 24),

            // Diş Bulguları
            if (evaluation.disNotlari.isNotEmpty) ...[
              _buildSectionHeader(Icons.straighten, 'Diş Bulguları'),
              const SizedBox(height: 12),
              ...evaluation.disNotlari.entries.map(
                (entry) => _buildToothFindingsRow(entry.key, entry.value),
              ),
              const SizedBox(height: 24),
            ],

            // Diş Eti
            if (evaluation.disEtiMuayenesi.isNotEmpty) ...[
              _buildSectionHeader(
                Icons.health_and_safety_outlined,
                'Diş Eti Muayenesi',
              ),
              _buildLargeTextCard(evaluation.disEtiMuayenesi),
              const SizedBox(height: 24),
            ],

            // Periodontal
            if (evaluation.periodontalMuayene.isNotEmpty) ...[
              _buildSectionHeader(
                Icons.biotech_outlined,
                'Periodontal Muayene',
              ),
              _buildLargeTextCard(evaluation.periodontalMuayene),
              const SizedBox(height: 24),
            ],

            // Genel Notlar
            if (evaluation.genelNotlar.isNotEmpty) ...[
              _buildSectionHeader(Icons.sticky_note_2_outlined, 'Genel Notlar'),
              _buildLargeTextCard(evaluation.genelNotlar, isNote: true),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFD32F2F), size: 22),
          const SizedBox(width: 8),
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
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(color: const Color(0xFF212121)),
          ),
        ],
      ),
    );
  }

  Widget _buildToothFindingsRow(String toothNo, List<String> findings) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFD32F2F),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                toothNo,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              findings.join(', '),
              style: GoogleFonts.poppins(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLargeTextCard(String text, {bool isNote = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isNote ? Colors.orange.withOpacity(0.05) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isNote ? Colors.orange.withOpacity(0.2) : Colors.grey.shade200,
        ),
      ),
      child: Text(text, style: GoogleFonts.poppins(fontSize: 15, height: 1.5)),
    );
  }
}
