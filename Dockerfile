# ---- Stage 1: build dependencies ----
FROM python:3.12-alpine AS builder

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir --user -r requirements.txt

# ---- Stage 2: final runtime image ----
FROM python:3.12-alpine

# Apply the latest Alpine security patches to the base OS packages
RUN apk update && apk upgrade --no-cache

# Create a dedicated non-root user/group to run the app
RUN addgroup -g 1000 appuser \
    && adduser -D -H -u 1000 -G appuser -s /sbin/nologin appuser

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
