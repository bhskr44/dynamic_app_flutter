import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimePickerWidget extends StatefulWidget {
  final Map<String, dynamic> widgetData;

  const DateTimePickerWidget({super.key, required this.widgetData});

  @override
  State<DateTimePickerWidget> createState() => _DateTimePickerWidgetState();
}

class _DateTimePickerWidgetState extends State<DateTimePickerWidget> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    final initialDate = widget.widgetData['initial_date']?.toString();
    if (initialDate != null) {
      try {
        _selectedDate = DateTime.parse(initialDate);
      } catch (e) {
        _selectedDate = null;
      }
    }

    final initialTime = widget.widgetData['initial_time']?.toString();
    if (initialTime != null) {
      try {
        final parts = initialTime.split(':');
        _selectedTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      } catch (e) {
        _selectedTime = null;
      }
    }
  }

  Future<void> _pickDate() async {
    final minDate = widget.widgetData['min_date'] != null
        ? DateTime.parse(widget.widgetData['min_date'])
        : DateTime(1900);
    final maxDate = widget.widgetData['max_date'] != null
        ? DateTime.parse(widget.widgetData['max_date'])
        : DateTime(2100);

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: minDate,
      lastDate: maxDate,
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  String _formatDate(DateTime date) {
    final format = widget.widgetData['date_format']?.toString() ?? 'yyyy-MM-dd';
    return DateFormat(format).format(date);
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.widgetData['label']?.toString() ?? 'Select Date/Time';
    final mode = widget.widgetData['mode']?.toString() ?? 'date'; // date, time, or both

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
          Row(
            children: [
              if (mode == 'date' || mode == 'both') ...[
                Expanded(
                  child: InkWell(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: Color(0xFF3B82F6),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _selectedDate != null
                                ? _formatDate(_selectedDate!)
                                : 'Select Date',
                            style: TextStyle(
                              fontSize: 15,
                              color: _selectedDate != null
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              if (mode == 'both') const SizedBox(width: 12),
              if (mode == 'time' || mode == 'both') ...[
                Expanded(
                  child: InkWell(
                    onTap: _pickTime,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            color: Color(0xFF3B82F6),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _selectedTime != null
                                ? _formatTime(_selectedTime!)
                                : 'Select Time',
                            style: TextStyle(
                              fontSize: 15,
                              color: _selectedTime != null
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
