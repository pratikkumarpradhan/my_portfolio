import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:portfolio/widget/leetcode_contribution.dart';
import 'home_screen.dart';

class LeetcodeScreen extends StatefulWidget {
  const LeetcodeScreen({super.key});

  @override
  State<LeetcodeScreen> createState() => _LeetcodeScreenState();
}

class _LeetcodeScreenState extends State<LeetcodeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0f0f1a),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: MediaQuery.of(context).size.width < 600 ? 130 : 160,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              },
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              label: MediaQuery.of(context).size.width < 600
                  ? const Text(
                      "Back",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    )
                  : const Text(
                      "Back",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.transparent,
                padding: MediaQuery.of(context).size.width < 600
                    ? const EdgeInsets.symmetric(horizontal: 8, vertical: 8)
                    : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ),
        title: Text(
          'LeetCode',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight, // Ensure it's at least full screen height
              ),
              child: Center( // Center the content vertically
                child: Container(
                  width: 800, // Fixed width for portrait
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.05),
                        Colors.white.withOpacity(0.02),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.code, color: Colors.white, size: 30),
                          const SizedBox(width: 8),
                          Text(
                            'LeetCode',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: 750,
                        height: 180,
                        child: LeetCodeGraphScreen(
                          profileUrl: LEETCODE_PROFILE_URL,
                          username: extractUsernameFromUrl(LEETCODE_PROFILE_URL),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Less',
                            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10),
                          ),
                          const SizedBox(width: 4),
                          Container(width: 10, height: 10, color: const Color(0xff161b22)),
                          const SizedBox(width: 2),
                          Container(width: 10, height: 10, color: const Color(0xff0e4429)),
                          const SizedBox(width: 2),
                          Container(width: 10, height: 10, color: const Color(0xff006d32)),
                          const SizedBox(width: 2),
                          Container(width: 10, height: 10, color: const Color(0xff26a641)),
                          const SizedBox(width: 2),
                          Container(width: 10, height: 10, color: const Color(0xff39d353)),
                          const SizedBox(width: 4),
                          Text(
                            'More',
                            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}