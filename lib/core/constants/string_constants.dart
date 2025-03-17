// core/constants/string_constants.dart

class StringConstants {
  // App Information
  static const String appName = 'Foodkie';
  static const String appSlogan = 'Restaurant Management Made Easy';
  static const String companyName = 'Foodkie Inc.';
  static const String appDescription = 'A comprehensive restaurant management system for managers, waiters, and kitchen staff.';

  // Auth Strings
  static const String login = 'Login';
  static const String register = 'Register';
  static const String forgotPassword = 'Forgot Password?';
  static const String resetPassword = 'Reset Password';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String name = 'Name';
  static const String phoneNumber = 'Phone Number';
  static const String role = 'Role';
  static const String selectRole = 'Select Role';
  static const String rememberMe = 'Remember Me';
  static const String dontHaveAccount = 'Don\'t have an account?';
  static const String alreadyHaveAccount = 'Already have an account?';
  static const String signUp = 'Sign Up';
  static const String signIn = 'Sign In';
  static const String logout = 'Logout';
  static const String logoutConfirmation = 'Are you sure you want to logout?';
  static const String verifyEmail = 'Verify Email';
  static const String verificationEmailSent = 'Verification email has been sent';
  static const String checkEmail = 'Please check your email';

  // Role Titles
  static const String managerTitle = 'Manager';
  static const String waiterTitle = 'Waiter';
  static const String kitchenTitle = 'Kitchen';

  // Role Descriptions
  static const String managerDescription = 'Manage food items, categories, staff, and analyze restaurant performance.';
  static const String waiterDescription = 'Take and manage customer orders from tables.';
  static const String kitchenDescription = 'View and process incoming orders for preparation.';

  // Common Action Buttons
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String add = 'Add';
  static const String update = 'Update';
  static const String confirm = 'Confirm';
  static const String submit = 'Submit';
  static const String continue_ = 'Continue';
  static const String back = 'Back';
  static const String next = 'Next';
  static const String done = 'Done';
  static const String yes = 'Yes';
  static const String no = 'No';
  static const String ok = 'OK';
  static const String apply = 'Apply';
  static const String search = 'Search';
  static const String filter = 'Filter';
  static const String sort = 'Sort';
  static const String clear = 'Clear';
  static const String reset = 'Reset';

  // Manager Dashboard
  static const String dashboard = 'Dashboard';
  static const String categories = 'Categories';
  static const String foodItems = 'Food Items';
  static const String tables = 'Tables';
  static const String staff = 'Staff';
  static const String reports = 'Reports';
  static const String analytics = 'Analytics';
  static const String settings = 'Settings';
  static const String profile = 'Profile';
  static const String addCategory = 'Add Category';
  static const String editCategory = 'Edit Category';
  static const String addFood = 'Add Food Item';
  static const String editFood = 'Edit Food Item';
  static const String addTable = 'Add Table';
  static const String editTable = 'Edit Table';
  static const String addStaff = 'Add Staff';
  static const String editStaff = 'Edit Staff';

  // Food Item Fields
  static const String foodName = 'Food Name';
  static const String description = 'Description';
  static const String price = 'Price';
  static const String category = 'Category';
  static const String selectCategory = 'Select Category';
  static const String preparationTime = 'Preparation Time (mins)';
  static const String availability = 'Availability';
  static const String available = 'Available';
  static const String unavailable = 'Unavailable';
  static const String image = 'Image';
  static const String selectImage = 'Select Image';
  static const String takePhoto = 'Take Photo';
  static const String chooseFromGallery = 'Choose from Gallery';

  // Table Fields
  static const String tableNumber = 'Table Number';
  static const String tableCapacity = 'Capacity';
  static const String tableStatus = 'Status';

  // Waiter Screens
  static const String selectTable = 'Select Table';
  static const String newOrder = 'New Order';
  static const String cart = 'Cart';
  static const String addToCart = 'Add to Cart';
  static const String placeOrder = 'Place Order';
  static const String orderConfirmation = 'Order Confirmation';
  static const String orderSummary = 'Order Summary';
  static const String orderHistory = 'Order History';
  static const String orderDetails = 'Order Details';
  static const String tableOccupied = 'Table is occupied';
  static const String tableAvailable = 'Table is available';
  static const String tableReserved = 'Table is reserved';
  static const String quantity = 'Quantity';
  static const String notes = 'Notes';
  static const String addNotes = 'Add Notes';
  static const String total = 'Total';
  static const String subtotal = 'Subtotal';
  static const String tax = 'Tax';
  static const String discount = 'Discount';

  // Kitchen Screens
  static const String pendingOrders = 'Pending Orders';
  static const String acceptedOrders = 'Accepted Orders';
  static const String preparingOrders = 'Preparing Orders';
  static const String readyOrders = 'Ready Orders';
  static const String acceptOrder = 'Accept Order';
  static const String startPreparing = 'Start Preparing';
  static const String markAsReady = 'Mark as Ready';
  static const String cancelOrder = 'Cancel Order';
  static const String orderAccepted = 'Order Accepted';
  static const String orderPreparing = 'Order Preparing';
  static const String orderReady = 'Order Ready';
  static const String orderCancelled = 'Order Cancelled';

  // Order Status
  static const String pending = 'Pending';
  static const String accepted = 'Accepted';
  static const String preparing = 'Preparing';
  static const String ready = 'Ready';
  static const String served = 'Served';
  static const String cancelled = 'Cancelled';

  // Notifications
  static const String notifications = 'Notifications';
  static const String newOrderNotification = 'New Order Received';
  static const String orderStatusChangedNotification = 'Order Status Changed';
  static const String orderReadyNotification = 'Order Ready for Serving';

  // Error Messages
  static const String errorOccurred = 'An error occurred';
  static const String tryAgainLater = 'Please try again later';
  static const String noInternet = 'No internet connection';
  static const String sessionExpired = 'Session expired. Please login again';
  static const String invalidCredentials = 'Invalid email or password';

  // Empty States
  static const String noCategories = 'No categories found';
  static const String noFoodItems = 'No food items found';
  static const String noTables = 'No tables found';
  static const String noOrders = 'No orders found';
  static const String noResults = 'No results found';
  static const String emptyCart = 'Your cart is empty';
  static const String noNotifications = 'No notifications';

  // Confirmation Messages
  static const String deleteConfirmation = 'Are you sure you want to delete this?';
  static const String cancelOrderConfirmation = 'Are you sure you want to cancel this order?';
  static const String discardChangesConfirmation = 'Discard changes?';

  // Success Messages
  static const String saveSuccess = 'Successfully saved';
  static const String updateSuccess = 'Successfully updated';
  static const String deleteSuccess = 'Successfully deleted';
  static const String orderPlacedSuccess = 'Order successfully placed';

  // Settings
  static const String darkMode = 'Dark Mode';
  static const String language = 'Language';
  static const String notifications_ = 'Notifications';
  static const String sound = 'Sound';
  static const String vibration = 'Vibration';
  static const String aboutApp = 'About App';
  static const String privacyPolicy = 'Privacy Policy';
  static const String termsConditions = 'Terms & Conditions';
  static const String contactUs = 'Contact Us';
  static const String rateApp = 'Rate App';
  static const String shareApp = 'Share App';
  static const String version = 'Version';
}