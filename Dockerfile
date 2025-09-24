# 基于 linuxserver 的 webtop ubuntu 变体
FROM ghcr.io/linuxserver/webtop:debian-xfce

# 设置非交互模式，避免安装过程中出现提示
ENV DEBIAN_FRONTEND=noninteractive

# 安装依赖和 Dolphin{anty}
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    ca-certificates \
    libnss3 \
    libxss1 \
    libatk1.0-0 \
    libgtk-3-0 \
    libasound2 \
    libdrm2 \
    libgbm1 \
    libxcomposite1 \
    libxrandr2 \
    libxdamage1 \
    libxtst6 \
    libpci3 \
    libatspi2.0-0 \
    fonts-liberation \
    libappindicator3-1 \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/* && \
    wget https://dolphin-anty-cdn.com/anty-app/dolphin-anty-linux-amd64-latest.deb && \
    dpkg -i dolphin-anty-linux-amd64-latest.deb && \
    apt-get install -f -y

# 设置启动命令，启动 Dolphin{anty}
ENTRYPOINT ["dolphin_anty", "--no-sandbox"]
