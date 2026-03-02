import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_online/di/service_locator.dart';
import 'package:flutter_online/features/events/bloc/event_type/event_type_bloc.dart';
import 'package:flutter_online/features/events/bloc/event_type/event_type_event.dart';
import 'package:flutter_online/features/events/bloc/event_type/event_type_state.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_online/core/routes/app_routes.dart';

class EventTypeDetailPage extends StatefulWidget {
  final String id;
  const EventTypeDetailPage({super.key, required this.id});

  @override
  State<EventTypeDetailPage> createState() => _EventTypeDetailPageState();
}

class _EventTypeDetailPageState extends State<EventTypeDetailPage> {
  late EventTypeBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = getIt<EventTypeBloc>();
    _bloc.add(GetEventTypeByIdEvent(widget.id));
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
        title: const Text("Event Type Details"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.push(AppRoutes.adminEventTypesEditPath(widget.id)).then((_) {
                 if (mounted) _bloc.add(GetEventTypeByIdEvent(widget.id));
              });
            }
          ),
        ],
      ),
      body: BlocProvider.value(
        value: _bloc,
        child: BlocConsumer<EventTypeBloc, EventTypeState>(
          listener: (context, state) {
            print("EventTypeDetailPage State: $state");
            // Generic error handling listener if needed
          },
          builder: (context, state) {
            if (state is EventTypeDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is EventTypeDetailFailure) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Error: ${state.error}", style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _bloc.add(GetEventTypeByIdEvent(widget.id)),
                      child: const Text("Retry"),
                    )
                  ],
                ),
              );
            } else if (state is EventTypeDetailLoaded) {
              final event = state.eventType;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (event.iconUrl != null && event.iconUrl!.isNotEmpty)
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child:  Image.network(
                            event.iconUrl!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image, size: 100),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            event.name,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: event.active ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: event.active ? Colors.green : Colors.red,
                            ),
                          ),
                          child: Text(
                            event.active ? "Active" : "Inactive",
                            style: TextStyle(
                              color: event.active ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(context, "Sort Order", event.sortOrder?.toString() ?? "N/A"),
                    const SizedBox(height: 16),
                    const Text(
                      "Description",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event.description ?? "No description available.",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "ID: ${event.id}",
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
