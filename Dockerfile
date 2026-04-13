FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    ENABLE_SENTENCE_TRANSFORMERS=false \
    MPLCONFIGDIR=/app/matplotlib-cache

WORKDIR /app

COPY requirements.fly.txt .
RUN pip install --upgrade pip && pip install -r requirements.fly.txt

# Pre-build the matplotlib font cache into the image so workers start instantly.
# Without this, each cold-start rebuilds the cache in /tmp (ephemeral), which
# takes 60-90 s and causes uvicorn to kill workers before they finish starting.
RUN mkdir -p /app/matplotlib-cache && \
    python -c "import matplotlib.font_manager; print('font cache ready')"

COPY . .

EXPOSE 8000

CMD ["uvicorn", "api.server:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "2"]
