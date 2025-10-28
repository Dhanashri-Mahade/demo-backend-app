#!/bin/bash
# myboq-daily-log-rotation.sh
# Purpose: Rotate MyBOQ logs daily and restart the app with new log file
# Location: /root/siliconmount/ssrpro/scripts/myboq-daily-log-rotation.sh

APP_PATH="/root/siliconmount/ssrpro"
cd "$APP_PATH" || exit

# Log file for tracking cron activity
ACTIVITY_LOG="scripts/cron-activity.log"
mkdir -p "$(dirname "$ACTIVITY_LOG")"

echo "📅 [$(date '+%Y-%m-%d %H:%M:%S')] 🔄 Starting daily log rotation check..." >> "$ACTIVITY_LOG"

# Check if MyBOQ.jar is running
PID=$(ps -ef | grep 'MyBOQ.jar' | grep -v grep | awk '{print $2}')

if [ ! -z "$PID" ]; then
    echo "✅ MyBOQ.jar is running (PID: $PID)" >> "$ACTIVITY_LOG"

    TODAY_LOG_DATE=$(date +'%d_%m_%y')
    TODAY_LOG_FILE="logs/myboq_${TODAY_LOG_DATE}.log"

    if [ -f "$TODAY_LOG_FILE" ]; then
        echo "ℹ️  Today's log file already exists: $TODAY_LOG_FILE" >> "$ACTIVITY_LOG"
    else
        echo "📂 Creating new log file: $TODAY_LOG_FILE" >> "$ACTIVITY_LOG"
        mkdir -p logs

        echo "🔄 Restarting app to use new log file..." >> "$ACTIVITY_LOG"

        # Stop running instance
        kill -9 "$PID"
        sleep 3
        echo "🛑 Stopped old instance (PID: $PID)" >> "$ACTIVITY_LOG"

        # Create log header
        {
          echo "📅 [$(date '+%Y-%m-%d %H:%M:%S')] ========================================"
          echo "📅 [$(date '+%Y-%m-%d %H:%M:%S')] 🌅 NEW DAY - APP RESTARTED"
          echo "📅 [$(date '+%Y-%m-%d %H:%M:%S')] 📂 Log File: $TODAY_LOG_FILE"
          echo "📅 [$(date '+%Y-%m-%d %H:%M:%S')] 🔌 Port: 8082"
          echo "📅 [$(date '+%Y-%m-%d %H:%M:%S')] ========================================"
        } >> "$TODAY_LOG_FILE"

        # Start new instance
        nohup java -jar jar/MyBOQ.jar --server.port=8082 >> "$TODAY_LOG_FILE" 2>&1 &
        sleep 5

        NEW_PID=$(ps -ef | grep 'MyBOQ.jar' | grep -v grep | awk '{print $2}')
        if [ ! -z "$NEW_PID" ]; then
            echo "✅ App restarted successfully (New PID: $NEW_PID)" >> "$ACTIVITY_LOG"
            echo "📂 Now logging to: $TODAY_LOG_FILE" >> "$ACTIVITY_LOG"
        else
            echo "❌ Failed to restart app!" >> "$ACTIVITY_LOG"
            exit 1
        fi
    fi

    # Log cleanup message
    echo "🧹 Log cleanup handled by separate cron job" >> "$ACTIVITY_LOG"
    TOTAL_LOG_FILES=$(ls -1 logs/myboq_*.log 2>/dev/null | wc -l)
    echo "📊 Total log files: $TOTAL_LOG_FILES" >> "$ACTIVITY_LOG"

else
    echo "❌ MyBOQ.jar not running, skipping log rotation" >> "$ACTIVITY_LOG"
fi

echo "🏁 Completed daily log rotation - $(date '+%Y-%m-%d %H:%M:%S')" >> "$ACTIVITY_LOG"
echo "=============================================================" >> "$ACTIVITY_LOG"
