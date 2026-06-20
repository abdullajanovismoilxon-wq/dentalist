class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final String? detail;

  ApiResponse({
    this.success = true,
    this.data,
    this.error,
    this.detail,
  });

  factory ApiResponse.success(T data) {
    return ApiResponse(success: true, data: data);
  }

  factory ApiResponse.failure(String error, {String? detail}) {
    return ApiResponse(success: false, error: error, detail: detail);
  }
}

class PaginatedResponse<T> {
  final int count;
  final String? next;
  final String? previous;
  final List<T> results;

  PaginatedResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    return PaginatedResponse(
      count: json['count'] ?? 0,
      next: json['next'],
      previous: json['previous'],
      results: (json['results'] as List<dynamic>?)
              ?.map((e) => fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
