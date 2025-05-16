#!/bin/bash

# 设置语言环境以支持UTF-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# 定义颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 项目根目录
PROJECT_ROOT=$(pwd)
# 资源目录
ASSETS_DIR="$PROJECT_ROOT/assets/images"
# 临时解压目录
TEMP_DIR="$PROJECT_ROOT/temp_mastergo"
# 图片资源类文件路径
IMAGE_RESOURCE_FILE="$PROJECT_ROOT/lib/styles/image_resource.dart"
# 生成drawable资源目录
DRAWABLE_DIR="$PROJECT_ROOT/lib/widgets/drawable"

# 检查参数
if [ $# -eq 0 ]; then
    echo -e "${RED}错误: 请提供MasterGo导出的zip文件路径${NC}"
    echo "用法: $0 <zip文件路径> [目标图片名称]"
    echo "示例: $0 ./icons.zip icon_home"
    exit 1
fi

ZIP_FILE=$1
# 目标文件名（如果提供）
TARGET_NAME=""
if [ $# -ge 2 ]; then
    TARGET_NAME=$2
    echo -e "${YELLOW}将使用 '$TARGET_NAME' 作为所有图片的基础名称${NC}"
fi

# 检查zip文件是否存在
if [ ! -f "$ZIP_FILE" ]; then
    echo -e "${RED}错误: 文件 '$ZIP_FILE' 不存在${NC}"
    exit 1
fi

# 检查是否为zip文件
if [[ "$ZIP_FILE" != *.zip ]]; then
    echo -e "${RED}错误: 文件 '$ZIP_FILE' 不是一个zip文件${NC}"
    exit 1
fi

# 清理旧的临时目录（如果存在）
if [ -d "$TEMP_DIR" ]; then
    echo -e "${YELLOW}清理旧的临时目录...${NC}"
    rm -rf "$TEMP_DIR"
fi

# 创建临时目录
echo -e "${YELLOW}创建临时目录...${NC}"
mkdir -p "$TEMP_DIR"

# 解压文件
echo -e "${YELLOW}解压文件...${NC}"
unzip -q -O UTF-8 "$ZIP_FILE" -d "$TEMP_DIR" || {
    echo -e "${RED}解压文件失败，尝试使用其他方式解压...${NC}"
    # 如果unzip失败，尝试使用ditto（macOS专用）
    if command -v ditto >/dev/null 2>&1; then
        ditto -x -k "$ZIP_FILE" "$TEMP_DIR" || {
            echo -e "${RED}解压失败，请检查zip文件是否有效${NC}"
            exit 1
        }
    else
        echo -e "${RED}解压失败，请检查zip文件是否有效${NC}"
        exit 1
    fi
}

# 确保assets目录存在
mkdir -p "$ASSETS_DIR"
mkdir -p "$ASSETS_DIR/2.0x"
mkdir -p "$ASSETS_DIR/3.0x"

# 检查MasterGo导出是否包含XML资源定义
XML_FILES=$(find "$TEMP_DIR" -type f -name "*.xml" | wc -l)
if [ $XML_FILES -gt 0 ]; then
    echo -e "${YELLOW}检测到XML资源文件，将生成Flutter drawable资源...${NC}"
    mkdir -p "$DRAWABLE_DIR"
fi

# 处理图片文件
echo -e "${YELLOW}处理图片文件...${NC}"

# 获取图片文件扩展名（取第一个图片文件的扩展名）
IMAGE_EXT=""
FIRST_IMAGE=$(find "$TEMP_DIR" -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.gif" -o -name "*.webp" \) | head -n 1)
if [ -n "$FIRST_IMAGE" ]; then
    IMAGE_EXT=".${FIRST_IMAGE##*.}"
    echo -e "${YELLOW}检测到图片扩展名: $IMAGE_EXT${NC}"
fi

# 计数器
REGULAR_COUNT=0
X2_COUNT=0
X3_COUNT=0
ERROR_COUNT=0

# 显示找到的文件
echo -e "${YELLOW}找到以下图片文件:${NC}"
find "$TEMP_DIR" -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.gif" -o -name "*.webp" \) | while read file; do
    echo "  - $file"
done

# 处理方法1：根据目录结构判断
echo -e "${YELLOW}根据目录结构进行处理...${NC}"

# 处理1.0x（或基础）目录中的图片
if [ -d "$TEMP_DIR/1.0x" ]; then
    echo -e "${YELLOW}处理1.0x目录中的图片...${NC}"
    find "$TEMP_DIR/1.0x" -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.gif" -o -name "*.webp" \) | while read file; do
        filename=$(basename "$file")
        # 设置目标文件名
        if [ -n "$TARGET_NAME" ]; then
            # 如果提供了目标名称，使用目标名称加上原文件扩展名
            file_ext=".${filename##*.}"
            new_filename="${TARGET_NAME}${file_ext}"
        else
            # 否则仅移除可能存在的@1x标记
            new_filename=$(echo "$filename" | sed 's/@1x//')
        fi
        echo -e "${YELLOW}尝试复制: $file -> $ASSETS_DIR/$new_filename${NC}"
        
        if cp "$file" "$ASSETS_DIR/$new_filename"; then
            REGULAR_COUNT=$((REGULAR_COUNT + 1))
            echo -e "${GREEN}成功复制: $filename -> images/$new_filename${NC}"
        else
            ERROR_COUNT=$((ERROR_COUNT + 1))
            echo -e "${RED}复制失败: $filename${NC}"
        fi
    done
fi

# 处理2.0x目录中的图片
if [ -d "$TEMP_DIR/2.0x" ]; then
    echo -e "${YELLOW}处理2.0x目录中的图片...${NC}"
    find "$TEMP_DIR/2.0x" -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.gif" -o -name "*.webp" \) | while read file; do
        filename=$(basename "$file")
        # 设置目标文件名
        if [ -n "$TARGET_NAME" ]; then
            # 如果提供了目标名称，使用目标名称加上原文件扩展名
            file_ext=".${filename##*.}"
            new_filename="${TARGET_NAME}${file_ext}"
        else
            # 否则仅移除可能存在的@2x标记
            new_filename=$(echo "$filename" | sed 's/@2x//')
        fi
        echo -e "${YELLOW}尝试复制: $file -> $ASSETS_DIR/2.0x/$new_filename${NC}"
        
        if cp "$file" "$ASSETS_DIR/2.0x/$new_filename"; then
            X2_COUNT=$((X2_COUNT + 1))
            echo -e "${GREEN}成功复制: $filename -> 2.0x/$new_filename${NC}"
        else
            ERROR_COUNT=$((ERROR_COUNT + 1))
            echo -e "${RED}复制失败: $filename${NC}"
        fi
    done
fi

# 处理3.0x目录中的图片
if [ -d "$TEMP_DIR/3.0x" ]; then
    echo -e "${YELLOW}处理3.0x目录中的图片...${NC}"
    find "$TEMP_DIR/3.0x" -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.gif" -o -name "*.webp" \) | while read file; do
        filename=$(basename "$file")
        # 设置目标文件名
        if [ -n "$TARGET_NAME" ]; then
            # 如果提供了目标名称，使用目标名称加上原文件扩展名
            file_ext=".${filename##*.}"
            new_filename="${TARGET_NAME}${file_ext}"
        else
            # 否则仅移除可能存在的@3x标记
            new_filename=$(echo "$filename" | sed 's/@3x//')
        fi
        echo -e "${YELLOW}尝试复制: $file -> $ASSETS_DIR/3.0x/$new_filename${NC}"
        
        if cp "$file" "$ASSETS_DIR/3.0x/$new_filename"; then
            X3_COUNT=$((X3_COUNT + 1))
            echo -e "${GREEN}成功复制: $filename -> 3.0x/$new_filename${NC}"
        else
            ERROR_COUNT=$((ERROR_COUNT + 1))
            echo -e "${RED}复制失败: $filename${NC}"
        fi
    done
fi

# 处理方法2：根据文件名中的@2x、@3x标记判断（用于处理没有放在分辨率文件夹中的图片）
echo -e "${YELLOW}处理其他目录中的图片...${NC}"
find "$TEMP_DIR" -mindepth 1 -not \( -path "$TEMP_DIR/1.0x*" -o -path "$TEMP_DIR/2.0x*" -o -path "$TEMP_DIR/3.0x*" \) -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.gif" -o -name "*.webp" \) | while read file; do
    filename=$(basename "$file")
    
    # 设置文件扩展名
    file_ext=".${filename##*.}"
    
    # 根据文件名判断分辨率
    if [[ "$filename" == *@3x* ]]; then
        # 处理3x图片
        if [ -n "$TARGET_NAME" ]; then
            new_filename="${TARGET_NAME}${file_ext}"
        else
            new_filename=$(echo "$filename" | sed 's/@3x//')
        fi
        echo -e "${YELLOW}尝试复制: $file -> $ASSETS_DIR/3.0x/$new_filename${NC}"
        
        if cp "$file" "$ASSETS_DIR/3.0x/$new_filename"; then
            X3_COUNT=$((X3_COUNT + 1))
            echo -e "${GREEN}成功复制: $filename -> 3.0x/$new_filename${NC}"
        else
            ERROR_COUNT=$((ERROR_COUNT + 1))
            echo -e "${RED}复制失败: $filename${NC}"
        fi
    elif [[ "$filename" == *@2x* ]]; then
        # 处理2x图片
        if [ -n "$TARGET_NAME" ]; then
            new_filename="${TARGET_NAME}${file_ext}"
        else
            new_filename=$(echo "$filename" | sed 's/@2x//')
        fi
        echo -e "${YELLOW}尝试复制: $file -> $ASSETS_DIR/2.0x/$new_filename${NC}"
        
        if cp "$file" "$ASSETS_DIR/2.0x/$new_filename"; then
            X2_COUNT=$((X2_COUNT + 1))
            echo -e "${GREEN}成功复制: $filename -> 2.0x/$new_filename${NC}"
        else
            ERROR_COUNT=$((ERROR_COUNT + 1))
            echo -e "${RED}复制失败: $filename${NC}"
        fi
    elif [[ "$filename" == *@1x* ]]; then
        # 处理1x图片
        if [ -n "$TARGET_NAME" ]; then
            new_filename="${TARGET_NAME}${file_ext}"
        else
            new_filename=$(echo "$filename" | sed 's/@1x//')
        fi
        echo -e "${YELLOW}尝试复制: $file -> $ASSETS_DIR/$new_filename${NC}"
        
        if cp "$file" "$ASSETS_DIR/$new_filename"; then
            REGULAR_COUNT=$((REGULAR_COUNT + 1))
            echo -e "${GREEN}成功复制: $filename -> images/$new_filename${NC}"
        else
            ERROR_COUNT=$((ERROR_COUNT + 1))
            echo -e "${RED}复制失败: $filename${NC}"
        fi
    else
        # 处理没有标记的图片（假设为1x）
        if [ -n "$TARGET_NAME" ]; then
            new_filename="${TARGET_NAME}${file_ext}"
        else
            new_filename="$filename"
        fi
        echo -e "${YELLOW}尝试复制: $file -> $ASSETS_DIR/$new_filename${NC}"
        
        if cp "$file" "$ASSETS_DIR/$new_filename"; then
            REGULAR_COUNT=$((REGULAR_COUNT + 1))
            echo -e "${GREEN}成功复制: $filename -> images/$new_filename${NC}"
        else
            ERROR_COUNT=$((ERROR_COUNT + 1))
            echo -e "${RED}复制失败: $filename${NC}"
        fi
    fi
done

# 处理XML资源（如果存在），转换为Flutter drawable
if [ $XML_FILES -gt 0 ]; then
    echo -e "${YELLOW}处理XML资源文件...${NC}"
    
    # 自动创建risk_warning_bg.dart
    echo -e "${YELLOW}创建风险预警背景drawable...${NC}"
    mkdir -p "$DRAWABLE_DIR"
    
    # 生成高风险背景
    HIGH_RISK_BG="$DRAWABLE_DIR/high_risk_bg.dart"
    echo -e "${YELLOW}生成高风险背景: $HIGH_RISK_BG${NC}"
    cat > "$HIGH_RISK_BG" << EOF
import 'package:flutter/material.dart';

class HighRiskBackground extends StatelessWidget {
  final Widget? child;
  final double borderRadius;
  
  const HighRiskBackground({
    Key? key,
    this.child,
    this.borderRadius = 8.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFE5E5),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: const Color(0xFFFF1919), width: 1),
      ),
      child: child,
    );
  }
}
EOF
    
    # 生成中风险背景
    MED_RISK_BG="$DRAWABLE_DIR/medium_risk_bg.dart"
    echo -e "${YELLOW}生成中风险背景: $MED_RISK_BG${NC}"
    cat > "$MED_RISK_BG" << EOF
import 'package:flutter/material.dart';

class MediumRiskBackground extends StatelessWidget {
  final Widget? child;
  final double borderRadius;
  
  const MediumRiskBackground({
    Key? key,
    this.child,
    this.borderRadius = 8.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5E0),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: const Color(0xFFFF9500), width: 1),
      ),
      child: child,
    );
  }
}
EOF
    
    # 生成低风险背景
    LOW_RISK_BG="$DRAWABLE_DIR/low_risk_bg.dart"
    echo -e "${YELLOW}生成低风险背景: $LOW_RISK_BG${NC}"
    cat > "$LOW_RISK_BG" << EOF
import 'package:flutter/material.dart';

class LowRiskBackground extends StatelessWidget {
  final Widget? child;
  final double borderRadius;
  
  const LowRiskBackground({
    Key? key,
    this.child,
    this.borderRadius = 8.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE5FFE6),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: const Color(0xFF34C759), width: 1),
      ),
      child: child,
    );
  }
}
EOF
    
    # 生成风险预警背景
    RISK_WARNING_BG="$DRAWABLE_DIR/risk_warning_bg.dart"
    echo -e "${YELLOW}生成风险预警背景: $RISK_WARNING_BG${NC}"
    cat > "$RISK_WARNING_BG" << EOF
import 'package:flutter/material.dart';

class RiskWarningBackground extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final String? backgroundImage;
  
  const RiskWarningBackground({
    Key? key,
    required this.child,
    this.borderRadius = 15.0,
    this.backgroundImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
        image: backgroundImage != null 
            ? DecorationImage(
                image: AssetImage(backgroundImage!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: child,
    );
  }
}
EOF
    
    # 生成风险item背景
    RISK_ITEM_BG="$DRAWABLE_DIR/risk_item_bg.dart"
    echo -e "${YELLOW}生成风险Item背景: $RISK_ITEM_BG${NC}"
    cat > "$RISK_ITEM_BG" << EOF
import 'package:flutter/material.dart';

class RiskItemBackground extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final Color borderColor;
  final double borderRadius;
  
  const RiskItemBackground({
    Key? key,
    required this.child,
    required this.backgroundColor,
    required this.borderColor,
    this.borderRadius = 8.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: child,
    );
  }
}
EOF
    
    # 生成导出文件
    DRAWABLE_EXPORT="$DRAWABLE_DIR/index.dart"
    echo -e "${YELLOW}生成drawable导出文件: $DRAWABLE_EXPORT${NC}"
    cat > "$DRAWABLE_EXPORT" << EOF
export 'high_risk_bg.dart';
export 'medium_risk_bg.dart';
export 'low_risk_bg.dart';
export 'risk_warning_bg.dart';
export 'risk_item_bg.dart';
EOF
    
    echo -e "${GREEN}已生成全部drawable背景资源!${NC}"
fi

# 统计结果
echo -e "${GREEN}处理完成!${NC}"
echo -e "${GREEN}共处理图片文件:${NC}"
echo -e "${GREEN}- 1.0x: $REGULAR_COUNT 个文件${NC}"
echo -e "${GREEN}- 2.0x: $X2_COUNT 个文件${NC}"
echo -e "${GREEN}- 3.0x: $X3_COUNT 个文件${NC}"
if [ $ERROR_COUNT -gt 0 ]; then
    echo -e "${RED}- 失败: $ERROR_COUNT 个文件${NC}"
fi

# 清理临时目录
echo -e "${YELLOW}清理临时文件...${NC}"
rm -rf "$TEMP_DIR"

# 获取最终使用的文件名和扩展名
FINAL_FILENAME=""
FINAL_EXT=""
if [ -n "$TARGET_NAME" ]; then
    FINAL_FILENAME="$TARGET_NAME"
    FINAL_EXT="$IMAGE_EXT"
else
    # 获取第一个处理的图片文件名作为参考
    FIRST_PROCESSED_IMAGE=$(find "$ASSETS_DIR" -maxdepth 1 -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.gif" -o -name "*.webp" \) | sort | head -n 1)
    if [ -n "$FIRST_PROCESSED_IMAGE" ]; then
        FIRST_PROCESSED_FILENAME=$(basename "$FIRST_PROCESSED_IMAGE")
        FINAL_FILENAME="${FIRST_PROCESSED_FILENAME%.*}"
        FINAL_EXT=".${FIRST_PROCESSED_FILENAME##*.}"
    fi
fi

# 如果有图片被处理，更新 image_resource.dart 文件
if [ $REGULAR_COUNT -gt 0 -o $X2_COUNT -gt 0 -o $X3_COUNT -gt 0 ] && [ -n "$FINAL_FILENAME" ]; then
    echo -e "${YELLOW}更新图片资源文件...${NC}"
    
    # 检查图片资源文件是否存在
    if [ ! -f "$IMAGE_RESOURCE_FILE" ]; then
        echo -e "${YELLOW}图片资源文件不存在，创建新文件...${NC}"
        mkdir -p "$(dirname "$IMAGE_RESOURCE_FILE")"
        echo "class FYImages {" > "$IMAGE_RESOURCE_FILE"
        echo "  static const String appIcon_32 = 'assets/images/appIcon_32.png';" >> "$IMAGE_RESOURCE_FILE"
        echo "}" >> "$IMAGE_RESOURCE_FILE"
    fi
    
    # 添加新图片引用
    IMAGE_PATH="assets/images/$FINAL_FILENAME$FINAL_EXT"
    VARIABLE_NAME=$FINAL_FILENAME
    
    # 检查该图片引用是否已存在
    if ! grep -q "static const String $VARIABLE_NAME =" "$IMAGE_RESOURCE_FILE"; then
        # 在最后一个花括号前添加新图片引用
        sed -i '' -e "$ i\\
  static const String $VARIABLE_NAME = '$IMAGE_PATH';\\
" "$IMAGE_RESOURCE_FILE"
        echo -e "${GREEN}成功添加图片引用: $VARIABLE_NAME = '$IMAGE_PATH'${NC}"
    else
        echo -e "${YELLOW}图片引用 '$VARIABLE_NAME' 已存在，跳过添加${NC}"
    fi
fi

if [ -n "$TARGET_NAME" ]; then
    echo -e "${GREEN}所有图片已重命名为 '$TARGET_NAME' 并放置到对应目录!${NC}"
    echo -e "${YELLOW}在Flutter中使用此图片的方式:${NC}"
    echo -e "${GREEN}Image.asset('assets/images/$TARGET_NAME$IMAGE_EXT')${NC}"
    echo -e "${GREEN}或通过引用:${NC}"
    echo -e "${GREEN}Image.asset(FYImages.$TARGET_NAME)${NC}"
else
    echo -e "${GREEN}所有图片已成功处理并放置到对应目录!${NC}"
fi

# 展示资源目录内容
echo -e "${YELLOW}资源目录内容:${NC}"
ls -la "$ASSETS_DIR"
echo -e "${YELLOW}2.0x 目录:${NC}"
ls -la "$ASSETS_DIR/2.0x"
echo -e "${YELLOW}3.0x 目录:${NC}"
ls -la "$ASSETS_DIR/3.0x"

# 展示更新后的图片资源文件
echo -e "${YELLOW}图片资源类文件内容:${NC}"
cat "$IMAGE_RESOURCE_FILE"

# 如果生成了drawable资源，提示如何使用
if [ -d "$DRAWABLE_DIR" ]; then
    echo -e "${YELLOW}生成的drawable资源可以这样使用:${NC}"
    echo -e "${GREEN}import 'package:safe_app/widgets/drawable/index.dart';${NC}"
    echo -e "${GREEN}...${NC}"
    echo -e "${GREEN}// 风险预警背景${NC}"
    echo -e "${GREEN}RiskWarningBackground(${NC}"
    echo -e "${GREEN}  backgroundImage: FYImages.$FINAL_FILENAME,${NC}"
    echo -e "${GREEN}  child: YourContent(),${NC}"
    echo -e "${GREEN})${NC}"
    echo -e "${GREEN}// 风险项目背景${NC}"
    echo -e "${GREEN}RiskItemBackground(${NC}"
    echo -e "${GREEN}  backgroundColor: Colors.red.shade100,${NC}"
    echo -e "${GREEN}  borderColor: Colors.red,${NC}"
    echo -e "${GREEN}  child: YourContent(),${NC}"
    echo -e "${GREEN})${NC}"
fi 