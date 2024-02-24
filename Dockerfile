# 使用debian为基础镜像
FROM debian:bullseye-slim

# 设置维护者信息
LABEL maintainer="ifui <ifui@foxmail.com>"

# 定义软件版本号和安装路径变量
ENV BAOTA_INSTALL_PATH=https://download.bt.cn/install/off_install.sh \
    BAOTA_UPDATE_PATH=https://io.bt.sy/install/update_panel.sh \
    TZ=Asia/Shanghai \
    DEBIAN_FRONTEND=noninteractive \
    NGINX_VERSION=1.21 \
    PHP_VERSION=7.4 \
    MYSQL_VERSION=5.6
    
# 创建用户组和用户,设置容器时间和更换国内源，安装依赖软件
RUN groupadd -f www && useradd -g www www \
    && ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone \
    && dpkg-reconfigure --frontend noninteractive tzdata \
    && sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y init procps wget iproute2 locales \
    && sed -i -e 's/# zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen \
    && wget -O install.sh ${BAOTA_INSTALL_PATH} \
    && echo y | bash install.sh \
    && echo "Baota8.0.1安装完成" \
    && sleep 3 \
    && wget -O update_panel.sh ${BAOTA_UPDATE_PATH} \
    && echo y | bash update_panel.sh \
    && echo "Baota8.0.5升级完成" \
    && sleep 3 \
    && rm -rf /var/lib/apt/lists/* \
    && chmod 777 /www/server/panel/install/install_soft.sh \
    && bash /www/server/panel/install/install_soft.sh 0 install nginx ${NGINX_VERSION} \
    && bash /www/server/panel/install/install_soft.sh 0 install php ${PHP_VERSION} \
    && bash /www/server/panel/install/install_soft.sh 0 install mysql ${MYSQL_VERSION} \
    && echo "NPM安装完成"

# 复制并设置权限
COPY app.sh /
RUN chmod 777 /app.sh

# 设置默认命令
CMD ["sh", "-c", "/app.sh & tail -f /dev/null"]
