class FeaturedTimeModel {
  final DateTime startTime;
  final DateTime endTime;
  
  FeaturedTimeModel({
    required this.startTime,
    required this.endTime,
  });
  
  Map<String, dynamic> toJson() => {
    "startTime": startTime.toIso8601String(),
    "endTime": endTime.toIso8601String(),
  };
}