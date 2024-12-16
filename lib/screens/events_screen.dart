import 'package:flutter/material.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> events = [
      {
        'title': 'Marathon 2024',
        'date': 'March 10, 2024',
        'location': 'Central Park, NY',
        'description': 'Join us for the annual marathon with participants from around the globe.'
      },
      {
        'title': 'Community Fun Run',
        'date': 'April 15, 2024',
        'location': 'Downtown, LA',
        'description': 'A fun event for all ages with various run categories and prizes.'
      },
      {
        'title': 'Trail Adventure',
        'date': 'May 22, 2024',
        'location': 'Rocky Mountain Trails, CO',
        'description': 'Explore the scenic trails with this adventurous running event.'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event['title'] ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(event['date'] ?? '', style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(event['location'] ?? '', style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    event['description'] ?? '',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('You have joined ${event['title']}!')),
                        );
                      },
                      child: const Text('Join'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}