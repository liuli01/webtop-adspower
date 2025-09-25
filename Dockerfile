FROM lscr.io/linuxserver/webtop:debian-xfce

ENV DEBIAN_FRONTEND=noninteractive

# 下载并安装 Dolphin Anty
RUN apt-get update -y && \
    curl -L -o /tmp/dolphin-anty.deb https://dolphin-anty-cdn.com/anty-app/dolphin-anty-linux-amd64-latest.deb && \
    apt-get install -y ./tmp/dolphin-anty.deb && \
    apt-get install -f -y && \
    rm /tmp/dolphin-anty.deb && \
    rm -rf /var/lib/apt/lists/*

# 创建包装脚本，保证 Dolphin Anty 启动带上参数
RUN sed -i 's|Exec=.*|Exec="/opt/Dolphin Anty/dolphin_anty" --no-sandbox %U|' \
    "/usr/share/applications/dolphin_anty.desktop"

# 保留 Webtop 默认入口
ENTRYPOINT ["/init"]
