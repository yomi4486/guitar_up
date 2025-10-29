class PracticeRecord {
  final String id;
  final String? title;
  final DateTime dateTime;
  final String? guitarType;
  final String? guitarModel;
  final String? ampEquipmentMemo;
  final String? impressionMemo;
  final String? referenceUrl;
  final List<String> videoPaths;

  PracticeRecord({
    required this.id,
    this.title,
    required this.dateTime,
    this.guitarType,
    this.guitarModel,
    this.ampEquipmentMemo,
    this.impressionMemo,
    this.referenceUrl,
    required this.videoPaths,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'dateTime': dateTime.toIso8601String(),
      'guitarType': guitarType,
      'guitarModel': guitarModel,
      'ampEquipmentMemo': ampEquipmentMemo,
      'impressionMemo': impressionMemo,
      'referenceUrl': referenceUrl,
      'videoPaths': videoPaths.join('|||'), // Store as delimited string
    };
  }

  factory PracticeRecord.fromMap(Map<String, dynamic> map) {
    return PracticeRecord(
      id: map['id'] as String,
      title: map['title'] as String?,
      dateTime: DateTime.parse(map['dateTime'] as String),
      guitarType: map['guitarType'] as String?,
      guitarModel: map['guitarModel'] as String?,
      ampEquipmentMemo: map['ampEquipmentMemo'] as String?,
      impressionMemo: map['impressionMemo'] as String?,
      referenceUrl: map['referenceUrl'] as String?,
      videoPaths: (map['videoPaths'] as String?)?.split('|||') ?? [],
    );
  }

  PracticeRecord copyWith({
    String? id,
    String? title,
    DateTime? dateTime,
    String? guitarType,
    String? guitarModel,
    String? ampEquipmentMemo,
    String? impressionMemo,
    String? referenceUrl,
    List<String>? videoPaths,
  }) {
    return PracticeRecord(
      id: id ?? this.id,
      title: title ?? this.title,
      dateTime: dateTime ?? this.dateTime,
      guitarType: guitarType ?? this.guitarType,
      guitarModel: guitarModel ?? this.guitarModel,
      ampEquipmentMemo: ampEquipmentMemo ?? this.ampEquipmentMemo,
      impressionMemo: impressionMemo ?? this.impressionMemo,
      referenceUrl: referenceUrl ?? this.referenceUrl,
      videoPaths: videoPaths ?? this.videoPaths,
    );
  }
}
