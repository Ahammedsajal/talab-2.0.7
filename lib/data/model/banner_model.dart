class BannerModel {
  final int? id;
  final String? image;
  final String? linkType;
  final String? linkTarget;
  final int? sequence;

  BannerModel({this.id, this.image, this.linkType, this.linkTarget, this.sequence});

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] is String ? int.tryParse(json['id'].toString()) : json['id'],
      image: json['image'] as String?,
      linkType: json['link_type'] as String?,
      linkTarget: json['link_target']?.toString(),
      sequence: json['sequence'] is String ? int.tryParse(json['sequence'].toString()) : json['sequence'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
      'link_type': linkType,
      'link_target': linkTarget,
      'sequence': sequence,
    };
  }
}
