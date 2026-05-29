// lib/screens/edit_booking_screen.dart
// Edit an existing booking (only the owner can do this)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/booking_model.dart';
import '../models/user_model.dart';
import '../services/booking_service.dart';
import '../utils/app_constants.dart';
import '../widgets/shared_widgets.dart';

class EditBookingScreen extends StatefulWidget {
  final BookingModel booking;
  final UserModel userModel;

  const EditBookingScreen({
    super.key,
    required this.booking,
    required this.userModel,
  });

  @override
  State<EditBookingScreen> createState() => _EditBookingScreenState();
}

class _EditBookingScreenState extends State<EditBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _purposeCtrl;
  final _bookingService = BookingService();

  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  bool _isLoading = false;
  bool? _isAvailable;

  @override
  void initState() {
    super.initState();
    _purposeCtrl = TextEditingController(text: widget.booking.purpose);
    _selectedDate = DateTime.tryParse(widget.booking.date);
    _selectedTimeSlot = widget.booking.timeSlot;
  }

  @override
  void dispose() {
    _purposeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme:
              const ColorScheme.light(primary: AppConstants.accentColor),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _isAvailable = null;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTimeSlot == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Fill in all fields')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);

      // Check availability only if date/time changed
      if (dateStr != widget.booking.date ||
          _selectedTimeSlot != widget.booking.timeSlot) {
        final available = await _bookingService.isSlotAvailable(
          roomName: widget.booking.roomName,
          date: dateStr,
          timeSlot: _selectedTimeSlot!,
          excludeBookingId: widget.booking.bookingId,
        );
        if (!available) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Room unavailable')),
            );
          }
          setState(() {
            _isAvailable = false;
            _isLoading = false;
          });
          return;
        }
      }

      final updatedBooking = widget.booking.copyWith(
        date: dateStr,
        timeSlot: _selectedTimeSlot,
        purpose: _purposeCtrl.text.trim(),
        userPhotoUrl: widget.userModel.photoUrl,
        userName: widget.userModel.fullName,
      );

      await _bookingService.updateBooking(updatedBooking);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Booking updated!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Booking')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Room name banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppConstants.accentColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppConstants.lightBlue),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_cafe,
                        color: AppConstants.accentColor),
                    const SizedBox(width: 10),
                    Text(
                      widget.booking.roomName,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.darkBlue),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Date picker
              const Text('Date',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppConstants.darkBlue)),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  _selectedDate == null
                      ? 'Choose date'
                      : DateFormat('EEEE, MMM d, yyyy').format(_selectedDate!),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  side: const BorderSide(color: AppConstants.accentColor),
                  foregroundColor: AppConstants.accentColor,
                ),
              ),
              const SizedBox(height: 20),

              // Time slot
              const Text('Time Slot',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppConstants.darkBlue)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppConstants.timeSlots.map((slot) {
                  final isSelected = _selectedTimeSlot == slot;
                  return ChoiceChip(
                    label: Text(slot),
                    selected: isSelected,
                    selectedColor: AppConstants.accentColor,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppConstants.darkBlue,
                    ),
                    onSelected: (_) => setState(() => _selectedTimeSlot = slot),
                  );
                }).toList(),
              ),
              if (_isAvailable == false) ...[
                const SizedBox(height: 10),
                const StatusBadge(isAvailable: false),
                const SizedBox(height: 16),
                const EmptyState(
                  title: 'Room unavailable',
                  description:
                      'This room has already been booked by another user.',
                  icon: Icons.event_busy_outlined,
                ),
              ],
              const SizedBox(height: 20),

              // Purpose
              const Text('Purpose',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppConstants.darkBlue)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _purposeCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                    hintText: 'Why are you booking this room?'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 32),

              PrimaryButton(
                label: 'Save Changes',
                onPressed: _save,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
