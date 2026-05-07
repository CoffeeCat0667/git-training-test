"""
图像处理工具库演示
"""

import cv2
import numpy as np
import sys
sys.path.append('..')

from src.filters import (
    to_grayscale,
    gaussian_blur,
    sobel_edge_detection,
    canny_edge_detection
)
from src.transforms import rotate, resize, flip


def main():
    image = np.random.randint(0, 255, (400, 600, 3), dtype=np.uint8)

    print("原始图像形状:", image.shape)

    # 1. 灰度化
    gray = to_grayscale(image)
    print("灰度图形状:", gray.shape)

    # 2. 高斯模糊
    blurred = gaussian_blur(image, kernel_size=15)
    print("模糊完成")

    # 3. 边缘检测
    edges_sobel = sobel_edge_detection(image)
    edges_canny = canny_edge_detection(image)
    print("边缘检测完成")

    # 4. 几何变换
    rotated = rotate(image, 45)
    resized = resize(image, width=300)
    flipped = flip(image, mode='horizontal')
    print("几何变换完成")

    # 显示结果
    cv2.imshow('Original', image)
    cv2.imshow('Grayscale', gray)
    cv2.imshow('Blurred', blurred)
    cv2.imshow('Sobel Edges', edges_sobel)
    cv2.imshow('Canny Edges', edges_canny)
    cv2.imshow('Rotated', rotated)
    cv2.imshow('Resized', resized)
    cv2.imshow('Flipped', flipped)

    print("\n按任意键关闭窗口...")
    cv2.waitKey(0)
    cv2.destroyAllWindows()


if __name__ == "__main__":
    main()
