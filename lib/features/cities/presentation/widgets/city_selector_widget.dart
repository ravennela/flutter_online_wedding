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
          onTap: onTap ?? () => _showCityDialog(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isScrolled
                  ? AppColors.surfaceMuted
                  : AppColors.surfaceMuted.withOpacity(0.92),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: isScrolled ? AppColors.border : AppColors.border,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_on,
                  size: 14,
                  color: AppColors.primaryDark,
                ),
                const SizedBox(width: 6),
                Text(
                  displayName,
                  style: AppTextStyles.labelM.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  hasCity ? 'Change' : '',
                  style: AppTextStyles.labelS.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showCityDialog(BuildContext context) async {
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

    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return _CityPickerAlertDialog(
          cities: state.cities,
          onSelect: (city) {
            cityCubit.selectCity(city);
            Navigator.of(dialogContext).pop();
          },
        );
      },
    );
  }
}

class _CityPickerAlertDialog extends StatelessWidget {
  final List<CityItem> cities;
  final void Function(CityItem) onSelect;

  const _CityPickerAlertDialog({
    required this.cities,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      title: Text(
        'Select City',
        style: AppTextStyles.headingM.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      content: cities.isEmpty
          ? Text(
              'No cities available',
              style: AppTextStyles.bodyM.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          : SizedBox(
              width: double.maxFinite,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.45,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: cities.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: AppColors.divider,
                  ),
                  itemBuilder: (context, index) {
                    final city = cities[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      leading: Icon(
                        Icons.location_city_outlined,
                        color: AppColors.primary,
                      ),
                      title: Text(
                        city.name,
                        style: AppTextStyles.bodyL.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () => onSelect(city),
                    );
                  },
                ),
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: AppTextStyles.labelM.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ),
      ],
    );
  }
}
