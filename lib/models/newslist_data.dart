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
      if (newsSourceUrl != null) 'news_source_url': newsSourceUrl,
      if (region != null) 'region': region,
    };
  }
}