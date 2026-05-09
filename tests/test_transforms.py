"""Geometric transforms module tests."""

import numpy as np
from src.transforms import rotate, resize, flip


def test_rotate_default_center():
    image = np.random.randint(0, 255, (100, 100, 3), dtype=np.uint8)
    rotated = rotate(image, 45)
    assert rotated.shape == image.shape


def test_rotate_preserves_shape():
    image = np.random.randint(0, 255, (64, 64), dtype=np.uint8)
    rotated = rotate(image, 90)
    assert rotated.shape == (64, 64)


def test_resize_by_width():
    image = np.random.randint(0, 255, (100, 200, 3), dtype=np.uint8)
    resized = resize(image, width=100)
    assert resized.shape[0] == 50
    assert resized.shape[1] == 100


def test_resize_by_height():
    image = np.random.randint(0, 255, (100, 200, 3), dtype=np.uint8)
    resized = resize(image, height=50)
    assert resized.shape[0] == 50
    assert resized.shape[1] == 100


def test_resize_no_change():
    image = np.random.randint(0, 255, (50, 50), dtype=np.uint8)
    resized = resize(image)
    assert resized.shape == image.shape


def test_flip_horizontal():
    image = np.random.randint(0, 255, (50, 100, 3), dtype=np.uint8)
    flipped = flip(image, mode='horizontal')
    assert flipped.shape == image.shape
    assert np.array_equal(flipped[:, 0], image[:, -1])


def test_flip_vertical():
    image = np.random.randint(0, 255, (100, 50, 3), dtype=np.uint8)
    flipped = flip(image, mode='vertical')
    assert flipped.shape == image.shape


def test_flip_both():
    image = np.random.randint(0, 255, (100, 100, 3), dtype=np.uint8)
    flipped = flip(image, mode='both')
    assert flipped.shape == image.shape
    assert np.array_equal(flipped[0], image[-1, ::-1])
