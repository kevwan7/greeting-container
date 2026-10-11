# Change to slim image, digest set due to minimum vulns at time of checking, 5 meds 2 minors (0 major/crit) - 09/10
FROM python:3.12-slim@sha256:a6e34c598f2467ed0e9a8d349809fcd8b5c603269512df273a0bb1784edc11b1 AS builder

WORKDIR /app

# Copy in req.txt into builder stage, for installs below
COPY app/requirements.txt app/requirements.txt

# No Apt pkgs needed - removed

# Added no-cache dir to tidy up after installs    
RUN pip install --no-cache-dir -r app/requirements.txt 

# Runtime Stage
FROM python:3.12-slim@sha256:a6e34c598f2467ed0e9a8d349809fcd8b5c603269512df273a0bb1784edc11b1

WORKDIR /app

# Create new non-root user called appuser without creating home dir
RUN useradd --system --no-create-home appuser

COPY --from=builder /usr/local /usr/local

COPY app/ app/

# Using non-root user for least priv
USER appuser

# Expose port 8080
EXPOSE 8080

# App source was copied to /app, so the app package lives in /app/app.
CMD ["gunicorn", "--chdir", "app", "--bind", "0.0.0.0:8080", "--workers", "2", "app:app"]
