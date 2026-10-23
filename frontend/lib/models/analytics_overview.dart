class AnalyticsOverview {
  final int completedTicketsCount;
  final double totalRevenuePhp;
  final int averageDurationMinutes;
  final DateTime? generatedAt;

  AnalyticsOverview({
    this.completedTicketsCount = 0,
    this.totalRevenuePhp = 0.0,
    this.averageDurationMinutes = 15,
    this.generatedAt,
  });

  factory AnalyticsOverview.fromJson(Map<String, dynamic> json) {
    return AnalyticsOverview(
      completedTicketsCount: json['completedTicketsCount'] is int 
          ? json['completedTicketsCount'] 
          : int.tryParse(json['completedTicketsCount']?.toString() ?? '0') ?? 0,
      totalRevenuePhp: (json['totalRevenuePhp'] is num) 
          ? (json['totalRevenuePhp'] as num).toDouble() 
          : double.tryParse(json['totalRevenuePhp']?.toString() ?? '0') ?? 0.0,
      averageDurationMinutes: json['averageDurationMinutes'] is int 
          ? json['averageDurationMinutes'] 
          : int.tryParse(json['averageDurationMinutes']?.toString() ?? '15') ?? 15,
      generatedAt: json['generatedAt'] != null ? DateTime.tryParse(json['generatedAt'].toString()) : null,
    );
  }
}
