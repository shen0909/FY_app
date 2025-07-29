class BannerModels {
  /// 点击后跳转页面显示的内容
  String content;
  bool enable;
  
  /// 背景图 base64
  String image;
  int sort;
  
  /// banner标题
  String title;
  String uuid;

  BannerModels({
    required this.content,
    required this.enable,
    required this.image,
    required this.sort,
    required this.title,
    required this.uuid,
  });

  factory BannerModels.fromJson(Map<String, dynamic> json) => BannerModels(
        content: json["content"] ?? "",
        enable: json["enable"] ?? false,
        image: json["image"] ?? "",
        sort: json["sort"] ?? 0,
        title: json["title"] ?? "",
        uuid: json["uuid"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "content": content,
        "enable": enable,
        "image": image,
        "sort": sort,
        "title": title,
        "uuid": uuid,
      };
} 