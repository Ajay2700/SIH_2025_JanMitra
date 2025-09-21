enum TicketPriority {
  low('low'),
  medium('medium'),
  high('high'),
  urgent('urgent');

  const TicketPriority(this.value);
  final String value;

  static TicketPriority fromString(String value) {
    switch (value.toLowerCase()) {
      case 'low':
        return TicketPriority.low;
      case 'medium':
        return TicketPriority.medium;
      case 'high':
        return TicketPriority.high;
      case 'urgent':
        return TicketPriority.urgent;
      default:
        return TicketPriority.medium;
    }
  }

  String get displayName {
    switch (this) {
      case TicketPriority.low:
        return 'Low';
      case TicketPriority.medium:
        return 'Medium';
      case TicketPriority.high:
        return 'High';
      case TicketPriority.urgent:
        return 'Urgent';
    }
  }

  String get color {
    switch (this) {
      case TicketPriority.low:
        return 'green';
      case TicketPriority.medium:
        return 'blue';
      case TicketPriority.high:
        return 'orange';
      case TicketPriority.urgent:
        return 'red';
    }
  }
}
