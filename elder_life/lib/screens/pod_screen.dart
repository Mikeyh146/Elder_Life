import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PodScreen extends StatefulWidget {
  const PodScreen({super.key});

  @override
  State<PodScreen> createState() => _PodScreenState();
}

class _PodScreenState extends State<PodScreen> {
  List<Map<String, dynamic>> pods = [];

  @override
  void initState() {
    super.initState();
    _loadPods();
  }

  Future<void> _loadPods() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('pods');
    if (saved != null) {
      setState(() {
        pods = List<Map<String, dynamic>>.from(json.decode(saved));
      });
    }
  }

  Future<void> _savePods() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pods', json.encode(pods));
  }

  String _generatePodCode() {
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final rand = Random();
    return '${letters[rand.nextInt(26)]}${letters[rand.nextInt(26)]}-${rand.nextInt(9000) + 1000}';
  }

  Future<void> _createPodDialog() async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Name Your Pod'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            validator: (val) => val == null || val.isEmpty ? 'Enter a pod name' : null,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final newPod = {
                  'name': controller.text.trim(),
                  'code': _generatePodCode(),
                  'gamesPlayed': 0,
                };
                setState(() => pods.add(newPod));
                _savePods();
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _renamePodDialog(int index) async {
    final controller = TextEditingController(text: pods[index]['name']);
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Pod'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            validator: (val) => val == null || val.isEmpty ? 'Enter a new name' : null,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                setState(() => pods[index]['name'] = controller.text.trim());
                _savePods();
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showOptionsDialog(int index) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(pods[index]['name']),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _renamePodDialog(index);
            },
            child: const Text('Rename'),
          ),
          TextButton(
            onPressed: () {
              setState(() => pods.removeAt(index));
              _savePods();
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _enterPod(int index) {
    Navigator.pushNamed(
  context,
  '/pod_detail',
  arguments: {
    'podId': 'abc123',      // Replace with actual pod ID
    'podName': 'Casual Pod' // Replace with actual pod name
  },
);
  }
  Widget _buildPodCard(int index) {
    if (index >= pods.length) {
      return Card(
        child: ListTile(
          title: const Text('Create Pod'),
          trailing: const Icon(Icons.add),
          onTap: pods.length >= 3 ? null : _createPodDialog,
        ),
      );
    }

    final pod = pods[index];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(pod['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Games Played: ${pod['gamesPlayed']}'),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => _enterPod(index),
                  child: const Text('Enter Pod'),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: () => _showOptionsDialog(index),
                  child: const Text('Options'),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: 3,
                itemBuilder: (_, index) => _buildPodCard(index),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
