// core/constants/api_constants.dart

class ApiConstants {
  // Firebase Cloud Functions API Endpoints (if needed)
  static const String baseUrl = 'https://us-central1-foodkie-app.cloudfunctions.net/api';

  // API Endpoints
  static const String sendNotification = '$baseUrl/sendNotification';
  static const String generateReport = '$baseUrl/generateReport';
  static const String processPayment = '$baseUrl/processPayment';

  // API Headers
  static Map<String, String> getHeaders(String token) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };

  // API Error Codes
  static const int badRequestCode = 400;
  static const int unauthorizedCode = 401;
  static const int forbiddenCode = 403;
  static const int notFoundCode = 404;
  static const int serverErrorCode = 500;

  // API Error Messages
  static const String connectionErrorMessage = 'Connection error. Please check your internet connection.';
  static const String timeoutErrorMessage = 'Request timed out. Please try again.';
  static const String serverErrorMessage = 'Server error. Please try again later.';
  static const String notFoundErrorMessage = 'Resource not found.';
  static const String unauthorizedErrorMessage = 'Unauthorized access. Please login again.';
  static const String unknownErrorMessage = 'An unknown error occurred. Please try again.';

  // API Request Timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);

  // API Retry Configuration
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  // API Content Types
  static const String jsonContentType = 'application/json; charset=utf-8';
  static const String formUrlEncodedContentType = 'application/x-www-form-urlencoded';
  static const String multipartFormDataContentType = 'multipart/form-data';
}