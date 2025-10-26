#!/bin/bash

# Moments 照片备份脚本
# 将 Moments 照片打包并备份到外置硬盘

# 配置变量
MOMENTS_SOURCE="/volume1/homes/admin/Drive/Moments"      # Moments 源目录
BACKUP_DEST="/volumeUSB1/usbshare/moment备份"            # 备份目标目录
BACKUP_PREFIX="moments_backup"                           # 备份文件前缀
LOG_FILE="/volume1/homes/admin/moments_backup.log"       # 日志文件路径
RETENTION_DAYS=180                                       # 保留天数（半年）

# 创建备份目录（如果不存在）
mkdir -p "$BACKUP_DEST"

# 日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
    echo "$1"  # 同时在控制台输出
}

# 检查源目录是否存在
if [ ! -d "$MOMENTS_SOURCE" ]; then
    log "错误: Moments 源目录不存在: $MOMENTS_SOURCE"
    exit 1
fi

# 检查目标目录是否存在
if [ ! -d "$BACKUP_DEST" ]; then
    log "错误: 备份目标目录不存在: $BACKUP_DEST"
    exit 1
fi

# 检查外置硬盘是否挂载
if ! mountpoint -q "/volumeUSB1"; then
    log "错误: 外置硬盘未正确挂载到 /volumeUSB1"
    exit 1
fi

# 生成备份文件名（包含日期时间）
BACKUP_FILENAME="${BACKUP_PREFIX}_$(date '+%Y%m%d_%H%M%S').tar.gz"
BACKUP_PATH="$BACKUP_DEST/$BACKUP_FILENAME"

log "================================================"
log "开始 Moments 照片备份..."
log "源目录: $MOMENTS_SOURCE"
log "备份文件: $BACKUP_PATH"

# 检查源目录是否为空
if [ -z "$(ls -A "$MOMENTS_SOURCE")" ]; then
    log "警告: Moments 源目录为空，跳过备份"
    exit 0
fi

# 执行备份
log "正在创建压缩包..."
cd "/volume1/homes/admin/Drive" || exit 1

if tar -czf "$BACKUP_PATH" "Moments" 2>> "$LOG_FILE"; then
    # 获取备份文件大小
    BACKUP_SIZE=$(du -h "$BACKUP_PATH" | cut -f1)
    log "备份成功完成! 文件大小: $BACKUP_SIZE"
    
    # 显示备份文件信息
    log "备份文件位置: $BACKUP_PATH"
    
    # 清理半年以上的旧备份（保留最近180天）
    log "正在清理 $RETENTION_DAYS 天前的旧备份..."
    find "$BACKUP_DEST" -name "${BACKUP_PREFIX}_*.tar.gz" -mtime +$RETENTION_DAYS -delete 2>/dev/null
    log "已清理 $RETENTION_DAYS 天前的备份文件"
else
    log "错误: 备份过程失败"
    exit 1
fi

log "备份任务完成"
log "================================================"
