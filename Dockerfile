FROM python:3.13-slim

ENV UV_PYTHON_DOWNLOADS=never \
    UV_PYTHON=/usr/local/bin/python3.13 \
    UV_LINK_MODE=copy

WORKDIR /app

RUN useradd --create-home appuser && chown appuser:appuser /app

RUN pip install uv

COPY --chown=appuser:appuser pyproject.toml .
COPY --chown=appuser:appuser uv.lock* .

USER appuser

RUN uv sync --frozen --no-dev

# Copy application code
COPY --chown=appuser:appuser app/ app/

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Run uvicorn directly from venv (avoids uv re-syncing at runtime)
CMD [".venv/bin/uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]