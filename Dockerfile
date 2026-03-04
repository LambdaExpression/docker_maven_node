FROM maven:3.5.4-jdk-8

# 修复 Debian Stretch 源：将原源指向 archive.debian.org（因为 stretch 已归档）
RUN sed -i 's/deb.debian.org/archive.debian.org/g' /etc/apt/sources.list && \
    sed -i '/security.debian.org/d' /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian-security stretch/updates main" >> /etc/apt/sources.list

# 安装 Node.js 所需依赖：curl 和 xz-utils
RUN apt-get update && \
    apt-get install -y curl xz-utils && \
    rm -rf /var/lib/apt/lists/*

# 设置 Node.js 版本和架构
ENV NODE_VERSION=v14.15.4
ENV NODE_ARCH=linux-x64
ENV NODE_PKG=node-${NODE_VERSION}-${NODE_ARCH}.tar.xz

# 下载、解压 Node.js 到 /usr/local，并清理安装包
RUN curl -fsSLO --compressed https://nodejs.org/dist/${NODE_VERSION}/${NODE_PKG} && \
    tar -xJf ${NODE_PKG} -C /usr/local --strip-components=1 && \
    rm ${NODE_PKG} && \
    # 验证 Node.js 和 npm 是否安装成功
    node --version && npm --version

# 使用 npm 全局安装 Yarn（最新稳定版）
RUN npm install -g yarn && \
    yarn --version && \
    # 清理 npm 缓存以减小镜像体积
    npm cache clean --force

# 基础镜像默认的 CMD 是 ["mvn"]，无需修改