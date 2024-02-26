# 使用debian为基础镜像
FROM debian:12.5-slim

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
    && echo -e "\e[1;32m时间设置完成.\e[0m 🕒" \

# 更新APT源
    && apt-get update > /dev/null 2>&1 \
    && echo -e "\e[1;32mAPT源更新完成.\e[0m 🔄" \

# 安装依赖软件
    && apt-get install -y init procps wget iproute2 locales > /dev/null 2>&1 \
    && echo -e "\e[1;32m前置环境设置完成.\e[0m ✅" \
    && sed -i -e 's/# zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen \
    && echo -e "\e[1;32m语言设置完成.\e[0m 🌍" \
    
# 下载并安装官方宝塔面板
    && wget -O install.sh ${BAOTA_INSTALL_PATH} \
    && echo y | bash install.sh --nginx-install ${NGINX_VERSION} --php-install ${PHP_VERSION} --mysql-install ${MYSQL_VERSION} --phpmyadmin-install ${PHPMYADMIN_VERSION} \
    && echo -e "\e[1;34m🌟✨✨ 官方宝塔面板安装完成 ✨✨🌟\e[0m 🚀" \
    && echo -e "\e[1;31m💡 Nginx ${NGINX_VERSION} 安装完成 💡💻\e[0m 💡" \
    && echo -e "\e[1;36m🚀🌈 PHP ${PHP_VERSION} 安装完成 🌈🚀\e[0m 🎉" \
    && echo -e "\e[1;32m🔒💻 phpMyAdmin ${PHPMYADMIN_VERSION} 安装完成 💻🔒\e[0m 🔒" \
    && sleep 1 \

# 更新宝塔面板至 8.0.5
    && wget -O update_panel.sh ${BAOTA_UPDATE_PATH} \
    && echo y | bash update_panel.sh \
    && echo -e "\e[1;32m宝塔面板升级至开心版完成.\e[0m 🎉" \
    && sleep 1

# 复制并设置权限
COPY app.sh /
RUN chmod 777 /app.sh

# 设置默认命令
CMD ["sh", "-c", "/app.sh & tail -f /dev/null"]
