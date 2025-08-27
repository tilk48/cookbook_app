import 'package:json_annotation/json_annotation.dart';

part 'shopping_list_models.g.dart';

@JsonSerializable()
class ShoppingList {
  final String id;
  final String name;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'update_at') 
  final DateTime updateAt;
  @JsonKey(name: 'list_items')
  final List<ShoppingListItem> listItems;

  const ShoppingList({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updateAt,
    required this.listItems,
  });

  factory ShoppingList.fromJson(Map<String, dynamic> json) => 
      _$ShoppingListFromJson(json);
  Map<String, dynamic> toJson() => _$ShoppingListToJson(this);
}

@JsonSerializable()
class ShoppingListItem {
  final String id;
  final String note;
  final double quantity;
  final String? unit;
  final String? food;
  final bool checked;
  @JsonKey(name: 'position')
  final int position;
  @JsonKey(name: 'is_food')
  final bool isFood;

  const ShoppingListItem({
    required this.id,
    required this.note,
    required this.quantity,
    this.unit,
    this.food,
    required this.checked,
    required this.position,
    required this.isFood,
  });

  factory ShoppingListItem.fromJson(Map<String, dynamic> json) => 
      _$ShoppingListItemFromJson(json);
  Map<String, dynamic> toJson() => _$ShoppingListItemToJson(this);
}

@JsonSerializable()
class CreateShoppingListRequest {
  final String name;

  const CreateShoppingListRequest({required this.name});

  factory CreateShoppingListRequest.fromJson(Map<String, dynamic> json) => 
      _$CreateShoppingListRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateShoppingListRequestToJson(this);
}

@JsonSerializable()
class CreateShoppingListItemRequest {
  final String note;
  final double quantity;
  final String? unit;
  final String? food;
  @JsonKey(name: 'is_food')
  final bool? isFood;

  const CreateShoppingListItemRequest({
    required this.note,
    required this.quantity,
    this.unit,
    this.food,
    this.isFood,
  });

  factory CreateShoppingListItemRequest.fromJson(Map<String, dynamic> json) => 
      _$CreateShoppingListItemRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateShoppingListItemRequestToJson(this);
}