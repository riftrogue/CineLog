import 'package:flutter/material.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_activity, size: 48, color: Colors.tealAccent),
          SizedBox(height: 16),
          Text(
            'Activity Page',
            style: TextStyle(fontSize: 24),
          ),
        ],
      ),
    );
  }
}
