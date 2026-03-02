import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_online/di/service_locator.dart';
import 'package:flutter_online/features/decorations/presentation/bloc/decoration_detail_bloc.dart';
import 'package:flutter_online/core/routes/app_routes.dart';
import 'package:go_router/go_router.dart';

class DecorationDetailPage extends StatefulWidget {
  final String id;
  const DecorationDetailPage({super.key, required this.id});

  @override
  State<DecorationDetailPage> createState() => _DecorationDetailPageState();
}

class _DecorationDetailPageState extends State<DecorationDetailPage> {
  late DecorationDetailBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = getIt<DecorationDetailBloc>();
    _bloc.add(LoadDecorationDetail(widget.id));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Decoration Details"),
      ),
      body: BlocProvider.value(
        value: _bloc,
        child: BlocConsumer<DecorationDetailBloc, DecorationDetailState>(
          listener: (context, state) {
            // Generic error handling listener if needed
          },
          builder: (context, state) {
            if (state is DecorationDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is DecorationDetailError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Error: ${state.message}", style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _bloc.add(LoadDecorationDetail(widget.id)),
                      child: const Text("Retry"),
                    )
                  ],
                ),
              );
            } else if (state is DecorationDetailLoaded) {
              final decoration = state.detail;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (decoration.imageUrls.isNotEmpty)
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: decoration.imageUrls.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  decoration.imageUrls[index],
                                  height: 200,
                                  width: 300,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const SizedBox(width: 200, child: Icon(Icons.broken_image, size: 50)),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            decoration.title,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: decoration.active ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: decoration.active ? Colors.green : Colors.red,
                            ),
                          ),
                          child: Text(
                            decoration.active ? "Active" : "Inactive",
                            style: TextStyle(
                              color: decoration.active ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(context, "Base Price", decoration.price.toString()),
                    const SizedBox(height: 8),
                    _buildDetailRow(context, "City ID", decoration.cityId),
                     const SizedBox(height: 8),
                    _buildDetailRow(context, "Event Type ID", decoration.eventTypeId),
                    const SizedBox(height: 16),
                    const Text(
                      "Description",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      decoration.description ?? "No description available.",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    if (decoration.inclusions != null) ...[
                      const Text(
                        "Inclusions",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        decoration.inclusions!,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 16),
                    ],
                     if (decoration.exclusions != null) ...[
                      const Text(
                        "Exclusions",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        decoration.exclusions!,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 16),
                    ],
                    const SizedBox(height: 24),
                    Text(
                      "ID: ${decoration.id}",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }
            // Initial or other states
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyLarge,
        children: [
          TextSpan(text: "$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: value),
        ],
      ),
    );
  }
}
