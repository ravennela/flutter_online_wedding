// To parse this JSON data, do
//
//     final verifyOtpModel = verifyOtpModelFromJson(jsonString);

import 'dart:convert';

VerifyOtpModel verifyOtpModelFromJson(String str) => VerifyOtpModel.fromJson(json.decode(str));

String verifyOtpModelToJson(VerifyOtpModel data) => json.encode(data.toJson());

class VerifyOtpModel {
    String token;
    String role;
    String userId;
    String name;

    VerifyOtpModel({
        required this.token,
        required this.role,
        required this.userId,
        required this.name,
    });

    factory VerifyOtpModel.fromJson(Map<String, dynamic> json) => VerifyOtpModel(
        token: json["token"]?.toString() ?? '',
        role: json["role"]?.toString() ?? 'USER',
        userId: json["userId"]?.toString() ?? '',
        name: json["name"]?.toString() ?? '',
    );

    Map<String, dynamic> toJson() => {
        "token": token,
        "role": role,
        "userId": userId,
        "name": name,
    };
}
