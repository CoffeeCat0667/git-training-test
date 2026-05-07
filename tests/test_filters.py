"""
滤波器模块测试
"""

import pytest
import numpy as np
import cv2
from src.filters import (
    to_grayscale,
    gaussian_blur,
    sobel_edge_detection,
    canny_edge_detection
)


def test_to_grayscale():
    """测试灰度化"""
    color_image = np.random.randint(0, 255, (100, 100, 3), dtype=np.uint8)
    gray_image = to_grayscale(color_image)

    assert len(gray_image.shape) == 2
    assert gray_image.shape == (100, 100)


def test_gaussian_blur():
    """测试高斯模糊"""
    image = np.random.randint(0, 255, (100, 100), dtype=np.uint8)
    blurred = gaussian_blur(image, kernel_size=5)

    assert blurred.shape == image.shape
    assert np.std(blurred) < np.std(image)


def test_sobel_edge_detection():
    """测试Sobel边缘检测"""
    image = np.zeros((100, 100), dtype=np.uint8)
    image[:, 50:] = 255

    edges = sobel_edge_detection(image)

    assert edges.shape == image.shape
    assert edges[:, 48:52].mean() > edges[:, :10].mean()


def test_canny_edge_detection():
    """测试Canny边缘检测"""
    image = np.random.randint(0, 255, (100, 100), dtype=np.uint8)
    edges = canny_edge_detection(image)

    assert edges.shape == image.shape
    assert edges.dtype == np.uint8


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
