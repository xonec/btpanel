FROM debian:bullseye-slim

LABEL maintainer="ifui <ifui@foxmail.com>"

RUN groupadd -f www && useradd -g www www

ENV BAOTA_INSTALL_PATH=https://download.bt.cn/install/off_install.sh \
    BAOTA_UPDATE_PATH=https://io.bt.sy/install/update_panel.sh \
    TZ=Asia/Shanghai \
    DEBIAN_FRONTEND=noninteractive \
    NGINX_VERSION=1.21 \
    PHP_VERSION=7.4 \
    MYSQL_VERSION=5.6
    
RUN ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone \
    && dpkg-reconfigure --frontend noninteractive tzdata \
    && sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list \
    && apt-get update > /dev/null \
    && apt-get install -y --no-install-recommends init procps wget iproute2 locales > /dev/null \
    && sed -i -e 's/# zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen \
    && wget -O install.sh ${BAOTA_INSTALL_PATH} > /dev/null \
    && echo y | bash install.sh > /dev/null \
    && echo "Baota8.0.1安装完成" \
    && sleep 3 \
    && wget -O update_panel.sh ${BAOTA_UPDATE_PATH} > /dev/null \
    && echo y | bash update_panel.sh > /dev/null \
    && echo "Baota8.0.5升级完成" \
    && sleep 3 \
    && rm -rf /var/lib/apt/lists/* \
    && chmod 777 /www/server/panel/install/install_soft.sh \
    && bash /www/server/panel/install/install_soft.sh 0 install nginx ${NGINX_VERSION} > /dev/null \
    && bash /www/server/panel/install/install_soft.sh 0 install php ${PHP_VERSION} > /dev/null \
    && bash /www/server/panel/install/install_soft.sh 0 install mysql ${MYSQL_VERSION} > /dev/null \
    && echo "NPM安装完成"

COPY app.sh /
RUN chmod 777 /app.sh

CMD ["sh", "-c", "/app.sh & tail -f /dev/null"]
