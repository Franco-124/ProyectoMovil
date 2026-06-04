import 'package:flutter/material.dart';
import '../../../../models/finance/category_model.dart';

class CategoryIconWidget extends StatelessWidget {
  final CategoryModel category;
  final double size;
  final double iconSize;

  const CategoryIconWidget({
    super.key,
    required this.category,
    this.size = 40.0,
    this.iconSize = 20.0,
  });

  static const Map<String, IconData> _iconMap = {
    'receipt':             Icons.receipt_rounded,
    'work':                Icons.work_rounded,
    'psychology':          Icons.psychology_rounded,
    'inventory_2':         Icons.inventory_2_rounded,
    'trending_up':         Icons.trending_up_rounded,
    'add_circle':          Icons.add_circle_rounded,
    'restaurant':          Icons.restaurant_rounded,
    'directions_car':      Icons.directions_car_rounded,
    'electrical_services': Icons.electrical_services_rounded,
    'subscriptions':       Icons.subscriptions_rounded,
    'computer':            Icons.computer_rounded,
    'campaign':            Icons.campaign_rounded,
    'school':              Icons.school_rounded,
    'health_and_safety':   Icons.health_and_safety_rounded,
    'home':                Icons.home_rounded,
    'sports_esports':      Icons.sports_esports_rounded,
    'remove_circle':       Icons.remove_circle_rounded,
  };

  IconData _getIconData(String? iconName) =>
      _iconMap[iconName] ?? Icons.circle_rounded;

  Color _getColor(String? hexColor) {
    if (hexColor == null) return Colors.grey;
    final hex = hexColor.replaceAll('#', '');
    try {
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor(category.color);
    final iconData = _getIconData(category.icon);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          iconData,
          color: color,
          size: iconSize,
        ),
      ),
    );
  }
}
