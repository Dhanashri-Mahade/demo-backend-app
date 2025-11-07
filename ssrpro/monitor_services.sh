#!/bin/bash

# ========= CONFIG =========
TO_EMAIL="dhanashri.mahade@siliconmount.com"
HOST=$(hostname)
DATE=$(date)

# ========= FUNCTIONS =========
send_mail() {
  SUBJECT="$1"
  MESSAGE="$2"
  echo "$MESSAGE" | mailx -s "$SUBJECT" -S from="Server Monitor Siliconmount <root@srv834068.hstgr.cloud>" "$TO_EMAIL"
}

log() {
  echo "[$(date)] $1" >> /var/log/monitor_services.log
}

# ========= CHECK NGINX =========
if ! systemctl is-active --quiet nginx; then
  log "🚨 Nginx is DOWN. Attempting recovery."
  send_mail "🚨 ALERT: Nginx Down on $HOST" "Nginx service stopped at $DATE"

  # Fix conflict with httpd and restart nginx
  systemctl stop httpd
  systemctl start nginx

  if systemctl is-active --quiet nginx; then
    log "✅ Nginx restarted successfully."
    send_mail "✅ Nginx Auto-Recovered on $HOST" "Nginx service restarted successfully."
  else
    log "❌ Nginx failed to restart."
    send_mail "❌ ALERT: Nginx Restart Failed on $HOST" "Manual check required."
  fi
fi

# ========= CHECK DOCKER CONTAINER =========
if ! docker ps --format '{{.Names}}' | grep -q 'smts_backend'; then
  log "🚨 SMTS Website Backend DOWN. Restarting."
  send_mail "🚨 ALERT: smts_backend Down on $HOST" "smts_backend stopped at $DATE"

  docker start smts_backend

  if docker ps --format '{{.Names}}' | grep -q 'smts_backend'; then
    log "✅ SMTS Website Backend restarted."
    send_mail "✅ smts_backend Auto-Recovered on $HOST" "Container restarted successfully."
  else
    log "❌ Failed to restart smts_backend."
    send_mail "❌ ALERT: smts_backend Restart Failed on $HOST" "Manual check required."
  fi
fi

# ========= CHECK JAVA BACKEND =========
# Check if Java process is listening on port 8082
if ! ps -ef | grep 'ssr-pro-0.0.1-SNAPSHOT.jar' | grep -v grep > /dev/null; then
  log "🚨 Java SSRPro backend not running on port 8082."
  send_mail "🚨 ALERT: Java SSRPro Down on $HOST" "Java process not found at $DATE"

  # 🔹 Current active JAR path and start command
  log "🔄 Attempting to restart SSRPro Java backend..."
  nohup java -jar /root/siliconmount/jar/ssr-pro-0.0.1-SNAPSHOT.jar --spring.profiles.active=prod > /root/siliconmount/logs/log.txt 2>&1 &
  echo $! > /root/siliconmount/jar/pid.file

  # 🔸 Future deployment path (when MyBOQ.jar replaces SSRPro)
  # nohup java -jar /root/siliconmount/ssrpro/jar/MyBOQ.jar --spring.profiles.active=prod > /root/siliconmount/logs/log.txt 2>&1 &
  # echo $! > /root/siliconmount/ssrpro/jar/pid.file

  sleep 10
  if ps -ef | grep 'ssr-pro-0.0.1-SNAPSHOT.jar' | grep -v grep > /dev/null; then
    log "✅ Java SSRPro restarted successfully."
    send_mail "✅ Java SSRPro Auto-Recovered on $HOST" "Java SSRPro service restarted successfully."
  else
    log "❌ Failed to restart Java SSRPro."
    send_mail "❌ ALERT: Java SSRPro Restart Failed on $HOST" "Manual check required."
  fi
else
  log "🟢 Java backend (SSRPro) is running normally on port 8082."
fi