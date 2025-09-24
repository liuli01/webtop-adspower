#!/bin/bash
set -euo pipefail

# 环境变量说明（你可以在 docker run 时传入）
# ADSPOWER_API_KEY   : AdsPower Local API key（必须）
# ADSPOWER_API_PORT  : 可选，默认 50325
# ADSPOWER_USERDATA_DIR: 可选，AdsPower 数据目录（默认 /opt/AdsPower）

API_PORT=${ADSPOWER_API_PORT:-50325}
API_KEY=${ADSPOWER_API_KEY:-}
ADSPACK="/tmp/AdsPower.deb"
ADSDIR=${ADSPOWER_USERDATA_DIR:-/opt/AdsPower}

# 安装 AdsPower（如果镜像里有 deb）
if [ -f "${ADSPACK}" ]; then
  echo "Installing AdsPower from ${ADSPACK} ..."
  dpkg -i "${ADSPACK}" || apt-get -f install -y
  rm -f "${ADSPACK}"
fi

# 简单准备目录权限
mkdir -p "${ADSDIR}"
chown -R 1000:1000 "${ADSDIR}" || true

# 启动 AdsPower（headless 模式），并把日志导到 /var/log/adspower.log
if [ -n "${API_KEY}" ]; then
  echo "Starting AdsPower headless with API port ${API_PORT} ..."
  # 可执行文件名可能不同，请在镜像内确认 AdsPower 的实际可执行路径（/opt/AdsPower/AdsPower 或 /opt/AdsPower/Adspower）
  ADSBIN="/opt/AdsPower/AdsPower"   # <- 根据实际路径调整
  if [ ! -x "${ADSBIN}" ]; then
    echo "Warning: ${ADSBIN} not found/executable. Try /opt/AdsPower/Adspower ..."
    ADSBIN="/opt/AdsPower/Adspower"
  fi

  if [ -x "${ADSBIN}" ]; then
    # 后台启动
    "${ADSBIN}" --headless=true --api-key="${API_KEY}" --api-port="${API_PORT}" &> /var/log/adspower.log &
    # 等待 API 启动（简单轮询）
    echo "Waiting for AdsPower API at http://127.0.0.1:${API_PORT} ..."
    for i in $(seq 1 30); do
      if curl -s "http://127.0.0.1:${API_PORT}/" >/dev/null 2>&1; then
        echo "AdsPower API is up."
        break
      fi
      sleep 1
    done
  else
    echo "AdsPower binary not found; skipping AdsPower start."
  fi
else
  echo "ADSPOWER_API_KEY not set — skipping AdsPower headless start. If you want AdsPower API, set ADSPOWER_API_KEY env."
fi


# 最后 exec 原始 webtop init，保留容器的原始行为（/init 是 linuxserver 容器中常见的 init）
# 如果 /init 不存在，可能是别的 entrypoint，需改成镜像实际的启动命令
if [ -x /init ]; then
  exec /init "$@"
else
  # fallback: 启动默认命令（你也可以把镜像原来的 CMD 写在这里）
  echo "No /init found — start /bin/bash as fallback"
  exec /bin/bash
fi