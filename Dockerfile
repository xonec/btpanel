# 使用debian为基础镜像
FROM debian:12.5-slim

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
    && echo "时间设置完成." \
    && apt-get update > /dev/null 2>&1 \
    && echo "APT源更新完成." \

# 安装依赖软件
    && apt-get install -y init procps wget iproute2 locales > /dev/null 2>&1 \
    && echo "前置环境设置完成." \
    && sed -i -e 's/# zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen \
    && echo "语言设置完成." \

# 下载并安装官方宝塔面板
    && wget -O install.sh ${BAOTA_INSTALL_PATH} \
    && echo y | bash install.sh --nginx-install ${NGINX_VERSION} --php-install ${PHP_VERSION} --mysql-install ${MYSQL_VERSION} --phpmyadmin-install ${PHPMYADMIN_VERSION} \
    && echo "🌟✨✨ 官方宝塔面板安装完成 ✨✨🌟" \
    && echo "💻💡 Nginx ${NGINX_VERSION} 安装完成 💡💻" \
    && echo "🚀🌈 PHP ${PHP_VERSION} 安装完成 🌈🚀" \
    && echo "🔒💻 phpMyAdmin ${PHPMYADMIN_VERSION} 安装完成 💻🔒" \
    && sleep 6 \

# 更新宝塔面板至 8.0.5
    && wget -O update_panel.sh ${BAOTA_UPDATE_PATH} \
    && echo y | bash update_panel.sh \
    && echo "宝塔面板升级至开心版完成." \
    && sleep 1 \

# 更新Gem包列表、所有Gem包、pip到最新版本、所有Python包、apt软件源列表和所有Debian软件包，然后清理缓存（完全静默）
RUN gem update --system --quiet && \
    gem update --quiet && \
    pip install --upgrade pip --quiet && \
    pip list --outdated | cut -d' ' -f1 | xargs pip install --upgrade --quiet && \
    apt-get update -qq && apt-get upgrade -y -qq && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && echo "🔒💻 更新包完成 💻🔒" \

# 复制并设置权限
COPY app.sh /
RUN chmod 777 /app.sh

# 设置默认命令
CMD ["sh", "-c", "/app.sh & tail -f /dev/null"]
