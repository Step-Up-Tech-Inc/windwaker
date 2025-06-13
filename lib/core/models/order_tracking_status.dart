import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_tracking_status.freezed.dart';
part 'order_tracking_status.g.dart';

@freezed
class OrderTrackingStatus with _$OrderTrackingStatus {
  const factory OrderTrackingStatus({
    required OrderStatusType status,
    required DateTime? time,
    String? estimated,
  }) = _OrderTrackingStatus;

  factory OrderTrackingStatus.fromJson(Map<String, dynamic> json) =>
      _$OrderTrackingStatusFromJson(json);
}

@JsonEnum(fieldRename: FieldRename.snake)
enum OrderStatusType { processed, preparing, onTheWay, delivered, cancelled }
