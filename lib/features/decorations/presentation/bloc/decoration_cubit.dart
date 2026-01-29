import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/decoration_item.dart';

abstract class DecorationState {}

class DecorationInitial extends DecorationState {}
class DecorationLoading extends DecorationState {}
class DecorationLoaded extends DecorationState {
  final List<DecorationItem> decorations;
  DecorationLoaded(this.decorations);
}
class DecorationError extends DecorationState {
  final String message;
  DecorationError(this.message);
}

class DecorationCubit extends Cubit<DecorationState> {
  DecorationCubit() : super(DecorationInitial());

  void loadDecorations(String eventId) async {
    emit(DecorationLoading());
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock data based on screenshots
    final mockDecorations = [
      const DecorationItem(
        id: '1',
        title: 'Floral Canopy',
        providerName: 'Elegant Weddings',
        price: '₹55,000',
        imageUrl: 'https://images.unsplash.com/photo-1519225468359-69632d4026d1?auto=format&fit=crop&w=800&q=80',
      ),
      const DecorationItem(
        id: '2',
        title: 'Minimalist Mandap',
        providerName: 'Zen Decor',
        price: '₹90,000',
        imageUrl: 'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?auto=format&fit=crop&w=800&q=80',
      ),
      const DecorationItem(
        id: '3',
        title: 'Fairy Light Tunnel',
        providerName: 'Glow Events',
        price: '₹45,000',
        imageUrl: 'https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&w=800&q=80',
      ),
      const DecorationItem(
        id: '4',
        title: 'Bohemian Stage',
        providerName: 'Boho Co.',
        price: '₹65,000',
        imageUrl: 'https://images.unsplash.com/photo-1527529482837-4698179dc6ce?auto=format&fit=crop&w=800&q=80',
      ),
      const DecorationItem(
        id: '5',
        title: 'Royal Entrance',
        providerName: 'Majestic Decors',
        price: '₹1,20,000',
        imageUrl: 'https://images.unsplash.com/photo-1583939003579-730e3918a45a?auto=format&fit=crop&w=800&q=80',
      ),
       const DecorationItem(
        id: '6',
        title: 'Garden Seating',
        providerName: 'Nature Vibe',
        price: '₹35,000',
        imageUrl: 'https://images.unsplash.com/photo-1469334031218-e382a71b716b?auto=format&fit=crop&w=800&q=80',
      ),
    ];

    emit(DecorationLoaded(mockDecorations));
  }
}
