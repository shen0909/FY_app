import 'dart:convert';

/// 基础分数据模型（对应接口的 base_score）
class BaseScore {
  final String entUuid;
  final int internalScore;
  final int operationScore;
  final int outsideScore;
  final String scoreDetails;
  final int secureScore;

  BaseScore({
    required this.entUuid,
    required this.internalScore,
    required this.operationScore,
    required this.outsideScore,
    required this.scoreDetails,
    required this.secureScore,
  });

  factory BaseScore.fromJson(Map<String, dynamic> json) {
    return BaseScore(
      entUuid: json['ent_uuid'] ?? '',
      internalScore: json['internal_score'] ?? 0,
      operationScore: json['operation_score'] ?? 0,
      outsideScore: json['outside_score'] ?? 0,
      scoreDetails: json['score_details'] ?? '{}',
      secureScore: json['secure_score'] ?? 0,
    );
  }
}

/// 新闻分数据模型（对应接口的 news_score）
class NewsScore {
  final Map<String, int> scores;

  NewsScore({required this.scores});

  factory NewsScore.fromJson(Map<String, dynamic> json) {
    Map<String, int> scores = {};
    json.forEach((key, value) {
      if (value is int) {
        scores[key] = value;
      }
    });
    return NewsScore(scores: scores);
  }
}

/// 评分总模型
class ScoreModel {
  final BaseScore? baseScore;
  final NewsScore? newsScore;

  ScoreModel({
    required this.baseScore,
    required this.newsScore,
  });

  factory ScoreModel.fromJson(Map<String, dynamic> json) {
    return ScoreModel(
      baseScore: json['base_score'] != null 
        ? BaseScore.fromJson(json['base_score']) 
        : null,
      newsScore: json['news_score'] != null && (json['news_score'] as Map).isNotEmpty
        ? NewsScore.fromJson(json['news_score']) 
        : null,
    );
  }
}

/// 企业评分详情数据模型（用于UI展示）
class EnterpriseScoreDetail {
  final Map<String, ScoreItem> externalScores; // 外部评分
  final Map<String, ScoreItem> internalScores; // 内部评分  
  final Map<String, ScoreItem> otherScores;    // 其他评分
  final int totalScore;                        // 总分

  EnterpriseScoreDetail({
    required this.externalScores,
    required this.internalScores,
    required this.otherScores,
    required this.totalScore,
  });

  /// 从接口数据创建评分详情
  factory EnterpriseScoreDetail.fromApiData(Map<String, dynamic> apiData) {
    // 解析成ScoreModel
    final scoreModel = ScoreModel.fromJson(apiData);
    
    // 初始化所有评分类型的默认值
    Map<String, ScoreItem> externalScores = _initializeExternalScores();
    Map<String, ScoreItem> internalScores = _initializeInternalScores();
    Map<String, ScoreItem> otherScores = _initializeOtherScores();

    // 处理基础分
    if (scoreModel.baseScore != null) {
      _processBaseScore(scoreModel.baseScore!, externalScores, internalScores, otherScores);
    }

    // 处理新闻分（只会出现在外部评分中）
    if (scoreModel.newsScore != null) {
      _processNewsScore(scoreModel.newsScore!, externalScores);
    }

    // 计算总分 = 所有基础分 + 所有新闻分
    int totalScore = 0;
    for (var item in externalScores.values) {
      totalScore += item.totalScore;
    }
    for (var item in internalScores.values) {
      totalScore += item.totalScore;
    }
    for (var item in otherScores.values) {
      totalScore += item.totalScore;
    }

    return EnterpriseScoreDetail(
      externalScores: externalScores,
      internalScores: internalScores,
      otherScores: otherScores,
      totalScore: totalScore,
    );
  }

  /// 处理基础分数据
  static void _processBaseScore(
    BaseScore baseScore,
    Map<String, ScoreItem> externalScores,
    Map<String, ScoreItem> internalScores,
    Map<String, ScoreItem> otherScores,
  ) {
    try {
      // 解析 score_details JSON字符串
      final details = json.decode(baseScore.scoreDetails) as Map<String, dynamic>;
      
      details.forEach((key, value) {
        final score = value as int? ?? 0;
        
        if (externalScores.containsKey(key)) {
          // 外部评分类型
          externalScores[key] = externalScores[key]!.copyWith(baseScore: score);
        } else if (internalScores.containsKey(key)) {
          // 内部评分类型
          internalScores[key] = internalScores[key]!.copyWith(baseScore: score);
        }
      });
      
      // 处理其他评分（运营分数和安全分数）
      otherScores['运营分数'] = otherScores['运营分数']!.copyWith(baseScore: baseScore.operationScore);
      otherScores['安全分数'] = otherScores['安全分数']!.copyWith(baseScore: baseScore.secureScore);
      
    } catch (e) {
      print('解析 score_details 失败: $e');
    }
  }

  /// 处理新闻分数据（只会出现在外部评分中）
  static void _processNewsScore(
    NewsScore newsScore,
    Map<String, ScoreItem> externalScores,
  ) {
    newsScore.scores.forEach((key, score) {
      if (externalScores.containsKey(key)) {
        externalScores[key] = externalScores[key]!.copyWith(newsScore: score);
      }
    });
  }

  /// 初始化外部评分类型
  static Map<String, ScoreItem> _initializeExternalScores() {
    const externalTypes = [
      "宣布调查", "实施调查", "人员打入", "人员拉出", "技术攻击",
      "实施制裁", "司法诉讼", "攻击抹黑", "脱钩断链", "外资渗透"
    ];
    
    return Map.fromEntries(
      externalTypes.map((type) => MapEntry(type, ScoreItem(name: type))),
    );
  }

  /// 初始化内部评分类型
  static Map<String, ScoreItem> _initializeInternalScores() {
    const internalTypes = [
      "失密泄密", "人员失管", "网络失管", "场所失管", "信息失管",
      "员工举报", "技术外流", "负面舆情", "制度缺失", "合规经营"
    ];
    
    return Map.fromEntries(
      internalTypes.map((type) => MapEntry(type, ScoreItem(name: type))),
    );
  }

  /// 初始化其他评分类型
  static Map<String, ScoreItem> _initializeOtherScores() {
    const otherTypes = ["运营分数", "安全分数"];
    
    return Map.fromEntries(
      otherTypes.map((type) => MapEntry(type, ScoreItem(name: type))),
    );
  }

  /// 获取外部评分总分
  int get externalTotalScore {
    return externalScores.values.fold(0, (sum, item) => sum + item.totalScore);
  }

  /// 获取内部评分总分
  int get internalTotalScore {
    return internalScores.values.fold(0, (sum, item) => sum + item.totalScore);
  }

  /// 获取其他评分总分
  int get otherTotalScore {
    return otherScores.values.fold(0, (sum, item) => sum + item.totalScore);
  }
}

/// 单个评分项
class ScoreItem {
  final String name;      // 评分项名称
  final int baseScore;    // 基础分
  final int newsScore;    // 新闻分

  ScoreItem({
    required this.name,
    this.baseScore = 0,
    this.newsScore = 0,
  });

  /// 获取该项的总分（基础分 + 新闻分）
  int get totalScore => baseScore + newsScore;

  /// 复制并修改字段
  ScoreItem copyWith({
    String? name,
    int? baseScore,
    int? newsScore,
  }) {
    return ScoreItem(
      name: name ?? this.name,
      baseScore: baseScore ?? this.baseScore,
      newsScore: newsScore ?? this.newsScore,
    );
  }

  @override
  String toString() {
    return 'ScoreItem(name: $name, baseScore: $baseScore, newsScore: $newsScore, totalScore: $totalScore)';
  }
}