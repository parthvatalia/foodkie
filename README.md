# Foodkie - Restaurant Management App

## Project Overview
Foodkie is a comprehensive restaurant management solution built with Flutter and Firebase. It features three distinct user roles:

1. **Manager**: Controls the restaurant's menu, categories, and settings
2. **Waiter**: Takes and manages customer orders
3. **Kitchen Staff**: Processes and fulfills orders

## Technology Stack
- **Frontend**: Flutter
- **Backend**: Firebase (Authentication, Firestore, Storage)
- **State Management**: Provider
- **Architecture Pattern**: Clean Architecture

## Project Structure
```
foodkie/
│
├── android/                      # Android platform-specific files
│
├── ios/                          # iOS platform-specific files
│
├── assets/                       # App assets
│   ├── animations/               # Lottie animation files
│   │   ├── loading.json
│   │   ├── success.json
│   │   ├── error.json
│   │   ├── empty.json
│   │   └── food_preparing.json
│   │
│   ├── fonts/                    # Custom fonts
│   │
│   ├── icons/                    # App icons
│   │   ├── category_icon.png
│   │   ├── food_icon.png
│   │   ├── kitchen_icon.png
│   │   ├── manager_icon.png
│   │   ├── order_icon.png
│   │   ├── table_icon.png
│   │   └── waiter_icon.png
│   │
│   └── images/                   # Images used in the app
│       ├── logo_full.png
│       ├── logo_icon.png
│       ├── login_bg.jpg
│       ├── onboarding_1.png
│       ├── onboarding_2.png
│       ├── onboarding_3.png
│       ├── food_placeholder.jpg
│       └── category_placeholder.jpg
│
├── lib/                          # Main Dart application code
│   │
│   ├── core/                     # Core utilities and helpers
│   │   │
│   │   ├── animations/           # Animation classes
│   │   │   ├── fade_animation.dart
│   │   │   ├── page_transition.dart
│   │   │   ├── pulse_animation.dart
│   │   │   ├── scale_animation.dart
│   │   │   └── slide_animation.dart
│   │   │
│   │   ├── constants/            # App constants
│   │   │   ├── api_constants.dart
│   │   │   ├── app_constants.dart
│   │   │   ├── assets_constants.dart
│   │   │   ├── error_constants.dart
│   │   │   ├── route_constants.dart
│   │   │   └── string_constants.dart
│   │   │
│   │   ├── enums/                # Enum definitions
│   │   │   └── app_enums.dart
│   │   │
│   │   ├── extensions/           # Extension methods
│   │   │   ├── context_extensions.dart
│   │   │   ├── datetime_extensions.dart
│   │   │   └── string_extensions.dart
│   │   │
│   │   ├── theme/                # App theming
│   │   │   └── app_theme.dart
│   │   │
│   │   └── utils/                # Utility functions
│   │       ├── date_formatter.dart
│   │       ├── firebase_utils.dart
│   │       ├── image_utils.dart
│   │       ├── toast_utils.dart
│   │       └── validators.dart
│   │
│   ├── data/                     # Data layer
│   │   │
│   │   ├── datasources/          # Data sources
│   │   │   │
│   │   │   ├── local/            # Local data sources
│   │   │   │   └── local_storage.dart
│   │   │   │
│   │   │   └── remote/           # Remote data sources
│   │   │       ├── auth_remote_source.dart
│   │   │       ├── category_remote_source.dart
│   │   │       ├── food_remote_source.dart
│   │   │       ├── order_remote_source.dart
│   │   │       └── table_remote_source.dart
│   │   │
│   │   ├── models/               # Data models
│   │   │   ├── category_model.dart
│   │   │   ├── food_item_model.dart
│   │   │   ├── order_item_model.dart
│   │   │   ├── order_model.dart
│   │   │   ├── table_model.dart
│   │   │   └── user_model.dart
│   │   │
│   │   └── repositories/         # Repository implementations
│   │       ├── auth_repository_impl.dart
│   │       ├── category_repository_impl.dart
│   │       ├── food_repository_impl.dart
│   │       ├── order_repository_impl.dart
│   │       └── table_repository_impl.dart
│   │
│   ├── domain/                   # Domain layer
│   │   │
│   │   ├── entities/             # Domain entities (if different from models)
│   │   │
│   │   ├── repositories/         # Repository interfaces
│   │   │   ├── auth_repository.dart
│   │   │   ├── category_repository.dart
│   │   │   ├── food_repository.dart
│   │   │   ├── order_repository.dart
│   │   │   └── table_repository.dart
│   │   │
│   │   └── usecases/             # Business logic use cases
│   │       ├── auth/
│   │       │   ├── login_usecase.dart
│   │       │   ├── logout_usecase.dart
│   │       │   └── register_usecase.dart
│   │       │
│   │       ├── category/
│   │       │   ├── add_category_usecase.dart
│   │       │   ├── delete_category_usecase.dart
│   │       │   ├── get_categories_usecase.dart
│   │       │   └── update_category_usecase.dart
│   │       │
│   │       ├── food/
│   │       │   ├── add_food_usecase.dart
│   │       │   ├── delete_food_usecase.dart
│   │       │   ├── get_foods_by_category_usecase.dart
│   │       │   ├── get_foods_usecase.dart
│   │       │   ├── search_foods_usecase.dart
│   │       │   └── update_food_usecase.dart
│   │       │
│   │       ├── order/
│   │       │   ├── accept_order_usecase.dart
│   │       │   ├── cancel_order_usecase.dart
│   │       │   ├── create_order_usecase.dart
│   │       │   ├── get_kitchen_orders_usecase.dart
│   │       │   ├── get_order_usecase.dart
│   │       │   ├── get_waiter_orders_usecase.dart
│   │       │   ├── mark_order_ready_usecase.dart
│   │       │   └── update_order_status_usecase.dart
│   │       │
│   │       └── table/
│   │           ├── add_table_usecase.dart
│   │           ├── delete_table_usecase.dart
│   │           ├── get_tables_usecase.dart
│   │           └── update_table_usecase.dart
│   │
│   ├── presentation/             # Presentation layer
│   │   │
│   │   ├── common_widgets/       # Shared widgets
│   │   │   ├── app_bar_widget.dart
│   │   │   ├── category_card.dart
│   │   │   ├── confirmation_dialog.dart
│   │   │   ├── custom_button.dart
│   │   │   ├── custom_drawer.dart
│   │   │   ├── custom_text_field.dart
│   │   │   ├── empty_state_widget.dart
│   │   │   ├── error_widget.dart
│   │   │   ├── food_item_card.dart
│   │   │   ├── image_picker_widget.dart
│   │   │   ├── loading_widget.dart
│   │   │   ├── order_card.dart
│   │   │   ├── search_bar.dart
│   │   │   ├── status_badge.dart
│   │   │   └── table_card.dart
│   │   │
│   │   ├── providers/           # Provider state management
│   │   │   ├── auth_provider.dart
│   │   │   ├── category_provider.dart
│   │   │   ├── food_item_provider.dart
│   │   │   ├── order_provider.dart
│   │   │   └── table_provider.dart
│   │   │
│   │   └── screens/             # App screens
│   │       │
│   │       ├── auth/            # Authentication screens
│   │       │   ├── forgot_password_screen.dart
│   │       │   ├── login_screen.dart
│   │       │   ├── onboarding_screen.dart
│   │       │   ├── register_screen.dart
│   │       │   ├── role_selection_screen.dart
│   │       │   ├── splash_screen.dart
│   │       │   └── verify_email_screen.dart
│   │       │
│   │       ├── kitchen/         # Kitchen staff screens
│   │       │   ├── kitchen_home_screen.dart
│   │       │   ├── kitchen_order_detail_screen.dart
│   │       │   ├── kitchen_order_history_screen.dart
│   │       │   └── kitchen_profile_screen.dart
│   │       │
│   │       ├── manager/         # Manager screens
│   │       │   ├── analytics/
│   │       │   │   └── analytics_screen.dart
│   │       │   │
│   │       │   ├── categories/
│   │       │   │   ├── add_category_screen.dart
│   │       │   │   ├── category_list_screen.dart
│   │       │   │   └── edit_category_screen.dart
│   │       │   │
│   │       │   ├── dashboard/
│   │       │   │   └── manager_dashboard_screen.dart
│   │       │   │
│   │       │   ├── food_items/
│   │       │   │   ├── add_food_screen.dart
│   │       │   │   ├── edit_food_screen.dart
│   │       │   │   └── food_list_screen.dart
│   │       │   │
│   │       │   ├── reports/
│   │       │   │   └── reports_screen.dart
│   │       │   │
│   │       │   ├── settings/
│   │       │   │   └── manager_settings_screen.dart
│   │       │   │
│   │       │   ├── staff/
│   │       │   │   ├── add_staff_screen.dart
│   │       │   │   ├── edit_staff_screen.dart
│   │       │   │   └── staff_list_screen.dart
│   │       │   │
│   │       │   └── tables/
│   │       │       ├── add_table_screen.dart
│   │       │       ├── edit_table_screen.dart
│   │       │       └── table_list_screen.dart
│   │       │
│   │       ├── shared/          # Screens shared between roles
│   │       │   ├── about_screen.dart
│   │       │   ├── change_password_screen.dart
│   │       │   ├── edit_profile_screen.dart
│   │       │   ├── help_screen.dart
│   │       │   ├── notification_screen.dart
│   │       │   ├── privacy_policy_screen.dart
│   │       │   └── terms_conditions_screen.dart
│   │       │
│   │       └── waiter/          # Waiter screens
│   │           ├── cart_screen.dart
│   │           ├── food_selection_screen.dart
│   │           ├── order_confirmation_screen.dart
│   │           ├── order_detail_screen.dart
│   │           ├── order_history_screen.dart
│   │           ├── search_screen.dart
│   │           ├── table_selection_screen.dart
│   │           └── waiter_home_screen.dart
│   │
│   └── main.dart                # Application entry point
│
├── test/                        # Test directory
│   ├── data/
│   │   ├── datasources/
│   │   ├── models/
│   │   └── repositories/
│   │
│   ├── domain/
│   │   └── usecases/
│   │
│   └── presentation/
│       ├── providers/
│       └── screens/
│
├── analysis_options.yaml        # Lint rules
├── pubspec.lock                 # Generated dependency lock file
├── pubspec.yaml                 # Project dependencies and settings
└── README.md                    # Project documentation
```

## Core Features

### Authentication Module
- Role-based login (Manager, Waiter, Kitchen)
- User profile management
- Role-specific navigation and screens

### Manager Module
- **Food Category Management**
    - Create, read, update, delete food categories
    - Upload category images
    - Sort and organize categories

- **Food Item Management**
    - Add, edit, and delete food items
    - Upload and manage food images
    - Set prices, descriptions, and preparation time
    - Mark items as available/unavailable

- **Staff Management**
    - Add staff members with specific roles
    - Manage permissions

- **Analytics and Reporting**
    - View daily/weekly/monthly sales
    - Track popular items
    - Order history

### Waiter Module
- **Order Management**
    - Create new orders for tables
    - Search foods by category
    - Add items to order with quantity and notes
    - Calculate bill total

- **Table Management**
    - Assign orders to specific tables
    - Track table status (available, occupied)

- **Order Status Tracking**
    - View order progress in real-time
    - Get notifications when orders are ready

### Kitchen Module
- **Order Queue**
    - View incoming orders in real-time
    - See order details including notes and quantities

- **Order Processing**
    - Accept orders
    - Mark orders as "in preparation"
    - Mark orders as "ready for serving"
    - Cancel orders (with reason)

- **Kitchen Dashboard**
    - Overview of pending and in-progress orders
    - Historical view of completed orders