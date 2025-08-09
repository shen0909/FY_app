import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:safe_app/models/news_detail_data.dart';
import 'package:safe_app/utils/toast_util.dart';
import 'package:safe_app/utils/datetime_utils.dart';
import 'package:safe_app/services/permission_service.dart';

/// DOCX文件导出工具类
/// 用于将舆情热点详情和事件动态导出为DOCX格式的文档
class DocxExportUtil {
  
  /// 导出舆情热点详情为DOCX文件
  /// 
  /// [newsDetail] 新闻详情数据
  /// [fileName] 可选的文件名，如果不提供将使用默认格式
  /// 
  /// 返回生成的文件路径，失败返回null
  static Future<String?> exportNewsDetailToDocx(
    NewsDetail newsDetail, {
    String? fileName,
  }) async {
    try {
      print('🚀 开始导出新闻详情DOCX文件...');
      
      // 请求存储权限
      final hasPermission = await PermissionService.requestStoragePermission(Get.context);
      if (!hasPermission) {
        print('❌ 权限被拒绝');
        ToastUtil.showShort('需要存储权限才能导出文件');
        return null;
      }
      
      print('✅ 权限获取成功');

      // 生成文件名
      final docFileName = fileName ?? '舆情热点详情_${_sanitizeFileName(newsDetail.newsTitle)}_${DateTime.now().millisecondsSinceEpoch}.docx';
      
      print('📄 文件名: $docFileName');

      // 创建DOCX文档内容
      final docxContent = _generateNewsDetailDocxContent(newsDetail);
      print('📝 文档内容生成完成，长度: ${docxContent.length}');
      
      // 生成DOCX文件
      final filePath = await _createDocxFile(docxContent, docFileName);
      
      if (filePath != null) {
        print('✅ 文件导出成功: $filePath');
        return filePath;
      } else {
        print('❌ 文件创建失败');
        ToastUtil.showShort('导出失败');
        return null;
      }
    } catch (e) {
      print('❌ 导出DOCX文件异常: $e');
      ToastUtil.showShort('导出失败: $e');
      return null;
    }
  }

  /// 导出事件动态列表为DOCX文件
  /// 
  /// [eventTitle] 事件标题
  /// [updates] 动态列表
  /// [selectedIndices] 选中的动态索引列表
  /// [fileName] 可选的文件名
  /// 
  /// 返回生成的文件路径，失败返回null
  static Future<String?> exportEventUpdatesToDocx(
    String eventTitle,
    List<Map<String, dynamic>> updates,
    List<int> selectedIndices, {
    String? fileName,
  }) async {
    try {
      print('🚀 开始导出事件动态DOCX文件...');
      
      // 请求存储权限
      final hasPermission = await PermissionService.requestStoragePermission(Get.context);
      if (!hasPermission) {
        print('❌ 权限被拒绝');
        ToastUtil.showShort('需要存储权限才能导出文件');
        return null;
      }
      
      print('✅ 权限获取成功');

      // 筛选选中的动态
      final selectedUpdates = selectedIndices
          .where((index) => index >= 0 && index < updates.length)
          .map((index) => updates[index])
          .toList();

      if (selectedUpdates.isEmpty) {
        print('❌ 没有选中的动态');
        ToastUtil.showShort('请选择要导出的动态');
        return null;
      }
      
      print('📋 选中动态数量: ${selectedUpdates.length}');

      // 生成文件名
      final docFileName = fileName ?? 
          '事件专题订阅_${_sanitizeFileName(eventTitle)}_${DateTime.now().millisecondsSinceEpoch}.docx';
      
      print('📄 文件名: $docFileName');

      // 创建DOCX文档内容
      final docxContent = _generateEventUpdatesDocxContent(eventTitle, selectedUpdates);
      print('📝 文档内容生成完成，长度: ${docxContent.length}');
      
      // 生成DOCX文件
      final filePath = await _createDocxFile(docxContent, docFileName);
      
      if (filePath != null) {
        print('✅ 文件导出成功: $filePath');
        return filePath;
      } else {
        print('❌ 文件创建失败');
        ToastUtil.showShort('导出失败');
        return null;
      }
    } catch (e) {
      print('❌ 导出DOCX文件异常: $e');
      ToastUtil.showShort('导出失败: $e');
      return null;
    }
  }

  /// 文件名安全化处理
  static String _sanitizeFileName(String fileName) {
    // 移除或替换不允许的字符
    return fileName
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .trim();
  }

  /// 生成新闻详情的DOCX文档内容
  static String _generateNewsDetailDocxContent(NewsDetail newsDetail) {
    final buffer = StringBuffer();

    // 文档标题
    buffer.writeln('舆情热点详情报告');
    buffer.writeln('=' * 40);
    buffer.writeln();

    // 基本信息
    buffer.writeln('基本信息');
    buffer.writeln('-' * 20);
    buffer.writeln('标题: ${newsDetail.newsTitle}');
    buffer.writeln('发布时间: ${newsDetail.publishTime}');
    buffer.writeln('新闻类型: ${newsDetail.newsType}');
    buffer.writeln('媒体来源: ${newsDetail.newsMedium}');
    buffer.writeln('涉及地区: ${newsDetail.region}');
    if (newsDetail.googleKeyword.isNotEmpty) {
      buffer.writeln('关键词: ${newsDetail.googleKeyword}');
    }
    buffer.writeln();

    // 新闻摘要
    if (newsDetail.newsSummary.isNotEmpty) {
      buffer.writeln('新闻摘要');
      buffer.writeln('-' * 20);
      buffer.writeln(newsDetail.newsSummary);
      buffer.writeln();
    }

    // 原文内容
    if (newsDetail.originContext.isNotEmpty) {
      buffer.writeln('原文内容');
      buffer.writeln('-' * 20);
      buffer.writeln(newsDetail.originContext);
      buffer.writeln();
    }

    // 译文内容
    if (newsDetail.translatedContext.isNotEmpty) {
      buffer.writeln('译文内容');
      buffer.writeln('-' * 20);
      buffer.writeln(newsDetail.translatedContext);
      buffer.writeln();
    }

    // 风险分析
    if (newsDetail.riskAnalysis.isNotEmpty) {
      buffer.writeln('风险分析');
      buffer.writeln('-' * 20);
      buffer.writeln(newsDetail.riskAnalysis);
      buffer.writeln();
    }

    // 影响评估
    buffer.writeln('影响评估');
    buffer.writeln('-' * 20);
    
    if (newsDetail.effect.directEffect.isNotEmpty) {
      buffer.writeln('直接影响:');
      for (final effect in newsDetail.effect.directEffect) {
        buffer.writeln('• $effect');
      }
      buffer.writeln();
    }
    
    if (newsDetail.effect.indirectEffect.isNotEmpty) {
      buffer.writeln('间接影响:');
      for (final effect in newsDetail.effect.indirectEffect) {
        buffer.writeln('• $effect');
      }
      buffer.writeln();
    }
    
    if (newsDetail.effect.effectCompany.isNotEmpty) {
      buffer.writeln('影响企业:');
      for (final company in newsDetail.effect.effectCompany) {
        buffer.writeln('• $company');
      }
      buffer.writeln();
    }

    // 决策建议
    buffer.writeln('决策建议');
    buffer.writeln('-' * 20);
    
    if (newsDetail.decisionSuggestion.overallStrategy.isNotEmpty) {
      buffer.writeln('整体策略:');
      buffer.writeln(newsDetail.decisionSuggestion.overallStrategy);
      buffer.writeln();
    }
    
    if (newsDetail.decisionSuggestion.shortTermMeasures.isNotEmpty) {
      buffer.writeln('短期措施:');
      for (final measure in newsDetail.decisionSuggestion.shortTermMeasures) {
        buffer.writeln('• $measure');
      }
      buffer.writeln();
    }
    
    if (newsDetail.decisionSuggestion.midTermMeasures.isNotEmpty) {
      buffer.writeln('中期措施:');
      for (final measure in newsDetail.decisionSuggestion.midTermMeasures) {
        buffer.writeln('• $measure');
      }
      buffer.writeln();
    }
    
    if (newsDetail.decisionSuggestion.longTermMeasures.isNotEmpty) {
      buffer.writeln('长期措施:');
      for (final measure in newsDetail.decisionSuggestion.longTermMeasures) {
        buffer.writeln('• $measure');
      }
      buffer.writeln();
    }

    // 风险应对措施
    if (newsDetail.riskMeasure.isNotEmpty) {
      buffer.writeln('风险应对措施');
      buffer.writeln('-' * 20);
      
      for (int i = 0; i < newsDetail.riskMeasure.length; i++) {
        final risk = newsDetail.riskMeasure[i];
        buffer.writeln('${i + 1}. 风险场景: ${risk.riskScenario}');
        buffer.writeln('   可能性: ${risk.possibility}');
        buffer.writeln('   影响程度: ${risk.impactLevel}');
        buffer.writeln('   应对措施: ${risk.countermeasures}');
        buffer.writeln();
      }
    }

    // 相关新闻
    if (newsDetail.relevantNews.isNotEmpty) {
      buffer.writeln('相关新闻');
      buffer.writeln('-' * 20);
      
      for (int i = 0; i < newsDetail.relevantNews.length; i++) {
        final news = newsDetail.relevantNews[i];
        buffer.writeln('${i + 1}. ${news.title}');
        buffer.writeln('   时间: ${news.time}');
        buffer.writeln();
      }
    }

    // 未来进展预测
    if (newsDetail.futureProgression.isNotEmpty) {
      buffer.writeln('未来进展预测');
      buffer.writeln('-' * 20);
      
      for (int i = 0; i < newsDetail.futureProgression.length; i++) {
        final progression = newsDetail.futureProgression[i];
        buffer.writeln('${i + 1}. ${progression.title}');
        buffer.writeln('   预计时间: ${progression.time}');
        buffer.writeln();
      }
    }

    // 原文链接
    if (newsDetail.newsSourceUrl.isNotEmpty) {
      buffer.writeln('原文链接');
      buffer.writeln('-' * 20);
      buffer.writeln(newsDetail.newsSourceUrl);
      buffer.writeln();
    }

    // 生成时间
    buffer.writeln('-' * 40);
    buffer.writeln('报告生成时间: ${DateTimeUtils.formatDetailTime(DateTime.now().toString())}');

    return buffer.toString();
  }

  /// 生成事件动态列表的DOCX文档内容
  static String _generateEventUpdatesDocxContent(
    String eventTitle,
    List<Map<String, dynamic>> updates,
  ) {
    final buffer = StringBuffer();

    // 文档标题
    buffer.writeln('事件/专题订阅报告');
    buffer.writeln('=' * 40);
    buffer.writeln();

    // 基本信息
    buffer.writeln('基本信息');
    buffer.writeln('-' * 20);
    buffer.writeln('事件/专题标题: $eventTitle');
    buffer.writeln('动态数量: ${updates.length}');
    buffer.writeln('导出时间: ${DateTimeUtils.formatDetailTime(DateTime.now().toString())}');
    buffer.writeln();

    // 动态列表
    buffer.writeln('最新动态');
    buffer.writeln('-' * 20);
    buffer.writeln();

    for (int i = 0; i < updates.length; i++) {
      final update = updates[i];
      buffer.writeln('${i + 1}. ${update['title'] ?? ''}');
      buffer.writeln('   发布时间: ${update['date'] ?? ''}');
      
      if (update['source'] != null && update['source'].toString().isNotEmpty) {
        buffer.writeln('   来源: ${update['source']}');
      }
      
      if (update['type'] != null && update['type'].toString().isNotEmpty) {
        buffer.writeln('   类型: ${update['type']}');
      }
      
      if (update['content'] != null && update['content'].toString().isNotEmpty) {
        buffer.writeln('   内容摘要:');
        buffer.writeln('   ${update['content']}');
      }
      
      buffer.writeln();
      buffer.writeln('   ' + '-' * 50);
      buffer.writeln();
    }

    // 统计信息
    buffer.writeln('统计信息');
    buffer.writeln('-' * 20);
    
    // 按来源统计
    final sourceCount = <String, int>{};
    for (final update in updates) {
      final source = update['source']?.toString() ?? '未知来源';
      sourceCount[source] = (sourceCount[source] ?? 0) + 1;
    }
    
    buffer.writeln('按来源统计:');
    sourceCount.forEach((source, count) {
      buffer.writeln('• $source: $count 条');
    });
    buffer.writeln();

    // 按类型统计
    final typeCount = <String, int>{};
    for (final update in updates) {
      final type = update['type']?.toString() ?? '未知类型';
      typeCount[type] = (typeCount[type] ?? 0) + 1;
    }
    
    buffer.writeln('按类型统计:');
    typeCount.forEach((type, count) {
      buffer.writeln('• $type: $count 条');
    });
    buffer.writeln();

    // 生成时间
    buffer.writeln('-' * 40);
    buffer.writeln('报告生成时间: ${DateTimeUtils.formatDetailTime(DateTime.now().toString())}');

    return buffer.toString();
  }

  /// 创建DOCX文件
  /// 
  /// [content] 文档内容
  /// [fileName] 文件名
  /// 
  /// 返回文件路径，失败返回null
  static Future<String?> _createDocxFile(String content, String fileName) async {
    try {
      print('📁 开始创建DOCX文件...');
      
      // 获取文件保存目录（参考AI问答页面的健壮实现）
      String? filePath;
      
      if (Platform.isAndroid) {
        // Android: 尝试多种保存路径
        try {
          // 方法1：尝试保存到外部存储的Downloads目录
          Directory? downloadsDir;
          
          if (await Permission.manageExternalStorage.isGranted) {
            downloadsDir = Directory('/storage/emulated/0/Download');
            if (!await downloadsDir.exists()) {
              downloadsDir = Directory('/storage/emulated/0/Downloads');
            }
          }
          
          // 方法2：如果上面失败，使用应用的外部存储目录
          if (downloadsDir == null || !await downloadsDir.exists()) {
            final externalDir = await getExternalStorageDirectory();
            if (externalDir != null) {
              downloadsDir = Directory('${externalDir.path}/Downloads');
              await downloadsDir.create(recursive: true);
            }
          }
          
          // 方法3：最后备选方案，使用应用文档目录
          if (downloadsDir == null || !await downloadsDir.exists()) {
            final appDocDir = await getApplicationDocumentsDirectory();
            downloadsDir = Directory('${appDocDir.path}/导出文件');
            await downloadsDir.create(recursive: true);
          }
          
          filePath = '${downloadsDir.path}/$fileName';
          print('📂 Android文件路径: $filePath');
          
        } catch (e) {
          print('❌ Android路径获取失败: $e');
          // 备选方案：保存到应用文档目录
          final appDocDir = await getApplicationDocumentsDirectory();
          final exportDir = Directory('${appDocDir.path}/导出文件');
          await exportDir.create(recursive: true);
          filePath = '${exportDir.path}/$fileName';
          print('📂 备选文件路径: $filePath');
        }
      } else {
        // iOS: 使用文档目录
        final directory = await getApplicationDocumentsDirectory();
        final exportDir = Directory('${directory.path}/导出文件');
        await exportDir.create(recursive: true);
        filePath = '${exportDir.path}/$fileName';
        print('📂 iOS文件路径: $filePath');
      }

      if (filePath == null) {
        print('❌ 无法确定文件保存路径');
        return null;
      }

      print('🏗️ 开始构建DOCX文档结构...');
      
      // 创建DOCX文档的基本结构
      final archive = Archive();

      // 1. [Content_Types].xml
      final contentTypesXml = _createContentTypesXml();
      archive.addFile(ArchiveFile('[Content_Types].xml', contentTypesXml.length, contentTypesXml));

      // 2. _rels/.rels
      final relsXml = _createRelsXml();
      archive.addFile(ArchiveFile('_rels/.rels', relsXml.length, relsXml));

      // 3. word/_rels/document.xml.rels
      final docRelsXml = _createDocumentRelsXml();
      archive.addFile(ArchiveFile('word/_rels/document.xml.rels', docRelsXml.length, docRelsXml));

      // 4. word/document.xml (主要内容)
      final documentXml = _createDocumentXml(content);
      archive.addFile(ArchiveFile('word/document.xml', documentXml.length, documentXml));

      // 5. word/styles.xml
      final stylesXml = _createStylesXml();
      archive.addFile(ArchiveFile('word/styles.xml', stylesXml.length, stylesXml));

      // 6. docProps/app.xml
      final appXml = _createAppXml();
      archive.addFile(ArchiveFile('docProps/app.xml', appXml.length, appXml));

      // 7. docProps/core.xml
      final coreXml = _createCoreXml();
      archive.addFile(ArchiveFile('docProps/core.xml', coreXml.length, coreXml));

      print('📦 生成ZIP压缩文件...');
      
      // 生成ZIP文件（DOCX格式）
      final zipData = ZipEncoder().encode(archive);
      if (zipData == null) {
        print('❌ ZIP压缩失败');
        return null;
      }

      print('💾 写入文件...');
      
      // 写入文件
      final file = File(filePath);
      await file.writeAsBytes(zipData);

      // 如果落在应用私有外部目录，则复制到公共Downloads（Android 10+ 推荐方式）
      if (Platform.isAndroid && file.path.contains('/Android/data/')) {
        try {
          const channel = MethodChannel('com.example.safe_app/media');
          final publicPath = await channel.invokeMethod<String>('saveToDownloads', {
            'path': file.path,
            'fileName': fileName,
          });
          if (publicPath != null && publicPath.isNotEmpty) {
            print('✅ 已复制到公共Downloads: $publicPath');
            return publicPath; // 直接返回公共路径
          }
        } catch (e) {
          print('⚠️ 复制到公共Downloads失败: $e');
        }
      }

      // Android: 主动通知媒体库刷新
      if (Platform.isAndroid) {
        try {
          const channel = MethodChannel('com.example.safe_app/media');
          await channel.invokeMethod('scanFile', {'path': file.path});
        } catch (e) {
          print('⚠️ 媒体库扫描调用失败: $e');
        }
      }
      
      // 验证文件是否成功创建
      if (await file.exists()) {
        final fileSize = await file.length();
        print('✅ 文件创建成功，大小: ${fileSize}字节');
        return filePath;
      } else {
        print('❌ 文件创建失败，文件不存在');
        return null;
      }

    } catch (e) {
      print('❌ 创建DOCX文件异常: $e');
      return null;
    }
  }

  /// 创建Content_Types.xml
  static Uint8List _createContentTypesXml() {
    const xml = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
  <Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>
  <Override PartName="/docProps/app.xml" ContentType="application/vnd.openxmlformats-officedocument.extended-properties+xml"/>
  <Override PartName="/docProps/core.xml" ContentType="application/vnd.openxmlformats-package.core-properties+xml"/>
</Types>''';
    return utf8.encode(xml);
  }

  /// 创建_rels/.rels
  static Uint8List _createRelsXml() {
    const xml = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
  <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties" Target="docProps/core.xml"/>
  <Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties" Target="docProps/app.xml"/>
</Relationships>''';
    return utf8.encode(xml);
  }

  /// 创建word/_rels/document.xml.rels
  static Uint8List _createDocumentRelsXml() {
    const xml = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
</Relationships>''';
    return utf8.encode(xml);
  }

  /// 创建word/document.xml
  static Uint8List _createDocumentXml(String content) {
    // 转义XML特殊字符
    final escapedContent = _escapeXml(content);
    
    // 将内容分段处理
    final paragraphs = escapedContent.split('\n');
    final paragraphsXml = paragraphs.map((para) {
      if (para.trim().isEmpty) {
        return '<w:p><w:r><w:t></w:t></w:r></w:p>';
      }
      return '<w:p><w:r><w:t>$para</w:t></w:r></w:p>';
    }).join('\n    ');

    final xml = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:body>
    $paragraphsXml
  </w:body>
</w:document>''';
    return utf8.encode(xml);
  }

  /// 创建word/styles.xml
  static Uint8List _createStylesXml() {
    const xml = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:docDefaults>
    <w:rPrDefault>
      <w:rPr>
        <w:rFonts w:ascii="Times New Roman" w:eastAsia="宋体" w:hAnsi="Times New Roman"/>
        <w:sz w:val="24"/>
        <w:szCs w:val="24"/>
        <w:lang w:val="en-US" w:eastAsia="zh-CN" w:bidi="ar-SA"/>
      </w:rPr>
    </w:rPrDefault>
  </w:docDefaults>
</w:styles>''';
    return utf8.encode(xml);
  }

  /// 创建docProps/app.xml
  static Uint8List _createAppXml() {
    const xml = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Properties xmlns="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties">
  <Application>Safe App</Application>
  <DocSecurity>0</DocSecurity>
  <Lines>1</Lines>
  <Paragraphs>1</Paragraphs>
  <ScaleCrop>false</ScaleCrop>
  <LinksUpToDate>false</LinksUpToDate>
  <SharedDoc>false</SharedDoc>
  <HyperlinksChanged>false</HyperlinksChanged>
  <AppVersion>1.0</AppVersion>
</Properties>''';
    return utf8.encode(xml);
  }

  /// 创建docProps/core.xml
  static Uint8List _createCoreXml() {
    final now = DateTime.now().toIso8601String();
    final xml = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:dcmitype="http://purl.org/dc/dcmitype/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <dc:title>舆情报告</dc:title>
  <dc:creator>Safe App</dc:creator>
  <cp:lastModifiedBy>Safe App</cp:lastModifiedBy>
  <cp:revision>1</cp:revision>
  <dcterms:created xsi:type="dcterms:W3CDTF">$now</dcterms:created>
  <dcterms:modified xsi:type="dcterms:W3CDTF">$now</dcterms:modified>
</cp:coreProperties>''';
    return utf8.encode(xml);
  }

  /// 转义XML特殊字符
  static String _escapeXml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }
}