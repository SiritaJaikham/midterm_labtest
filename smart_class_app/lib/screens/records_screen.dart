import 'package:flutter/material.dart';
import '../models/attendance_record.dart';
import '../services/database_service.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  late Future<List<AttendanceRecord>> _recordsFuture;

  @override
  void initState() {
    super.initState();
    _recordsFuture = DatabaseService.instance.getAllRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Records'),
      ),
      body: FutureBuilder<List<AttendanceRecord>>(
        future: _recordsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final records = snapshot.data ?? [];
          if (records.isEmpty) {
            return const Center(child: Text('No records saved yet'));
          }

          return ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, index) {
              final r = records[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.type.toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('Timestamp: ${r.timestamp}'),
                      Text('QR Code: ${r.qrCode}'),
                      Text('Location: ${r.latitude}, ${r.longitude}'),
                      if (r.previousTopic != null) Text('Previous Topic: ${r.previousTopic}'),
                      if (r.expectedTopic != null) Text('Expected Topic: ${r.expectedTopic}'),
                      if (r.moodScore != null) Text('Mood Score: ${r.moodScore}'),
                      if (r.learnedToday != null) Text('Learned Today: ${r.learnedToday}'),
                      if (r.feedback != null) Text('Feedback: ${r.feedback}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}