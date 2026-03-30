#!/bin/bash

# XFRouter API 服务停止脚本
# 停止所有相关服务并清理资源

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
XFRouter API 服务停止脚本

使用方法:
  ./stop.sh [选项]

选项:
  all     - 停止所有服务 (默认)
  docker  - 仅停止 Docker 服务
  backend - 仅停止后端进程
  clean   - 停止服务并清理资源
  force   - 强制停止所有相关进程
  help    - 显示此帮助信息

示例:
  ./stop.sh         # 停止所有服务
  ./stop.sh docker  # 仅停止 Docker 容器
  ./stop.sh clean   # 停止服务并清理
  ./stop.sh force   # 强制停止

EOF
}

# 停止 Docker 服务
stop_docker() {
    log_info "停止 Docker 服务..."
    
    # 检查 docker-compose 是否存在
    if [ -f "docker-compose.yml" ] || [ -f "docker-compose.yaml" ]; then
        # 停止并移除容器
        if command -v docker-compose &> /dev/null; then
            docker-compose down --remove-orphans 2>/dev/null || true
        elif docker compose version &> /dev/null; then
            docker compose down --remove-orphans 2>/dev/null || true
        fi
        
        # 移除相关容器（包括可能存在的孤立容器）
        docker ps -a --filter "name=new-api" --format "{{.Names}}" | xargs -r docker rm -f 2>/dev/null || true
        docker ps -a --filter "name=postgres" --format "{{.Names}}" | xargs -r docker rm -f 2>/dev/null || true
        docker ps -a --filter "name=redis" --format "{{.Names}}" | xargs -r docker rm -f 2>/dev/null || true
        
        log_success "Docker 服务已停止"
    else
        log_warning "未找到 docker-compose 配置文件"
    fi
}

# 停止后端进程
stop_backend() {
    log_info "停止后端进程..."
    
    # 查找并停止 Go 进程
    local go_pids=$(pgrep -f "go run" 2>/dev/null || true)
    if [ -n "$go_pids" ]; then
        echo "$go_pids" | xargs kill -TERM 2>/dev/null || true
        sleep 2
        echo "$go_pids" | xargs kill -KILL 2>/dev/null || true
        log_success "后端开发服务器已停止"
    fi
    
    # 查找并停止 new-api 二进制进程
    local api_pids=$(pgrep -f "new-api" 2>/dev/null || true)
    if [ -n "$api_pids" ]; then
        echo "$api_pids" | xargs kill -TERM 2>/dev/null || true
        sleep 2
        echo "$api_pids" | xargs kill -KILL 2>/dev/null || true
        log_success "new-api 进程已停止"
    fi
    
    # 查找并停止监听 3000 端口的进程
    local port_pids=$(lsof -ti:3000 2>/dev/null || true)
    if [ -n "$port_pids" ]; then
        echo "$port_pids" | xargs kill -TERM 2>/dev/null || true
        sleep 2
        echo "$port_pids" | xargs kill -KILL 2>/dev/null || true
        log_success "端口 3000 进程已停止"
    fi
}

# 强制停止所有相关进程
force_stop() {
    log_warning "强制停止所有相关进程..."
    
    # 强制停止所有 Go 相关进程
    pkill -f "go run" 2>/dev/null || true
    pkill -f "new-api" 2>/dev/null || true
    pkill -f "main.go" 2>/dev/null || true
    
    # 强制停止占用 3000 端口的进程
    lsof -ti:3000 | xargs kill -9 2>/dev/null || true
    
    # 强制停止 Docker 容器
    docker ps --filter "name=new-api" --format "{{.Names}}" | xargs -r docker kill 2>/dev/null || true
    docker ps --filter "name=postgres" --format "{{.Names}}" | xargs -r docker kill 2>/dev/null || true
    docker ps --filter "name=redis" --format "{{.Names}}" | xargs -r docker kill 2>/dev/null || true
    
    sleep 2
    
    log_success "强制停止完成"
}

# 清理资源
clean_resources() {
    log_info "清理系统资源..."
    
    # 清理 Docker 资源
    if command -v docker &> /dev/null; then
        # 停止所有容器
        docker stop $(docker ps -q) 2>/dev/null || true
        
        # 清理未使用的镜像、容器、网络
        docker system prune -f 2>/dev/null || true
        
        # 清理构建缓存
        docker builder prune -f 2>/dev/null || true
        
        log_success "Docker 资源清理完成"
    fi
    
    # 清理临时文件
    rm -rf /tmp/new-api-* 2>/dev/null || true
    rm -rf /tmp/go-build-* 2>/dev/null || true
    
    # 清理日志文件（可选）
    if [ -d "logs" ]; then
        # 保留最近的日志，删除旧日志
        find logs -name "*.log" -mtime +7 -delete 2>/dev/null || true
        log_info "日志文件清理完成"
    fi
    
    log_success "资源清理完成"
}

# 检查服务状态
check_status() {
    log_info "检查服务状态..."
    
    # 检查 Docker 容器
    local running_containers=$(docker ps --filter "name=new-api" --format "{{.Names}}" 2>/dev/null || true)
    if [ -n "$running_containers" ]; then
        log_warning "仍在运行的 Docker 容器: $running_containers"
    else
        log_success "没有运行的 Docker 容器"
    fi
    
    # 检查端口占用
    local port_usage=$(lsof -i:3000 2>/dev/null || true)
    if [ -n "$port_usage" ]; then
        log_warning "端口 3000 仍在使用:"
        echo "$port_usage"
    else
        log_success "端口 3000 已释放"
    fi
    
    # 检查进程
    local go_processes=$(pgrep -f "go run\|new-api" 2>/dev/null || true)
    if [ -n "$go_processes" ]; then
        log_warning "仍在运行的 Go 进程: $go_processes"
    else
        log_success "没有运行的后端进程"
    fi
}

# 主函数
main() {
    local command=${1:-"all"}
    
    case $command in
        "all")
            log_info "=== 停止所有服务 ==="
            stop_docker
            stop_backend
            check_status
            ;;
        "docker")
            log_info "=== 停止 Docker 服务 ==="
            stop_docker
            check_status
            ;;
        "backend")
            log_info "=== 停止后端服务 ==="
            stop_backend
            check_status
            ;;
        "clean")
            log_info "=== 停止服务并清理 ==="
            stop_docker
            stop_backend
            clean_resources
            check_status
            ;;
        "force")
            log_info "=== 强制停止 ==="
            force_stop
            check_status
            ;;
        "status")
            check_status
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
