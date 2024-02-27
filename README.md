# 自动构建宝塔(LNMP)Docker容器镜像

本Docker容器镜像基于Debian:12-Slim构建，用于快速部署包含Nginx、PHP和MySQL的Web应用环境。

**重要提示：本Docker容器镜像仅供个人学习和测试之用，切勿在生产环境中使用。我们无法对因在生产环境中使用此镜像而造成的任何损失或问题负责。请谨慎使用，并遵守相关法律法规。**

[Docker](https://hub.docker.com/r/hogarfly/btpanel)

## 使用方法

1. 构建Docker镜像：
    ```bash
    docker build -t my-webapp .
    ```

2. 运行Docker容器：
    ```bash
    docker run -d my-webapp
    ```

## 环境变量

- `BAOTA_INSTALL_PATH`: 宝塔安装脚本路径，默认为https://download.bt.cn/install/off_install.sh
- `BAOTA_UPDATE_PATH`: 宝塔更新脚本路径，默认为https://io.bt.sy/install/update_panel.sh
- `TZ`: 时区，默认为Asia/Shanghai
- `NGINX_VERSION`: Nginx版本号，默认为1.22
- `PHP_VERSION`: PHP版本号，默认为7.4
- `MYSQL_VERSION`: MySQL版本号，默认为5.6

例如，如果你想在安装软件时只显示错误信息，你可以这样做：

apt-get install -y package-name > /dev/null

这条命令将标准输出（stdout）重定向到/dev/null，但是错误输出（stderr）仍然会显示在终端上。

如果你想完全静默安装，即不显示任何输出，你可以这样做：

apt-get install -y package-name > /dev/null 2>&1


## 注意事项

- 容器启动后会自动安装宝塔面板，并进行升级操作。
- 默认命令会执行`app.sh`脚本并持续输出日志。

### 常用命令
```bash
# 构建容器
docker build

# 不缓存构建
docker build --no-cache .

# 查看运行情况
docker ps

# 启动容器
docker start <container_name>

# 停止容器
docker stop <container_name>

# 删除容器
docker rm <container_name>

# 删除容器和数据卷
docker rm -v <container_name>


```bash
# 构建容器
docker-compose build

# 不缓存构建，执行后默认登录信息会变化
docker-compose build --no-cache

# 查看运行情况
docker-compose ps

# 启动宝塔镜像
docker-compose up -d app

# 启动宝塔数据备份迁移系统
docker-compose up -d app_backup

# 启动所有
docker-compose up -d

# 停止运行
docker-compose stop app

# 删除容器和数据卷
docker-compose down --volumes

```

