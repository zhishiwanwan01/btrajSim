#!/bin/bash
set -e # 遇到错误立即退出

xhost + # 允许 Docker 容器访问 X11 显示服务器

# Auto-detect Windows client IP (SSH source)
WINDOWS_IP=$(who am i | awk '{print $5}' | sed 's/[()]//g' | cut -d: -f1)
if [ -z "$WINDOWS_IP" ]; then
    # Fallback: from SSH_CLIENT env
    WINDOWS_IP=$(echo $SSH_CLIENT | cut -d' ' -f1)
fi
echo "检测到的Windows IP: $WINDOWS_IP"
# Export for docker-compose
export DISPLAY_IP="$WINDOWS_IP:0.0"

# 构建并启动 ROS Melodic 容器
docker compose -f .devcontainer/docker-compose.yml up -d --build ros-melodic