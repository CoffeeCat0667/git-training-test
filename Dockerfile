# ==============================================================================
# Production Dockerfile for vision-toolkit
#
# Build: docker build -t vision-toolkit:v1.0 .
# Run:   docker run --rm vision-toolkit:v1.0
# ==============================================================================

FROM python:3.10-slim

# ---------- Environment variables ----------
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# ---------- System dependencies ----------
# Use Debian mirror for faster downloads in China
RUN sed -i 's|deb.debian.org|mirrors.tuna.tsinghua.edu.cn|g' /etc/apt/sources.list.d/debian.sources 2>/dev/null; \
    apt-get update && apt-get install -y --no-install-recommends \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    libgl1 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# ---------- Install Python dependencies ----------
COPY requirements.txt .
RUN pip install --no-cache-dir -i https://pypi.tuna.tsinghua.edu.cn/simple -r requirements.txt

# ---------- Copy source code ----------
COPY src/ ./src/
COPY tests/ ./tests/
COPY examples/ ./examples/

ENV PYTHONPATH=/app

CMD ["pytest", "tests/", "-v", "--cov=src"]
