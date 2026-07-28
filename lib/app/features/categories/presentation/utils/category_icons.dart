import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class CategoryIcons {
  static const Map<String, IconData> icons = {
    'category': Symbols.category_rounded,
    'shopping_cart': Symbols.shopping_cart_rounded,
    'local_dining': Symbols.local_dining_rounded,
    'fastfood': Symbols.fastfood_rounded,
    'liquor': Symbols.liquor_rounded,
    'local_cafe': Symbols.local_cafe_rounded,
    'checkroom': Symbols.checkroom_rounded,
    'kitchen': Symbols.kitchen_rounded,
    'devices': Symbols.devices_rounded,
    'sports_esports': Symbols.sports_esports_rounded,
    'fitness_center': Symbols.fitness_center_rounded,
    'toys': Symbols.toys_rounded,
    'pets': Symbols.pets_rounded,
    'local_florist': Symbols.local_florist_rounded,
    'healing': Symbols.healing_rounded,
    'science': Symbols.science_rounded,
    'school': Symbols.school_rounded,
    'menu_book': Symbols.menu_book_rounded,
    'build': Symbols.build_rounded,
    'home_repair_service': Symbols.home_repair_service_rounded,
    'cleaning_services': Symbols.cleaning_services_rounded,
    'directions_car': Symbols.directions_car_rounded,
    'card_travel': Symbols.card_travel_rounded,
    'headphones': Symbols.headphones_rounded,
    'watch': Symbols.watch_rounded,
    'directions_bike': Symbols.directions_bike_rounded,
    'local_mall': Symbols.local_mall_rounded,
    'camera_alt': Symbols.camera_alt_rounded,
    'storefront': Symbols.storefront_rounded,
    'electrical_services': Symbols.electrical_services_rounded,
    'plumbing': Symbols.plumbing_rounded,
    'eco': Symbols.eco_rounded,
    'diamond': Symbols.diamond_rounded,
    'medication': Symbols.medication_rounded,
    'bed': Symbols.bed_rounded,
  };

  static IconData getIcon(String key) {
    return icons[key] ?? Symbols.category_rounded;
  }
}
