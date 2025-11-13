import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/models/user_notification.dart';

/// A compact, modern notification card used across the app.
class NotificationCard extends StatelessWidget {
  final UserNotification notification;
  final VoidCallback? onTap;
  final bool dense;

  const NotificationCard({
    Key? key,
    required this.notification,
    this.onTap,
    this.dense = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = _getNotificationColor(notification.type);
    final icon = _getNotificationIcon(notification.type);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: dense ? 10 : 16,
          ),
          margin: EdgeInsets.only(bottom: dense ? 12 : 18),
          decoration: BoxDecoration(
            color: notification.isRead ? Colors.white : color.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: notification.isRead
                  ? Colors.grey.shade200
                  : color.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left icon circle
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(icon, color: Colors.white, size: 18),
              ),

              const SizedBox(width: 12),

              // Title, event name (full) and full message
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade900,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        Text(
                          _formatTimeAgo(notification.createdAt),
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),

                    if (notification.eventTitle != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        notification.eventTitle!,
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 13,
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],

                    if (notification.message.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        notification.message,
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                        softWrap: true,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // read-dot
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: notification.isRead ? Colors.grey.shade300 : color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'registration_cancelled':
        return Icons.cancel_outlined;
      case 'event_update':
        return Icons.info_outline;
      case 'registration_confirmed':
        return Icons.check_circle_outline;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'registration_cancelled':
        return Colors.red.shade600;
      case 'event_update':
        return Colors.blue.shade600;
      case 'registration_confirmed':
        return Colors.green.shade600;
      default:
        return const Color(0xFF3F3D9C);
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}
