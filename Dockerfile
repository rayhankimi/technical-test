FROM python:3.14-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Because the app is simple, we don't need any multistage docker configuration here
# Only add necessary thing such as making sure app is not running in root user
WORKDIR /app
RUN useradd -r -u 1001 -d /app app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY --chown=app:app app ./app
USER app
EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request,sys; sys.exit(0 if urllib.request.urlopen('http://127.0.0.1:8000/health').status==200 else 1)"

CMD [ "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000" ]