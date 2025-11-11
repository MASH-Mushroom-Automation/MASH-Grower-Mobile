import 'package:flutter/material.dart';
import '../../../core/services/device_connection_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> with SingleTickerProviderStateMixin {
  final DeviceConnectionService _deviceService = DeviceConnectionService();
  late TabController _tabController;
  
  bool _isLoading = true;
  Map<String, dynamic>? _statistics;
  List<dynamic> _sensorLogs = [];
  List<dynamic> _actuatorLogs = [];
  List<dynamic> _aiDecisions = [];
  
  int _selectedHours = 24;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final stats = await _deviceService.getStatistics(hours: _selectedHours);
      final sensors = await _deviceService.getSensorLogs(hours: _selectedHours, limit: 100);
      final actuators = await _deviceService.getActuatorLogs(hours: _selectedHours, limit: 50);
      final decisions = await _deviceService.getAIDecisionLogs(hours: _selectedHours, limit: 20);

      if (mounted) {
        setState(() {
          _statistics = stats;
          _sensorLogs = sensors ?? [];
          _actuatorLogs = actuators ?? [];
          _aiDecisions = decisions ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // Time Range Selector
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                const Text(
                  'Time Range:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D5F4C),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildTimeChip('24h', 24),
                        const SizedBox(width: 8),
                        _buildTimeChip('7d', 168),
                        const SizedBox(width: 8),
                        _buildTimeChip('30d', 720),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Color(0xFF2D5F4C)),
                  onPressed: _loadData,
                ),
              ],
            ),
          ),

          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF2D5F4C),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF4CAF50),
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Sensors'),
                Tab(text: 'Actuators'),
                Tab(text: 'AI Logs'),
              ],
            ),
          ),

          // Tab Views
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF2D5F4C),
                    ),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(),
                      _buildSensorsTab(),
                      _buildActuatorsTab(),
                      _buildAILogsTab(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeChip(String label, int hours) {
    final isSelected = _selectedHours == hours;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedHours = hours);
        _loadData();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4CAF50) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    if (_statistics == null) {
      return const Center(child: Text('No data available'));
    }

    final sensorStats = _statistics!['sensor_readings'] as Map<String, dynamic>?;
    final actuatorUsage = _statistics!['actuator_usage'] as Map<String, dynamic>?;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistics Cards
          const Text(
            'Statistics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D5F4C),
            ),
          ),
          const SizedBox(height: 16),

          if (sensorStats != null) ...[
            _buildStatCard(
              'Average CO2',
              '${sensorStats['co2']?['avg']?.toStringAsFixed(0) ?? 'N/A'} ppm',
              Icons.air,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildStatCard(
              'Average Temperature',
              '${sensorStats['temperature']?['avg']?.toStringAsFixed(1) ?? 'N/A'}°C',
              Icons.thermostat,
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildStatCard(
              'Average Humidity',
              '${sensorStats['humidity']?['avg']?.toStringAsFixed(1) ?? 'N/A'}%',
              Icons.water_drop,
              Colors.cyan,
            ),
          ],

          const SizedBox(height: 24),

          const Text(
            'Actuator Usage',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D5F4C),
            ),
          ),
          const SizedBox(height: 16),

          if (actuatorUsage != null) ...[
            _buildUsageBar('Exhaust Fan', actuatorUsage['exhaust_fan'] ?? 0),
            const SizedBox(height: 12),
            _buildUsageBar('Blower Fan', actuatorUsage['blower_fan'] ?? 0),
            const SizedBox(height: 12),
            _buildUsageBar('Humidifier', actuatorUsage['humidifier'] ?? 0),
            const SizedBox(height: 12),
            _buildUsageBar('LED Lights', actuatorUsage['led_lights'] ?? 0),
          ],

          const SizedBox(height: 24),

          // AI Decisions Count
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.psychology, color: Colors.white, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AI Decisions Made',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${_statistics!['ai_decisions_count'] ?? 0}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorsTab() {
    if (_sensorLogs.isEmpty) {
      return const Center(child: Text('No sensor data available'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _sensorLogs.length,
      itemBuilder: (context, index) {
        final log = _sensorLogs[index];
        return _buildSensorLogCard(log);
      },
    );
  }

  Widget _buildActuatorsTab() {
    if (_actuatorLogs.isEmpty) {
      return const Center(child: Text('No actuator data available'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _actuatorLogs.length,
      itemBuilder: (context, index) {
        final log = _actuatorLogs[index];
        return _buildActuatorLogCard(log);
      },
    );
  }

  Widget _buildAILogsTab() {
    if (_aiDecisions.isEmpty) {
      return const Center(child: Text('No AI decisions available'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _aiDecisions.length,
      itemBuilder: (context, index) {
        final decision = _aiDecisions[index];
        return _buildAIDecisionCard(decision);
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D5F4C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageBar(String label, int count) {
    final maxCount = 100;
    final percentage = (count / maxCount * 100).clamp(0, 100);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D5F4C),
                ),
              ),
              Text(
                '$count times',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorLogCard(Map<String, dynamic> log) {
    final timestamp = log['timestamp'] ?? '';
    final timeAgo = _formatTimeAgo(timestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                timeAgo,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: log['mode'] == 's' 
                      ? Colors.purple.shade50 
                      : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  log['mode'] == 's' ? 'Spawning' : 'Fruiting',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: log['mode'] == 's' 
                        ? Colors.purple.shade700 
                        : Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSensorValue('CO2', '${log['co2']}ppm', Icons.air),
              ),
              Expanded(
                child: _buildSensorValue('Temp', '${log['temperature']}°C', Icons.thermostat),
              ),
              Expanded(
                child: _buildSensorValue('Humidity', '${log['humidity']}%', Icons.water_drop),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSensorValue(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF4CAF50)),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D5F4C),
          ),
        ),
      ],
    );
  }

  Widget _buildActuatorLogCard(Map<String, dynamic> log) {
    final timestamp = log['timestamp'] ?? '';
    final timeAgo = _formatTimeAgo(timestamp);
    final triggeredBy = log['triggered_by'] ?? 'manual';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: triggeredBy == 'ai' 
              ? const Color(0xFF4CAF50).withValues(alpha: 0.3)
              : Colors.grey.shade300,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    triggeredBy == 'ai' ? Icons.psychology : Icons.touch_app,
                    size: 16,
                    color: triggeredBy == 'ai' ? const Color(0xFF4CAF50) : Colors.grey,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    triggeredBy == 'ai' ? 'AI Control' : 'Manual',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: triggeredBy == 'ai' ? const Color(0xFF4CAF50) : Colors.grey,
                    ),
                  ),
                ],
              ),
              Text(
                timeAgo,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildActuatorChip('Exhaust', log['exhaust_fan'] == 1),
              _buildActuatorChip('Blower', log['blower_fan'] == 1),
              _buildActuatorChip('Humidifier', log['humidifier'] == 1),
              _buildActuatorChip('LED', log['led_lights'] == 1),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActuatorChip(String label, bool isOn) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isOn ? const Color(0xFF4CAF50).withValues(alpha: 0.1) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isOn ? const Color(0xFF4CAF50) : Colors.grey.shade300,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOn ? Icons.check_circle : Icons.cancel,
            size: 14,
            color: isOn ? const Color(0xFF4CAF50) : Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isOn ? const Color(0xFF2D5F4C) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIDecisionCard(Map<String, dynamic> decision) {
    final timestamp = decision['timestamp'] ?? '';
    final timeAgo = _formatTimeAgo(timestamp);
    final actions = decision['actions'] as Map<String, dynamic>? ?? {};
    final reasoning = decision['reasoning'] as List<dynamic>? ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4CAF50).withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.psychology, color: Color(0xFF4CAF50), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    decision['mode'] ?? 'Unknown',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D5F4C),
                    ),
                  ),
                ],
              ),
              Text(
                timeAgo,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: actions.entries.map((entry) {
                final actuatorName = entry.key.replaceAll('_', ' ').toUpperCase();
                final isOn = entry.value as bool;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isOn
                        ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$actuatorName ${isOn ? "ON" : "OFF"}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isOn ? const Color(0xFF2D5F4C) : Colors.red.shade700,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          if (reasoning.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: reasoning.map((reason) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, size: 14, color: Colors.blue.shade700),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            reason.toString(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTimeAgo(String timestamp) {
    try {
      final dt = DateTime.parse(timestamp);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (e) {
      return 'Unknown';
    }
  }
}
