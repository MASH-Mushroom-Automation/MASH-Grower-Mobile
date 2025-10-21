import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../devices/wifi_device_connection_screen.dart';

class AnalyticsViewScreen extends StatefulWidget {
  const AnalyticsViewScreen({super.key});

  @override
  State<AnalyticsViewScreen> createState() => _AnalyticsViewScreenState();
}

class _AnalyticsViewScreenState extends State<AnalyticsViewScreen> {
  String _selectedPeriod = 'Week';
  final List<String> _periods = ['Day', 'Week', 'Month', 'Year'];
  String _selectedDevice = 'All Devices';
  // Set to empty list to test no device state
  final List<String> _devices = ['All Devices', 'Chamber 1', 'Chamber 2'];
  bool _hasDevices = true; // Change to false to show empty state
  
  // Mock data based on period
  Map<String, dynamic> get _currentData {
    switch (_selectedPeriod) {
      case 'Day':
        return {
          'energy': '12 kWh',
          'energyChange': '+5%',
          'energyTrend': 'up',
          'avgTemp': '30.2°C',
          'avgHumidity': '55%',
          'uptime': '100%',
          'efficiency': '92%',
          'responseTime': '0.8s',
        };
      case 'Week':
        return {
          'energy': '165 kWh',
          'energyChange': '-12%',
          'energyTrend': 'down',
          'avgTemp': '29.5°C',
          'avgHumidity': '52%',
          'uptime': '99.8%',
          'efficiency': '87.5%',
          'responseTime': '1.2s',
        };
      case 'Month':
        return {
          'energy': '680 kWh',
          'energyChange': '-8%',
          'energyTrend': 'down',
          'avgTemp': '29.8°C',
          'avgHumidity': '53%',
          'uptime': '99.2%',
          'efficiency': '85%',
          'responseTime': '1.5s',
        };
      case 'Year':
        return {
          'energy': '8,450 kWh',
          'energyChange': '-15%',
          'energyTrend': 'down',
          'avgTemp': '29.1°C',
          'avgHumidity': '51%',
          'uptime': '98.5%',
          'efficiency': '83%',
          'responseTime': '1.8s',
        };
      default:
        return {};
    }
  }

  // Mock time-series data for charts based on selected period
  List<double> _energySeries() {
    switch (_selectedPeriod) {
      case 'Day':
        return [10, 12, 11, 13, 12.5, 12, 12.2, 11.8, 12.4, 12.0, 11.7, 12.1];
      case 'Week':
        return [20, 24, 22, 19, 18, 21, 25];
      case 'Month':
        return [80, 76, 70, 72, 68, 65, 60, 62, 64, 66, 63, 61];
      case 'Year':
        return [700, 680, 720, 760, 740, 710, 690, 670, 650, 640, 660, 680];
      default:
        return [0, 0, 0];
    }
  }

  List<double> _temperatureSeries() {
    switch (_selectedPeriod) {
      case 'Day':
        return [29.5, 30.0, 30.4, 31.0, 30.8, 30.1, 29.9, 29.7, 30.2, 30.0, 29.8, 29.6];
      case 'Week':
        return [29.2, 29.8, 30.1, 30.0, 29.7, 29.5, 29.9];
      case 'Month':
        return [29.0, 29.3, 29.6, 29.8, 30.1, 29.9, 29.7, 29.5, 29.6, 29.4, 29.3, 29.5];
      case 'Year':
        return [28.8, 29.1, 29.3, 29.5, 29.8, 29.7, 29.6, 29.4, 29.2, 29.1, 29.0, 29.2];
      default:
        return [0, 0, 0];
    }
  }

  List<double> _humiditySeries() {
    switch (_selectedPeriod) {
      case 'Day':
        return [52, 53, 54, 55, 56, 55, 54, 53, 52, 51, 52, 53];
      case 'Week':
        return [50, 52, 54, 53, 51, 52, 53];
      case 'Month':
        return [52, 53, 54, 55, 54, 53, 52, 51, 52, 53, 54, 53];
      case 'Year':
        return [50, 51, 52, 53, 52, 51, 50, 49, 50, 51, 52, 51];
      default:
        return [0, 0, 0];
    }
  }

  List<FlSpot> _toSpots(List<double> series) {
    return List<FlSpot>.generate(series.length, (i) => FlSpot(i.toDouble(), series[i]));
  }

  // Get X-axis labels based on period
  String _getXAxisLabel(int index) {
    switch (_selectedPeriod) {
      case 'Day':
        // Hours: 0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22
        return '${index * 2}h';
      case 'Week':
        // Days: Mon, Tue, Wed, Thu, Fri, Sat, Sun
        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        return index < days.length ? days[index] : '';
      case 'Month':
        // Weeks: W1, W2, W3, W4
        return 'W${index + 1}';
      case 'Year':
        // Months: Jan, Feb, Mar, etc.
        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        return index < months.length ? months[index] : '';
      default:
        return '';
    }
  }

  // Get interval for showing X-axis labels
  double _getXAxisInterval() {
    switch (_selectedPeriod) {
      case 'Day':
        return 2; // Show every 2 hours
      case 'Week':
        return 1; // Show every day
      case 'Month':
        return 2; // Show every 2 weeks
      case 'Year':
        return 2; // Show every 2 months
      default:
        return 1;
    }
  }
  

  double _getResponseTimeProgress(String responseTime) {
    // Convert response time to progress (lower is better, so invert)
    final time = double.parse(responseTime.replaceAll('s', ''));
    // Assuming 2s is 0% and 0s is 100%
    return (2.0 - time) / 2.0;
  }

  @override
  Widget build(BuildContext context) {
    // Show empty state if no devices
    if (!_hasDevices) {
      return _buildEmptyState();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF2D5F4C),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Analytics',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF2D5F4C),
                      Color(0xFF1E4034),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Period Selector
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: _periods.map((period) {
                      final isSelected = period == _selectedPeriod;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedPeriod = period;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF2D5F4C) : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              period,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? Colors.white : Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 16),

                // Device Filter
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.filter_list, color: Color(0xFF2D5F4C), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedDevice,
                            isExpanded: true,
                            items: _devices.map((device) {
                              return DropdownMenuItem(
                                value: device,
                                child: Text(
                                  device,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF2D5F4C),
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedDevice = value!;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Energy Usage Card
                _buildAnalyticsCard(
                  title: 'Energy Usage',
                  icon: Icons.bolt,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Consumption',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _currentData['energy'],
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D5F4C),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _currentData['energyTrend'] == 'down' 
                                ? Colors.green.shade100 
                                : Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _currentData['energyTrend'] == 'down' 
                                    ? Icons.arrow_downward 
                                    : Icons.arrow_upward,
                                size: 16,
                                color: _currentData['energyTrend'] == 'down'
                                    ? Colors.green.shade700
                                    : Colors.orange.shade700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _currentData['energyChange'],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: _currentData['energyTrend'] == 'down'
                                      ? Colors.green.shade700
                                      : Colors.orange.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Energy Usage Chart
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Legend
                        Row(
                          children: [
                            Container(
                              width: 16,
                              height: 3,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2D5F4C),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Energy (kWh)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 200,
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                horizontalInterval: 5,
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                    color: Colors.grey.shade200,
                                    strokeWidth: 1,
                                  );
                                },
                              ),
                              titlesData: FlTitlesData(
                                show: true,
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    interval: _selectedPeriod == 'Year' ? 200 : (_selectedPeriod == 'Month' ? 20 : 5),
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        value.toInt().toString(),
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 10,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 30,
                                    interval: _getXAxisInterval(),
                                    getTitlesWidget: (value, meta) {
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          _getXAxisLabel(value.toInt()),
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 10,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(
                                show: true,
                                border: Border(
                                  bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                                  left: BorderSide(color: Colors.grey.shade300, width: 1),
                                ),
                              ),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: _toSpots(_energySeries()),
                                  isCurved: true,
                                  color: const Color(0xFF2D5F4C),
                                  barWidth: 3,
                                  dotData: const FlDotData(show: false),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: const Color(0xFF2D5F4C).withOpacity(0.15),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Temperature & Humidity Card
                _buildAnalyticsCard(
                  title: 'Temperature & Humidity',
                  icon: Icons.thermostat,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricItem(
                            label: 'Avg Temperature',
                            value: _currentData['avgTemp'],
                            icon: Icons.thermostat,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMetricItem(
                            label: 'Avg Humidity',
                            value: _currentData['avgHumidity'],
                            icon: Icons.water_drop,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Temperature & Humidity Chart
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Legend
                        Row(
                          children: [
                            Container(
                              width: 16,
                              height: 3,
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Temperature (°C)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              width: 16,
                              height: 3,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Humidity (%)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 200,
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                horizontalInterval: 10,
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                    color: Colors.grey.shade200,
                                    strokeWidth: 1,
                                  );
                                },
                              ),
                              titlesData: FlTitlesData(
                                show: true,
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    interval: 10,
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        value.toInt().toString(),
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 10,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 30,
                                    interval: _getXAxisInterval(),
                                    getTitlesWidget: (value, meta) {
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          _getXAxisLabel(value.toInt()),
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 10,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(
                                show: true,
                                border: Border(
                                  bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                                  left: BorderSide(color: Colors.grey.shade300, width: 1),
                                ),
                              ),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: _toSpots(_temperatureSeries()),
                                  isCurved: true,
                                  color: Colors.orange,
                                  barWidth: 3,
                                  dotData: const FlDotData(show: false),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: Colors.orange.withOpacity(0.10),
                                  ),
                                ),
                                LineChartBarData(
                                  spots: _toSpots(_humiditySeries()),
                                  isCurved: true,
                                  color: Colors.blue,
                                  barWidth: 3,
                                  dotData: const FlDotData(show: false),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: Colors.blue.withOpacity(0.08),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // System Performance Card
                _buildAnalyticsCard(
                  title: 'System Performance',
                  icon: Icons.speed,
                  children: [
                    _buildPerformanceItem(
                      label: 'Uptime',
                      value: _currentData['uptime'],
                      progress: double.parse(_currentData['uptime'].replaceAll('%', '')) / 100,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 16),
                    _buildPerformanceItem(
                      label: 'Efficiency',
                      value: _currentData['efficiency'],
                      progress: double.parse(_currentData['efficiency'].replaceAll('%', '')) / 100,
                      color: const Color(0xFF2D5F4C),
                    ),
                    const SizedBox(height: 16),
                    _buildPerformanceItem(
                      label: 'Response Time',
                      value: _currentData['responseTime'],
                      progress: _getResponseTimeProgress(_currentData['responseTime']),
                      color: Colors.blue,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Alerts & Events Card
                _buildAnalyticsCard(
                  title: 'Recent Alerts & Events',
                  icon: Icons.notifications,
                  children: [
                    _buildAlertItem(
                      title: 'Temperature spike detected',
                      time: '2 hours ago',
                      type: 'warning',
                    ),
                    const Divider(height: 24),
                    _buildAlertItem(
                      title: 'Humidity level optimal',
                      time: '5 hours ago',
                      type: 'success',
                    ),
                    const Divider(height: 24),
                    _buildAlertItem(
                      title: 'System maintenance completed',
                      time: '1 day ago',
                      type: 'info',
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D5F4C).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFF2D5F4C), size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D5F4C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceItem({
    required String label,
    required String value,
    required double progress,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2D5F4C),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildAlertItem({
    required String title,
    required String time,
    required String type,
  }) {
    Color iconColor;
    IconData iconData;

    switch (type) {
      case 'warning':
        iconColor = Colors.orange;
        iconData = Icons.warning_amber_rounded;
        break;
      case 'success':
        iconColor = Colors.green;
        iconData = Icons.check_circle;
        break;
      case 'info':
        iconColor = Colors.blue;
        iconData = Icons.info;
        break;
      default:
        iconColor = Colors.grey;
        iconData = Icons.circle;
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(iconData, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2D5F4C),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Analytics',
          style: TextStyle(
            color: Color(0xFF2D5F4C),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D5F4C).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.analytics_outlined,
                  size: 80,
                  color: Color(0xFF2D5F4C),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'No Analytics Available',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D5F4C),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Connect a device to start tracking energy usage, temperature, humidity, and system performance',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WiFiDeviceConnectionScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D5F4C),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Connect Device',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
