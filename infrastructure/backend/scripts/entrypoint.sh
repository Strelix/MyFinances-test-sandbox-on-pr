#!/bin/sh

echo "[SYSTEM] Copying nginx config file"
# Check if the nginx_config directory exists
if [ -d /mnt/nginx_config ]; then
  # Check if the nginx config file exists in the volume
  if [ ! -f /mnt/nginx_config/default.conf ]; then
    echo "Copying nginx config to /mnt/nginx_config/default.conf"
    cp /app/nginx/default.conf /mnt/nginx_config/default.conf
  else
    echo "Nginx config already exists in /mnt/nginx_config"
  fi
else
  echo "Nginx config directory /mnt/nginx_config does not exist. Skipping config copy."
fi

echo "[SYSTEM] [DJANGO] About to migrate"
python3 manage.py migrate --no-input

echo "[SYSTEM] [DJANGO] About to collect static"
python3 manage.py collectstatic --no-input

# Start Gunicorn in the background
echo "[SYSTEM] [DJANGO] Starting Gunicorn"
gunicorn settings.wsgi:application --bind 0.0.0.0:9012 --workers 2 &

# Start Celery in the background
#echo "[SYSTEM] [CELERY] Starting Celery"
#celery -A backend worker --loglevel=info &

# Wait for background processes to finish
wait -n
