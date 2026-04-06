import 'package:flutter/material.dart';
import 'package:flutter_online/core/routes/app_routes.dart';
import 'package:flutter_online/core/theme/app_colors.dart';
import 'package:flutter_online/core/theme/app_text_styles.dart';
import 'package:flutter_online/features/booking/domain/models/booking_args.dart';
import 'package:flutter_online/shared/widgets/primary_button.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class SelectEventDatePage extends StatefulWidget {
  final BookingArgs args;

  const SelectEventDatePage({super.key, required this.args});

  @override
  State<SelectEventDatePage> createState() => _SelectEventDatePageState();
}

class _SelectEventDatePageState extends State<SelectEventDatePage> {
  DateTime _focusedDay = DateTime(2026, 3, 1);
  DateTime? _selectedDay = DateTime(2026, 3, 20);
  TimeOfDay? _selectedTime;

  // Selected time slots for demonstration
  final List<TimeOfDay> _timeSlots = [
    const TimeOfDay(hour: 9, minute: 0),
    const TimeOfDay(hour: 11, minute: 0),
    const TimeOfDay(hour: 13, minute: 0),
    const TimeOfDay(hour: 15, minute: 0),
    const TimeOfDay(hour: 17, minute: 0),
    const TimeOfDay(hour: 19, minute: 0),
  ];

  // For demonstration: Assume some dates are booked
  final List<int> _bookedDays = [5, 12, 18, 25];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Schedule Experience',
          style: AppTextStyles.headingM,
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth >= 1024) {
                  return _buildDesktopLayout();
                } else if (constraints.maxWidth >= 768) {
                  return _buildTabletLayout();
                } else {
                  return _buildMobileLayout();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.divider, width: 0.5)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RESERVATION STEP 2',
                style: AppTextStyles.labelS.copyWith(
                  color: AppColors.textHint,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                '50% Completed',
                style: AppTextStyles.labelS.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Stack(
            children: [
              Container(
                height: 6,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                height: 6,
                width: MediaQuery.of(context).size.width * 0.5,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Date & Time',
          style: AppTextStyles.headingXL,
        ),
        const SizedBox(height: 8),
        Text(
          'Coordinate the perfect moment for your curated celebration.',
          style: AppTextStyles.bodyL.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeading(),
                const SizedBox(height: 40),
                _buildCalendarCard(),
                const SizedBox(height: 32),
                _buildBookingSummaryCard(),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
        _buildBottomFixedCTA(),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeading(),
                      const SizedBox(height: 32),
                      _buildCalendarCard(),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                flex: 4,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildBookingSummaryCard(isCompact: true),
                      const SizedBox(height: 24),
                      _buildCTA(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeading(),
                      const SizedBox(height: 48),
                      _buildCalendarCard(),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 80),
              Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildBookingSummaryCard(isDesktop: true),
                      const SizedBox(height: 32),
                      _buildCTA(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCalendarHeader(),
          const SizedBox(height: 24),
          _buildCalendarGrid(),
          const SizedBox(height: 20),
          _buildLegend(),
          const SizedBox(height: 32),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 32),
          _buildTimePickerSection(),
        ],
      ),
    );
  }

  Widget _buildTimePickerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Experience Time',
          style: AppTextStyles.headingS.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _timeSlots.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final time = _timeSlots[index];
              final isSelected = _selectedTime == time;

              return InkWell(
                onTap: () => setState(() => _selectedTime = time),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.divider,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      time.format(context),
                      style: AppTextStyles.labelM.copyWith(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildNavButton(
          icon: Icons.chevron_left,
          onTap: () => setState(() => _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1)),
        ),
        Text(
          DateFormat('MMMM yyyy').format(_focusedDay).toUpperCase(),
          style: AppTextStyles.labelM.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            color: AppColors.textPrimary,
          ),
        ),
        _buildNavButton(
          icon: Icons.chevron_right,
          onTap: () => setState(() => _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1)),
        ),
      ],
    );
  }

  Widget _buildNavButton({required IconData icon, required VoidCallback onTap}) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: AppColors.primary, size: 24),
      style: IconButton.styleFrom(
        backgroundColor: AppColors.accentRose.withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.all(8),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = DateUtils.getDaysInMonth(_focusedDay.year, _focusedDay.month);
    final firstDayOffset = DateTime(_focusedDay.year, _focusedDay.month, 1).weekday % 7;
    final totalCells = ((daysInMonth + firstDayOffset) / 7).ceil() * 7;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
              .map((d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: AppTextStyles.labelS.copyWith(
                          color: AppColors.textHint,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: totalCells,
          itemBuilder: (context, index) {
            final dayNumber = index - firstDayOffset + 1;
            if (dayNumber < 1 || dayNumber > daysInMonth) {
              return const SizedBox.shrink();
            }

            final currentDay = DateTime(_focusedDay.year, _focusedDay.month, dayNumber);
            final isSelected = _selectedDay != null &&
                _selectedDay!.year == currentDay.year &&
                _selectedDay!.month == currentDay.month &&
                _selectedDay!.day == currentDay.day;

            final isBooked = _bookedDays.contains(dayNumber);
            final isPast = currentDay.isBefore(DateTime.now().subtract(const Duration(days: 1)));
            final isDisabled = isBooked || isPast;

            return GestureDetector(
              onTap: isDisabled ? null : () => setState(() => _selectedDay = currentDay),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  shape: BoxShape.circle,
                  border: isSelected
                      ? null
                      : Border.all(
                          color: isDisabled ? Colors.transparent : AppColors.divider,
                          width: 1,
                        ),
                ),
                child: Center(
                  child: Text(
                    dayNumber.toString(),
                    style: AppTextStyles.bodyM.copyWith(
                      color: isSelected
                          ? Colors.white
                          : isDisabled
                              ? AppColors.textDisabled
                              : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(AppColors.primary, 'Selected'),
        const SizedBox(width: 20),
        _buildLegendItem(Colors.transparent, 'Available', isOutline: true),
        const SizedBox(width: 20),
        _buildLegendItem(AppColors.divider, 'Reserved'),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label, {bool isOutline = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: isOutline ? Colors.transparent : color.withOpacity(0.8),
            shape: BoxShape.circle,
            border: isOutline ? Border.all(color: AppColors.divider, width: 1.5) : null,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _buildBookingSummaryCard({bool isDesktop = false, bool isCompact = false}) {
    final detail = widget.args.decorationDetail;
    final address = widget.args.address;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            color: AppColors.accentRose.withOpacity(0.15),
            child: Text(
              'EXPERIENCE RECAP',
              style: AppTextStyles.labelS.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                color: AppColors.primary,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildSummaryLine(Icons.auto_awesome_outlined, 'Package', detail.name),
                const SizedBox(height: 12),
                _buildSummaryLine(Icons.location_on_outlined, 'Venue', '${address.area}, ${address.city}'),
                const SizedBox(height: 12),
                _buildSummaryLine(Icons.calendar_today_outlined, 'Date',
                    _selectedDay != null ? DateFormat('MMMM dd, yyyy').format(_selectedDay!) : 'Pending'),
                const SizedBox(height: 12),
                _buildSummaryLine(Icons.schedule_outlined, 'Time',
                    _selectedTime != null ? _selectedTime!.format(context) : 'Pending'),
                const SizedBox(height: 20),
                const Divider(height: 1, color: AppColors.divider),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Amount',
                      style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary),
                    ),
                    Text(
                      detail.formattedPrice,
                      style: AppTextStyles.price.copyWith(fontSize: 22, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryLine(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textHint),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: AppTextStyles.bodyS.copyWith(color: AppColors.textSecondary),
              children: [
                TextSpan(text: '$label: '),
                TextSpan(
                  text: value,
                  style: AppTextStyles.bodyS.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomFixedCTA() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.95),
        border: const Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: _buildCTA(),
    );
  }

  Widget _buildCTA() {
    return PrimaryButton(
      text: 'CONFIRM SCHEDULE',
      onPressed: (_selectedDay == null || _selectedTime == null) ? null : () {
        context.push(
          AppRoutes.paymentMethod.replaceAll(':id', widget.args.decorationDetail.id),
          extra: widget.args.copyWith(
            selectedDate: _selectedDay,
            selectedTime: _selectedTime,
          ),
        );
      },
    );
  }
}
