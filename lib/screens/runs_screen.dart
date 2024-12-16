import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RunsScreen extends ConsumerStatefulWidget {
  const RunsScreen({Key? key}) : super(key: key);

  @override
  _RunsScreenState createState() => _RunsScreenState();
}

class _RunsScreenState extends ConsumerState<RunsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  bool _isLoading = false;

  Future<void> _addRun() async {
    if (_distanceController.text.isEmpty || _timeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all fields.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _firestore.collection('runs').add({
        'distance': _distanceController.text,
        'time': _timeController.text,
        'date': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Run added successfully!')),
      );

      _distanceController.clear();
      _timeController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add run: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showAddRunDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Run'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _distanceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Distance (km)'),
            ),
            TextField(
              controller: _timeController,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(labelText: 'Time (e.g., 30 mins)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _addRun();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildRunCard(Map<String, dynamic> runData) {
    final distance = runData['distance'] ?? '0';
    final time = runData['time'] ?? 'N/A';
    final date = runData['date'] != null
        ? (runData['date'] as Timestamp).toDate()
        : DateTime.now();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Distance: $distance km',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Time: $time',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            Text(
              '${date.day}/${date.month}/${date.year}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Runs'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('runs').orderBy('date', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No runs logged yet. Add your first run!'),
            );
          }

          final runs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: runs.length,
            itemBuilder: (context, index) {
              final runData = runs[index].data() as Map<String, dynamic>;
              return _buildRunCard(runData);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddRunDialog,
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.add),
      ),
    );
  }
}
