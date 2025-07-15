// To parse this JSON data, do
//
//     final catgorymodal = catgorymodalFromJson(jsonString);

import 'dart:convert';

Catgorymodal catgorymodalFromJson(String str) => Catgorymodal.fromJson(json.decode(str));

String catgorymodalToJson(Catgorymodal data) => json.encode(data.toJson());

class Catgorymodal {
  int status;
  List<ProductCategory> productCategory;

  Catgorymodal({
    required this.status,
    required this.productCategory,
  });

  factory Catgorymodal.fromJson(Map<String, dynamic> json) => Catgorymodal(
    status: json["status"],
    productCategory: List<ProductCategory>.from(json["product_category"].map((x) => ProductCategory.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "product_category": List<dynamic>.from(productCategory.map((x) => x.toJson())),
  };
}

class ProductCategory {
  int id;
  String category;
  String img;
  String image;
  int amount;


  ProductCategory({
    required this.id,
    required this.category,
    required this.img,
    required this.image,
    required this.amount,

  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) => ProductCategory(
    id: json["id"],
    category: json["category"],
    img: json["img"],
    image: json["image"],
      amount : json["amount"],

  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "category": category,
    "img": img,
    "image": image,
    "amount":amount,

  };
}
