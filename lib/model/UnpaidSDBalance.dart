class UnpaidSDBalanceResponse {
  final String message;
  final bool isSuccess;
  final double data;
  final int totalRecords;
  final int pageNumber;
  final int pageSize;

  UnpaidSDBalanceResponse({
    required this.message,
    required this.isSuccess,
    required this.data,
    required this.totalRecords,
    required this.pageNumber,
    required this.pageSize,
  });

  factory UnpaidSDBalanceResponse.fromJson(Map<String, dynamic> json) {
    return UnpaidSDBalanceResponse(
      message: json['message'] ?? '',
      isSuccess: json['isSuccess'] ?? false,
      data: json['data']?.toDouble() ?? 0.0,
      totalRecords: json['totalRecords'] ?? 0,
      pageNumber: json['pageNumber'] ?? 0,
      pageSize: json['pageSize'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'isSuccess': isSuccess,
      'data': data,
      'totalRecords': totalRecords,
      'pageNumber': pageNumber,
      'pageSize': pageSize,
    };
  }
}