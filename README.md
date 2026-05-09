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

## Docker 使用

### 快速开始

```bash
# 1. 构建镜像
docker build -t vision-toolkit:latest .

# 2. 跑测试（验证镜像可用）
docker run --rm vision-toolkit:latest

# 3. 运行 demo（输出保存到本地 output/）
mkdir -p output
docker run --rm \
    -v "$(pwd)/output:/app/output" \
    vision-toolkit:latest \
    python examples/demo.py
```

### 使用 Docker Compose（推荐）

```bash
# 跑测试（含覆盖率）
docker compose run --rm test

# 进入交互式开发 shell
docker compose run --rm dev

# 运行演示
docker compose run --rm demo
```

### 从 GHCR 拉取预构建镜像

```bash
docker pull ghcr.io/coffeecat0667/vision-toolkit:latest
docker run --rm ghcr.io/coffeecat0667/vision-toolkit:latest
```

### 常见问题

**Q: 构建时报 `libGL.so.1: cannot open shared object file`？**
A: Dockerfile 里需要装 `libgl1`。OpenCV 在 import 时会动态加载这个库。

**Q: 代码改了，容器里看不到？**
A: 两种方案：
- 开发时用 `docker compose run --rm dev`，代码通过 volume 挂载
- 或者每次改代码后 `docker build` 重新构建镜像

**Q: 镜像体积太大？**
A: 检查：
- 是否用了 `python:3.10-slim` 而不是 `python:3.10`
- 是否在 `apt-get install` 同一层清理了 `/var/lib/apt/lists/*`
- 考虑用多阶段构建（见 V2 Dockerfile）

**Q: `docker: permission denied`？**
A: Linux 下把当前用户加入 docker 组：`sudo usermod -aG docker $USER`，然后重新登录。

**Q: Windows 下 volume 挂载路径怎么写？**
A: PowerShell 用 `${PWD}`，Git Bash 用 `$(pwd)`，WSL 里用 Linux 路径。

## 许可证

MIT License
