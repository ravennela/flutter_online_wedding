import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_online/core/routes/app_routes.dart';
import 'package:flutter_online/core/theme/app_colors.dart';
import 'package:flutter_online/core/theme/app_text_styles.dart';
import 'package:flutter_online/features/cities/domain/models/city_item.dart';
import 'package:flutter_online/features/cities/presentation/cubit/city_cubit.dart';
import 'package:flutter_online/shared/widgets/error_widget.dart' as app_error;
import 'package:flutter_online/shared/widgets/loading_widget.dart';
import 'package:go_router/go_router.dart';

/// Mandatory city selection screen shown at app startup when no city is saved.
/// Blocks app access until user selects a city.
class CitySelectionPage extends StatefulWidget {
  const CitySelectionPage({super.key});

  @override
  State<CitySelectionPage> createState() => _CitySelectionPageState();
}

class _CitySelectionPageState extends State<CitySelectionPage> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<CityCubit>().loadCities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Text(
                'Select Your City',
                style: AppTextStyles.headingL.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please select a city to continue. This helps us show relevant decorations and events.',
                style: AppTextStyles.bodyM.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Search cities...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: BlocBuilder<CityCubit, CityState>(
                  builder: (context, state) {
                    if (state is CityLoading) {
                      return const LoadingWidget(
                        message: 'Loading cities...',
                      );
                    }
                    if (state is CityError) {
                      return app_error.ErrorWidget(
                        message: state.message,
                        onRetry: () =>
                            context.read<CityCubit>().loadCities(),
                      );
                    }
                    if (state is CityListLoaded) {
                      final filtered = state.cities.where((c) {
                        if (_searchQuery.isEmpty) return true;
                        return c.name.toLowerCase().contains(_searchQuery);
                      }).toList();

                      if (filtered.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_off,
                                size: 64,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isEmpty
                                    ? 'No cities available'
                                    : 'No cities match your search',
                                style: AppTextStyles.bodyL,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final city = filtered[index];
                          return _CityTile(
                            city: city,
                            onTap: () => _onCitySelected(context, city),
                          );
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onCitySelected(BuildContext context, CityItem city) async {
    await context.read<CityCubit>().selectCity(city);
    if (!context.mounted) return;
    context.go(AppRoutes.splash);
  }
}

class _CityTile extends StatelessWidget {
  final CityItem city;
  final VoidCallback onTap;

  const _CityTile({required this.city, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.location_city,
          color: AppColors.primary,
          size: 24,
        ),
      ),
      title: Text(
        city.name,
        style: AppTextStyles.headingS.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: onTap,
    );
  }
}
