import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:portfolio/widget/github_contribution.dart';
import 'home_screen.dart';

class GitHubScreen extends StatefulWidget {
  const GitHubScreen({super.key});

  @override
  State<GitHubScreen> createState() => _GitHubScreenState();
}

class _GitHubScreenState extends State<GitHubScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0f0f1a),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0B1020),
                Color(0xFF101828),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
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
        // title: Text(
        //   'GitHub',
        //    style: GoogleFonts.comfortaa(
        //           color: Colors.white,
        //           fontWeight: FontWeight.bold,
        //           letterSpacing: 1.2,
        //           fontSize: 28,
        //         ),
        // ),
        // centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight, // Ensure it's at least full screen height
              ),
              child: Center( // Center the content vertically
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Text(
                        'GitHub',
                        style: GoogleFonts.comfortaa(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          fontSize: 28,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                        child: Container(
                          width: 800, // Fixed width for portrait
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xCC0B132B), // deep navy glass
                                Color(0x99112233), // slate glass
                                Color(0x66121A2E), // subtle violet tint
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(color: Colors.cyanAccent.withOpacity(0.14), width: 1.2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.35),
                                blurRadius: 28,
                                offset: const Offset(0, 12),
                              ),
                              BoxShadow(
                                color: Colors.cyanAccent.withOpacity(0.06),
                                blurRadius: 20,
                                spreadRadius: 1,
                              ),
                            ],
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
                            'GitHub',
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
                        child: GitHubContributionsWidget(
                          username: 'pratikkumarpradhan',
                          token: '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',
                          height: 180,
                          contributionColors: const [
                            Color(0xFF40C463), // Medium Green - few contributions
                            Color(0xFF7BC96F), // Light Green
                            Color(0xFF9BE9A8), // Lighter Green
                            Color(0xFFB8E6B8), // Very Light Green
                            Color(0xFFD4F4D4), // Lightest Green - most contributions
                          ],
                          emptyColor: const Color(0xff161b22),
                          backgroundColor: Colors.transparent,
                          loadingWidget: const Center(child: CircularProgressIndicator(color: Colors.cyanAccent)),
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
                          Container(width: 10, height: 10, color: const Color(0xFF40C463)),
                          const SizedBox(width: 2),
                          Container(width: 10, height: 10, color: const Color(0xFF7BC96F)),
                          const SizedBox(width: 2),
                          Container(width: 10, height: 10, color: const Color(0xFF9BE9A8)),
                          const SizedBox(width: 2),
                          Container(width: 10, height: 10, color: const Color(0xFFB8E6B8)),
                          const SizedBox(width: 2),
                          Container(width: 10, height: 10, color: const Color(0xFFD4F4D4)),
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
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}