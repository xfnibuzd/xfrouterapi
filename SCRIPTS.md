# XFRouter API 脚本使用指南

本项目提供了完整的自动化脚本系统，覆盖构建、启动、停止、清理等所有操作。

## 🚀 快速开始

### 最简单的方式
```bash
# 交互式菜单，选择所需操作
make quick
# 或者
./quick-start.sh
```

### 常用命令组合
```bash
# 开发环境：构建 + 启动
make dev && make start

# 生产环境：构建 + 部署
make prod

# 重启服务
make restart

# 完全重置
make clean-all && make prod
```

## 📋 脚本概览

| 脚本 | 功能 | 主要用途 |
|------|------|----------|
| `build.sh` | 构建项目 | 前端构建、Docker镜像构建 |
| `start.sh` | 启动服务 | 开发环境、生产环境启动 |
| `stop.sh` | 停止服务 | 停止所有相关进程 |
| `quick-start.sh` | 快速启动 | 交互式菜单，常用操作 |
| `Makefile` | 命令别名 | 便捷的命令封装 |

## 🛠️ 构建脚本 (build.sh)

### 基本用法
```bash
./build.sh [环境]
```

### 环境选项
- `dev` - 开发环境 (仅构建前端)
- `prod` - 生产环境 (构建 + Docker部署)
- `docker` - 仅构建Docker镜像
- `clean` - 清理构建产物

### 示例
```bash
./build.sh dev      # 开发环境构建
./build.sh prod     # 生产环境构建
./build.sh docker   # 仅构建Docker镜像
./build.sh clean    # 清理
```

## 🚀 启动脚本 (start.sh)

### 基本用法
```bash
./start.sh [模式] [选项]
```

### 启动模式
- `dev` - 开发环境 (前端热重载 + 后端开发服务器)
- `prod` - 生产环境 (Docker容器)
- `docker` - 仅启动Docker容器
- `backend` - 仅启动后端开发服务器
- `frontend` - 仅启动前端开发服务器

### 选项参数
- `--check` - 启动前检查依赖
- `--build` - 启动前构建项目
- `--clean` - 启动前清理旧服务
- `--port PORT` - 指定端口 (默认: 3000)
- `--debug` - 启用调试模式
- `--watch` - 监控文件变化 (开发模式)
- `--logs` - 启动后显示日志

### 示例
```bash
# 开发环境，带构建和文件监控
./start.sh dev --build --watch

# 生产环境，带依赖检查
./start.sh prod --check

# 后端调试模式
./start.sh backend --debug

# 自定义端口启动
./start.sh docker --port 3001
```

## 🛑 停止脚本 (stop.sh)

### 基本用法
```bash
./stop.sh [选项]
```

### 停止选项
- `all` - 停止所有服务 (默认)
- `docker` - 仅停止Docker服务
- `backend` - 仅停止后端进程
- `clean` - 停止服务并清理资源
- `force` - 强制停止所有相关进程
- `status` - 检查服务状态

### 示例
```bash
./stop.sh         # 停止所有服务
./stop.sh docker  # 仅停止Docker
./stop.sh force   # 强制停止
./stop.sh clean   # 停止并清理
```

## ⚡ 快速启动 (quick-start.sh)

### 交互式菜单
```bash
./quick-start.sh
```

### 直接命令
```bash
./quick-start.sh dev      # 开发环境
./quick-start.sh prod     # 生产环境
./quick-start.sh stop     # 停止服务
./quick-start.sh restart  # 重启服务
```

## 📝 Makefile 命令

### 构建命令
```bash
make dev         # 开发环境构建
make prod        # 生产环境构建
make docker      # 仅构建Docker镜像
make frontend    # 仅构建前端
make test        # 运行测试
```

### 启动命令
```bash
make start       # 启动开发环境
make start-prod  # 启动生产环境
make start-docker # 启动Docker容器
make start-backend # 仅启动后端
make start-frontend # 仅启动前端
make quick       # 快速启动菜单
```

### 服务管理
```bash
make stop        # 停止所有服务
make stop-force  # 强制停止
make restart     # 重启服务
make status      # 检查状态
make check-status # 检查服务状态
```

### 清理命令
```bash
make clean       # 清理构建产物
make clean-all   # 完全清理
```

## 🔄 常用工作流

### 日常开发
```bash
# 1. 启动开发环境
make quick
# 选择 1) 开发环境

# 2. 或者直接命令
make start

# 3. 查看状态
make status

# 4. 停止服务
make stop
```

### 生产部署
```bash
# 1. 完全清理
make clean-all

# 2. 生产部署
make prod

# 3. 检查状态
make status
```

### 故障处理
```bash
# 1. 强制停止
make stop-force

# 2. 清理资源
./stop.sh clean

# 3. 重新部署
make prod
```

### 仅前端开发
```bash
# 构建并启动前端
make frontend && make start-frontend
```

### 仅后端开发
```bash
# 启动后端开发服务器
make start-backend --debug
```

## 🔧 高级配置

### 环境变量
```bash
# 代理设置
export HTTP_PROXY=http://127.0.0.1:7897
export HTTPS_PROXY=http://127.0.0.1:7897

# 调试模式
export DEBUG=true

# 自定义端口
export PORT=3001
```

### Docker 配置
修改 `docker-compose.yml` 可自定义：
- 端口映射
- 数据库配置
- 环境变量
- 资源限制

### 前端配置
修改 `web/` 目录下的配置文件：
- `vite.config.js` - 构建配置
- `package.json` - 依赖配置
- `.env*` - 环境变量

## 📊 监控和日志

### 查看日志
```bash
# Docker 日志
docker compose logs new-api

# 实时日志
docker compose logs -f new-api

# 所有服务日志
docker compose logs
```

### 健康检查
```bash
# API 状态
curl http://localhost:3000/api/status

# 服务状态
make status

# 端口占用
lsof -i :3000
```

## 🚨 故障排除

### 常见问题

#### 1. 端口被占用
```bash
# 查看占用进程
lsof -i :3000

# 强制停止
make stop-force

# 或使用其他端口
./start.sh dev --port 3001
```

#### 2. 依赖问题
```bash
# 检查依赖
./start.sh dev --check

# 重新安装依赖
cd web && rm -rf node_modules && bun install
```

#### 3. Docker 问题
```bash
# 检查Docker状态
docker ps
docker compose ps

# 重启Docker服务
sudo systemctl restart docker

# 清理Docker资源
docker system prune -a
```

#### 4. 构建失败
```bash
# 清理构建缓存
make clean

# 重新构建
make prod

# 查看详细错误
./build.sh prod 2>&1 | tee build.log
```

## 💡 最佳实践

### 开发环境
1. 使用 `make quick` 进入交互式菜单
2. 开发时启用 `--watch` 文件监控
3. 定期检查 `make status` 服务状态

### 生产环境
1. 部署前使用 `--check` 检查依赖
2. 使用 `make clean-all` 完全清理后部署
3. 定期备份重要数据

### 维护
1. 定期运行 `make clean` 清理构建产物
2. 监控磁盘空间和资源使用
3. 及时更新依赖和镜像

---

如有问题，请查看各脚本的 `--help` 选项或查看详细日志。
