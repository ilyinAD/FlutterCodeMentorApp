class ApiErrorModel {
  final String error;
  final List<FieldError>? details;

  const ApiErrorModel({required this.error, this.details});

  factory ApiErrorModel.fromJson(Map<String, dynamic> json) {
    return ApiErrorModel(
      error: json['error'] as String? ?? 'Unknown error',
      details: (json['details'] as List<dynamic>?)
          ?.map((e) => FieldError.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class FieldError {
  final String? field;
  final String? message;

  const FieldError({this.field, this.message});

  factory FieldError.fromJson(Map<String, dynamic> json) {
    return FieldError(
      field: json['field'] as String?,
      message: json['message'] as String?,
    );
  }
}
