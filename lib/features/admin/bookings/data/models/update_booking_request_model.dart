class UpdateBookingRequestModel {
  final String? vendorId;
  final String? decorationId;
  final double? totalAmount;
  final double? advanceAmount;
  final String? eventDate;
  final String? eventTime;
  final String? status;
  final String? note;

  UpdateBookingRequestModel({
    this.vendorId,
    this.decorationId,
    this.totalAmount,
    this.advanceAmount,
    this.eventDate,
    this.eventTime,
    this.status,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      if (vendorId != null) 'vendorId': vendorId,
      if (decorationId != null) 'decorationId': decorationId,
      if (totalAmount != null) 'totalAmount': totalAmount,
      if (advanceAmount != null) 'advanceAmount': advanceAmount,
      if (eventDate != null) 'eventDate': eventDate,
      if (eventTime != null) 'eventTime': eventTime,
      if (status != null) 'status': status,
      if (note != null) 'note': note,
    };
  }

  factory UpdateBookingRequestModel.fromJson(Map<String, dynamic> json) {
    return UpdateBookingRequestModel(
      vendorId: json['vendorId'] as String?,
      decorationId: json['decorationId'] as String?,
      totalAmount: (json['totalAmount'] as num?)?.toDouble(),
      advanceAmount: (json['advanceAmount'] as num?)?.toDouble(),
      eventDate: json['eventDate'] as String?,
      eventTime: json['eventTime'] as String?,
      status: json['status'] as String?,
      note: json['note'] as String?,
    );
  }
}
