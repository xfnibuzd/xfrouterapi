# XFRouter API 部署指南

## 快速开始

### 本地开发
```bash
# 克隆项目
git clone <repository-url>
cd xfrouterapi

# 开发环境构建
make dev
# 或者
./build.sh dev

# 启动后端开发服务器
make backend
```

### 生产部署
```bash
# 一键部署到生产环境
make prod
# 或者
./build.sh prod
```

## 构建系统说明

### 脚本方式 (推荐)

#### build.sh 脚本
功能完整的构建脚本，支持多种环境：

```bash
# 开发环境 - 仅构建前端
./build.sh dev

# 生产环境 - 构建 + Docker 部署
./build.sh prod

# 仅构建 Docker 镜像
./build.sh docker

# 清理构建产物
./build.sh clean

# 显示帮助
./build.sh help
```

#### Makefile 方式
提供便捷的命令别名：

```bash
# 开发环境
make dev

# 生产环境
make prod

# 仅构建前端
make frontend

# 仅构建 Docker 镜像
make docker

# 启动后端开发服务器
make backend

# 运行测试
make test

# 清理
make clean

# 显示帮助
make help
```

### 手动方式

如果需要手动控制每个步骤：

#### 1. 构建前端
```bash
cd web
bun install  # 或 npm install --prefer-offline --legacy-peer-deps
DISABLE_ESLINT_PLUGIN='true' VITE_REACT_APP_VERSION=$(cat ../VERSION) bun run build
cd ..
```

#### 2. 构建 Docker 镜像
```bash
# 设置代理（如果需要）
export HTTP_PROXY=http://127.0.0.1:7897
export HTTPS_PROXY=http://127.0.0.1:7897

# 构建镜像
docker compose build new-api

# 启动服务
docker compose up -d
```

## 环境要求

### 基础依赖
- **Node.js** >= 18.0.0
- **Go** >= 1.22 (仅本地开发需要)
- **Docker** >= 20.0.0
- **Docker Compose** >= 2.0.0

### 包管理器支持
- **bun** (推荐)
- **npm** (备选)

### 代理支持
脚本会自动检测并使用以下代理端口：
- 7890 (常见 HTTP 代理)
- 7897 (Clash Verge 默认)
- 8888 (常见备用)
- 1087 (常见 SOCKS5)

## 配置说明

### 环境变量
```bash
# 代理设置
HTTP_PROXY=http://127.0.0.1:7897
HTTPS_PROXY=http://127.0.0.1:7897

# 构建变量
DISABLE_ESLINT_PLUGIN='true'
VITE_REACT_APP_VERSION=v1.0.0
```

### Docker 配置
主要配置文件：
- `docker-compose.yml` - 服务编排
- `Dockerfile.local` - 本地构建配置
- `.env` - 环境变量 (可选)

### 数据库配置
支持三种数据库：
- **SQLite** (默认，无需配置)
- **PostgreSQL** (推荐生产环境)
- **MySQL** (传统选择)

在 `docker-compose.yml` 中修改数据库配置。

## 部署场景

### 1. 本地开发
```bash
# 快速启动开发环境
make dev && make backend
```

### 2. 服务器部署
```bash
# 服务器上一键部署
git pull
make prod
```

### 3. CI/CD 集成
```yaml
# GitHub Actions 示例
- name: Build and Deploy
  run: |
    chmod +x build.sh
    ./build.sh prod
```

### 4. 仅前端更新
```bash
# 只更新前端代码
make frontend
docker compose restart new-api
```

### 5. 仅后端更新
```bash
# 只更新后端代码
make docker
docker compose up -d
```

## 故障排除

### 常见问题

#### 1. 代理问题
```bash
# 手动设置代理
export HTTP_PROXY=http://127.0.0.1:7897
export HTTPS_PROXY=http://127.0.0.1:7897

# 或禁用代理
unset HTTP_PROXY HTTPS_PROXY
```

#### 2. 端口冲突
```bash
# 检查端口占用
lsof -i :3000

# 修改 docker-compose.yml 中的端口映射
ports:
  - "3001:3000"  # 改为其他端口
```

#### 3. 权限问题
```bash
# 给脚本执行权限
chmod +x build.sh

# Docker 权限问题
sudo usermod -aG docker $USER
```

#### 4. 内存不足
```bash
# 清理 Docker 缓存
docker system prune -a

# 限制构建内存
export DOCKER_BUILDKIT=1
```

### 日志查看
```bash
# 查看服务日志
docker compose logs new-api

# 实时日志
docker compose logs -f new-api

# 所有服务日志
docker compose logs
```

### 健康检查
```bash
# 检查服务状态
curl http://localhost:3000/api/status

# 检查容器状态
docker ps
```

## 性能优化

### 构建优化
- 使用 `bun` 替代 `npm` (更快的包管理)
- 启用 Docker 构建缓存
- 使用多阶段构建减少镜像大小

### 运行优化
- 配置适当的资源限制
- 使用 Redis 缓存提升性能
- 配置反向代理 (Nginx)

### 监控建议
- 监控容器资源使用
- 设置日志轮转
- 配置健康检查告警

## 安全建议

### 生产环境
- 修改默认密码
- 使用 HTTPS
- 限制网络访问
- 定期更新镜像

### 网络安全
- 配置防火墙规则
- 使用内部网络通信
- 限制数据库访问

### 数据安全
- 定期备份数据
- 加密敏感信息
- 审计访问日志

## 维护指南

### 日常维护
```bash
# 清理旧镜像
docker image prune -f

# 清理日志
make clean

# 更新依赖
cd web && bun update
```

### 版本更新
```bash
# 更新代码
git pull

# 重新构建
make prod

# 验证更新
curl http://localhost:3000/api/status
```

### 备份恢复
```bash
# 备份数据
docker compose exec postgres pg_dump -U root new-api > backup.sql

# 恢复数据
docker compose exec -T postgres psql -U root new-api < backup.sql
```

---

如有问题，请查看日志或联系技术支持。
