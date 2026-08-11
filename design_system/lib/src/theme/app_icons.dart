import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Centralized icons repository for the application and design system.
abstract class AppIcons {
  // --- ASSET PATHS & PACKAGES ---
  static const String pixLogo = 'assets/icons/pix_logo.svg';
  static const String package = 'design_system';

  // --- GENERAL ACTIONS & SYSTEM ICONS ---
  static const IconData add = Symbols.add_rounded;
  static const IconData add2 = Symbols.add_2_rounded;
  static const IconData arrowDown = Icons.keyboard_arrow_down_rounded;
  static const IconData arrowUp = Icons.keyboard_arrow_up_rounded;
  static const IconData bookmarkAdd = Symbols.bookmark_add_rounded;
  static const IconData check = Symbols.check_rounded;
  static const IconData checkCircle = Symbols.check_circle_rounded;
  static const IconData checkCircleOutline = Symbols.check_circle_outline_rounded;
  static const IconData close = Symbols.close_rounded;
  static const IconData delete = Symbols.delete_outline_rounded;
  static const IconData deleteFilled = Symbols.delete;
  static const IconData dropDown = Icons.arrow_drop_down;
  static const IconData edit = Symbols.edit_rounded;
  static const IconData error = Symbols.error_rounded;
  static const IconData errorCircle = Symbols.error_circle_rounded;
  static const IconData info = Symbols.info_rounded;
  static const IconData logout = Icons.logout;
  static const IconData package2 = Symbols.package_2_rounded;
  static const IconData play = Symbols.play_arrow_rounded;
  static const IconData remove = Symbols.remove_rounded;
  static const IconData save = Symbols.save_rounded;
  static const IconData search = Symbols.search_rounded;
  static const IconData searchOff = Symbols.search_off_rounded;
  static const IconData stacks = Symbols.stacks_rounded;
  static const IconData visibility = Icons.visibility_outlined;
  static const IconData visibilityOff = Icons.visibility_off_outlined;
  static const IconData warning = Symbols.warning_rounded;

  // --- DOMAIN & FEATURE ICONS ---
  static const IconData adminPanelSettings = Symbols.admin_panel_settings_rounded;
  static const IconData assignmentReturn = Symbols.assignment_return_rounded;
  static const IconData badge = Symbols.badge_rounded;
  static const IconData barChart = Symbols.bar_chart_rounded;
  static const IconData barcodeScanner = Symbols.barcode_scanner_rounded;
  static const IconData block = Symbols.block_rounded;
  static const IconData brokenImage = Symbols.broken_image_rounded;
  static const IconData cancel = Symbols.cancel_rounded;
  static const IconData chevronRight = Symbols.chevron_right_rounded;
  static const IconData creditCard = Symbols.credit_card_rounded;
  static const IconData creditScore = Symbols.credit_score_rounded;
  static const IconData crown = Symbols.crown;
  static const IconData currency = Symbols.universal_currency_alt_rounded;
  static const IconData deliveryTruck = Symbols.delivery_truck_speed_rounded;
  static const IconData editNote = Symbols.edit_note_rounded;
  static const IconData fingerprint = Symbols.fingerprint;
  static const IconData group = Symbols.group_rounded;
  static const IconData history = Symbols.history_rounded;
  static const IconData homeWork = Symbols.home_work_rounded;
  static const IconData image = Symbols.image_rounded;
  static const IconData inventory2 = Symbols.inventory_2_rounded;
  static const IconData keyboard = Symbols.keyboard;
  static const IconData lists = Symbols.lists_rounded;
  static const IconData localShipping = Symbols.local_shipping_rounded;
  static const IconData lockPerson = Symbols.lock_person;
  static const IconData mail = Symbols.mail_rounded;
  static const IconData orderApprove = Symbols.order_approve_sharp;
  static const IconData person = Symbols.person;
  static const IconData phone = Symbols.phone;
  static const IconData powerSettings = Symbols.power_settings_new_rounded;
  static const IconData qrCode = Symbols.qr_code_2_rounded;
  static const IconData receipt = Symbols.receipt_long_rounded;
  static const IconData receiptLong = Symbols.receipt_long_rounded;
  static const IconData shieldPerson = Symbols.shield_person;
  static const IconData shoppingBag = Symbols.shopping_bag_rounded;
  static const IconData shoppingCart = Symbols.shopping_cart_rounded;
  static const IconData store = Symbols.store_rounded;
  static const IconData supervisorAccount = Symbols.supervisor_account_rounded;
  static const IconData trendingDown = Symbols.trending_down_rounded;
  static const IconData trendingUp = Symbols.trending_up_rounded;
  static const IconData tune = Symbols.tune_rounded;
  static const IconData work = Symbols.work_rounded;

  // --- CATEGORY ICONS ---
  static const IconData defaultCategory = Symbols.category_rounded;

  static const Map<String, IconData> categoryIcons = {
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

  /// Returns the icon associated with [key], or [defaultCategory] if key is null/unmatched.
  static IconData getCategoryIcon(String? key) {
    if (key == null) return defaultCategory;
    return categoryIcons[key] ?? defaultCategory;
  }
}
