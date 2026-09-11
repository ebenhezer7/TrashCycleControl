import 'package:flutter/material.dart';
import '../models/recycling_tool.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  // Dummy data initialization
  final List<RecyclingTool> tools = [
    RecyclingTool(
      id: '1',
      name: 'Low-Smoke Incinerator',
      type: ToolType.incinerator,
      emissionStatus: 'Aman',
      parameters: [
        ToolParameter(
          label: 'Suhu Ruang Bakar',
          value: 450.0,
          unit: '°C',
          minTarget: 400.0,
          maxTarget: 600.0,
        ),
      ],
    ),
    RecyclingTool(
      id: '2',
      name: 'Smart Composting Bin',
      type: ToolType.composting,
      parameters: [
        ToolParameter(
          label: 'Kelembapan Kompos',
          value: 35.5, // Alert state (< 40%)
          unit: '%',
          minTarget: 40.0,
          maxTarget: 60.0,
        ),
        ToolParameter(
          label: 'Suhu Termofilik',
          value: 55.0,
          unit: '°C',
          minTarget: 45.0,
          maxTarget: 65.0,
        ),
      ],
    ),
    RecyclingTool(
      id: '3',
      name: 'Sistem Pirolisis Plastik',
      type: ToolType.pyrolysis,
      parameters: [
        ToolParameter(
          label: 'Suhu Reaktor',
          value: 420.0,
          unit: '°C',
          minTarget: 350.0,
          maxTarget: 500.0,
        ),
        ToolParameter(
          label: 'Tekanan Internal',
          value: 0.6, // Alert state (> 0.5 bar)
          unit: 'bar',
          minTarget: 0.0,
          maxTarget: 0.5,
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Monitoring'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: tools.length,
        itemBuilder: (context, index) {
          final tool = tools[index];
          return ToolCard(tool: tool);
        },
      ),
    );
  }
}

class ToolCard extends StatelessWidget {
  final RecyclingTool tool;

  const ToolCard({super.key, required this.tool});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isAlert = tool.hasAlert;

    return Card(
      elevation: isAlert ? 4 : 1,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isAlert ? colorScheme.error : Colors.transparent,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isAlert
                  ? colorScheme.errorContainer
                  : colorScheme.surfaceVariant,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _getToolIcon(tool.type),
                      color: isAlert ? colorScheme.error : colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      tool.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: isAlert ? colorScheme.onErrorContainer : null,
                      ),
                    ),
                  ],
                ),
                if (isAlert)
                  Icon(Icons.warning_amber_rounded, color: colorScheme.error),
              ],
            ),
          ),

          // Parameter List
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: tool.parameters.map((param) => _buildParameterRow(context, param)).toList(),
            ),
          ),

          // Emission status for Incinerator
          if (tool.type == ToolType.incinerator)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  const Text('Status Emisi: ', style: TextStyle(fontWeight: FontWeight.w500)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      tool.emissionStatus,
                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

          // Recommendation Banners
          ...tool.parameters.where((p) => p.isAlert).map((p) => _buildRecommendationBanner(context, p)),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildParameterRow(BuildContext context, ToolParameter param) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(param.label, style: const TextStyle(fontSize: 16)),
              Text(
                '${param.value} ${param.unit}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: param.isAlert ? colorScheme.error : colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Progress Bar/Indicator
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _calculateProgress(param),
              backgroundColor: colorScheme.outlineVariant,
              color: param.isAlert ? colorScheme.error : colorScheme.primary,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Target: ${param.minTarget} - ${param.maxTarget} ${param.unit}',
            style: TextStyle(fontSize: 12, color: colorScheme.outline),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationBanner(BuildContext context, ToolParameter param) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: colorScheme.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Rekomendasi: ${param.recommendation}',
              style: TextStyle(
                color: colorScheme.error,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateProgress(ToolParameter param) {
    // Normalizing value for progress bar (simplified)
    double progress = param.value / (param.maxTarget * 1.2);
    return progress.clamp(0.0, 1.0);
  }

  IconData _getToolIcon(ToolType type) {
    switch (type) {
      case ToolType.incinerator:
        return Icons.local_fire_department;
      case ToolType.composting:
        return Icons.eco;
      case ToolType.pyrolysis:
        return Icons.settings_input_component;
    }
  }
}
