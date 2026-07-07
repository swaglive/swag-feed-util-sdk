import 'package:freezed_annotation/freezed_annotation.dart';

part 'selected_domain_tracker_resources.freezed.dart';

@freezed
abstract class SelectedDomainTrackerResources
    with _$SelectedDomainTrackerResources {
  const factory SelectedDomainTrackerResources({
    required Map<String, Uri> uris,
    required Map<String, String> overrideRemoteConfigs,
    required bool isFrontendChanged,
  }) = _SelectedDomainTrackerResources;
}
