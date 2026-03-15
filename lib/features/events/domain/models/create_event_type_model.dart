
// To parse this JSON data, do
//
//     final createEventType = createEventTypeFromJson(jsonString);

import 'dart:convert';

CreateEventTypeModel createEventTypeFromJson(String str) => CreateEventTypeModel.fromJson(json.decode(str));

String createEventTypeToJson(CreateEventTypeModel data) => json.encode(data.toJson());

class CreateEventTypeModel {
    bool active;
    String? description;
    String? iconUrl;
    String? iconPublicId;
    String id;
    String name;
    int? sortOrder;

    CreateEventTypeModel({
        required this.active,
        this.description,
        this.iconUrl,
        this.iconPublicId,
        required this.id,
        required this.name,
        this.sortOrder,
    });

    factory CreateEventTypeModel.fromJson(Map<String, dynamic> json) => CreateEventTypeModel(
        active: json["active"] ?? false,
        description: json["description"],
        iconUrl: json["iconUrl"],
        iconPublicId: json["iconPublicId"],
        id: json["id"] ?? "",
        name: json["name"] ?? "",
        sortOrder: json["sortOrder"],
    );

    Map<String, dynamic> toJson() => {
        "active": active,
        "description": description,
        "iconUrl": iconUrl,
        "iconPublicId": iconPublicId,
        "id": id,
        "name": name,
        "sortOrder": sortOrder,
    };
}
