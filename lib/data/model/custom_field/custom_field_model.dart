class CustomFieldModel {
  int? id;
  String? name;
  /// Translated name returned from the backend
  String? translatedName;
  List? value;
  String? type;
  String? image;
  int? required;
  int? minLength;
  String? nameAr;
  int? maxLength;
  dynamic values;
  /// Translated values returned from the backend
  dynamic translatedValues;

  CustomFieldModel(
      {this.id,
      this.name,
      this.translatedName,
      this.type,
      this.values,
      this.translatedValues,
      this.image,
      this.required,
      this.maxLength,
      this.minLength,
      this.nameAr,
      this.value});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'translated_name': translatedName,
      'type': type,
      'values': values,
      'translated_values': translatedValues,
      'image': image,
      'name_ar': nameAr,
      'required': required,
      'min_length': minLength,
      'max_length': maxLength,
      'value': value,
    };
  }

  factory CustomFieldModel.fromMap(Map<String, dynamic> map) {
    return CustomFieldModel(
      id: map['id'] as int,
      name: map['translated_name'] ?? map['name'],
      translatedName: map['translated_name'],
      type: map['type'] as String,
      values: map['translated_values'] ?? map['values'] as dynamic,
      translatedValues: map['translated_values'],
      image: map['image'],
      required: map['required'],
      maxLength: map['max_length'],
      minLength: map['min_length'],
      value: map['value'],
    );
  }

  @override
  String toString() {
    return 'CustomFieldModel(id: $id, name: $name, type: $type, image: $image, required: $required, minLength: $minLength, maxLength: $maxLength, values: $values,value:$value)';
  }
}

class VerificationFieldModel {
  int? id;
  String? name;
  String? type;
  int? required;
  int? minLength;
  int? maxLength;
  String? status;
  dynamic values;

  VerificationFieldModel({
    this.id,
    this.name,
    this.type,
    this.values,
    this.required,
    this.maxLength,
    this.minLength,
    this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'values': values,
      'required': required,
      'min_length': minLength,
      'max_length': maxLength,
      'status': status,
    };
  }

  factory VerificationFieldModel.fromMap(Map<String, dynamic> map) {
    return VerificationFieldModel(
      id: map['id'] as int,
      name: map['name'] as String,
      type: map['type'] as String,
      values: map['values'] as dynamic,
      required: map['is_required'],
      maxLength: map['max_length'],
      minLength: map['min_length'],
      status: map['status'],
    );
  }

  @override
  String toString() {
    return 'VerificationFieldModel(id: $id, name: $name, type: $type, required: $required, minLength: $minLength, maxLength: $maxLength, values: $values,status:$status)';
  }
}
