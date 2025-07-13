import 'dart:convert';

class NewsDetail {
  final String newsId;
  final String newsTitle;
  final String newsType;
  final String newsMedium;
  final String googleKeyword;
  final String publishTime;
  final String newsSummary;
  final String region;
  final String riskAnalysis;
  final Effect effect;
  final List<RelevantNews> relevantNews;
  final List<FutureProgression> futureProgression;
  final DecisionSuggestion decisionSuggestion;
  final List<RiskMeasure> riskMeasure;
  final String originContext;
  final String translatedContext;
  final String newsSourceUrl;

  NewsDetail({
    required this.newsId,
    required this.newsTitle,
    required this.newsType,
    required this.newsMedium,
    required this.googleKeyword,
    required this.publishTime,
    required this.newsSummary,
    required this.region,
    required this.riskAnalysis,
    required this.effect,
    required this.relevantNews,
    required this.futureProgression,
    required this.decisionSuggestion,
    required this.riskMeasure,
    required this.originContext,
    required this.translatedContext,
    required this.newsSourceUrl,
  });

  factory NewsDetail.fromJson(Map<String, dynamic> json) {
    Effect effectObj;
    if (json['effect'] is Map) {
      effectObj = Effect.fromJson(json['effect']);
    } else if (json['effect'] is String && json['effect'].isNotEmpty) {
      try {
        // 尝试解析JSON字符串
        Map<String, dynamic> effectMap = jsonDecode(json['effect']);
        effectObj = Effect.fromJson(effectMap);
      } catch (e) {
        effectObj = Effect(
          directEffect: [],
          indirectEffect: [],
          effectCompany: [],
        );
      }
    } else {
      effectObj = Effect(
        directEffect: [],
        indirectEffect: [],
        effectCompany: [],
      );
    }

    List<RelevantNews> relevantNewsList = [];
    if (json['relevant_news'] is List) {
      relevantNewsList = (json['relevant_news'] as List)
          .map((e) => RelevantNews.fromJson(e))
          .toList();
    } else if (json['relevant_news'] is String && json['relevant_news'].isNotEmpty) {
      try {
        // 尝试解析JSON字符串
        List<dynamic> relevantNewsData = jsonDecode(json['relevant_news']);
        relevantNewsList = relevantNewsData
            .map((e) => RelevantNews.fromJson(e))
            .toList();
      } catch (e) {
        relevantNewsList = [];
      }
    }

    // 安全地处理future_progression字段
    List<FutureProgression> futureProgressionList = [];
    if (json['future_progression'] is List) {
      futureProgressionList = (json['future_progression'] as List)
          .map((e) => FutureProgression.fromJson(e))
          .toList();
    } else if (json['future_progression'] is String && json['future_progression'].isNotEmpty) {
      try {
        // 尝试解析JSON字符串
        List<dynamic> futureProgressionData = jsonDecode(json['future_progression']);
        futureProgressionList = futureProgressionData
            .map((e) => FutureProgression.fromJson(e))
            .toList();
      } catch (e) {
        // 解析失败，使用空列表
        futureProgressionList = [];
      }
    }

    // 安全地处理decision_suggestion字段，新接口可能返回JSON字符串
    DecisionSuggestion decisionSuggestionObj;
    if (json['decision_suggestion'] is Map) {
      decisionSuggestionObj = DecisionSuggestion.fromJson(json['decision_suggestion']);
    } else if (json['decision_suggestion'] is String && json['decision_suggestion'].isNotEmpty) {
      try {
        Map<String, dynamic> suggestionMap = jsonDecode(json['decision_suggestion']);
        decisionSuggestionObj = DecisionSuggestion.fromJson(suggestionMap);
      } catch (e) {
        // 如果解析失败，把整个字符串作为整体策略
        decisionSuggestionObj = DecisionSuggestion(
          overallStrategy: json['decision_suggestion'],
          shortTermMeasures: [],
          midTermMeasures: [],
          longTermMeasures: [],
        );
      }
    } else {
      decisionSuggestionObj = DecisionSuggestion(
        overallStrategy: '',
        shortTermMeasures: [],
        midTermMeasures: [],
        longTermMeasures: [],
      );
    }

    List<RiskMeasure> riskMeasureList = [];
    if (json['risk_measure'] is List) {
      riskMeasureList = (json['risk_measure'] as List)
          .map((e) => RiskMeasure.fromJson(e))
          .toList();
    } else if (json['risk_measure'] is String && json['risk_measure'].isNotEmpty) {
      try {
        // 尝试解析JSON字符串
        List<dynamic> riskMeasureData = jsonDecode(json['risk_measure']);
        riskMeasureList = riskMeasureData
            .map((e) => RiskMeasure.fromJson(e))
            .toList();
      } catch (e) {
        // 解析失败，使用空列表
        riskMeasureList = [];
      }
    }

    return NewsDetail(
      newsId: json['news_id']?.toString() ?? '',
      newsTitle: json['news_title']?.toString() ?? '',
      newsType: json['news_type']?.toString() ?? '',
      newsMedium: json['news_medium']?.toString() ?? '',
      googleKeyword: json['google_keyword']?.toString() ?? '',
      publishTime: json['publish_time']?.toString() ?? '',
      newsSummary: json['news_summary']?.toString() ?? '',
      region: json['region']?.toString() ?? '',
      riskAnalysis: json['risk_analysis']?.toString() ?? '',
      effect: effectObj,
      relevantNews: relevantNewsList,
      futureProgression: futureProgressionList,
      decisionSuggestion: decisionSuggestionObj,
      riskMeasure: riskMeasureList,
      originContext: json['origin_context']?.toString() ?? '',
      translatedContext: json['translated_context']?.toString() ?? '',
      newsSourceUrl: json['news_source_url']?.toString() ?? '',
    );
  }
}

class Effect {
  final List<String> directEffect;
  final List<String> indirectEffect;
  final List<String> effectCompany;

  Effect({
    required this.directEffect,
    required this.indirectEffect,
    required this.effectCompany,
  });

  factory Effect.fromJson(Map<String, dynamic> json) {
    // 安全处理数组字段，确保它们不为null
    return Effect(
      directEffect: (json['direct_effect'] is List)
          ? (json['direct_effect'] as List).map((e) => e.toString()).toList()
          : [],
      indirectEffect: (json['indirect_effect'] is List)
          ? (json['indirect_effect'] as List).map((e) => e.toString()).toList()
          : [],
      effectCompany: (json['effect_company'] is List)
          ? (json['effect_company'] as List).map((e) => e.toString()).toList()
          : [],
    );
  }
}

class RelevantNews {
  final String id;
  final String title;
  final String time;

  RelevantNews({
    required this.id,
    required this.title,
    required this.time,
  });

  factory RelevantNews.fromJson(Map<String, dynamic> json) {
    return RelevantNews(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
    );
  }
}

class FutureProgression {
  final String title;
  final String time;

  FutureProgression({
    required this.title,
    required this.time,
  });

  factory FutureProgression.fromJson(Map<String, dynamic> json) {
    return FutureProgression(
      title: json['title']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
    );
  }
}

/// 决策建议
class DecisionSuggestion {
  final String overallStrategy;
  final List<String> shortTermMeasures; // 修改为 List<String>
  final List<String> midTermMeasures;    // 修改为 List<String>
  final List<String> longTermMeasures;   // 修改为 List<String>

  DecisionSuggestion({
    required this.overallStrategy,
    required this.shortTermMeasures,
    required this.midTermMeasures,
    required this.longTermMeasures,
  });

  factory DecisionSuggestion.fromJson(Map<String, dynamic> json) {
    String overallStrategy = json['overall_strategy']?.toString() ?? '';
    List<String> shortTermMeasures = [];
    List<String> midTermMeasures = [];
    List<String> longTermMeasures = [];

    // 处理措施字段，使其能正确解析为 List<String>
    if (json['short_term_measures'] is List) {
      shortTermMeasures = (json['short_term_measures'] as List)
          .map((e) => e.toString())
          .toList();
    } else if (json['short_term_measures'] is String && (json['short_term_measures'] as String).isNotEmpty) {
      // 如果是字符串，尝试按换行符分割
      shortTermMeasures = (json['short_term_measures'] as String).split('\n').where((s) => s.isNotEmpty).toList();
    }

    if (json['mid_term_measures'] is List) {
      midTermMeasures = (json['mid_term_measures'] as List)
          .map((e) => e.toString())
          .toList();
    } else if (json['mid_term_measures'] is String && (json['mid_term_measures'] as String).isNotEmpty) {
      midTermMeasures = (json['mid_term_measures'] as String).split('\n').where((s) => s.isNotEmpty).toList();
    }

    if (json['long_term_measures'] is List) {
      longTermMeasures = (json['long_term_measures'] as List)
          .map((e) => e.toString())
          .toList();
    } else if (json['long_term_measures'] is String && (json['long_term_measures'] as String).isNotEmpty) {
      longTermMeasures = (json['long_term_measures'] as String).split('\n').where((s) => s.isNotEmpty).toList();
    }

    return DecisionSuggestion(
      overallStrategy: overallStrategy,
      shortTermMeasures: shortTermMeasures,
      midTermMeasures: midTermMeasures,
      longTermMeasures: longTermMeasures,
    );
  }
}

class RiskMeasure {
  final String riskScenario;  // 风险场景
  final String possibility;   // 可能性
  final String impactLevel;   // 影响程度
  final String countermeasures; // 应对措施

  RiskMeasure({
    required this.riskScenario,
    required this.possibility,
    required this.impactLevel,
    required this.countermeasures,
  });

  factory RiskMeasure.fromJson(Map<String, dynamic> json) {
    return RiskMeasure(
      riskScenario: json['风险场景']?.toString() ?? '',
      possibility: json['可能性']?.toString() ?? '',
      impactLevel: json['影响程度']?.toString() ?? '',
      countermeasures: json['应对措施']?.toString() ?? '',
    );
  }
} 