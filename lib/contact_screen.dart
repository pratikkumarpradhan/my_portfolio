// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'dart:ui';

// class ContactScreen extends StatelessWidget {
//   const ContactScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               Color(0xFF0F2027), // Dark blue/green
//               Color(0xFF203A43),
//               Color(0xFF2C5364), // Deep slate blue
//             ],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Contact Me',
//                   style: GoogleFonts.poppins(
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 const SizedBox(height: 30),

//                 ContactCard(
//                   icon: Icons.phone,
//                   label: 'Phone',
//                   value: '+91 9434693252',
//                 ),
//                 const SizedBox(height: 20),

//                 ContactCard(
//                   icon: Icons.email,
//                   label: 'Email',
//                   value: 'pratikkumarpradhan2006@gmail.com',
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class ContactCard extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String value;

//   const ContactCard({
//     super.key,
//     required this.icon,
//     required this.label,
//     required this.value,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(20),
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [
//                 Colors.white.withOpacity(0.08),
//                 Colors.white.withOpacity(0.03),
//               ],
//             ),
//             borderRadius: BorderRadius.circular(20),
//             border: Border.all(color: Colors.white.withOpacity(0.10), width: 1.5),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.13),
//                 blurRadius: 18,
//                 offset: Offset(0, 6),
//               ),
//             ],
//           ),
//           child: Row(
//             children: [
//               Icon(icon, color: Colors.cyanAccent, size: 30),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       label,
//                       style: GoogleFonts.poppins(
//                         fontSize: 14,
//                         color: Colors.white60,
//                       ),
//                     ),
//                     Text(
//                       value,
//                       style: GoogleFonts.poppins(
//                         fontSize: 16,
//                         color: Colors.white,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }