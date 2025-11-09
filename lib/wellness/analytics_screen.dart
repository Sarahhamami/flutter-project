import 'package:flutter/material.dart';
import '../services/wellness_service.dart';

class AnalyticsScreen extends StatefulWidget {
  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final WellnessService _wellnessService = WellnessService();
  Map<String, dynamic> _analyticsData = {};
  bool _isLoading = true;

  // Custom colors
  final Color whiteColor = Colors.white;
  final Color lightGreenColor = Color(0xFF20c997);
  final Color blueColor = Color(0xFF0dcaf0);
  final Color grayColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    final data = await _wellnessService.getAnalyticsData(1);
    setState(() {
      _analyticsData = data;
      _isLoading = false;
    });
  }

  Widget _buildProgressCard(String title, Map<String, dynamic> goal) {
    final progress = (goal['achieved'] / goal['target'] * 100).toDouble();
    return Card(
      elevation: 3,
      color: whiteColor,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: grayColor.withOpacity(0.2),
              color: progress >= 100 ? Colors.green : blueColor,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${goal['achieved']}/${goal['target']} ${goal['unit']}',
                  style: TextStyle(fontSize: 14, color: grayColor),
                ),
                Text(
                  '${progress.toInt()}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: progress >= 100 ? Colors.green : blueColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendCard(String title, List<dynamic> trendData, String emoji) {
    return Card(
      elevation: 3,
      color: whiteColor,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(emoji, style: TextStyle(fontSize: 20)),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 12),
            Container(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: trendData.asMap().entries.map((entry) {
                  final index = entry.key;
                  final value = entry.value;
                  final day = ['M', 'T', 'W', 'T', 'F', 'S', 'S'][index];
                  
                  return Column(
                    children: [
                      Text(
                        value.toString(),
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Container(
                        width: 20,
                        height: 30,
                        child: CustomPaint(
                          painter: _BarPainter(
                            value: value.toDouble(),
                            maxValue: 10,
                            color: blueColor,
                          ),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        day,
                        style: TextStyle(fontSize: 10, color: grayColor),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: Text(
          'Wellness Analytics',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: blueColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: blueColor),
                  SizedBox(height: 16),
                  Text(
                    'Loading analytics...',
                    style: TextStyle(color: grayColor),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Weekly Progress',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  // Weekly goals
                  if (_analyticsData['weeklyGoals'] != null) ...[
                    _buildProgressCard(
                      'Sleep',
                      _analyticsData['weeklyGoals']['sleep'],
                    ),
                    SizedBox(height: 12),
                    _buildProgressCard(
                      'Meditation',
                      _analyticsData['weeklyGoals']['meditation'],
                    ),
                    SizedBox(height: 12),
                    _buildProgressCard(
                      'Exercise',
                      _analyticsData['weeklyGoals']['exercise'],
                    ),
                    SizedBox(height: 20),
                  ],
                  
                  // Trends
                  Text(
                    'Weekly Trends',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  if (_analyticsData['sleepTrend'] != null) ...[
                    _buildTrendCard('Sleep Hours', _analyticsData['sleepTrend'], '😴'),
                    SizedBox(height: 12),
                  ],
                  
                  if (_analyticsData['moodTrend'] != null) ...[
                    _buildTrendCard('Mood Level', _analyticsData['moodTrend'], '😊'),
                    SizedBox(height: 12),
                  ],
                  
                  if (_analyticsData['stressTrend'] != null) ...[
                    _buildTrendCard('Stress Level', _analyticsData['stressTrend'], '😌'),
                    SizedBox(height: 12),
                  ],
                  
                  if (_analyticsData['energyTrend'] != null) ...[
                    _buildTrendCard('Energy Level', _analyticsData['energyTrend'], '⚡'),
                    SizedBox(height: 20),
                  ],
                  
                  // Insights
                  if (_analyticsData['insights'] != null) ...[
                    Text(
                      'Insights & Recommendations',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 16),
                    ..._analyticsData['insights'].map<Widget>((insight) => Card(
                      elevation: 2,
                      color: lightGreenColor.withOpacity(0.1),
                      child: ListTile(
                        leading: Icon(Icons.lightbulb, color: lightGreenColor),
                        title: Text(
                          insight,
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    )).toList(),
                  ],
                ],
              ),
            ),
    );
  }
}

class _BarPainter extends CustomPainter {
  final double value;
  final double maxValue;
  final Color color;

  _BarPainter({
    required this.value,
    required this.maxValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final height = (value / maxValue) * size.height;
    final rect = Rect.fromLTRB(
      0,
      size.height - height,
      size.width,
      size.height,
    );

    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(4));
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}