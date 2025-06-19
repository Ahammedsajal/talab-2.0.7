class ItemCardField {
  final String? name;
  final String? icon;
  final String? value;

  ItemCardField({this.name, this.icon, this.value});

  factory ItemCardField.fromJson(Map<String, dynamic> json) {
    var value = json['value'];
    String? processedValue;
    if (value is List && value.isNotEmpty) {
      // Extract the first value from the list and convert to string
      processedValue = value.first.toString();
    } else if (value != null) {
      // Handle non-list values (e.g., string or number)
      processedValue = value.toString();
    }
    return ItemCardField(
      name: json['name'],
      icon: json['icon'],
      value: processedValue,
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
    return 'ItemCardField(name: $name, icon: $icon, value: $value)';
  }
}
