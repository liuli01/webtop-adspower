# 基于 linuxserver 的 webtop debian变体
FROM ghcr.io/linuxserver/webtop:debian-xfce


ENV DEBIAN_FRONTEND=noninteractive

# 安装必要依赖
RUN apt-get update && apt-get install -f \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# 下载并安装 Dolphin{anty}
RUN curl -L -o /tmp/dolphin-anty.deb https://dolphin-anty-cdn.com/anty-app/dolphin-anty-linux-amd64-latest.deb && \
    dpkg -i /tmp/dolphin-anty.deb || apt-get install -f -y && \
    rm /tmp/dolphin-anty.deb

# 如果Chromium已安装，则重命名以避免冲突，并创建指向 Dolphin{anty} 的符号链接
RUN if [ -f /usr/bin/chromium ]; then mv /usr/bin/chromium /usr/bin/chromium.bak; fi && \
    ln -s /usr/bin/dolphin_anty /usr/bin/chromium

# 创建启动脚本，带 --no-sandbox 参数
RUN echo '#!/bin/bash\nexec dolphin_anty --no-sandbox "$@"' > /usr/local/bin/dolphin-anty-wrapper && \
    chmod +x /usr/local/bin/dolphin-anty-wrapper && \
    ln -sf /usr/local/bin/dolphin-anty-wrapper /usr/bin/dolphin_anty

# 保留 Webtop 默认入口
ENTRYPOINT ["/init"]
