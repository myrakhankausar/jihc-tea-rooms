import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/booking_model.dart';
import '../utils/app_constants.dart';

class JihcLogo extends StatelessWidget {
  final double size;

  const JihcLogo({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/jihc_logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(label),
                ],
              ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final bool isAvailable;

  const StatusBadge({super.key, required this.isAvailable});

  @override
  Widget build(BuildContext context) {
    return BookingStatusChip(
      status: isAvailable ? BookingStatus.completed : BookingStatus.cancelled,
      customLabel: isAvailable ? 'Бос' : 'Брондалған',
    );
  }
}

class BookingStatusChip extends StatelessWidget {
  final BookingStatus status;
  final String? customLabel;

  const BookingStatusChip({
    super.key,
    required this.status,
    this.customLabel,
  });

  @override
  Widget build(BuildContext context) {
    late final Color background;
    late final Color foreground;
    late final IconData icon;
    late final String label;

    switch (status) {
      case BookingStatus.active:
        background = AppConstants.availableColor.withValues(alpha: 0.16);
        foreground = AppConstants.availableColor;
        icon = Icons.play_circle_outline;
        label = 'Белсенді';
        break;
      case BookingStatus.completed:
        background =
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.14);
        foreground = Theme.of(context).colorScheme.primary;
        icon = Icons.check_circle_outline;
        label = 'Аяқталды';
        break;
      case BookingStatus.cancelled:
        background = AppConstants.bookedColor.withValues(alpha: 0.14);
        foreground = AppConstants.bookedColor;
        icon = Icons.cancel_outlined;
        label = 'Күші жойылды';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: foreground),
          const SizedBox(width: 6),
          Text(
            customLabel ?? label,
            style: TextStyle(
              color: foreground,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileAvatar extends StatelessWidget {
  final String name;
  final String photoUrl;
  final double radius;

  const ProfileAvatar({
    super.key,
    required this.name,
    required this.photoUrl,
    this.radius = 22,
  });

  @override
  Widget build(BuildContext context) {
    final firstLetter = name.isNotEmpty ? name[0].toUpperCase() : 'S';
    return CircleAvatar(
      radius: radius,
      backgroundColor:
          Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
      backgroundImage: avatarImageProvider(photoUrl),
      child: photoUrl.isEmpty
          ? Text(
              firstLetter,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );
  }
}

ImageProvider<Object>? avatarImageProvider(String photoUrl) {
  if (photoUrl.isEmpty) {
    return null;
  }
  if (photoUrl.startsWith('data:image/')) {
    final bytes = _bytesFromDataUrl(photoUrl);
    if (bytes != null) {
      return MemoryImage(bytes);
    }
    return null;
  }
  return NetworkImage(photoUrl);
}

Uint8List? _bytesFromDataUrl(String dataUrl) {
  final commaIndex = dataUrl.indexOf(',');
  if (commaIndex == -1) {
    return null;
  }
  final encoded = dataUrl.substring(commaIndex + 1);
  try {
    return base64Decode(encoded);
  } catch (_) {
    return null;
  }
}

class BookingCard extends StatelessWidget {
  final String roomName;
  final String date;
  final String timeSlot;
  final String purpose;
  final String userName;
  final bool isOwner;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;
  final String userPhotoUrl;
  final BookingStatus? status;

  const BookingCard({
    super.key,
    required this.roomName,
    required this.date,
    required this.timeSlot,
    required this.purpose,
    required this.userName,
    this.isOwner = false,
    this.onEdit,
    this.onDelete,
    this.onTap,
    this.userPhotoUrl = '',
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ProfileAvatar(name: userName, photoUrl: userPhotoUrl),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        Text(
                          roomName,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  if (status != null) BookingStatusChip(status: status!),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _FactPill(icon: Icons.calendar_today_outlined, text: date),
                  _FactPill(icon: Icons.schedule, text: timeSlot),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                purpose,
                style: TextStyle(
                  height: 1.5,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              if (isOwner || onDelete != null || onEdit != null) ...[
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onEdit != null)
                      TextButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Өзгерту'),
                      ),
                    if (onDelete != null)
                      TextButton.icon(
                        onPressed: onDelete,
                        icon: const Icon(Icons.cancel_outlined,
                            color: AppConstants.bookedColor),
                        label: const Text(
                          'Бас тарту',
                          style: TextStyle(color: AppConstants.bookedColor),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class BookingTimelineCard extends StatelessWidget {
  final BookingModel booking;
  final bool showRoomName;
  final bool canCancel;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;

  const BookingTimelineCard({
    super.key,
    required this.booking,
    this.showRoomName = true,
    this.canCancel = false,
    this.onTap,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _timelineColor(booking.displayStatus),
              ),
            ),
            Container(
              width: 2,
              height: 132,
              color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
            ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ProfileAvatar(
                          name: booking.userName,
                          photoUrl: booking.userPhotoUrl,
                          radius: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking.userName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700),
                              ),
                              Text(
                                booking.dateLabel,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        BookingStatusChip(status: booking.displayStatus),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _FactPill(
                          icon: Icons.access_time,
                          text: booking.timelineTimeLabel,
                        ),
                        if (showRoomName)
                          _FactPill(
                            icon: Icons.meeting_room_outlined,
                            text: booking.roomName,
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      booking.purpose,
                      style: TextStyle(
                        height: 1.5,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    if (canCancel && onCancel != null) ...[
                      const SizedBox(height: 14),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: onCancel,
                          icon: const Icon(
                            Icons.cancel_schedule_send_outlined,
                            color: AppConstants.bookedColor,
                          ),
                          label: const Text(
                            'Бронды болдырмау',
                            style: TextStyle(color: AppConstants.bookedColor),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _timelineColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.active:
        return AppConstants.availableColor;
      case BookingStatus.completed:
        return AppConstants.accentColor;
      case BookingStatus.cancelled:
        return AppConstants.bookedColor;
    }
  }
}

class LoadingState extends StatefulWidget {
  final String message;

  const LoadingState({
    super.key,
    this.message = 'Брондар жүктелуде...',
  });

  @override
  State<LoadingState> createState() => _LoadingStateState();
}

class _LoadingStateState extends State<LoadingState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final scale = 0.92 + (_controller.value * 0.08);
              return Transform.scale(scale: scale, child: child);
            },
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
              ),
              child:
                  const Icon(Icons.local_cafe, color: Colors.white, size: 34),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            widget.message,
            style: TextStyle(color: Colors.grey[600], fontSize: 15),
          ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final String? message;
  final String? title;
  final String? description;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    this.message,
    this.title,
    this.description,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  }) : assert(
          message != null || (title != null && description != null),
          'Provide either message or both title and description.',
        );

  @override
  Widget build(BuildContext context) {
    final resolvedTitle = title ?? '';
    final resolvedDescription = description ?? message ?? '';
    final hasDedicatedTitle = title != null;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              ),
              child: Icon(icon,
                  size: 42, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 20),
            if (hasDedicatedTitle) ...[
              Text(
                resolvedTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
            ],
            Text(
              resolvedDescription,
              style:
                  TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.5),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 18),
              OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorState({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                size: 72, color: AppConstants.bookedColor),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                  fontSize: 16, color: AppConstants.bookedColor),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Қайталау'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).appBarTheme.foregroundColor,
                      ),
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      subtitle!,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
              ],
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}

class RoomCard extends StatelessWidget {
  final String roomName;
  final VoidCallback onTap;
  final String? subtitle;
  final IconData icon;
  final String? ownerName;
  final String ownerPhotoUrl;
  final bool isBooked;

  const RoomCard({
    super.key,
    required this.roomName,
    required this.onTap,
    this.subtitle,
    this.icon = Icons.local_cafe_outlined,
    this.ownerName,
    this.ownerPhotoUrl = '',
    this.isBooked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                ),
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      roomName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          subtitle!,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    if (isBooked && ownerName != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            ProfileAvatar(
                              name: ownerName!,
                              photoUrl: ownerPhotoUrl,
                              radius: 12,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Booked by $ownerName',
                                style: const TextStyle(
                                  color: AppConstants.bookedColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              if (isBooked)
                const Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: BookingStatusChip(
                    status: BookingStatus.cancelled,
                    customLabel: 'Booked',
                  ),
                ),
              Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.grey[400], size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class ResponsiveContent extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ResponsiveContent({
    super.key,
    required this.child,
    this.maxWidth = 1100,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

class AnalyticsCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const AnalyticsCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 14),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}

class _FactPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FactPill({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color:
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
