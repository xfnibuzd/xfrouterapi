#!/bin/bash

# XFRouter API 一键构建脚本
# 支持本地开发和远端部署
# 使用方法: ./build.sh [环境]
# 环境: dev(开发) | prod(生产) | docker(仅构建Docker镜像)

set -e  # 遇到错误立即退出

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 显示帮助信息
show_help() {
    cat << EOF
XFRouter API 构建脚本

使用方法:
  ./build.sh [环境]

环境选项:
  dev     - 开发环境 (构建前端 + 启动本地服务)
  prod    - 生产环境 (构建前端 + Docker镜像 + 启动容器)
  docker  - 仅构建Docker镜像
  clean   - 清理所有构建产物

示例:
  ./build.sh dev     # 本地开发
  ./build.sh prod    # 生产部署
  ./build.sh docker  # 仅构建镜像
  ./build.sh clean   # 清理

EOF
}

# 检查依赖
check_dependencies() {
    local env=$1
    
    case $env in
        "dev"|"prod")
            # 检查 Node.js
            if ! command -v node &> /dev/null; then
                log_error "Node.js 未安装，请先安装 Node.js"
                exit 1
            fi
            
            # 检查包管理器
            if command -v bun &> /dev/null; then
                PKG_MANAGER="bun"
                PKG_INSTALL="bun install"
                PKG_BUILD="DISABLE_ESLINT_PLUGIN='true' VITE_REACT_APP_VERSION=\$(cat VERSION) bun run build"
            elif command -v npm &> /dev/null; then
                PKG_MANAGER="npm"
                PKG_INSTALL="npm install --prefer-offline --legacy-peer-deps"
                PKG_BUILD="DISABLE_ESLINT_PLUGIN='true' VITE_REACT_APP_VERSION=\$(cat VERSION) npm run build"
            else
                log_error "未找到包管理器 (bun 或 npm)"
                exit 1
            fi
            ;;
        "docker"|"prod")
            # 检查 Docker
            if ! command -v docker &> /dev/null; then
                log_error "Docker 未安装，请先安装 Docker"
                exit 1
            fi
            
            if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
                log_error "Docker Compose 未安装，请先安装 Docker Compose"
                exit 1
            fi
            ;;
    esac
}

# 设置代理
setup_proxy() {
    if [ -n "$HTTP_PROXY" ] || [ -n "$HTTPS_PROXY" ]; then
        log_info "使用环境变量代理: HTTP_PROXY=$HTTP_PROXY"
        export DOCKER_BUILD_PROXY="$HTTP_PROXY"
    else
        # 检测常见代理端口
        for port in 7890 7897 8888 1087; do
            if curl -s --connect-timeout 2 --proxy "http://127.0.0.1:$port" https://www.google.com > /dev/null 2>&1; then
                log_info "检测到代理端口: $port"
                export HTTP_PROXY="http://127.0.0.1:$port"
                export HTTPS_PROXY="http://127.0.0.1:$port"
                export DOCKER_BUILD_PROXY="http://127.0.0.1:$port"
                break
            fi
        done
    fi
}

# 构建前端
build_frontend() {
    log_info "开始构建前端..."
    
    cd web
    
    # 安装依赖
    log_info "安装前端依赖 ($PKG_MANAGER)..."
    $PKG_INSTALL
    
    # 构建
    log_info "构建前端资源..."
    eval $PKG_BUILD
    
    cd ..
    
    if [ ! -d "web/dist" ]; then
        log_error "前端构建失败: web/dist 目录不存在"
        exit 1
    fi
    
    log_success "前端构建完成"
}

# Docker 构建
build_docker() {
    log_info "开始构建 Docker 镜像..."
    
    # 设置代理环境变量
    local proxy_args=""
    if [ -n "$DOCKER_BUILD_PROXY" ]; then
        proxy_args="--build-arg HTTP_PROXY=$DOCKER_BUILD_PROXY --build-arg HTTPS_PROXY=$DOCKER_BUILD_PROXY"
    fi
    
    # 构建镜像
    docker compose build $proxy_args new-api
    
    log_success "Docker 镜像构建完成: xfrouterapi:local"
}

# 启动服务
start_services() {
    log_info "启动服务..."
    
    # 停止现有服务
    docker compose down 2>/dev/null || true
    
    # 启动服务
    docker compose up -d
    
    # 等待服务启动
    log_info "等待服务启动..."
    sleep 5
    
    # 健康检查
    if curl -s http://localhost:3000/api/status > /dev/null; then
        log_success "服务启动成功!"
        log_info "访问地址: http://localhost:3000"
        log_info "API 状态: http://localhost:3000/api/status"
    else
        log_error "服务启动失败，请检查日志: docker compose logs new-api"
        exit 1
    fi
}

# 本地开发
dev_build() {
    log_info "=== 开发环境构建 ==="
    
    check_dependencies "dev"
    setup_proxy
    build_frontend
    
    log_info "开发环境构建完成!"
    log_info "前端资源位于: web/dist/"
    log_info "如需启动后端，请运行: go run ."
}

# 生产构建
prod_build() {
    log_info "=== 生产环境构建 ==="
    
    check_dependencies "prod"
    setup_proxy
    build_frontend
    build_docker
    start_services
    
    log_success "生产环境部署完成!"
}

# 仅构建 Docker 镜像
docker_build() {
    log_info "=== Docker 镜像构建 ==="
    
    check_dependencies "docker"
    setup_proxy
    build_docker
    
    log_success "Docker 镜像构建完成!"
    log_info "运行镜像: docker compose up -d"
}

# 清理构建产物
clean_build() {
    log_info "=== 清理构建产物 ==="
    
    # 清理前端
    rm -rf web/dist
    rm -rf web/.cache
    rm -rf web/.temp
    rm -rf web/node_modules/.cache
    
    # 清理 Docker
    docker compose down 2>/dev/null || true
    docker image prune -f 2>/dev/null || true
    docker system prune -f 2>/dev/null || true
    
    # 清理日志
    rm -f logs/*.log
    
    log_success "清理完成!"
}

# 主函数
main() {
    local command=${1:-"help"}
    
    case $command in
        "dev")
            dev_build
            ;;
        "prod")
            prod_build
            ;;
        "docker")
            docker_build
            ;;
        "clean")
            clean_build
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            log_error "未知命令: $command"
            show_help
            exit 1
            ;;
    esac
}

# 脚本入口
main "$@"
