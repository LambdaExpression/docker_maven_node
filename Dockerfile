FROM maven:3.5.4-jdk-8

# 完全重写 sources.list 为 Debian Stretch 归档源（主仓库和安全仓库）
RUN rm -f /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian stretch main" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian-security stretch/updates main" >> /etc/apt/sources.list && \
    # 添加配置忽略 Release 文件的有效期检查（归档源已冻结）
    echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until

# 更新并安装 curl 和 xz-utils，允许使用不安全仓库和未认证包（绕过签名错误）
RUN apt-get update -o Acquire::AllowInsecureRepositories=yes -o Acquire::AllowDowngradeToInsecureRepositories=yes && \
    apt-get install -y --allow-unauthenticated curl xz-utils && \
    rm -rf /var/lib/apt/lists/*

# 设置 Node.js 版本和架构
ENV NODE_VERSION=v14.15.4
ENV NODE_ARCH=linux-x64
ENV NODE_PKG=node-${NODE_VERSION}-${NODE_ARCH}.tar.xz

# 下载、解压 Node.js 到 /usr/local，并清理安装包
# 使用 -k 忽略 curl 的证书验证（防止因 ca-certificates 缺失导致下载失败）
RUN curl -fsSLO --compressed -k https://nodejs.org/dist/${NODE_VERSION}/${NODE_PKG} && \
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