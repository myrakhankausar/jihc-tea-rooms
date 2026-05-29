// lib/screens/create_booking_screen.dart
// Form to create a new tea room booking

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/booking_model.dart';
import '../models/user_model.dart';
import '../services/booking_service.dart';
import '../utils/app_constants.dart';
import '../widgets/shared_widgets.dart';

class CreateBookingScreen extends StatefulWidget {
  final String roomName;
  final UserModel userModel;

  const CreateBookingScreen({
    super.key,
    required this.roomName,
    required this.userModel,
  });

  @override
  State<CreateBookingScreen> createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _purposeCtrl = TextEditingController();
  final _bookingService = BookingService();

  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  bool _isLoading = false;
  bool? _isAvailable;
  String _checkingStatus = '';

  @override
  void dispose() {
    _purposeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppConstants.accentColor,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _isAvailable = null;
      });
      _checkAvailability();
    }
  }

  Future<void> _checkAvailability() async {
    if (_selectedDate == null || _selectedTimeSlot == null) return;
    setState(() {
      _checkingStatus = 'Checking...';
      _isAvailable = null;
    });
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      final available = await _bookingService.isSlotAvailable(
        roomName: widget.roomName,
        date: dateStr,
        timeSlot: _selectedTimeSlot!,
      );
      setState(() {
        _isAvailable = available;
        _checkingStatus = '';
      });
    } catch (e) {
      setState(() => _checkingStatus = 'Check failed');
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      _showSnack('Please select a date');
      return;
    }
    if (_selectedTimeSlot == null) {
      _showSnack('Please select a time slot');
      return;
    }
    if (_isAvailable == false) {
      _showSnack('Room unavailable');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      // Double-check availability
      final available = await _bookingService.isSlotAvailable(
        roomName: widget.roomName,
        date: dateStr,
        timeSlot: _selectedTimeSlot!,
      );
      if (!available) {
        _showSnack('Room unavailable');
        setState(() {
          _isAvailable = false;
          _isLoading = false;
        });
        return;
      }

      final bookingId = _bookingService.generateBookingId();
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final booking = BookingModel.create(
        bookingId: bookingId,
        userId: uid,
        userName: widget.userModel.fullName,
        userPhotoUrl: widget.userModel.photoUrl,
        gender: widget.userModel.gender,
        roomName: widget.roomName,
        bookingDate: _selectedDate!,
        timeSlot: _selectedTimeSlot!,
        purpose: _purposeCtrl.text.trim(),
      );

      await _bookingService.createBooking(booking);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Booking created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      _showSnack('Error creating booking: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book a Room')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Room name (read-only)
              Container(
                padding: const EdgeInsets.all(16),
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
                      widget.roomName,
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
              const Text('Select Date',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppConstants.darkBlue)),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  _selectedDate == null
                      ? 'Choose a date'
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

              // Time slot selection
              const Text('Select Time Slot',
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
                      fontWeight: FontWeight.w500,
                    ),
                    onSelected: (_) {
                      setState(() {
                        _selectedTimeSlot = slot;
                        _isAvailable = null;
                      });
                      _checkAvailability();
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Availability status
              if (_checkingStatus.isNotEmpty)
                const LoadingState(message: 'Checking availability...'),
              if (_isAvailable != null)
                Center(child: StatusBadge(isAvailable: _isAvailable!)),
              if (_isAvailable == false) ...[
                const SizedBox(height: 16),
                const EmptyState(
                  title: 'Room unavailable',
                  description:
                      'This room has already been booked by another user.',
                  icon: Icons.event_busy_outlined,
                ),
              ],
              const SizedBox(height: 20),

              // Purpose field
              const Text('Purpose / Reason',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppConstants.darkBlue)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _purposeCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText:
                      'e.g. Study group tea, Girls gathering, Birthday celebration...',
                  alignLabelWithHint: true,
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Please enter a purpose'
                    : null,
              ),
              const SizedBox(height: 32),

              PrimaryButton(
                label: 'Confirm Booking',
                onPressed: _isAvailable == false ? null : _submit,
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
