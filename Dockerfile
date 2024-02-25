# 使用debian为基础镜像
FROM debian:12.5-slim

# 设置维护者信息
LABEL maintainer="ifui <ifui@foxmail.com>"

RUN groupadd -f www && useradd -g www www

# 定义软件版本号和安装路径变量
ENV BAOTA_INSTALL_PATH=https://download.bt.cn/install/off_install.sh \
    BAOTA_UPDATE_PATH=https://io.bt.sy/install/update_panel.sh \
    TZ=Asia/Shanghai \
    DEBIAN_FRONTEND=noninteractive \
    NGINX_VERSION=1.22 \
    PHP_VERSION=7.4 \
    PHPMYADMIN_VERSION=5.2 \
    MYSQL_VERSION=8.0

# 设置容器时间
RUN ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone \
    && dpkg-reconfigure --frontend noninteractive tzdata \
    && echo "时间设置完成."

# 更换国内源并更新APT源
RUN sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list \
    && apt-get update > /dev/null 2>&1 \
    && echo "APT源更新完成."

# 安装依赖软件
RUN apt-get install -y init procps wget iproute2 locales > /dev/null 2>&1 \
    && echo "前置环境设置完成." \
    && sed -i -e 's/# zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen \
    && echo "语言设置完成."

# 下载并安装宝塔面板 8.0.1
RUN wget -O install.sh ${BAOTA_INSTALL_PATH} \
    && echo y | bash install.sh \
    && echo "宝塔面板 8.0.1 安装完成." \
    && sleep 3

# 更新宝塔面板至 8.0.5
RUN wget -O update_panel.sh ${BAOTA_UPDATE_PATH} \
    && echo y | bash update_panel.sh \
    && echo "宝塔面板升级至 8.0.5 完成." \
    && sleep 1

# 清理APT缓存
RUN rm -rf /var/lib/apt/lists/*

# 安装Nginx
RUN chmod 777 /www/server/panel/install/install_soft.sh \
    && bash /www/server/panel/install/install_soft.sh 0 install nginx ${NGINX_VERSION} > /dev/null 2>&1 \
    && echo "Nginx ${NGINX_VERSION} 安装完成." \
    && sleep 3

# 安装PHP
RUN bash /www/server/panel/install/install_soft.sh 0 install php ${PHP_VERSION} > /dev/null 2>&1 \
    && echo "PHP ${PHP_VERSION} 安装完成." \
    && sleep 3

# 安装MySQL
RUN bash /www/server/panel/install/install_soft.sh 0 install mysql ${MYSQL_VERSION} > /dev/null 2>&1 \
    && echo "MySQL ${MYSQL_VERSION} 安装完成." \
    && sleep 3

# 安装phpMyAdmin
RUN bash /www/server/panel/install/install_soft.sh 1 install phpmyadmin ${PHPMYADMIN_VERSION} > /dev/null 2>&1 \
    && echo "phpMyAdmin ${PHPMYADMIN_VERSION} 安装完成." \
    && sleep 3

# 安装NPM
RUN echo "NPM 安装完成."

# 复制并设置权限
COPY app.sh /
RUN chmod 777 /app.sh

# 设置默认命令
CMD ["sh", "-c", "/app.sh & tail -f /dev/null"]
