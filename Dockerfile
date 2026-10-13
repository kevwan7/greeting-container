# Change to CG, using latest and digest not available due to being a paid service - 0 Vulns as of 13/10
FROM cgr.dev/chainguard/python:latest-dev AS builder

WORKDIR /app

# Create a virtual env in /app/venv
RUN python -m venv /app/venv

ENV PATH="/app/venv/bin:$PATH"

# Copy in req.txt into builder stage, for installs below
COPY app/requirements.txt app/requirements.txt

# No Apt pkgs needed - removed

# Added no-cache dir to tidy up after installs    
RUN pip install --no-cache-dir -r app/requirements.txt 


# Runtime Stage - CG image used, using latest and digest not available due to being a paid service, and using due to 200MB smaller than dev
FROM cgr.dev/chainguard/python:latest

WORKDIR /app

# Bring over venv that contains packages and gunicorn
COPY --from=builder /app/venv /app/venv

COPY app/ app/

# Non-root user (Chainguard's built-in non-root, UID 65532), so no useradd needed
USER 65532

# Expose port 8080
EXPOSE 8080

# App source was copied to /app, so the app package lives in /app/app.
ENTRYPOINT ["/app/venv/bin/gunicorn"]
CMD ["--chdir", "app", "--bind", "0.0.0.0:8080", "--workers", "2", "app:app"]
