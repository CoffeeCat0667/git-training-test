"""pytest shared fixtures for vision-toolkit tests."""

import pytest
import numpy as np


@pytest.fixture
def random_color_image():
    """Generate a random 100x100 color image."""
    return np.random.randint(0, 255, (100, 100, 3), dtype=np.uint8)


@pytest.fixture
def random_gray_image():
    """Generate a random 100x100 grayscale image."""
    return np.random.randint(0, 255, (100, 100), dtype=np.uint8)


@pytest.fixture
def edge_image():
    """Generate a synthetic image with a sharp vertical edge."""
    image = np.zeros((100, 100), dtype=np.uint8)
    image[:, 50:] = 255
    return image
