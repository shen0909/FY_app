import 'package:safe_app/models/risk_factor_new.dart';

/// 风险因素解析测试
class RiskFactorTest {
  
  /// 测试不同类型的风险因素数据解析
  static void testRiskFactorParsing() {
    print('=== 开始测试风险因素解析 ===');
    
    // 测试案例1：空字符串
    testCase1();
    
    // 测试案例2：空数组字符串
    testCase2();
    
    // 测试案例3：包含具体内容的数组
    testCase3();
    
    // 测试案例4：格式错误的JSON
    testCase4();
    
    // 测试案例5：null值
    testCase5();
    
    print('=== 风险因素解析测试完成 ===');
  }
  
  /// 测试案例1：空字符串
  static void testCase1() {
    print('\n--- 测试案例1：空字符串 ---');
    const String riskFactorString = "";
    
    final result = RiskFactorParser.parseRiskFactor(riskFactorString);
    print('输入: "$riskFactorString"');
    print('解析结果: ${result.length} 个风险因素');
    print('预期: 0 个风险因素');
    print('测试结果: ${result.length == 0 ? "通过" : "失败"}');
  }
  
  /// 测试案例2：空数组字符串
  static void testCase2() {
    print('\n--- 测试案例2：空数组字符串 ---');
    const String riskFactorString = "[]";
    
    final result = RiskFactorParser.parseRiskFactor(riskFactorString);
    print('输入: "$riskFactorString"');
    print('解析结果: ${result.length} 个风险因素');
    print('预期: 0 个风险因素');
    print('测试结果: ${result.length == 0 ? "通过" : "失败"}');
  }
  
  /// 测试案例3：包含具体内容的数组（华为的例子）
  static void testCase3() {
    print('\n--- 测试案例3：包含具体内容的数组 ---');
    const String riskFactorString = '''[{
      "factor_name":"技术依赖风险",
      "factor_item":[{
        "factor_item_name":"芯片设计工具依赖",
        "factor_item_content":"华为海思半导体依赖美国EDA(电子设计自动化)工具进行芯片设计，如CadenceSynopsys和Mentor Graphics等公司的软件。"
      },{
        "factor_item_name":"高端芯片制造依赖",
        "factor_item_content":"华为自研的麒麟芯片需要台积电等代工厂使用美国设备(如应用材料、科磊、泛林集团等公司的设备)进行生产。"
      }]
    }]''';
    
    final result = RiskFactorParser.parseRiskFactor(riskFactorString);
    print('输入: 华为风险因素数据');
    print('解析结果: ${result.length} 个风险因素');
    
    if (result.isNotEmpty) {
      final firstFactor = result.first;
      print('第一个风险因素名称: ${firstFactor.factorName}');
      print('第一个风险因素项目数量: ${firstFactor.factorItems.length}');
      
      if (firstFactor.factorItems.isNotEmpty) {
        final firstItem = firstFactor.factorItems.first;
        print('第一个项目名称: ${firstItem.factorItemName}');
        print('第一个项目内容长度: ${firstItem.factorItemContent.length} 字符');
      }
    }
    
    print('预期: 1 个风险因素，包含2个项目');
    print('测试结果: ${result.length == 1 && result.first.factorItems.length == 2 ? "通过" : "失败"}');
  }
  
  /// 测试案例4：格式错误的JSON
  static void testCase4() {
    print('\n--- 测试案例4：格式错误的JSON ---');
    const String riskFactorString = '[{"invalid": "json"}';
    
    final result = RiskFactorParser.parseRiskFactor(riskFactorString);
    print('输入: "$riskFactorString"');
    print('解析结果: ${result.length} 个风险因素');
    print('预期: 0 个风险因素（因为格式错误）');
    print('测试结果: ${result.length == 0 ? "通过" : "失败"}');
  }
  
  /// 测试案例5：null值
  static void testCase5() {
    print('\n--- 测试案例5：null值 ---');
    String? riskFactorString;
    
    final result = RiskFactorParser.parseRiskFactor(riskFactorString);
    print('输入: null');
    print('解析结果: ${result.length} 个风险因素');
    print('预期: 0 个风险因素');
    print('测试结果: ${result.length == 0 ? "通过" : "失败"}');
  }
  
  /// 示例：如何在实际应用中使用
  static void usageExample() {
    print('\n=== 使用示例 ===');
    
    // 模拟API返回的数据
    final Map<String, dynamic> apiResponse = {
      "uuid": "6aa6668c-e867-44da-ae55-7fd386686b43",
      "zh_name": "华为技术有限公司",
      "risk_factor": '''[{
        "factor_name":"技术依赖风险",
        "factor_item":[{
          "factor_item_name":"芯片设计工具依赖",
          "factor_item_content":"华为海思半导体依赖美国EDA工具进行芯片设计。"
        }]
      }]''',
      // 其他字段...
    };
    
    // 解析风险因素
    final riskFactors = RiskFactorParser.parseRiskFactor(apiResponse['risk_factor']);
    
    print('企业名称: ${apiResponse['zh_name']}');
    print('风险因素数量: ${riskFactors.length}');
    
    for (int i = 0; i < riskFactors.length; i++) {
      final factor = riskFactors[i];
      print('\n风险因素 ${i + 1}: ${factor.factorName}');
      
      for (int j = 0; j < factor.factorItems.length; j++) {
        final item = factor.factorItems[j];
        print('  项目 ${j + 1}: ${item.factorItemName}');
        print('  内容: ${item.factorItemContent}');
      }
    }
  }
}