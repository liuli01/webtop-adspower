# 基于 linuxserver 的 webtop ubuntu 变体
FROM ghcr.io/linuxserver/webtop:debian-xfce


ENV DEBIAN_FRONTEND=noninteractive

# 安装必要依赖
RUN apt-get update && apt-get install -y \
    wget gnupg ca-certificates libnss3 libxss1 \
    libatk1.0-0 libgtk-3-0 libasound2 libdrm2 libgbm1 \
    libxcomposite1 libxrandr2 libxdamage1 libxtst6 \
    libpci3 libatspi2.0-0 fonts-liberation libappindicator3-1 \
    libsecret-common libsecret-1-0 && \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# 下载并安装 Dolphin{anty}
RUN wget -O /tmp/dolphin-anty.deb https://dolphin-anty-cdn.com/anty-app/dolphin-anty-linux-amd64-latest.deb && \
    dpkg -i /tmp/dolphin-anty.deb || apt-get install -f -y && \
    rm /tmp/dolphin-anty.deb

# 替换 Chromium 为 Dolphin{anty}
RUN if [ -f /usr/bin/chromium ]; then mv /usr/bin/chromium /usr/bin/chromium.bak; fi && \
    ln -s /usr/bin/dolphin_anty /usr/bin/chromium

# 创建启动脚本，带 --no-sandbox 参数
RUN echo '#!/bin/bash\nexec dolphin_anty --no-sandbox "$@"' > /usr/local/bin/dolphin-anty-wrapper && \
    chmod +x /usr/local/bin/dolphin-anty-wrapper && \
    ln -sf /usr/local/bin/dolphin-anty-wrapper /usr/bin/dolphin_anty

# 保留 Webtop 默认入口
ENTRYPOINT ["/init"]
