class ItemCardField {
  final String? name;
  final String? icon;
  final String? value;

  ItemCardField({this.name, this.icon, this.value});

  factory ItemCardField.fromJson(Map<String, dynamic> json) {
    return ItemCardField(
      name: json['name'],
      icon: json['icon'],
      value: json['value']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'icon': icon,
      'value': value,
    };
  }

  @override
  String toString() {
    return 'ItemCardField(name: \$name, icon: \$icon, value: \$value)';
  }
}
