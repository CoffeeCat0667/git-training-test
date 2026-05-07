"""
图像滤波器模块
实现常见的图像滤波算法
"""

import cv2
import numpy as np


def to_grayscale(image: np.ndarray) -> np.ndarray:
    """
    将彩色图像转换为灰度图

    Args:
        image: 输入图像 (H, W, 3)

    Returns:
        灰度图像 (H, W)
    """
    if len(image.shape) == 2:
        return image
    return cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)


def gaussian_blur(image: np.ndarray, kernel_size: int = 5,
                  sigma: float = 1.0) -> np.ndarray:
    """
    高斯模糊

    Args:
        image: 输入图像
        kernel_size: 卷积核大小（奇数）
        sigma: 高斯核标准差

    Returns:
        模糊后的图像
    """
    if kernel_size % 2 == 0:
        kernel_size += 1
    return cv2.GaussianBlur(image, (kernel_size, kernel_size), sigma)


def sobel_edge_detection(image: np.ndarray) -> np.ndarray:
    """
    Sobel边缘检测

    Args:
        image: 输入图像（灰度图）

    Returns:
        边缘图像
    """
    if len(image.shape) == 3:
        image = to_grayscale(image)

    grad_x = cv2.Sobel(image, cv2.CV_64F, 1, 0, ksize=3)
    grad_y = cv2.Sobel(image, cv2.CV_64F, 0, 1, ksize=3)

    magnitude = np.sqrt(grad_x**2 + grad_y**2)
    magnitude = np.uint8(magnitude / magnitude.max() * 255)

    return magnitude


def canny_edge_detection(image: np.ndarray,
                         threshold1: int = 50,
                         threshold2: int = 150) -> np.ndarray:
    """
    Canny边缘检测

    Args:
        image: 输入图像
        threshold1: 低阈值
        threshold2: 高阈值

    Returns:
        边缘图像
    """
    if len(image.shape) == 3:
        image = to_grayscale(image)
    return cv2.Canny(image, threshold1, threshold2)
