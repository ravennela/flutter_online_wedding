import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_online/core/theme/app_colors.dart';
import 'package:flutter_online/core/theme/app_text_styles.dart';
import 'package:flutter_online/features/cities/domain/models/city_item.dart';
import 'package:flutter_online/features/cities/presentation/cubit/city_cubit.dart';

/// Displays selected city with [Change] button. Format: 📍 CityName [Change]
class CitySelectorWidget extends StatelessWidget {
  final bool isScrolled;
  final VoidCallback? onTap;

  const CitySelectorWidget({
    super.key,
    required this.isScrolled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CityCubit, CityState>(
      builder: (context, state) {
        String displayName = 'Select City';
        bool hasCity = false;
        if (state is CitySelected) {
          displayName = state.cityName;
          hasCity = true;
        } else if (state is CityListLoaded &&
            state.cityId != null &&
            state.cityName != null) {
          displayName = state.cityName!;
          hasCity = true;
        }

        return GestureDetector(
          onTap: onTap ?? () => _showCityBottomSheet(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isScrolled
                  ? AppColors.background
                  : Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: isScrolled ? AppColors.divider : Colors.white30,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_on,
                  size: 14,
                  color: isScrolled ? AppColors.primary : Colors.white,
                ),
                const SizedBox(width: 6),
                Text(
                  displayName,
                  style: AppTextStyles.labelM.copyWith(
                    color: isScrolled ? AppColors.textPrimary : Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  hasCity ? 'Change' : '',
                  style: AppTextStyles.labelS.copyWith(
                    color: isScrolled ? AppColors.primary : Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 16,
                  color: isScrolled ? AppColors.textSecondary : Colors.white70,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCityBottomSheet(BuildContext context) async {
    final cityCubit = context.read<CityCubit>();
    await cityCubit.loadCities();

    if (!context.mounted) return;

    final state = cityCubit.state;
    if (state is CityError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
      return;
    }

    if (state is! CityListLoaded) return;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CitySelectionSheet(
        cities: state.cities,
        onSelect: (city) {
          cityCubit.selectCity(city);
          Navigator.pop(ctx);
        },
      ),
    );
  }
}

class _CitySelectionSheet extends StatelessWidget {
  final List<CityItem> cities;
  final void Function(CityItem) onSelect;

  const _CitySelectionSheet({
    required this.cities,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Select City',
              style: AppTextStyles.headingM.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: cities.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('No cities available'),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: cities.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final city = cities[index];
                      return ListTile(
                        leading: const Icon(Icons.location_city),
                        title: Text(city.name),
                        onTap: () => onSelect(city),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
