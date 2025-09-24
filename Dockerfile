# 基于 linuxserver 的 webtop ubuntu 变体
FROM ghcr.io/linuxserver/webtop:ubuntu-xfce

ENV DEBIAN_FRONTEND=noninteractive

# 必要依赖（示例，可能根据 AdsPower 的依赖需要调整）
RUN apt-get update && apt-get install -y \
    ca-certificates \
    wget \
    gnupg \
    libxss1 libnss3 libatk1.0-0 libgtk-3-0 libdrm2 libgbm1 \
    --no-install-recommends && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# 下载 AdsPower 安装包
RUN wget -O /tmp/AdsPower.deb https://version.adspower.net/software/linux-x64-global/7.7.18/AdsPower-Global-7.7.18-x64.deb

# 拷贝并设置启动脚本
COPY start-adspower.sh /usr/local/bin/start-adspower.sh
RUN chmod +x /usr/local/bin/start-adspower.sh

# 可选：移除自带 chromium（如果镜像里有），避免冲突
# RUN apt-get remove -y chromium-browser chromium || true

# 入口：执行我们的启动脚本（脚本最后会 exec /init 保持 webtop 行为）
ENTRYPOINT [ "/usr/local/bin/start-adspower.sh" ]
CMD [ ]
