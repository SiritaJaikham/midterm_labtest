import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../models/attendance_record.dart';
import '../services/database_service.dart';
import '../services/location_service.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _previousTopicController = TextEditingController();
  final _expectedTopicController = TextEditingController();

  int _moodScore = 3;
  String _qrCode = '';
  Position? _position;
  bool _isSaving = false;

  Future<void> _scanQrCode() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QrScanPage(
          onScanned: (code) {
            setState(() {
              _qrCode = code;
            });
          },
        ),
      ),
    );
  }

  Future<void> _getLocation() async {
    try {
      final pos = await LocationService.getCurrentLocation();
      setState(() {
        _position = pos;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location error: $e')),
      );
    }
  }

  Future<void> _saveCheckIn() async {
    if (!_formKey.currentState!.validate()) return;
    if (_qrCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please scan QR Code first')),
      );
      return;
    }
    if (_position == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please capture GPS location first')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final record = AttendanceRecord(
      type: 'checkin',
      qrCode: _qrCode,
      latitude: _position!.latitude,
      longitude: _position!.longitude,
      timestamp: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      previousTopic: _previousTopicController.text.trim(),
      expectedTopic: _expectedTopicController.text.trim(),
      moodScore: _moodScore,
    );

    await DatabaseService.instance.insertRecord(record);

    if (!mounted) return;
    setState(() {
      _isSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Check-in saved successfully')),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _previousTopicController.dispose();
    _expectedTopicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationText = _position == null
        ? 'No location captured yet'
        : 'Lat: ${_position!.latitude}, Lng: ${_position!.longitude}';

    return Scaffold(
      appBar: AppBar(title: const Text('Check-in')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.qr_code_scanner),
                  title: const Text('QR Code'),
                  subtitle: Text(_qrCode.isEmpty ? 'Not scanned yet' : _qrCode),
                  trailing: ElevatedButton(
                    onPressed: _scanQrCode,
                    child: const Text('Scan'),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.location_on),
                  title: const Text('GPS Location'),
                  subtitle: Text(locationText),
                  trailing: ElevatedButton(
                    onPressed: _getLocation,
                    child: const Text('Get'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _previousTopicController,
                decoration: const InputDecoration(
                  labelText: 'What topic was covered in the previous class?',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Please enter previous topic' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _expectedTopicController,
                decoration: const InputDecoration(
                  labelText: 'What topic do you expect to learn today?',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Please enter expected topic' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _moodScore,
                decoration: const InputDecoration(
                  labelText: 'Mood before class',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('1 - Very negative')),
                  DropdownMenuItem(value: 2, child: Text('2 - Negative')),
                  DropdownMenuItem(value: 3, child: Text('3 - Neutral')),
                  DropdownMenuItem(value: 4, child: Text('4 - Positive')),
                  DropdownMenuItem(value: 5, child: Text('5 - Very positive')),
                ],
                onChanged: (value) {
                  setState(() {
                    _moodScore = value ?? 3;
                  });
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSaving ? null : _saveCheckIn,
                  child: Text(_isSaving ? 'Saving...' : 'Save Check-in'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QrScanPage extends StatefulWidget {
  final void Function(String code) onScanned;

  const QrScanPage({super.key, required this.onScanned});

  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  bool _handled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code')),
      body: MobileScanner(
        onDetect: (capture) {
          if (_handled) return;
          final barcode = capture.barcodes.firstOrNull;
          final code = barcode?.rawValue;
          if (code != null && code.isNotEmpty) {
            _handled = true;
            widget.onScanned(code);
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}