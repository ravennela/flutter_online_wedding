// To parse this JSON data, do
//
//     final sendOtpModel = sendOtpModelFromJson(jsonString);

import 'dart:convert';

SendOtpModel sendOtpModelFromJson(String str) => SendOtpModel.fromJson(json.decode(str));

String sendOtpModelToJson(SendOtpModel data) => json.encode(data.toJson());

class SendOtpModel {
    String message;
    String phone;
    String otp;

    SendOtpModel({
        required this.message,
        required this.phone,
        required this.otp,
    });

    factory SendOtpModel.fromJson(Map<String, dynamic> json) => SendOtpModel(
        message: json["message"],
        phone: json["phone"],
        otp: json["otp"],
    );

    Map<String, dynamic> toJson() => {
        "message": message,
        "phone": phone,
        "otp": otp,
    };
}
