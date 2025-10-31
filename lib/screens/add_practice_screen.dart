import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../models/practice_record.dart';
import '../services/practice_records_provider.dart';

class AddPracticeScreen extends StatefulWidget {
  final PracticeRecord? existingRecord;

  const AddPracticeScreen({super.key, this.existingRecord});

  @override
  State<AddPracticeScreen> createState() => _AddPracticeScreenState();
}

class _AddPracticeScreenState extends State<AddPracticeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _guitarTypeController = TextEditingController();
  final _guitarModelController = TextEditingController();
  final _ampEquipmentController = TextEditingController();
  final _impressionController = TextEditingController();
  final _referenceUrlController = TextEditingController();
  
  DateTime _selectedDateTime = DateTime.now();
  List<String> _videoPaths = [];
  final ImagePicker _picker = ImagePicker();
  List<String> _guitarSuggestions = [];

  @override
  void initState() {
    super.initState();
    _loadGuitarSuggestions();
    
    if (widget.existingRecord != null) {
      final record = widget.existingRecord!;
      _titleController.text = record.title ?? '';
      _guitarTypeController.text = record.guitarType ?? '';
      _guitarModelController.text = record.guitarModel ?? '';
      _ampEquipmentController.text = record.ampEquipmentMemo ?? '';
      _impressionController.text = record.impressionMemo ?? '';
      _referenceUrlController.text = record.referenceUrl ?? '';
      _selectedDateTime = record.dateTime;
      _videoPaths = List.from(record.videoPaths);
    }
  }

  Future<void> _loadGuitarSuggestions() async {
    final provider = Provider.of<PracticeRecordsProvider>(context, listen: false);
    final suggestions = await provider.getGuitarModelSuggestions();
    setState(() {
      _guitarSuggestions = suggestions;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _guitarTypeController.dispose();
    _guitarModelController.dispose();
    _ampEquipmentController.dispose();
    _impressionController.dispose();
    _referenceUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        setState(() {
          _videoPaths.add(video.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('動画の選択に失敗しました: $e')),
        );
      }
    }
  }

  Future<void> _recordVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.camera);
      if (video != null) {
        setState(() {
          _videoPaths.add(video.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('動画の撮影に失敗しました: $e')),
        );
      }
    }
  }

  void _removeVideo(int index) {
    setState(() {
      _videoPaths.removeAt(index);
    });
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _saveRecord() async {
    if (_formKey.currentState!.validate()) {
      try {
        final provider = Provider.of<PracticeRecordsProvider>(context, listen: false);
        
        final record = PracticeRecord(
          id: widget.existingRecord?.id ?? const Uuid().v4(),
          title: _titleController.text.trim().isEmpty ? null : _titleController.text.trim(),
          dateTime: _selectedDateTime,
          guitarType: _guitarTypeController.text.trim().isEmpty ? null : _guitarTypeController.text.trim(),
          guitarModel: _guitarModelController.text.trim().isEmpty ? null : _guitarModelController.text.trim(),
          ampEquipmentMemo: _ampEquipmentController.text.trim().isEmpty ? null : _ampEquipmentController.text.trim(),
          impressionMemo: _impressionController.text.trim().isEmpty ? null : _impressionController.text.trim(),
          referenceUrl: _referenceUrlController.text.trim().isEmpty ? null : _referenceUrlController.text.trim(),
          videoPaths: _videoPaths,
        );

        if (widget.existingRecord != null) {
          await provider.updateRecord(record);
        } else {
          await provider.addRecord(record);
        }

        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('保存に失敗しました: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingRecord != null ? '練習記録を編集' : '新しい練習記録'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveRecord,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Videos Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '動画',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _recordVideo,
                            icon: const Icon(Icons.videocam),
                            label: const Text('撮影'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _pickVideo,
                            icon: const Icon(Icons.video_library),
                            label: const Text('選択'),
                          ),
                        ),
                      ],
                    ),
                    if (_videoPaths.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _videoPaths.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: const Icon(Icons.video_file),
                            title: Text('動画 ${index + 1}'),
                            subtitle: Text(
                              _videoPaths[index].split('/').last,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _removeVideo(index),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Basic Info Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '基本情報',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'タイトル（任意）',
                        hintText: '例: アルペジオ練習',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('日時'),
                      subtitle: Text(
                        DateFormat('yyyy年MM月dd日 HH:mm').format(_selectedDateTime),
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: _selectDateTime,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Guitar Info Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ギター情報',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _guitarTypeController,
                      decoration: const InputDecoration(
                        labelText: 'ギターの種類（任意）',
                        hintText: '例: エレキギター、アコースティックギター',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return _guitarSuggestions;
                        }
                        return _guitarSuggestions.where((String option) {
                          return option.toLowerCase().contains(
                                textEditingValue.text.toLowerCase(),
                              );
                        });
                      },
                      onSelected: (String selection) {
                        _guitarModelController.text = selection;
                      },
                      fieldViewBuilder: (
                        BuildContext context,
                        TextEditingController fieldTextEditingController,
                        FocusNode fieldFocusNode,
                        VoidCallback onFieldSubmitted,
                      ) {
                        fieldTextEditingController.text = _guitarModelController.text;
                        fieldTextEditingController.selection = TextSelection.fromPosition(
                          TextPosition(offset: fieldTextEditingController.text.length),
                        );
                        
                        return TextFormField(
                          controller: fieldTextEditingController,
                          focusNode: fieldFocusNode,
                          decoration: const InputDecoration(
                            labelText: '型番（任意）',
                            hintText: '例: Fender Stratocaster',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.arrow_drop_down),
                          ),
                          onChanged: (value) {
                            _guitarModelController.text = value;
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Equipment & Notes Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '機材・メモ',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _ampEquipmentController,
                      decoration: const InputDecoration(
                        labelText: 'アンプ・機材のメモ（任意）',
                        hintText: '例: Marshall JCM800、Boss DS-1',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _impressionController,
                      decoration: const InputDecoration(
                        labelText: 'その他所感メモ（任意）',
                        hintText: '練習の感想や気づいたことを記録',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Reference URL Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '参考URL',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _referenceUrlController,
                      decoration: const InputDecoration(
                        labelText: 'YouTube動画やTAB譜のURL（任意）',
                        hintText: 'https://www.youtube.com/watch?v=...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.link),
                      ),
                      keyboardType: TextInputType.url,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            ElevatedButton(
              onPressed: _saveRecord,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                widget.existingRecord != null ? '更新する' : '保存する',
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
