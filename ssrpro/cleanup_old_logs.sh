#!/bin/bash
# cleanup_old_logs.sh
# Purpose: Delete MyBOQ log files older than 10 days
# Location: /root/siliconmount/ssrpro/scripts/cleanup_old_logs.sh

cd /root/siliconmount/ssrpro || exit

echo "🧹 [$(date '+%Y-%m-%d %H:%M:%S')] Starting log cleanup..."

LOG_DIR="logs"
LOG_PATTERN="myboq_*.log"

if [ ! -d "$LOG_DIR" ]; then
  echo "⚠️ Logs directory not found: $LOG_DIR"
  exit 1
fi

DELETED_COUNT=$(find "$LOG_DIR"/ -name "$LOG_PATTERN" -mtime +9 -print | wc -l)

if [ "$DELETED_COUNT" -gt 0 ]; then
  echo "🗑️  Deleting $DELETED_COUNT old log files..."
  find "$LOG_DIR"/ -name "$LOG_PATTERN" -mtime +9 -delete
  echo "✅ Cleaned up $DELETED_COUNT log files older than 10 days"
else
  echo "✅ No old log files to delete"
fi

echo "📊 Current log files:"
ls -la "$LOG_DIR"/myboq_*.log 2>/dev/null || echo "No log files found"

echo "🏁 [$(date '+%Y-%m-%d %H:%M:%S')] Cleanup completed"
echo "=================================================="


