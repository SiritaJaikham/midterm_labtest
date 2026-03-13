class AttendanceRecord {
  final int? id;
  final String type;
  final String qrCode;
  final double latitude;
  final double longitude;
  final String timestamp;
  final String? previousTopic;
  final String? expectedTopic;
  final int? moodScore;
  final String? learnedToday;
  final String? feedback;

  AttendanceRecord({
    this.id,
    required this.type,
    required this.qrCode,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.previousTopic,
    this.expectedTopic,
    this.moodScore,
    this.learnedToday,
    this.feedback,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'qrCode': qrCode,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp,
      'previousTopic': previousTopic,
      'expectedTopic': expectedTopic,
      'moodScore': moodScore,
      'learnedToday': learnedToday,
      'feedback': feedback,
    };
  }

  factory AttendanceRecord.fromMap(Map<String, dynamic> map) {
    return AttendanceRecord(
      id: map['id'] as int?,
      type: map['type'] as String,
      qrCode: map['qrCode'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      timestamp: map['timestamp'] as String,
      previousTopic: map['previousTopic'] as String?,
      expectedTopic: map['expectedTopic'] as String?,
      moodScore: map['moodScore'] as int?,
      learnedToday: map['learnedToday'] as String?,
      feedback: map['feedback'] as String?,
    );
  }
}