import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/practice_record.dart';
import '../services/practice_records_provider.dart';
import 'add_practice_screen.dart';

class PracticeDetailScreen extends StatefulWidget {
  final PracticeRecord record;

  const PracticeDetailScreen({super.key, required this.record});

  @override
  State<PracticeDetailScreen> createState() => _PracticeDetailScreenState();
}

class _PracticeDetailScreenState extends State<PracticeDetailScreen> {
  List<VideoPlayerController?> _videoControllers = [];
  int _currentVideoIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayers();
  }

  Future<void> _initializeVideoPlayers() async {
    for (var path in widget.record.videoPaths) {
      try {
        final controller = VideoPlayerController.file(File(path));
        await controller.initialize();
        setState(() {
          _videoControllers.add(controller);
        });
      } catch (e) {
        debugPrint('Error initializing video: $e');
        _videoControllers.add(null);
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _videoControllers) {
      controller?.dispose();
    }
    super.dispose();
  }

  Future<void> _deleteRecord() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除確認'),
        content: const Text('この練習記録を削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final provider = Provider.of<PracticeRecordsProvider>(context, listen: false);
        await provider.deleteRecord(widget.record.id);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('削除しました')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('削除に失敗しました: $e')),
          );
        }
      }
    }
  }

  Future<void> _editRecord() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPracticeScreen(existingRecord: widget.record),
      ),
    );

    if (result == true && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('更新しました')),
      );
    }
  }

  Future<void> _launchUrl(String urlString) async {
    try {
      final uri = Uri.parse(urlString);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('URLを開けませんでした')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラー: $e')),
        );
      }
    }
  }

  String? _extractYouTubeId(String url) {
    final regExp = RegExp(
      r'(?:youtube\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?)\/|\S*?[?&]v=)|youtu\.be\/)([a-zA-Z0-9_-]{11})',
    );
    final match = regExp.firstMatch(url);
    return match?.group(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('練習記録の詳細'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editRecord,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteRecord,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Title
          Text(
            widget.record.title ?? '無題',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          
          // Date
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 20),
              const SizedBox(width: 8),
              Text(
                DateFormat('yyyy年MM月dd日 HH:mm').format(widget.record.dateTime),
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Videos
          if (widget.record.videoPaths.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '動画 (${widget.record.videoPaths.length})',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    if (_videoControllers.isNotEmpty &&
                        _currentVideoIndex < _videoControllers.length &&
                        _videoControllers[_currentVideoIndex] != null)
                      Column(
                        children: [
                          AspectRatio(
                            aspectRatio: _videoControllers[_currentVideoIndex]!.value.aspectRatio,
                            child: VideoPlayer(_videoControllers[_currentVideoIndex]!),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(
                                  _videoControllers[_currentVideoIndex]!.value.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                ),
                                onPressed: () {
                                  setState(() {
                                    if (_videoControllers[_currentVideoIndex]!.value.isPlaying) {
                                      _videoControllers[_currentVideoIndex]!.pause();
                                    } else {
                                      _videoControllers[_currentVideoIndex]!.play();
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      )
                    else
                      Container(
                        height: 200,
                        alignment: Alignment.center,
                        color: Colors.grey[300],
                        child: const Icon(Icons.video_library, size: 64),
                      ),
                    if (widget.record.videoPaths.length > 1) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 60,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.record.videoPaths.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                if (_videoControllers[_currentVideoIndex] != null) {
                                  _videoControllers[_currentVideoIndex]!.pause();
                                }
                                setState(() {
                                  _currentVideoIndex = index;
                                });
                              },
                              child: Container(
                                width: 80,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: _currentVideoIndex == index
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: _currentVideoIndex == index
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Guitar Info
          if (widget.record.guitarType != null || widget.record.guitarModel != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ギター情報',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    if (widget.record.guitarType != null) ...[
                      _buildInfoRow(Icons.music_note, 'ギターの種類', widget.record.guitarType!),
                      const SizedBox(height: 8),
                    ],
                    if (widget.record.guitarModel != null)
                      _buildInfoRow(Icons.model_training, '型番', widget.record.guitarModel!),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Equipment Memo
          if (widget.record.ampEquipmentMemo != null && widget.record.ampEquipmentMemo!.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'アンプ・機材のメモ',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.record.ampEquipmentMemo!,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Impression Memo
          if (widget.record.impressionMemo != null && widget.record.impressionMemo!.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'その他所感メモ',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.record.impressionMemo!,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Reference URL
          if (widget.record.referenceUrl != null && widget.record.referenceUrl!.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '参考URL',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () => _launchUrl(widget.record.referenceUrl!),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _extractYouTubeId(widget.record.referenceUrl!) != null
                                  ? Icons.play_circle
                                  : Icons.link,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.record.referenceUrl!,
                                style: const TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }
}
