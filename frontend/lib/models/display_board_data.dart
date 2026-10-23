class DisplayBoardData {
  final String? eventType;
  final int? currentServingNumber;
  final String? currentServingCustomer;
  final int? almostNextNumber;
  final String? almostNextCustomer;
  final int totalWaitingCount;
  final List<int> waitingNumbers;
  final String? alertMessage;
  final DateTime? timestamp;

  DisplayBoardData({
    this.eventType,
    this.currentServingNumber,
    this.currentServingCustomer,
    this.almostNextNumber,
    this.almostNextCustomer,
    this.totalWaitingCount = 0,
    this.waitingNumbers = const [],
    this.alertMessage,
    this.timestamp,
  });

  factory DisplayBoardData.fromJson(Map<String, dynamic> json) {
    final numbers = <int>[];
    if (json['waitingNumbers'] is List) {
      for (final item in json['waitingNumbers']) {
        if (item is int) {
          numbers.add(item);
        } else if (item != null) {
          final parsed = int.tryParse(item.toString());
          if (parsed != null) numbers.add(parsed);
        }
      }
    }

    return DisplayBoardData(
      eventType: json['eventType']?.toString(),
      currentServingNumber: json['currentServingNumber'] is int 
          ? json['currentServingNumber'] 
          : int.tryParse(json['currentServingNumber']?.toString() ?? ''),
      currentServingCustomer: json['currentServingCustomer']?.toString(),
      almostNextNumber: json['almostNextNumber'] is int 
          ? json['almostNextNumber'] 
          : int.tryParse(json['almostNextNumber']?.toString() ?? ''),
      almostNextCustomer: json['almostNextCustomer']?.toString(),
      totalWaitingCount: json['totalWaitingCount'] is int 
          ? json['totalWaitingCount'] 
          : int.tryParse(json['totalWaitingCount']?.toString() ?? '0') ?? 0,
      waitingNumbers: numbers,
      alertMessage: json['alertMessage']?.toString(),
      timestamp: json['timestamp'] != null ? DateTime.tryParse(json['timestamp'].toString()) : null,
    );
  }
}
