enum ErrorType {
  missingApiKey,
  invalidApiKey,
  networkError,
  apiError,
  rateLimitExceeded,
  unknown,
}

class AiResponse {
  final bool isSuccess;
  final String? data;
  final ErrorType? errorType;
  final String? errorMessage;

  AiResponse._({
    required this.isSuccess,
    this.data,
    this.errorType,
    this.errorMessage,
  });

  factory AiResponse.success({required String data}) {
    return AiResponse._(isSuccess: true, data: data);
  }

  factory AiResponse.error({
    required ErrorType type,
    required String message,
  }) {
    return AiResponse._(
      isSuccess: false,
      errorType: type,
      errorMessage: message,
    );
  }

  bool get isError => !isSuccess;
  bool get hasData => data != null && data!.isNotEmpty;
}