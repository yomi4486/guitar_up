import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'add_practice_screen.dart';
import '../services/practice_records_provider.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GuitarUp - 練習'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome Card
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.music_note,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'ようこそ GuitarUp へ',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ギターの練習を記録して上達を実感しましょう',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // New Record Button
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddPracticeScreen(),
                    ),
                  );
                  if (result == true) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('練習記録を保存しました')),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('新しい練習を記録'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 32),
              
              // Usage Guide
              Text(
                '使い方',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              _buildGuideItem(
                context,
                Icons.videocam,
                '動画を撮影または選択',
                '練習中の演奏を動画で記録できます',
              ),
              const SizedBox(height: 12),
              _buildGuideItem(
                context,
                Icons.edit_note,
                '詳細情報を入力',
                'ギターの種類、アンプ、所感などを記録',
              ),
              const SizedBox(height: 12),
              _buildGuideItem(
                context,
                Icons.link,
                '参考URLを追加',
                'YouTube動画やTAB譜のURLを保存',
              ),
              const SizedBox(height: 12),
              _buildGuideItem(
                context,
                Icons.history,
                '記録タブで振り返り',
                '過去の練習を見返して成長を確認',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuideItem(BuildContext context, IconData icon, String title, String description) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              icon,
              size: 40,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
