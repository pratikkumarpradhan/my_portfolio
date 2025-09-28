
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

/// Replace this with your actual LeetCode profile URL
const String LEETCODE_PROFILE_URL = "https://leetcode.com/u/Pratik_Kumar_Pradhan/";

/// Helper to extract username from profile URL
String extractUsernameFromUrl(String url) {
  final uri = Uri.parse(url);
  final segments = uri.pathSegments.where((p) => p.isNotEmpty).toList();
  if (segments.isEmpty) return "";
  if (segments[0].toLowerCase() == 'u' && segments.length >= 2) {
    return segments[1];
  }
  return segments[0];
}

/// Fetch contributions from LeetCode GraphQL
Future<Map<DateTime, int>> fetchLeetCodeContributions(String username) async {
  final url = Uri.parse("https://leetcode.com/graphql");
  final headers = {
    "Content-Type": "application/json",
    "Referer": "https://leetcode.com/$username/",
    "Origin": "https://leetcode.com",
    "User-Agent": "Mozilla/5.0"
  };

  // 1. Yearly submission calendar
  final calendarBody = jsonEncode({
    "query": """
      query userProfileCalendar(\$username: String!) {
        matchedUser(username: \$username) {
          userCalendar {
            submissionCalendar
          }
        }
      }
    """,
    "variables": {"username": username}
  });

  final calendarRes = await http.post(url, headers: headers, body: calendarBody);

  if (calendarRes.statusCode != 200) {
    throw Exception("Failed to fetch calendar: ${calendarRes.statusCode}");
  }

  final calendarJson = jsonDecode(calendarRes.body);
  final calendar = calendarJson['data']?['matchedUser']?['userCalendar']?['submissionCalendar'];

  Map<DateTime, int> contributions = {};
  if (calendar != null) {
    final parsed = Map<String, dynamic>.from(jsonDecode(calendar));
    contributions = parsed.map((key, value) {
      final timestamp = int.parse(key) * 1000;
      return MapEntry(DateTime.fromMillisecondsSinceEpoch(timestamp), value as int);
    });
  }

  // 2. Today's accepted submissions (to ensure latest activity)
  final recentBody = jsonEncode({
    "query": """
      query recentAcSubmissions(\$username: String!) {
        recentAcSubmissionList(username: \$username) {
          id
          title
          timestamp
        }
      }
    """,
    "variables": {"username": username}
  });

  final recentRes = await http.post(url, headers: headers, body: recentBody);
  if (recentRes.statusCode == 200) {
    final recentJson = jsonDecode(recentRes.body);
    final recentSubs = recentJson['data']?['recentAcSubmissionList'] ?? [];

    for (var sub in recentSubs) {
      final ts = int.parse(sub['timestamp']) * 1000;
      final date = DateTime.fromMillisecondsSinceEpoch(ts).toLocal();
      final today = DateTime(date.year, date.month, date.day);

      contributions[today] = (contributions[today] ?? 0) + 1;
    }
  }

  return contributions;
}

/// Widget for rendering contributions graph with scrollable layout
class LeetCodeContributionsWidget extends StatefulWidget {
  final Map<DateTime, int> contributions;
  final double height;
  final List<Color> contributionColors;
  final Color emptyColor;
  final Color backgroundColor;
  final TextStyle? monthLabelStyle;
  final TextStyle? dayLabelStyle;
  final Widget? loadingWidget;

  const LeetCodeContributionsWidget({
    super.key,
    required this.contributions,
    required this.height,
    required this.contributionColors,
    required this.emptyColor,
    required this.backgroundColor,
    this.monthLabelStyle,
    this.dayLabelStyle,
    this.loadingWidget,
  });

  @override
  State<LeetCodeContributionsWidget> createState() => _LeetCodeContributionsWidgetState();
}

class _LeetCodeContributionsWidgetState extends State<LeetCodeContributionsWidget> {
  final ScrollController scrollController = ScrollController();

  Color _getColor(int count) {
    if (count == 0) return widget.emptyColor;
    final index = (count ~/ 2).clamp(0, widget.contributionColors.length - 1);
    return widget.contributionColors.reversed.toList()[index]; // reversed for dark = more
  }

  Map<String, List<ContributionDay>> _groupByMonth() {
    final Map<String, List<ContributionDay>> monthGroups = {};
    for (var entry in widget.contributions.entries) {
      final key = DateFormat('yyyy-MM').format(entry.key);
      monthGroups.putIfAbsent(key, () => []).add(
        ContributionDay(date: entry.key, count: entry.value),
      );
    }
    return monthGroups;
  }

  @override
  Widget build(BuildContext context) {
    final cellSize = 14.0;
    final cellSpacing = 4.0;
    final monthGroups = _groupByMonth();

    return SizedBox(
      height: widget.height + 50,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: SingleChildScrollView(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: monthGroups.entries.map((entry) {
                    final days = entry.value;
                    days.sort((a, b) => a.date.compareTo(b.date));

                    // Group into weeks
                    final List<List<ContributionDay?>> weeks = [];
                    List<ContributionDay?> currentWeek = List.filled(7, null);
                    for (var day in days) {
                      final weekday = day.date.weekday % 7;
                      currentWeek[weekday] = day;
                      if (weekday == 6) {
                        weeks.add(currentWeek);
                        currentWeek = List.filled(7, null);
                      }
                    }
                    if (currentWeek.any((d) => d != null)) {
                      weeks.add(currentWeek);
                    }

                    final monthLabel = DateFormat.MMM().format(days.first.date);

                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 6.0),
                              child: Text(
                                monthLabel,
                                style: widget.monthLabelStyle ??
                                    const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Row(
                            children: weeks.map((week) {
                              return Column(
                                children: List.generate(7, (i) {
                                  final day = week[i];
                                  return Container(
                                    margin: EdgeInsets.only(bottom: cellSpacing, right: cellSpacing),
                                    width: cellSize,
                                    height: cellSize,
                                    decoration: BoxDecoration(
                                      color: day != null
                                          ? _getColor(day.count)
                                          : widget.emptyColor.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    child: day != null
                                        ? Tooltip(
                                            message: '${day.count} submissions\n${DateFormat.yMMMd().format(day.date)}',
                                            child: Container(color: Colors.transparent),
                                          )
                                        : const SizedBox.shrink(),
                                  );
                                }),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          // ⬅️ Scroll Left Button
          Positioned(
            left: 8,
            top: widget.height / 2 - 24,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.all(6),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 18, color: Colors.white),
                onPressed: () {
                  scrollController.animateTo(
                    scrollController.offset - 200,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.ease,
                  );
                },
              ),
            ),
          ),

          // ➡️ Scroll Right Button
          Positioned(
            right: 8,
            top: widget.height / 2 - 24,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.all(6),
              child: IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.white),
                onPressed: () {
                  scrollController.animateTo(
                    scrollController.offset + 200,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.ease,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ContributionDay {
  final DateTime date;
  final int count;

  ContributionDay({required this.date, required this.count});
}

/// Main Graph Screen (embed in LeetcodeScreen)
class LeetCodeGraphScreen extends StatefulWidget {
  final String? profileUrl;
  final String? username;
  const LeetCodeGraphScreen({super.key, this.profileUrl, this.username});

  @override
  State<LeetCodeGraphScreen> createState() => _LeetCodeGraphScreenState();
}

class _LeetCodeGraphScreenState extends State<LeetCodeGraphScreen> {
  Map<DateTime, int> contributions = {};
  bool isLoading = true;
  String? usernameUsed;
  bool fetchFailed = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final providedUsername = widget.username?.trim() ?? '';
    final urlUsername = (widget.profileUrl?.isNotEmpty ?? false)
        ? extractUsernameFromUrl(widget.profileUrl!)
        : '';
    final username = providedUsername.isNotEmpty ? providedUsername : urlUsername;
    usernameUsed = username;

    if (username.isEmpty) {
      setState(() => isLoading = false);
      return;
    }

    try {
      contributions = await fetchLeetCodeContributions(username);
    } catch (e) {
      fetchFailed = true;
      debugPrint("Error fetching data: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
    }

    if (contributions.isEmpty) {
      // On web, LeetCode GraphQL may be blocked by CORS. Fallback to external SVG heatmap.
      if (kIsWeb && (usernameUsed?.isNotEmpty ?? false)) {
        final heatmapUrl =
            'https://leetcard.jacoblin.cool/${usernameUsed!}?ext=heatmap&border=0&radius=8&theme=dark';
        return Center(
          child: SvgPicture.network(
            heatmapUrl,
            width: 750,
            height: 180,
            placeholderBuilder: (context) => const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.cyanAccent),
            ),
          ),
        );
      }

      return const Center(
        child: Text(
          "No activity found",
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return LeetCodeContributionsWidget(
      contributions: contributions,
      height: 180,
      contributionColors: const [
        Color(0xFF216E39), // Very Dark Green - few contributions
        Color(0xFF30A14E), // Darker Green
        Color(0xFF40C463), // Medium Green
        Color(0xFF9BE9A8), // Deepest Green
      ],
      emptyColor: const Color(0xff161b22),
      backgroundColor: Colors.transparent,
      loadingWidget: const Center(child: CircularProgressIndicator(color: Colors.cyanAccent)),
    );
  }
}
