import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/models/decoration_item.dart';

class DecorationCard extends StatefulWidget {
  final DecorationItem item;
  final VoidCallback onTap;

  const DecorationCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  State<DecorationCard> createState() => _DecorationCardState();
}

class _DecorationCardState extends State<DecorationCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image with Favorite Icon
                    Expanded(
                      flex: 4, 
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                           ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                             child: Image.network(
                               widget.item.imageUrl,
                               fit: BoxFit.cover,
                               errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[200]),
                             ),
                           ),
                           Positioned(
                             top: 8,
                             right: 8,
                             child: CircleAvatar(
                               backgroundColor: Colors.white,
                               radius: 14,
                               child: Icon(Icons.favorite_border, size: 16, color: Colors.grey[400]),
                             ),
                           )
                        ],
                      ),
                    ),
                    
                    // Details
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.item.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.headingS.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.item.providerName,
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Starting from',
                                  style: AppTextStyles.caption.copyWith(fontSize: 10),
                                ),
                                Text(
                                  widget.item.price,
                                  style: AppTextStyles.bodyM.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFE65100), // Vibrant Orange/Red for price
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
