# ---- Stage 1: build dependencies ----
FROM python:3.12-slim AS builder

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir --user -r requirements.txt

# ---- Stage 2: final runtime image ----
FROM python:3.12-slim

# Create a dedicated non-root user/group to run the app
RUN groupadd --gid 1000 appuser \
    && useradd --uid 1000 --gid appuser --shell /bin/false --no-create-home appuser

WORKDIR /app

# Bring in the Python packages installed in the builder stage
COPY --from=builder /root/.local /home/appuser/.local

# Copy only the application code (tests are excluded via .dockerignore)
COPY app ./app

# Make sure the copied packages are on PATH and owned by the non-root user
ENV PATH=/home/appuser/.local/bin:$PATH
RUN chown -R appuser:appuser /app /home/appuser/.local

USER appuser

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
