import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/decoration_item.dart';

class DecorationCard extends StatelessWidget {
  final DecorationItem item;
  final VoidCallback onTap;

  const DecorationCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// IMAGE (Square for consistent grid)
          AspectRatio(
            aspectRatio: 1.1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: Image.network(
                item.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: Colors.grey[100]),
              ),
            ),
          ),

          const SizedBox(height: 16),

          /// TITLE & PRICE ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                item.price,
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          /// LOCATION
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 12, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                item.subtitle ?? 'Hyderabad',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// DESCRIPTION
          Text(
            'A curated selection of premium decor themes, meticulously crafted to transform your venue into a masterpiece.',
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              color: Colors.grey[700],
              fontStyle: FontStyle.italic,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 16),

          /// FOOTER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// RATING
              Row(
                children: [
                  const Icon(Icons.star_rounded, size: 14, color: Colors.black),
                  const SizedBox(width: 4),
                  Text(
                    item.rating.toString(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              /// BOOK BUTTON (Solid black minimal)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      "BOOK NOW",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 10),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
