enum ToolType { incinerator, composting, pyrolysis }

class ToolParameter {
  final String label;
  final double value;
  final String unit;
  final double minTarget;
  final double maxTarget;
  final String? status;

  ToolParameter({
    required this.label,
    required this.value,
    required this.unit,
    required this.minTarget,
    required this.maxTarget,
    this.status,
  });

  bool get isAlert => value < minTarget || value > maxTarget;

  String get recommendation {
    if (value < minTarget) {
      if (label.toLowerCase().contains('kelembapan')) return 'Segera nyalakan pompa air mini';
      if (label.toLowerCase().contains('suhu')) return 'Tingkatkan intensitas panas/pembakaran';
      return 'Parameter di bawah batas optimal';
    }
    if (value > maxTarget) {
      if (label.toLowerCase().contains('tekanan')) return 'Periksa Safety Relief Valve';
      if (label.toLowerCase().contains('suhu')) return 'Kurangi intensitas panas/aktifkan pendingin';
      return 'Parameter melebihi batas aman';
    }
    return 'Status Normal';
  }
}

class RecyclingTool {
  final String id;
  final String name;
  final ToolType type;
  final List<ToolParameter> parameters;
  final String emissionStatus;

  RecyclingTool({
    required this.id,
    required this.name,
    required this.type,
    required this.parameters,
    this.emissionStatus = 'Normal',
  });

  bool get hasAlert => parameters.any((p) => p.isAlert);
}
