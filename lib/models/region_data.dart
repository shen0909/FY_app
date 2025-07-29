class RegionData {
  String code;
  String name;
  List<RegionData> children;

  RegionData({
    required this.code,
    required this.name,
    required this.children,
  });

  factory RegionData.fromJson(Map<String, dynamic> json) => RegionData(
        code: json["code"] ?? "",
        name: json["name"] ?? "",
        children: List<RegionData>.from(
            json["children"]?.map((x) => RegionData.fromJson(x)) ?? []),
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "name": name,
        "children": List<dynamic>.from(children.map((x) => x.toJson())),
      };
} 