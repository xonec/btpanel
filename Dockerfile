# 使用debian为基础镜像
FROM debian:bullseye-slim

# 设置维护者信息
LABEL maintainer="ifui <ifui@foxmail.com>"

RUN groupadd -f www && useradd -g www www

# 定义软件版本号和安装路径变量
ENV BAOTA_INSTALL_PATH=https://download.bt.cn/install/off_install.sh \
    BAOTA_UPDATE_PATH=https://io.bt.sy/install/update_panel.sh \
    TZ=Asia/Shanghai \
    DEBIAN_FRONTEND=noninteractive \
    NGINX_VERSION=1.21 \
    PHP_VERSION=7.4 \
    MYSQL_VERSION=5.6

# 设置容器时间和更换国内源，安装依赖软件
RUN ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime
RUN echo ${TZ} > /etc/timezone
RUN dpkg-reconfigure --frontend noninteractive tzdata
RUN echo "时间设置完成。"
RUN sed -i -e 's/# zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' /etc/locale.gen
RUN locale-gen
RUN echo "语言设置完成。"
RUN sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list
RUN apt-get update
RUN echo "APT源更新完成。"
RUN apt-get install -y init procps wget iproute2 locales
RUN echo "前置环境设置完成。"
RUN wget -O install.sh ${BAOTA_INSTALL_PATH}
RUN echo y | bash install.sh
RUN echo "宝塔面板 8.0.1 安装完成。"
RUN sleep 3
RUN wget -O update_panel.sh ${BAOTA_UPDATE_PATH}
RUN echo y | bash update_panel.sh
RUN echo "宝塔面板升级至 8.0.5 完成。"
RUN sleep 3
RUN rm -rf /var/lib/apt/lists/*
RUN chmod 777 /www/server/panel/install/install_soft.sh
RUN bash /www/server/panel/install/install_soft.sh 0 install nginx ${NGINX_VERSION}
RUN echo "Nginx ${NGINX_VERSION} 安装完成。"
#RUN bash /www/server/panel/install/install_soft.sh 0 install php ${PHP_VERSION}
#RUN echo "PHP ${PHP_VERSION} 安装完成。"
#RUN bash /www/server/panel/install/install_soft.sh 0 install mysql ${MYSQL_VERSION}
#RUN echo "MySQL ${MYSQL_VERSION} 安装完成。"
RUN echo "NPM 安装完成。"


# 复制并设置权限
COPY app.sh /
RUN chmod 777 /app.sh

# 设置默认命令
CMD ["sh", "-c", "/app.sh & tail -f /dev/null"]
