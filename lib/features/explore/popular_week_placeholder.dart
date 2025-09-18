import 'package:flutter/material.dart';

class PopularWeekPlaceholderPage extends StatelessWidget {
  const PopularWeekPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Popular this week'),
      ),
      body: const Center(
        child: Text('Full list coming soon'),
      ),
    );
  }
}
