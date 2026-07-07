import 'package:freezed_annotation/freezed_annotation.dart';

class MillisecondsToDurationConverter implements JsonConverter<Duration, int> {
  const MillisecondsToDurationConverter();

  @override
  Duration fromJson(int json) => Duration(milliseconds: json);

  @override
  int toJson(Duration duration) => duration.inMilliseconds;
}
