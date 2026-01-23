import 'package:flutter/material.dart';
import '../../l10n/app_strings.dart';
import '../../theme/app_theme.dart';

class CaregiverGuideScreen extends StatelessWidget {
  const CaregiverGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(Localizations.localeOf(context).languageCode);
    final isBM = Localizations.localeOf(context).languageCode == 'ms';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isBM ? 'Panduan Penjaga' : 'Caregiver Guide'),
        backgroundColor: AppTheme.primaryPurple,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSection(
            context,
            icon: Icons.supervisor_account,
            title: 'How to Support Your Loved One',
            titleBM: 'Cara Menyokong Orang Tersayang Anda',
            content: [
              'Create a quiet, distraction-free environment for exercises',
              'Be patient and encouraging during sessions',
              'Celebrate small victories and progress',
              'Allow time for responses without rushing',
            ],
            contentBM: [
              'Cipta persekitaran yang tenang tanpa gangguan untuk latihan',
              'Bersabar dan memberi galakan semasa sesi',
              'Raikan kejayaan kecil dan kemajuan',
              'Beri masa untuk menjawab tanpa tergesa-gesa',
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            icon: Icons.schedule,
            title: 'Best Practices',
            titleBM: 'Amalan Terbaik',
            content: [
              'Schedule regular practice sessions (15-20 minutes daily)',
              'Practice at the same time each day for consistency',
              'Take breaks if the patient shows fatigue',
              'Review progress with the therapist regularly',
            ],
            contentBM: [
              'Jadualkan sesi latihan tetap (15-20 minit sehari)',
              'Amalkan pada waktu yang sama setiap hari untuk konsistensi',
              'Ambil rehat jika pesakit menunjukkan keletihan',
              'Semak kemajuan dengan ahli terapi secara berkala',
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            icon: Icons.tips_and_updates,
            title: 'Exercise Tips',
            titleBM: 'Petua Latihan',
            content: [
              'Start with easier categories (animals, food)',
              'Use real objects or pictures to reinforce learning',
              'Encourage writing and speaking the words aloud',
              'Repeat exercises to build confidence',
            ],
            contentBM: [
              'Mulakan dengan kategori yang lebih mudah (haiwan, makanan)',
              'Gunakan objek sebenar atau gambar untuk perkukuh pembelajaran',
              'Galakkan menulis dan menyebut perkataan dengan kuat',
              'Ulang latihan untuk membina keyakinan',
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            icon: Icons.warning_amber,
            title: 'What to Watch For',
            titleBM: 'Perkara Yang Perlu Diperhatikan',
            content: [
              'Signs of frustration or fatigue',
              'Difficulty with specific categories',
              'Need for more or fewer cues',
              'Changes in response time or accuracy',
            ],
            contentBM: [
              'Tanda-tanda kekecewaan atau keletihan',
              'Kesukaran dengan kategori tertentu',
              'Keperluan untuk lebih banyak atau kurang petunjuk',
              'Perubahan dalam masa respons atau ketepatan',
            ],
          ),
          const SizedBox(height: 24),
          Card(
            color: AppTheme.primaryPurpleLight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.contact_phone, color: AppTheme.primaryPurple),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Perlukan bantuan?',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryPurple,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Hubungi ahli terapi pesakit jika anda perhatikan:\n• Kesukaran atau kemunduran yang ketara\n• Masalah teknikal dengan aplikasi\n• Soalan mengenai latihan',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String titleBM,
    required List<String> content,
    required List<String> contentBM,
  }) {
    final isBM = Localizations.localeOf(context).languageCode == 'ms';
    final displayTitle = isBM ? titleBM : title;
    final displayContent = isBM ? contentBM : content;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.primaryPurple, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    displayTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...displayContent.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0, left: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontSize: 16)),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(fontSize: 14, height: 1.4),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
