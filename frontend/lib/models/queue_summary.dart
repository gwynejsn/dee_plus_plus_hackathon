import 'queue_ticket.dart';

class QueueSummary {
  final int totalActive;
  final int waitingCount;
  final int servingCount;
  final QueueTicket? currentlyServing;
  final List<QueueTicket> activeTickets;

  QueueSummary({
    this.totalActive = 0,
    this.waitingCount = 0,
    this.servingCount = 0,
    this.currentlyServing,
    this.activeTickets = const [],
  });

  factory QueueSummary.fromJson(Map<String, dynamic> json) {
    QueueTicket? serving;
    if (json['currentlyServing'] is Map<String, dynamic>) {
      serving = QueueTicket.fromJson(json['currentlyServing'] as Map<String, dynamic>);
    }

    final activeList = <QueueTicket>[];
    if (json['activeTickets'] is List) {
      for (final item in json['activeTickets']) {
        if (item is Map<String, dynamic>) {
          activeList.add(QueueTicket.fromJson(item));
        }
      }
    }

    return QueueSummary(
      totalActive: json['totalActive'] is int ? json['totalActive'] : 0,
      waitingCount: json['waitingCount'] is int ? json['waitingCount'] : 0,
      servingCount: json['servingCount'] is int ? json['servingCount'] : 0,
      currentlyServing: serving,
      activeTickets: activeList,
    );
  }
}
