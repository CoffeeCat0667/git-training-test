"""
工具函数模块
"""

import cv2
import numpy as np


def load_image(path: str) -> np.ndarray:
    """加载图像文件"""
    image = cv2.imread(path)
    if image is None:
        raise FileNotFoundError(f"无法加载图像: {path}")
    return image


def save_image(image: np.ndarray, path: str) -> None:
    """保存图像文件"""
    cv2.imwrite(path, image)


def get_image_info(image: np.ndarray) -> dict:
    """获取图像基本信息"""
    info = {
        "shape": image.shape,
        "dtype": str(image.dtype),
        "channels": 1 if len(image.shape) == 2 else image.shape[2],
        "min": int(image.min()),
        "max": int(image.max()),
        "mean": float(image.mean()),
    }
    return info
