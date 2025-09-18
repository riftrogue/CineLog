// import 'package:flutter/material.dart';
// import 'login_page.dart';


// class LandingPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Column(
//         children: [
//           Expanded(
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.tealAccent,
//                 borderRadius: BorderRadius.only(
//                   bottomLeft: Radius.circular(50),
//                   bottomRight: Radius.circular(50),
//                 ),
//               ),
//               child: Center(
//                 child: Text(
//                   'Welcome',
//                   style: TextStyle(
//                     fontSize: 32,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 // Text(
//                 //   'Lorem ipsum dolor sit amet consectetur.',
//                 //   style: TextStyle(
//                 //     fontSize: 16,
//                 //     color: Colors.white70,
//                 //   ),
//                 //   textAlign: TextAlign.center,
//                 // ),
//                 SizedBox(height: 32),
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => LoginPage()),
//                     );
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.teal,
//                     padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
//                   ),
//                   child: Text(
//                     'Continue',
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }