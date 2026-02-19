import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/patient.dart';
import '../../models/dental_evaluation.dart';
import '../../services/firestore_service.dart';
import '../../services/storage_service.dart';
import '../evaluation/dental_evaluation_screen.dart';
import '../evaluation/general_evaluation_screen.dart';
import '../evaluation/evaluation_detail_screen.dart';

class PatientDetailScreen extends StatefulWidget {
  final String patientId;
  const PatientDetailScreen({super.key, required this.patientId});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  final _firestoreService = FirestoreService();
  final _storageService = StorageService();
  bool _isUploadingPhoto = false;
  int _currentPhotoIndex = 0;
  final PageController _photoPageController = PageController();
  late final Stream<Patient> _patientStream;

  @override
  void initState() {
    super.initState();
    _patientStream = _firestoreService.getPatientsStream().map(
      (patients) => patients.firstWhere((p) => p.id == widget.patientId),
    );
  }

  @override
  void dispose() {
    _photoPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Patient>(
      stream: _patientStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Hasta Detayı')),
            body: const Center(
              child: CircularProgressIndicator(color: Color(0xFFD32F2F)),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('Hasta Detayı')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Hasta bilgisi yüklenemedi',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final patient = snapshot.data!;
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // App Bar with photo carousel
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.more_vert,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    onPressed: () => _showOptionsMenu(context, patient),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildPhotoCarousel(patient),
                ),
              ),

              // Patient Info
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Hasta Bilgileri
                      _buildInfoCard(patient),
                      const SizedBox(height: 16),

                      // Anamnez
                      _buildAnamnezCard(patient),
                      const SizedBox(height: 16),

                      // Muayene Geçmişi
                      _buildEvaluationsCard(patient),
                      const SizedBox(height: 16),

                      // Fotoğraf Yönetimi
                      _buildPhotoManagementCard(patient),
                      const SizedBox(height: 16),

                      // Değerlendirme Butonları
                      _buildEvaluationButtons(patient),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPhotoCarousel(Patient patient) {
    if (patient.fotograflar.isEmpty) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFD32F2F), Color(0xFFB71C1C)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Icon(
                Icons.camera_alt_outlined,
                size: 64,
                color: Colors.white.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 12),
              Text(
                'Henüz fotoğraf eklenmemiş',
                style: GoogleFonts.poppins(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        PageView.builder(
          key: ValueKey('photo_carousel_${patient.fotograflar.length}'),
          controller: _photoPageController,
          itemCount: patient.fotograflar.length,
          onPageChanged: (index) {
            if (mounted) {
              setState(() => _currentPhotoIndex = index);
            }
          },
          itemBuilder: (context, index) {
            if (index >= patient.fotograflar.length)
              return const SizedBox.shrink();
            final photo = patient.fotograflar[index];
            return GestureDetector(
              onTap: () =>
                  _showFullScreenPhoto(context, patient.fotograflar, index),
              child: CachedNetworkImage(
                imageUrl: photo.url,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: CircularProgressIndicator(color: Color(0xFFD32F2F)),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.broken_image, size: 48),
                ),
              ),
            );
          },
        ),
        // Photo label
        Positioned(
          bottom: 60,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              (patient.fotograflar.isNotEmpty &&
                      _currentPhotoIndex < patient.fotograflar.length)
                  ? (patient.fotograflar[_currentPhotoIndex].label.isEmpty
                        ? 'Fotoğraf ${_currentPhotoIndex + 1}'
                        : patient.fotograflar[_currentPhotoIndex].label)
                  : 'Fotoğraf',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        // Navigation arrows
        if (patient.fotograflar.length > 1) ...[
          Positioned(
            left: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: IconButton(
                onPressed: _currentPhotoIndex > 0
                    ? () => _photoPageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      )
                    : null,
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.chevron_left, color: Colors.white),
                ),
              ),
            ),
          ),
          Positioned(
            right: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: IconButton(
                onPressed: _currentPhotoIndex < patient.fotograflar.length - 1
                    ? () => _photoPageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      )
                    : null,
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.chevron_right, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
        // Page indicator
        if (patient.fotograflar.length > 1)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                patient.fotograflar.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _currentPhotoIndex == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPhotoIndex == index
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoCard(Patient patient) {
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
                  Icons.info_outline,
                  color: Color(0xFFD32F2F),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Hasta Bilgileri',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFD32F2F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _infoRow('Hasta No', patient.hastaNo),
          _infoRow('Ad Soyad', patient.tamAd),
          _infoRow('Cinsiyet', patient.cinsiyet),
          _infoRow(
            'Doğum Tarihi',
            '${DateFormat('dd.MM.yyyy').format(patient.dogumTarihi)} (${patient.yas} yaş)',
          ),
          _infoRow('Bölge/Köy', patient.bolge),
          _infoRow(
            'Kayıt Tarihi',
            DateFormat('dd.MM.yyyy HH:mm').format(patient.olusturmaTarihi),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF212121),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnamnezCard(Patient patient) {
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
                  Icons.description_outlined,
                  color: Color(0xFFD32F2F),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Anamnez',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFD32F2F),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _editAnamnez(patient),
                icon: const Icon(
                  Icons.edit_outlined,
                  color: Color(0xFFD32F2F),
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              patient.anamnez.isEmpty
                  ? 'Henüz anamnez bilgisi eklenmemiş.'
                  : patient.anamnez,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: patient.anamnez.isEmpty
                    ? Colors.grey.shade400
                    : const Color(0xFF212121),
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoManagementCard(Patient patient) {
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
                  Icons.photo_library_outlined,
                  color: Color(0xFFD32F2F),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Resim Ekle',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFD32F2F),
                ),
              ),
              const Spacer(),
              if (_isUploadingPhoto)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Color(0xFFD32F2F),
                    strokeWidth: 2.5,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _photoActionButton(
                  icon: Icons.photo_library_outlined,
                  label: 'Fotoğraf Arşivi',
                  onTap: () => _addPhoto(patient, ImageSource.gallery),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _photoActionButton(
                  icon: Icons.camera_alt_outlined,
                  label: 'Fotoğraf Çek',
                  onTap: () => _addPhoto(patient, ImageSource.camera),
                ),
              ),
            ],
          ),
          if (patient.fotograflar.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              '${patient.fotograflar.length} fotoğraf yüklendi',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _photoActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: _isUploadingPhoto ? null : onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              Icon(icon, color: const Color(0xFFD32F2F), size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF424242),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEvaluationButtons(Patient patient) {
    return Column(
      children: [
        // Dental Değerlendirme
        _evaluationButton(
          icon: Icons.straighten,
          label: 'Dental Değerlendirme',
          subtitle: 'Diş muayenesi ve bulgular',
          color: const Color(0xFFD32F2F),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    DentalEvaluationScreen(patientId: patient.id),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        // Genel Değerlendirme
        _evaluationButton(
          icon: Icons.assessment_outlined,
          label: 'Genel Değerlendirme',
          subtitle: 'Diş eti ve periodontal muayene',
          color: const Color(0xFFD32F2F),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    GeneralEvaluationScreen(patientId: patient.id),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _evaluationButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF212121),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: color, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addPhoto(Patient patient, ImageSource source) async {
    setState(() => _isUploadingPhoto = true);
    try {
      XFile? imageFile;
      if (source == ImageSource.gallery) {
        imageFile = await _storageService.pickImageFromGallery();
      } else {
        imageFile = await _storageService.pickImageFromCamera();
      }

      if (imageFile != null) {
        if (mounted) {
          final label = await _showLabelDialog();
          if (label == null) {
            setState(() => _isUploadingPhoto = false);
            return;
          }

          final url = await _storageService.uploadPatientPhoto(
            patient.id,
            imageFile,
          );
          await _firestoreService.addPhotoToPatient(
            patient.id,
            PatientPhoto(url: url, label: label),
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Fotoğraf başarıyla eklendi'),
                backgroundColor: Colors.green.shade600,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fotoğraf yüklenemedi: $e'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  Future<String?> _showLabelDialog() async {
    final controller = TextEditingController();
    return await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Fotoğraf Başlığı',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bu fotoğraf için bir başlık girin (örn: Ön Ağız İçi, Üst Çene vb.)',
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText: 'Başlık girin...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              Navigator.pop(context, text.isEmpty ? 'Fotoğraf' : text);
            },
            child: Text('Kaydet', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  void _editAnamnez(Patient patient) {
    final controller = TextEditingController(text: patient.anamnez);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Anamnez Düzenle',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: TextField(
          controller: controller,
          maxLines: 8,
          decoration: InputDecoration(
            hintText: 'Anamnez bilgisi girin...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () async {
              final newAnamnez = controller.text.trim();
              await _firestoreService.updateAnamnez(patient.id, newAnamnez);
              if (mounted) {
                final scaffold = ScaffoldMessenger.of(context);
                Navigator.of(context).pop();
                scaffold.showSnackBar(
                  SnackBar(
                    content: const Text('Anamnez güncellendi'),
                    backgroundColor: Colors.green.shade600,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Text('Kaydet', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  Widget _buildEvaluationsCard(Patient patient) {
    return StreamBuilder<List<DentalEvaluation>>(
      stream: _firestoreService.getEvaluationsStream(patient.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: Color(0xFFD32F2F)),
            ),
          );
        }

        final evaluations = snapshot.data ?? [];

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
                      Icons.history_outlined,
                      color: Color(0xFFD32F2F),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Muayene Geçmişi',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFD32F2F),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (evaluations.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'Henüz kaydedilmiş muayene bulunmuyor.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: evaluations.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 24),
                  itemBuilder: (context, index) {
                    final eval = evaluations[index];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EvaluationDetailScreen(
                              evaluation: eval,
                              patient: patient,
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormat(
                                      'dd MMMM yyyy HH:mm',
                                      'tr_TR',
                                    ).format(eval.olusturmaTarihi),
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  Text(
                                    'Detay için tıklayın',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: const Color(0xFFD32F2F),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                onPressed: () => _deleteEvaluation(eval.id),
                                icon: Icon(
                                  Icons.delete_outline,
                                  size: 18,
                                  color: Colors.grey.shade400,
                                ),
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Diş Bulguları (Özet)
                          if (eval.disNotlari.isNotEmpty) ...[
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: eval.disNotlari.entries.take(3).map((
                                entry,
                              ) {
                                return Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFD32F2F),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            entry.key,
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          entry.value.join(', '),
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: const Color(0xFF424242),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],

                          // Diş Eti Muayenesi
                          if (eval.disEtiMuayenesi.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            _evaluationMiniRow(
                              Icons.health_and_safety_outlined,
                              'Diş Eti',
                              eval.disEtiMuayenesi,
                            ),
                          ],

                          // Periodontal Muayene
                          if (eval.periodontalMuayene.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            _evaluationMiniRow(
                              Icons.biotech_outlined,
                              'Periodontal',
                              eval.periodontalMuayene,
                            ),
                          ],

                          // Genel Notlar
                          if (eval.genelNotlar.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.orange.withValues(alpha: 0.1),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.sticky_note_2_outlined,
                                    size: 16,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      eval.genelNotlar,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.grey.shade800,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _evaluationMiniRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFFD32F2F)),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF212121),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _deleteEvaluation(String evaluationId) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Silmeyi Onayla'),
        content: const Text(
          'Bu muayene kaydını silmek istediğinize emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _firestoreService.deleteEvaluation(
          widget.patientId,
          evaluationId,
        );
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Kayıt silindi')),
        );
      } catch (e) {
        scaffoldMessenger.showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    }
  }

  void _showOptionsMenu(BuildContext context, Patient patient) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(
                  Icons.label_outline,
                  color: Color(0xFFD32F2F),
                ),
                title: Text(
                  'Fotoğraf Başlığını Düzenle',
                  style: GoogleFonts.poppins(),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _editPhotoLabel(patient);
                },
              ),
              if (patient.fotograflar.isNotEmpty &&
                  _currentPhotoIndex < patient.fotograflar.length)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: Text('Bu Fotoğrafı Sil', style: GoogleFonts.poppins()),
                  onTap: () async {
                    Navigator.pop(context);
                    final photo = patient.fotograflar[_currentPhotoIndex];
                    await _storageService.deletePhoto(photo.url);
                    await _firestoreService.removePhotoFromPatient(
                      patient.id,
                      photo,
                    );
                    setState(() => _currentPhotoIndex = 0);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _editPhotoLabel(Patient patient) async {
    final photo = patient.fotograflar[_currentPhotoIndex];
    final controller = TextEditingController(text: photo.label);

    final newLabel = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Başlığı Düzenle',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: TextField(
          controller: controller,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: 'Yeni başlık girin...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text('Güncelle', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );

    if (newLabel != null && newLabel.isNotEmpty) {
      await _firestoreService.updatePhotoLabel(patient.id, photo.url, newLabel);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Başlık güncellendi')));
      }
    }
  }

  void _showFullScreenPhoto(
    BuildContext context,
    List<PatientPhoto> photos,
    int initialIndex,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: Text(
              photos[initialIndex].label.isEmpty
                  ? 'Fotoğraf ${initialIndex + 1}'
                  : photos[initialIndex].label,
              style: GoogleFonts.poppins(fontSize: 16),
            ),
          ),
          body: InteractiveViewer(
            child: Center(
              child: CachedNetworkImage(
                imageUrl: photos[initialIndex].url,
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
