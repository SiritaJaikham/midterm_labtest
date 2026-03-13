import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../models/attendance_record.dart';
import '../services/database_service.dart';
import '../services/location_service.dart';

class FinishClassScreen extends StatefulWidget {
  const FinishClassScreen({super.key});

  @override
  State<FinishClassScreen> createState() => _FinishClassScreenState();
}

class _FinishClassScreenState extends State<FinishClassScreen> {
  final _formKey = GlobalKey<FormState>();
  final _learnedTodayController = TextEditingController();
  final _feedbackController = TextEditingController();

  String _qrCode = '';
  Position? _position;
  bool _isSaving = false;

  Future<void> _scanQrCode() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FinishQrScanPage(
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

  Future<void> _saveFinishClass() async {
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
      type: 'finish',
      qrCode: _qrCode,
      latitude: _position!.latitude,
      longitude: _position!.longitude,
      timestamp: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      learnedToday: _learnedTodayController.text.trim(),
      feedback: _feedbackController.text.trim(),
    );

    await DatabaseService.instance.insertRecord(record);

    if (!mounted) return;
    setState(() {
      _isSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Finish class record saved successfully')),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _learnedTodayController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationText = _position == null
        ? 'No location captured yet'
        : 'Lat: ${_position!.latitude}, Lng: ${_position!.longitude}';

    return Scaffold(
      appBar: AppBar(title: const Text('Finish Class')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.qr_code),
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
                controller: _learnedTodayController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'What did you learn today?',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Please enter learning summary' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _feedbackController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Feedback about the class or instructor',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Please enter feedback' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSaving ? null : _saveFinishClass,
                  child: Text(_isSaving ? 'Saving...' : 'Save Finish Class'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FinishQrScanPage extends StatefulWidget {
  final void Function(String code) onScanned;

  const FinishQrScanPage({super.key, required this.onScanned});

  @override
  State<FinishQrScanPage> createState() => _FinishQrScanPageState();
}

class _FinishQrScanPageState extends State<FinishQrScanPage> {
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