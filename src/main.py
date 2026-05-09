"""vision-toolkit API server with health check endpoint."""

import cv2
import numpy as np
from fastapi import FastAPI

app = FastAPI(title="Vision Toolkit API", version="1.0.0")


@app.get("/health")
async def health():
    return {
        "status": "healthy",
        "opencv_version": cv2.__version__,
        "numpy_version": np.__version__,
    }


@app.get("/")
async def root():
    return {"service": "vision-toolkit", "version": "1.0.0"}
