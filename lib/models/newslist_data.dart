class NewsItem {
  final String newsId;
  final String newsTitle;
  final String newsType;
  final String newsMedium;
  final String googleKeyword;
  final String publishTime;
  final String newsSummary;
  final String? newsSourceUrl;
  final String? region;
  final bool isRead;        // 是否已读
  final bool isHot;         // 是否为热点新闻

  NewsItem({
    required this.newsId,
    required this.newsTitle,
    required this.newsType,
    required this.newsMedium,
    required this.googleKeyword,
    required this.publishTime,
    required this.newsSummary,
    this.newsSourceUrl,
    this.region,
    this.isRead = false,
    this.isHot = false,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      newsId: json['news_id'] ?? '',
      newsTitle: json['news_title'] ?? '',
      newsType: json['news_type'] ?? '',
      newsMedium: json['news_medium'] ?? '',
      googleKeyword: json['google_keyword'] ?? '',
      publishTime: json['publish_time'] ?? '',
      newsSummary: json['news_summary'] ?? '',
      newsSourceUrl: json['news_source_url'],
      region: json['region'],
      isRead: json['is_read'] ?? false,
      isHot: json['is_hot'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'news_id': newsId,
      'news_title': newsTitle,
      'news_type': newsType,
      'news_medium': newsMedium,
      'google_keyword': googleKeyword,
      'publish_time': publishTime,
      'news_summary': newsSummary,
      'news_source_url': newsSourceUrl ?? '',
      'region': region ?? '',
      'is_read': isRead,
      'is_hot': isHot,
    };
  }
}