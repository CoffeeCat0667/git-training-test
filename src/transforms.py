"""
图像几何变换模块
"""

import cv2
import numpy as np


def rotate(image: np.ndarray, angle: float,
           center: tuple = None) -> np.ndarray:
    """
    旋转图像

    Args:
        image: 输入图像
        angle: 旋转角度（度）
        center: 旋转中心，默认为图像中心

    Returns:
        旋转后的图像
    """
    h, w = image.shape[:2]
    if center is None:
        center = (w // 2, h // 2)

    M = cv2.getRotationMatrix2D(center, angle, 1.0)
    rotated = cv2.warpAffine(image, M, (w, h))
    return rotated


def resize(image: np.ndarray, width: int = None,
           height: int = None, interpolation=cv2.INTER_LINEAR) -> np.ndarray:
    """
    缩放图像

    Args:
        image: 输入图像
        width: 目标宽度
        height: 目标高度
        interpolation: 插值方法

    Returns:
        缩放后的图像
    """
    h, w = image.shape[:2]

    if width is None and height is None:
        return image

    if width is None:
        ratio = height / h
        width = int(w * ratio)
    elif height is None:
        ratio = width / w
        height = int(h * ratio)

    return cv2.resize(image, (width, height), interpolation=interpolation)


def flip(image: np.ndarray, mode: str = 'horizontal') -> np.ndarray:
    """
    翻转图像

    Args:
        image: 输入图像
        mode: 'horizontal', 'vertical', 或 'both'

    Returns:
        翻转后的图像
    """
    if mode == 'horizontal':
        return cv2.flip(image, 1)
    elif mode == 'vertical':
        return cv2.flip(image, 0)
    elif mode == 'both':
        return cv2.flip(image, -1)
    else:
        raise ValueError(f"Unknown flip mode: {mode}")
