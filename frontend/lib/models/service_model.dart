class ServiceModel {
  final String id;
  final String name;
  final String category;
  final double unitPrice;
  final int baselineDurationMinutes;
  final bool active;

  ServiceModel({
    required this.id,
    required this.name,
    required this.category,
    required this.unitPrice,
    required this.baselineDurationMinutes,
    this.active = true,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Service',
      category: json['category']?.toString() ?? 'GENERAL',
      unitPrice: (json['unitPrice'] is num) 
          ? (json['unitPrice'] as num).toDouble() 
          : double.tryParse(json['unitPrice']?.toString() ?? '0') ?? 0.0,
      baselineDurationMinutes: json['baselineDurationMinutes'] is int 
          ? json['baselineDurationMinutes'] 
          : int.tryParse(json['baselineDurationMinutes']?.toString() ?? '15') ?? 15,
      active: json['active'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'unitPrice': unitPrice,
      'baselineDurationMinutes': baselineDurationMinutes,
    };
  }
}
