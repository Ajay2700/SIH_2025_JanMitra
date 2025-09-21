import 'package:flutter/material.dart';
import 'package:jan_mitra/core/theme/app_theme.dart';
import 'package:jan_mitra/core/utils/constants.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool isCompact;

  const StatusBadge({super.key, required this.status, this.isCompact = false});

  @override
  Widget build(BuildContext context) {
    // Define background color based on status
    Color backgroundColor;
    IconData? icon;
    String displayText = status;

    // Determine color and icon based on status
    switch (status) {
      case AppConstants.statusSubmitted:
        backgroundColor = AppTheme.submittedColor;
        icon = Icons.add_circle_outline;
        displayText = isCompact ? 'Submitted' : 'Submitted';
        break;
      case AppConstants.statusAcknowledged:
        backgroundColor = AppTheme.acknowledgedColor;
        icon = Icons.visibility;
        displayText = isCompact ? 'Ack.' : 'Acknowledged';
        break;
      case AppConstants.statusInProgress:
        backgroundColor = AppTheme.inProgressColor;
        icon = Icons.engineering;
        displayText = isCompact ? 'In Prog.' : 'In Progress';
        break;
      case AppConstants.statusResolved:
        backgroundColor = AppTheme.resolvedColor;
        icon = Icons.check_circle_outline;
        displayText = isCompact ? 'Resolved' : 'Resolved';
        break;
      case AppConstants.statusRejected:
        backgroundColor = AppTheme.rejectedColor;
        icon = Icons.cancel_outlined;
        displayText = isCompact ? 'Rejected' : 'Rejected';
        break;
      default:
        backgroundColor = Colors.grey;
        icon = Icons.help_outline;
        displayText = isCompact ? 'Unknown' : 'Unknown';
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 12,
        vertical: isCompact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(isCompact ? 12 : 16),
        border: Border.all(color: backgroundColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isCompact)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Icon(icon, size: 16, color: backgroundColor),
            ),
          Text(
            displayText,
            style: TextStyle(
              color: backgroundColor,
              fontWeight: FontWeight.w600,
              fontSize: isCompact ? 12 : 13,
            ),
          ),
        ],
      ),
    );
  }
}

class PriorityBadge extends StatelessWidget {
  final String priority;
  final bool isCompact;

  const PriorityBadge({
    super.key,
    required this.priority,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    String displayText = priority;
    IconData? icon;

    // Determine color based on priority
    switch (priority) {
      case AppConstants.priorityLow:
        backgroundColor = AppTheme.lowPriorityColor;
        icon = Icons.arrow_downward;
        displayText = isCompact ? 'Low' : 'Low Priority';
        break;
      case AppConstants.priorityMedium:
        backgroundColor = AppTheme.mediumPriorityColor;
        icon = Icons.remove;
        displayText = isCompact ? 'Med' : 'Medium Priority';
        break;
      case AppConstants.priorityHigh:
        backgroundColor = AppTheme.highPriorityColor;
        icon = Icons.arrow_upward;
        displayText = isCompact ? 'High' : 'High Priority';
        break;
      default:
        backgroundColor = Colors.grey;
        icon = Icons.help_outline;
        displayText = isCompact ? '?' : 'Unknown';
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 12,
        vertical: isCompact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isCompact ? 12 : 16),
        border: Border.all(color: backgroundColor.withOpacity(0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isCompact)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Icon(icon, size: 16, color: backgroundColor),
            ),
          Text(
            displayText,
            style: TextStyle(
              color: backgroundColor,
              fontWeight: FontWeight.w600,
              fontSize: isCompact ? 12 : 13,
            ),
          ),
        ],
      ),
    );
  }
}
