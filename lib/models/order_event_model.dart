// 我的订阅-事件模型
class OrderEventModels {
  final String uuid;
  final String name;
  final String description;
  final List<String> keyword;
  final String createdAt;
  final String updatedAt;
  final int relateNewsCount;
  final int readingCount;
  final int followerCount;

  OrderEventModels({
    required this.uuid,
    required this.name,
    required this.description,
    required this.keyword,
    required this.createdAt,
    required this.updatedAt,
    required this.relateNewsCount,
    required this.readingCount,
    required this.followerCount,
  });

  factory OrderEventModels.fromJson(Map<String, dynamic> json) {
    final String keywordString = json['keyword'] as String;
    final List<String> keywordList = keywordString
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return OrderEventModels(
      uuid: json['uuid'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      keyword: keywordList,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      relateNewsCount: json['relate_news_count'] as int,
      readingCount: json['reading_count'] as int,
      followerCount: json['follower_count'] as int,
    );
  }

  // Optional: If you need to convert your Event object back to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'name': name,
      'description': description,
      'keyword': keyword.join(','),
      'created_at': createdAt,
      'updated_at': updatedAt,
      'relate_news_count': relateNewsCount,
      'reading_count': readingCount,
      'follower_count': followerCount,
    };
  }

  @override
  String toString() {
    return 'Event(uuid: $uuid, name: $name, description: $description, keyword: $keyword, '
        'createdAt: $createdAt, updatedAt: $updatedAt, relateNewsCount: $relateNewsCount, '
        'readingCount: $readingCount, followerCount: $followerCount)';
  }
}