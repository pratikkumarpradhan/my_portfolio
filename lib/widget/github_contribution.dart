import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class GitHubContributionsWidget extends StatefulWidget {
  final String username;
  final String token;
  final double height;
  final List<Color> contributionColors;
  final Color emptyColor;
  final Color backgroundColor;
  final TextStyle? monthLabelStyle;
  final TextStyle? dayLabelStyle;
  final Widget? loadingWidget;

  const GitHubContributionsWidget({
    super.key,
    required this.username,
    required this.token,
    required this.height,
    required this.contributionColors,
    required this.emptyColor,
    required this.backgroundColor,
    this.monthLabelStyle,
    this.dayLabelStyle,
    this.loadingWidget,
  });

  @override
  State<GitHubContributionsWidget> createState() =>
      _GitHubContributionsWidgetState();
}

class _GitHubContributionsWidgetState extends State<GitHubContributionsWidget> {
  final ScrollController scrollController = ScrollController();
  List<ContributionDay> _allDays = [];
  bool _isLoading = true;
  String? _error;
  late DateTime _currentDate;

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
    _fetchAllYears();
  }

  Future<void> _fetchAllYears() async {
    final List<ContributionDay> totalDays = [];

    // Only fetch 2025 data
    final result = await _fetchYearlyContributions(2025);
    if (result != null) {
      totalDays.addAll(result);
    }

    setState(() {
      _allDays = totalDays;
      _isLoading = false;
    });

    // ⏩ Delay scroll until frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentMonth();
    });
  }

  Future<List<ContributionDay>?> _fetchYearlyContributions(int year) async {
    const url = 'https://api.github.com/graphql';
    final from = DateTime(year, 1, 1).toIso8601String();
    final to = DateTime(year, 12, 31).toIso8601String();

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'query': '''
        query {
          user(login: "${widget.username}") {
            contributionsCollection(from: "$from", to: "$to") {
              contributionCalendar {
                weeks {
                  contributionDays {
                    date
                    contributionCount
                  }
                }
              }
            }
          }
        }
        '''
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final weeks = data['data']['user']['contributionsCollection']['contributionCalendar']['weeks'];
      final yearDays = <ContributionDay>[];

      for (var week in weeks) {
        for (var day in week['contributionDays']) {
          yearDays.add(
            ContributionDay(
              date: DateTime.parse(day['date']),
              count: day['contributionCount'],
            ),
          );
        }
      }

      return yearDays;
    } else {
      debugPrint('GitHub API error: ${response.body}');
      setState(() {
        _error = 'Failed to load contributions.';
      });
      return null;
    }
  }

  Color _getColor(int count) {
    if (count == 0) return widget.emptyColor;
    final index = (count ~/ 2).clamp(0, widget.contributionColors.length - 1);
    return widget.contributionColors[index]; // dark = few, light = many
  }

  void _scrollToCurrentMonth() {
    final monthGroups = _groupByMonth();
    if (monthGroups.isEmpty) return;
    
    // Scroll to April 2025 (first month in our range)
    final aprilKey = '2025-04';
    double offset = 0;
    
    for (final entry in monthGroups.entries) {
      if (entry.key == aprilKey) break;
      offset += (entry.value.length / 7).ceil() * 18 + 12;
    }

    scrollController.animateTo(
      offset - 100,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
    );
  }

  Map<String, List<ContributionDay>> _groupByMonth() {
    final Map<String, List<ContributionDay>> monthGroups = {};
    for (var day in _allDays) {
      // Filter to only April (4) to September (9) 2025
      if (day.date.year == 2025 && day.date.month >= 4 && day.date.month <= 12) {
        final key = DateFormat('yyyy-MM').format(day.date);
        monthGroups.putIfAbsent(key, () => []).add(day);
      }
    }
    return monthGroups;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.loadingWidget ??
          const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
    }

    if (_error != null) {
      return Center(child: Text(_error!, style: const TextStyle(color: Colors.red)));
    }

    final cellSize = 14.0;
    final cellSpacing = 4.0;
    final monthGroups = _groupByMonth();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.18), width: 1.2),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0B1020),
            Color(0xFF101828),
            Color(0xFF0B1020),
          ],
          stops: [0.0, 0.6, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
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
                                                message: '${day.count} contributions\n${DateFormat.yMMMd().format(day.date)}',
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
                    color: const Color(0xFF0B1020).withOpacity(0.7),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withOpacity(0.18)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
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
                    color: const Color(0xFF0B1020).withOpacity(0.7),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withOpacity(0.18)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
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
        ),
      ),
    );
  }
}

class ContributionDay {
  final DateTime date;
  final int count;

  ContributionDay({required this.date, required this.count});
}