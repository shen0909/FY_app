class BannerModels {
  /// 点击后跳转页面显示的内容
  String content;
  bool enable;
  /// 背景图URL
  String imageUrl;
  int sort;
  
  /// banner标题
  String title;
  String uuid;

  BannerModels({
    required this.content,
    required this.enable,
    required this.imageUrl,
    required this.sort,
    required this.title,
    required this.uuid,
  });

  factory BannerModels.fromJson(Map<String, dynamic> json) => BannerModels(
        content: json["content"] ?? "",
        enable: json["enable"] ?? false,
        imageUrl: json["image_url"] ?? "",
        sort: json["sort"] ?? 0,
        title: json["title"] ?? "",
        uuid: json["uuid"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "content": content,
        "enable": enable,
        "image_url": imageUrl,
        "sort": sort,
        "title": title,
        "uuid": uuid,
      };
} 