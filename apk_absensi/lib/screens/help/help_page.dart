// pages/help_page.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:apk_absensi/models/faq_model.dart';

class HelpPage extends StatelessWidget {
  HelpPage({super.key});

  // Data FAQ
  final List<FAQ> faqs = [
    FAQ(
      question: "Bagaimana cara melakukan absensi?",
      answer: "Untuk melakukan absensi, buka menu 'Absensi' lalu pilih 'Check In' di pagi hari dan 'Check Out' di sore hari. Pastikan Anda mengupload foto selfie sebagai bukti kehadiran.",
    ),
    FAQ(
      question: "Apa yang harus dilakukan jika lupa melakukan absensi?",
      answer: "Jika lupa melakukan absensi, segera hubungi HRD atau atasan langsung untuk mengajukan permohonan perbaikan absensi. Lampirkan bukti yang mendukung.",
    ),
    FAQ(
      question: "Bagaimana cara mengajukan cuti?",
      answer: "Untuk mengajukan cuti, buka menu 'Cuti' lalu pilih 'Ajukan Cuti'. Isi formulir pengajuan cuti dengan lengkap dan tunggu persetujuan dari atasan.",
    ),
    FAQ(
      question: "Kapan gaji biasanya ditransfer?",
      answer: "Gaji biasanya ditransfer pada tanggal 25 setiap bulan. Jika tanggal 25 jatuh pada hari libur, akan diproses pada hari kerja sebelumnya.",
    ),
    FAQ(
      question: "Bagaimana cara mengubah foto profil?",
      answer: "Untuk mengubah foto profil, buka menu 'Pengaturan' lalu pilih 'Ubah Foto'. Anda dapat memilih foto dari galeri atau mengambil foto baru.",
    ),
    FAQ(
      question: "Apa yang harus dilakukan jika password lupa?",
      answer: "Jika lupa password, Anda dapat menggunakan fitur 'Ubah Password' di menu Pengaturan. Masukkan password lama dan buat password baru.",
    ),
    FAQ(
      question: "Bagaimana cara melihat riwayat gaji?",
      answer: "Riwayat gaji dapat dilihat di menu 'Gaji & Potongan'. Anda dapat melihat detail gaji untuk setiap periode.",
    ),
    FAQ(
      question: "Apa saja fitur yang tersedia untuk karyawan?",
      answer: "Fitur untuk karyawan meliputi: Absensi, Pengajuan Cuti, Lihat Gaji, Profil, dan Pengaturan. Semua fitur dapat diakses melalui menu dashboard.",
    ),
  ];

  // Data kontak support
  final List<Map<String, String>> supportContacts = [
    {
      'department': 'HRD',
      'name': 'Budi Santoso',
      'phone': '081234567890',
      'email': 'hrd@company.com',
    },
    {
      'department': 'IT Support',
      'name': 'Ahmad Rizki',
      'phone': '081234567891',
      'email': 'it-support@company.com',
    },
    {
      'department': 'Finance',
      'name': 'Siti Rahma',
      'phone': '081234567892',
      'email': 'finance@company.com',
    },
  ];

  Future<void> _launchPhone(String phone) async {
    final Uri url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri url = Uri.parse('mailto:$email');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bantuan & Dukungan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.greenAccent[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Section
          _buildHeaderSection(),
          const SizedBox(height: 24),

          // FAQ Section
          _buildFaqSection(),
          const SizedBox(height: 24),

          // Contact Support Section
          _buildContactSection(),
          const SizedBox(height: 24),

          // App Info Section
          _buildAppInfoSection(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.help_outline,
              size: 64,
              color: Colors.greenAccent[700],
            ),
            const SizedBox(height: 16),
            const Text(
              'Butuh Bantuan?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Temukan jawaban untuk pertanyaan umum atau hubungi tim support kami untuk bantuan lebih lanjut.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pertanyaan Umum (FAQ)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Temukan jawaban untuk pertanyaan yang sering diajukan',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: faqs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            return _buildFaqItem(faqs[index]);
          },
        ),
      ],
    );
  }

  Widget _buildFaqItem(FAQ faq) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ExpansionTile(
        leading: Icon(
          Icons.help,
          color: Colors.greenAccent[700],
        ),
        title: Text(
          faq.question,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Text(
              faq.answer,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hubungi Support',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tim support kami siap membantu Anda',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: supportContacts.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _buildContactCard(supportContacts[index]);
          },
        ),
      ],
    );
  }

  Widget _buildContactCard(Map<String, String> contact) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.greenAccent[700]?.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    color: Colors.greenAccent[700],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact['department']!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        contact['name']!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildContactInfo(
              Icons.phone,
              contact['phone']!,
              () => _launchPhone(contact['phone']!),
            ),
            const SizedBox(height: 8),
            _buildContactInfo(
              Icons.email,
              contact['email']!,
              () => _launchEmail(contact['email']!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo(IconData icon, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.greenAccent[700],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Aplikasi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildAppInfoItem('Versi Aplikasi', '1.0.0'),
            _buildAppInfoItem('Dibuat Oleh', 'Tim IT Perusahaan'),
            _buildAppInfoItem('Update Terakhir', 'November 2024'),
            _buildAppInfoItem('Platform', 'Android & iOS'),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}