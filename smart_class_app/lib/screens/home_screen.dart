import 'package:flutter/material.dart';
import 'checkin_screen.dart';
import 'finish_class_screen.dart';
import 'records_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Class App')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.school, size: 72),
            const SizedBox(height: 16),
            const Text(
              'Smart Class Check-in & Learning Reflection',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CheckInScreen()),
                  );
                },
                child: const Text('Check-in Before Class'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FinishClassScreen()),
                  );
                },
                child: const Text('Finish Class'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RecordsScreen()),
                  );
                },
                child: const Text('View Saved Records'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}