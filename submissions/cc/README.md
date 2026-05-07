# Vision Toolkit - 图像处理工具库

简单易用的计算机视觉工具库，实现常见的图像处理算法。

## 功能特性

### 图像滤波
- ✅ 灰度化转换
- ✅ 高斯模糊
- ✅ Sobel边缘检测
- ✅ Canny边缘检测

### 几何变换
- ✅ 图像旋转
- ✅ 图像缩放
- ✅ 图像翻转

## 安装

```bash
# 克隆仓库
git clone https://github.com/CoffeeCat0667/vision-toolkit.git
cd vision-toolkit

# 安装依赖
pip install -r requirements.txt
```

## 快速开始

```python
import cv2
from src.filters import gaussian_blur, canny_edge_detection
from src.transforms import rotate, resize

# 读取图像
image = cv2.imread('image.jpg')

# 高斯模糊
blurred = gaussian_blur(image, kernel_size=5)

# 边缘检测
edges = canny_edge_detection(image)

# 旋转45度
rotated = rotate(image, 45)

# 缩放到宽度300
resized = resize(image, width=300)
```

## 运行示例

```bash
python examples/demo.py
```

## 运行测试

```bash
pytest tests/ -v
```

## 项目结构

```
vision-toolkit/
├── src/              # 源代码
├── tests/            # 测试
├── examples/         # 示例
└── README.md         # 文档
```

## 作者

- 姓名：CoffeeCat0667
- 姓名简拼：cc
- 日期：2026-05-07

## 许可证

MIT License
