FROM maven:3.5.4-jdk-8

# 修复软件源：将所有 deb.debian.org 替换为 archive.debian.org，
# 安全源替换为 archive.debian.org/debian-security，
# 删除不存在的 stretch-updates 行，并禁用 Valid-Until 检查
RUN cp /etc/apt/sources.list /etc/apt/sources.list.bak && \
    sed -i 's/deb.debian.org/archive.debian.org/g' /etc/apt/sources.list && \
    sed -i 's|security.debian.org|archive.debian.org/debian-security|g' /etc/apt/sources.list && \
    sed -i '/stretch-updates/d' /etc/apt/sources.list && \
    echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until

# 更新并安装 curl 和 xz-utils，允许未认证的包和 insecure 仓库
RUN apt-get update -o Acquire::AllowInsecureRepositories=yes -o Acquire::AllowDowngradeToInsecureRepositories=yes && \
    apt-get install -y --allow-unauthenticated curl xz-utils && \
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