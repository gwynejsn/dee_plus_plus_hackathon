class AiPrediction {
  final int predictedDurationMinutes;
  final double confidenceScore;
  final double varianceFactor;
  final String summaryInsight;
  final String operationalAdvice;
  final String bottleneckRisk;
  final DateTime? generatedAt;

  AiPrediction({
    required this.predictedDurationMinutes,
    required this.confidenceScore,
    required this.varianceFactor,
    required this.summaryInsight,
    required this.operationalAdvice,
    required this.bottleneckRisk,
    this.generatedAt,
  });

  factory AiPrediction.fromJson(Map<String, dynamic> json) {
    return AiPrediction(
      predictedDurationMinutes: json['predictedDurationMinutes'] is int 
          ? json['predictedDurationMinutes'] 
          : int.tryParse(json['predictedDurationMinutes']?.toString() ?? '15') ?? 15,
      confidenceScore: (json['confidenceScore'] is num) 
          ? (json['confidenceScore'] as num).toDouble() 
          : double.tryParse(json['confidenceScore']?.toString() ?? '0.85') ?? 0.85,
      varianceFactor: (json['varianceFactor'] is num) 
          ? (json['varianceFactor'] as num).toDouble() 
          : double.tryParse(json['varianceFactor']?.toString() ?? '1.0') ?? 1.0,
      summaryInsight: json['summaryInsight']?.toString() ?? 'Predictive wait analysis available.',
      operationalAdvice: json['operationalAdvice']?.toString() ?? 'Maintain standard service flow.',
      bottleneckRisk: json['bottleneckRisk']?.toString() ?? 'LOW',
      generatedAt: json['generatedAt'] != null ? DateTime.tryParse(json['generatedAt'].toString()) : null,
    );
  }
}
