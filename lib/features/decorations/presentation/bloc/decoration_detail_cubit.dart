import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/decoration_detail.dart';

abstract class DecorationDetailState {}

class DecorationDetailInitial extends DecorationDetailState {}

class DecorationDetailLoading extends DecorationDetailState {}

class DecorationDetailLoaded extends DecorationDetailState {
  final DecorationDetail detail;
  DecorationDetailLoaded(this.detail);
}

class DecorationDetailError extends DecorationDetailState {
  final String message;
  DecorationDetailError(this.message);
}

class DecorationDetailCubit extends Cubit<DecorationDetailState> {
  DecorationDetailCubit() : super(DecorationDetailInitial());

  void loadDecorationDetail(String id) async {
    emit(DecorationDetailLoading());
    // Simulate network
    await Future.delayed(const Duration(milliseconds: 600));

    // Mock Response matching screenshot 2/3 (Grand Floral Arch & Royal Floral Stage)
    // We will combine elements to make it "Grand Floral Archway - Rose Gold Edition"
    // Price: $1,200 (or ₹90,000 to be consistent with previous screens)
    
    try {
      final mockDetail = DecorationDetail(
        id: id,
        title: "Grand Floral Archway - Rose Gold Edition",
        providerName: "Bloom & Co.",
        providerImage: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80", // User avatar
        price: "₹90,000",
        rating: 4.8,
        images: [
           "https://images.unsplash.com/photo-1519225468359-69632d4026d1?auto=format&fit=crop&w=1200&q=80",
           "https://images.unsplash.com/photo-1511795409834-ef04bbd61622?auto=format&fit=crop&w=1200&q=80",
           "https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&w=1200&q=80",
        ],
        tags: ["Wedding", "Floral", "Outdoor", "Luxury", "Rose Gold"],
        features: {
          "Professional Setup & Teardown": "Full service handling by our expert team.",
          "Customizable Silk Florals": "Choose your color palette to match your theme.",
          "Premium Lighting": "Includes 4x LED spot lights for evening events."
        },
        description: "Transform your venue with our signature Rose Gold Floral Archway. Handcrafted with premium silk flowers and real foliage, this setup creates a breathtaking focal point for your vows or entrance."
      );
      emit(DecorationDetailLoaded(mockDetail));
    } catch (e) {
      emit(DecorationDetailError("Failed to load details"));
    }
  }
}
