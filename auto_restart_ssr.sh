#!/bin/bash

# 定义 ssrmu.sh 脚本路径
SSRMU_SCRIPT="/root/ssrmu.sh"

# 检查 ssrmu.sh 是否存在
if [ ! -f "$SSRMU_SCRIPT" ]; then
    echo "❌ 错误: 未找到 ssrmu.sh，请确认该脚本位于 /root 目录！"
    exit 1
fi

# 需要写入的 cron 任务
CRON_JOB="0 4 * * * echo '12' | $SSRMU_SCRIPT"

# 检查是否已存在该 cron 任务
crontab -l 2>/dev/null | grep -F "$CRON_JOB" >/dev/null
if [ $? -eq 0 ]; then
    echo "✅ 定时任务已存在，无需重复添加。"
else
    (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
    echo "🆕 已成功添加定时任务，每天 4:00 自动重启 SSR。"
fi

# 重启 cron 服务
if command -v systemctl >/dev/null 2>&1; then
    systemctl restart cron 2>/dev/null || systemctl restart crond 2>/dev/null
else
    service cron restart 2>/dev/null || service crond restart 2>/dev/null
fi

# **检查 cron 是否成功写入**
crontab -l 2>/dev/null | grep -F "$CRON_JOB" >/dev/null
if [ $? -eq 0 ]; then
    echo "✅ 确认成功写入 crontab！SSR 将在每天 4:00 自动重启。"
else
    echo "❌ 错误: crontab 任务写入失败，请手动检查！"
    exit 1
fi

echo "🎉 脚本执行完毕！你可以使用 'crontab -l' 查看任务。"
