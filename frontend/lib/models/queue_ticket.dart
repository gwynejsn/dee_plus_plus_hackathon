enum TicketState {
  waiting,
  almostNext,
  nowServing,
  completed,
  cancelled;

  static TicketState fromString(String? val) {
    if (val == null) return TicketState.waiting;
    final upper = val.toUpperCase().replaceAll('-', '_');
    switch (upper) {
      case 'ALMOST_NEXT':
        return TicketState.almostNext;
      case 'NOW_SERVING':
      case 'SERVING':
        return TicketState.nowServing;
      case 'COMPLETED':
        return TicketState.completed;
      case 'CANCELLED':
      case 'CANCELED':
        return TicketState.cancelled;
      case 'WAITING':
      case 'IN_LINE':
      default:
        return TicketState.waiting;
    }
  }

  String get displayName {
    switch (this) {
      case TicketState.waiting:
        return 'IN LINE';
      case TicketState.almostNext:
        return 'ALMOST NEXT';
      case TicketState.nowServing:
        return 'NOW SERVING';
      case TicketState.completed:
        return 'COMPLETED';
      case TicketState.cancelled:
        return 'CANCELLED';
    }
  }
}

class QueueTicket {
  final String id;
  final int ticketNumber;
  final String customerName;
  final String serviceId;
  final String serviceName;
  final double servicePrice;
  final int estimatedWaitMinutes;
  final int? actualDurationMinutes;
  final TicketState state;
  final bool onMyWayConfirmed;
  final String? alertMessage;
  final int? peopleAhead;
  final DateTime? createdAt;
  final DateTime? calledAt;
  final DateTime? completedAt;

  QueueTicket({
    required this.id,
    required this.ticketNumber,
    required this.customerName,
    this.serviceId = '',
    this.serviceName = 'Standard Service',
    this.servicePrice = 0.0,
    this.estimatedWaitMinutes = 15,
    this.actualDurationMinutes,
    this.state = TicketState.waiting,
    this.onMyWayConfirmed = false,
    this.alertMessage,
    this.peopleAhead,
    this.createdAt,
    this.calledAt,
    this.completedAt,
  });

  bool get isWaiting => state == TicketState.waiting;
  bool get isAlmostNext => state == TicketState.almostNext;
  bool get isNowServing => state == TicketState.nowServing;
  bool get isCompleted => state == TicketState.completed;
  bool get isCancelled => state == TicketState.cancelled;

  factory QueueTicket.fromJson(Map<String, dynamic> json) {
    return QueueTicket(
      id: json['id']?.toString() ?? json['ticketId']?.toString() ?? '',
      ticketNumber: json['ticketNumber'] is int 
          ? json['ticketNumber'] 
          : int.tryParse(json['ticketNumber']?.toString() ?? '0') ?? 0,
      customerName: json['customerName']?.toString() ?? 'Walk-in Guest',
      serviceId: json['serviceId']?.toString() ?? '',
      serviceName: json['serviceName']?.toString() ?? 'Standard Service',
      servicePrice: (json['servicePrice'] is num) 
          ? (json['servicePrice'] as num).toDouble() 
          : double.tryParse(json['servicePrice']?.toString() ?? '0') ?? 0.0,
      estimatedWaitMinutes: json['estimatedWaitMinutes'] is int 
          ? json['estimatedWaitMinutes'] 
          : int.tryParse(json['estimatedWaitMinutes']?.toString() ?? '15') ?? 15,
      actualDurationMinutes: json['actualDurationMinutes'] is int 
          ? json['actualDurationMinutes'] 
          : int.tryParse(json['actualDurationMinutes']?.toString() ?? ''),
      state: TicketState.fromString(json['state']?.toString() ?? json['status']?.toString()),
      onMyWayConfirmed: json['onMyWayConfirmed'] == true,
      alertMessage: json['alertMessage']?.toString(),
      peopleAhead: json['peopleAhead'] is int 
          ? json['peopleAhead'] 
          : int.tryParse(json['peopleAhead']?.toString() ?? ''),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      calledAt: json['calledAt'] != null ? DateTime.tryParse(json['calledAt'].toString()) : null,
      completedAt: json['completedAt'] != null ? DateTime.tryParse(json['completedAt'].toString()) : null,
    );
  }
}
