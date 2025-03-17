// core/constants/error_constants.dart

class ErrorConstants {
  // Authentication Errors
  static const String invalidEmail = 'Invalid email address.';
  static const String invalidPassword = 'Password must be at least 6 characters.';
  static const String wrongCredentials = 'Incorrect email or password.';
  static const String emailInUse = 'This email is already in use.';
  static const String weakPassword = 'Password is too weak.';
  static const String accountNotFound = 'Account not found.';
  static const String userDisabled = 'This account has been disabled.';
  static const String sessionExpired = 'Your session has expired. Please log in again.';
  static const String invalidVerificationCode = 'Invalid verification code.';
  static const String tooManyRequests = 'Too many requests. Please try again later.';

  // Network Errors
  static const String noInternet = 'No internet connection.';
  static const String connectionTimeout = 'Connection timed out.';
  static const String serverError = 'Server error. Please try again later.';
  static const String unknownError = 'An unknown error occurred.';

  // Input Validation Errors
  static const String requiredField = 'This field is required.';
  static const String invalidPhone = 'Invalid phone number.';
  static const String invalidUrl = 'Invalid URL.';
  static const String invalidNumber = 'Invalid number.';
  static const String invalidDate = 'Invalid date.';
  static const String invalidTime = 'Invalid time.';
  static const String invalidPrice = 'Price must be greater than 0.';
  static const String invalidQuantity = 'Quantity must be greater than 0.';

  // File/Image Errors
  static const String fileTooBig = 'File size exceeds the maximum limit.';
  static const String unsupportedFileFormat = 'Unsupported file format.';
  static const String failedToUpload = 'Failed to upload file.';
  static const String failedToDownload = 'Failed to download file.';
  static const String failedToDelete = 'Failed to delete file.';

  // Restaurant Management Errors
  static const String categoryExists = 'A category with this name already exists.';
  static const String foodItemExists = 'A food item with this name already exists.';
  static const String tableExists = 'A table with this number already exists.';
  static const String categoryNotFound = 'Category not found.';
  static const String foodItemNotFound = 'Food item not found.';
  static const String tableNotFound = 'Table not found.';
  static const String orderNotFound = 'Order not found.';
  static const String itemNotAvailable = 'Item is not available.';
  static const String tableNotAvailable = 'Table is not available.';
  static const String insufficientPermission = 'You don\'t have permission to perform this action.';
  static const String orderAlreadyProcessed = 'This order has already been processed.';
  static const String orderAlreadyCancelled = 'This order has already been cancelled.';

  // Database Errors
  static const String failedToFetch = 'Failed to fetch data.';
  static const String failedToCreate = 'Failed to create data.';
  static const String failedToUpdate = 'Failed to update data.';
  static const String documentNotFound = 'Document not found.';
  static const String collectionNotFound = 'Collection not found.';

  // Payment Errors
  static const String paymentFailed = 'Payment failed.';
  static const String invalidPaymentMethod = 'Invalid payment method.';
  static const String paymentCancelled = 'Payment was cancelled.';
  static const String paymentDeclined = 'Payment was declined.';
  static const String insufficientFunds = 'Insufficient funds.';
}