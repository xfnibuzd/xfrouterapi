#!/bin/bash

# XFRouter API 服务启动脚本
# 支持多种启动模式和环境配置

set -e  # 遇到错误立即退出

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
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

log_step() {
    echo -e "${PURPLE}[STEP]${NC} $1"
}

log_debug() {
    if [ "$DEBUG" = "true" ]; then
        echo -e "${CYAN}[DEBUG]${NC} $1"
    fi
}

# 显示帮助信息
show_help() {
    cat << EOF
XFRouter API 服务启动脚本

使用方法:
  ./start.sh [模式] [选项]

启动模式:
  dev      - 开发环境 (前端热重载 + 后端开发服务器)
  prod     - 生产环境 (Docker 容器)
  docker   - 仅启动 Docker 容器
  backend  - 仅启动后端开发服务器
  frontend - 仅启动前端开发服务器

选项:
  --check      - 启动前检查依赖
  --build      - 启动前构建项目
  --clean      - 启动前清理旧服务
  --port PORT  - 指定端口 (默认: 3000)
  --debug      - 启用调试模式
  --watch      - 监控文件变化 (开发模式)
  --logs       - 启动后显示日志

示例:
  ./start.sh dev --build --watch    # 开发环境 + 构建 + 文件监控
  ./start.sh prod --check           # 生产环境 + 依赖检查
  ./start.sh docker --port 3001     # Docker + 自定义端口
  ./start.sh backend --debug        # 后端 + 调试模式

EOF
}

# 检查依赖
check_dependencies() {
    local mode=$1
    
    log_step "检查系统依赖..."
    
    # 检查基础命令
    local required_commands=("curl" "lsof")
    for cmd in "${required_commands[@]}"; do
        if ! command -v $cmd &> /dev/null; then
            log_error "缺少必需命令: $cmd"
            exit 1
        fi
    done
    
    case $mode in
        "dev"|"frontend")
            # 检查 Node.js
            if ! command -v node &> /dev/null; then
                log_error "Node.js 未安装，请先安装 Node.js >= 18"
                exit 1
            fi
            
            # 检查包管理器
            if command -v bun &> /dev/null; then
                PKG_MANAGER="bun"
                PKG_DEV="bun run dev"
                PKG_INSTALL="bun install"
            elif command -v npm &> /dev/null; then
                PKG_MANAGER="npm"
                PKG_DEV="npm run dev"
                PKG_INSTALL="npm install"
            else
                log_error "未找到包管理器 (bun 或 npm)"
                exit 1
            fi
            log_info "使用包管理器: $PKG_MANAGER"
            ;;
            
        "backend")
            # 检查 Go
            if ! command -v go &> /dev/null; then
                log_error "Go 未安装，请先安装 Go >= 1.22"
                exit 1
            fi
            log_info "Go 版本: $(go version)"
            ;;
            
        "prod"|"docker")
            # 检查 Docker
            if ! command -v docker &> /dev/null; then
                log_error "Docker 未安装，请先安装 Docker"
                exit 1
            fi
            
            if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
                log_error "Docker Compose 未安装，请先安装 Docker Compose"
                exit 1
            fi
            log_info "Docker 版本: $(docker --version)"
            ;;
    esac
    
    log_success "依赖检查通过"
}

# 设置代理
setup_proxy() {
    if [ -n "$HTTP_PROXY" ] || [ -n "$HTTPS_PROXY" ]; then
        log_info "使用环境变量代理: HTTP_PROXY=$HTTP_PROXY"
        return 0
    fi
    
    # 自动检测代理
    for port in 7890 7897 8888 1087; do
        if curl -s --connect-timeout 2 --proxy "http://127.0.0.1:$port" https://www.google.com > /dev/null 2>&1; then
            log_info "检测到代理端口: $port"
            export HTTP_PROXY="http://127.0.0.1:$port"
            export HTTPS_PROXY="http://127.0.0.1:$port"
            return 0
        fi
    done
    
    log_info "未检测到代理，使用直连"
}

# 检查端口占用
check_port() {
    local port=${1:-3000}
    
    if lsof -i :$port &> /dev/null; then
        log_warning "端口 $port 已被占用:"
        lsof -i :$port
        return 1
    fi
    return 0
}

# 构建项目
build_project() {
    local mode=$1
    
    log_step "构建项目..."
    
    case $mode in
        "dev"|"frontend")
            # 构建前端
            cd web
            log_info "安装前端依赖..."
            $PKG_INSTALL
            
            if [ "$mode" = "frontend" ]; then
                cd ..
                return 0
            fi
            ;;
        "prod"|"docker")
            # 检查前端构建
            if [ ! -d "web/dist" ]; then
                log_info "前端未构建，开始构建..."
                ./build.sh dev
            fi
            ;;
    esac
    
    log_success "项目构建完成"
}

# 清理旧服务
clean_services() {
    log_step "清理旧服务..."
    
    # 使用停止脚本清理
    if [ -f "./stop.sh" ]; then
        ./stop.sh all 2>/dev/null || true
    fi
    
    # 等待端口释放
    sleep 2
    
    log_success "服务清理完成"
}

# 启动前端开发服务器
start_frontend() {
    local port=${1:-3000}
    
    log_step "启动前端开发服务器..."
    
    cd web
    
    # 设置端口环境变量
    export PORT=$port
    
    log_info "前端服务器将启动在端口: $port"
    log_info "访问地址: http://localhost:$port"
    
    if [ "$WATCH" = "true" ]; then
        log_info "文件监控已启用"
    fi
    
    # 启动开发服务器
    if [ "$WATCH" = "true" ]; then
        $PKG_DEV
    else
        $PKG_DEV --no-watch 2>/dev/null || $PKG_DEV
    fi
    
    cd ..
}

# 启动后端开发服务器
start_backend() {
    local port=${1:-3000}
    
    log_step "启动后端开发服务器..."
    
    # 检查配置文件
    if [ ! -f "go.mod" ]; then
        log_error "未找到 go.mod 文件"
        exit 1
    fi
    
    # 设置环境变量
    export PORT=$port
    
    if [ "$DEBUG" = "true" ]; then
        export GIN_MODE=debug
        log_info "调试模式已启用"
    fi
    
    log_info "后端服务器将启动在端口: $port"
    log_info "API 地址: http://localhost:$port/api/status"
    
    # 启动 Go 服务器
    if [ "$WATCH" = "true" ]; then
        # 使用 air 进行热重载 (如果安装了)
        if command -v air &> /dev/null; then
            log_info "使用 air 热重载"
            air
        else
            log_info "热重载需要安装 air: go install github.com/cosmtrek/air@latest"
            go run .
        fi
    else
        go run .
    fi
}

# 启动开发环境
start_dev() {
    local port=${1:-3000}
    
    log_step "启动开发环境..."
    
    # 检查端口
    if ! check_port $port; then
        log_error "端口 $port 被占用，请先停止相关服务或使用其他端口"
        exit 1
    fi
    
    # 构建项目
    if [ "$BUILD" = "true" ]; then
        build_project "dev"
    fi
    
    # 启动服务
    if [ "$WATCH" = "true" ]; then
        log_info "开发模式: 前端热重载 + 后端开发服务器"
        
        # 后台启动后端
        log_info "后台启动后端服务器..."
        start_backend $port &
        BACKEND_PID=$!
        
        # 等待后端启动
        sleep 3
        
        # 前台启动前端
        log_info "前台启动前端服务器..."
        start_frontend $port
        
        # 清理后台进程
        kill $BACKEND_PID 2>/dev/null || true
    else
        log_info "仅启动前端开发服务器"
        start_frontend $port
    fi
}

# 启动生产环境
start_prod() {
    local port=${1:-3000}
    
    log_step "启动生产环境..."
    
    # 检查 Docker
    if ! docker ps &> /dev/null; then
        log_error "Docker 服务未运行，请先启动 Docker"
        exit 1
    fi
    
    # 构建项目
    if [ "$BUILD" = "true" ]; then
        log_info "构建生产环境..."
        ./build.sh prod
        return 0
    fi
    
    # 检查镜像
    if ! docker images | grep -q "xfrouterapi:local"; then
        log_warning "未找到本地镜像，开始构建..."
        ./build.sh docker
    fi
    
    # 启动容器
    log_info "启动 Docker 容器..."
    
    # 修改端口映射 (如果需要)
    if [ "$port" != "3000" ]; then
        log_info "使用端口: $port"
        # 这里可以动态修改 docker-compose.yml 或使用环境变量
    fi
    
    docker compose up -d
    
    # 等待服务启动
    log_info "等待服务启动..."
    sleep 5
    
    # 健康检查
    if curl -s http://localhost:$port/api/status > /dev/null; then
        log_success "生产环境启动成功!"
        log_info "访问地址: http://localhost:$port"
        log_info "API 状态: http://localhost:$port/api/status"
        
        if [ "$LOGS" = "true" ]; then
            log_info "显示服务日志..."
            docker compose logs -f new-api
        fi
    else
        log_error "服务启动失败，请检查日志: docker compose logs new-api"
        exit 1
    fi
}

# 启动 Docker 容器
start_docker() {
    local port=${1:-3000}
    
    log_step "启动 Docker 容器..."
    
    # 检查 Docker
    if ! docker ps &> /dev/null; then
        log_error "Docker 服务未运行"
        exit 1
    fi
    
    # 启动容器
    docker compose up -d
    
    # 等待启动
    sleep 3
    
    # 检查状态
    if curl -s http://localhost:$port/api/status > /dev/null; then
        log_success "Docker 容器启动成功!"
        log_info "访问地址: http://localhost:$port"
        
        if [ "$LOGS" = "true" ]; then
            docker compose logs -f new-api
        fi
    else
        log_error "容器启动失败"
        docker compose logs new-api
        exit 1
    fi
}

# 显示服务状态
show_status() {
    local port=${1:-3000}
    
    log_step "检查服务状态..."
    
    # 检查端口
    if lsof -i :$port &> /dev/null; then
        log_success "端口 $port 正在使用"
        lsof -i :$port
    else
        log_warning "端口 $port 未使用"
    fi
    
    # 检查 API
    if curl -s http://localhost:$port/api/status > /dev/null; then
        log_success "API 服务正常"
        curl -s http://localhost:$port/api/status | jq '.data.version' 2>/dev/null || echo "版本信息获取失败"
    else
        log_warning "API 服务无响应"
    fi
    
    # 检查 Docker 容器
    if docker ps --format "table {{.Names}}\t{{.Status}}" | grep -q "new-api"; then
        log_success "Docker 容器运行中"
        docker ps --format "table {{.Names}}\t{{.Status}}" | grep new-api
    else
        log_warning "Docker 容器未运行"
    fi
}

# 主函数
main() {
    local mode=${1:-"help"}
    shift
    
    # 解析参数
    BUILD=false
    CLEAN=false
    CHECK=false
    PORT=3000
    DEBUG=false
    WATCH=false
    LOGS=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --check)
                CHECK=true
                shift
                ;;
            --build)
                BUILD=true
                shift
                ;;
            --clean)
                CLEAN=true
                shift
                ;;
            --port)
                PORT="$2"
                shift 2
                ;;
            --debug)
                DEBUG=true
                shift
                ;;
            --watch)
                WATCH=true
                shift
                ;;
            --logs)
                LOGS=true
                shift
                ;;
            *)
                log_error "未知参数: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # 设置代理
    setup_proxy
    
    # 执行相应操作
    case $mode in
        "dev")
            log_info "=== 开发环境启动 ==="
            [ "$CHECK" = "true" ] && check_dependencies "dev"
            [ "$CLEAN" = "true" ] && clean_services
            start_dev $PORT
            ;;
        "prod")
            log_info "=== 生产环境启动 ==="
            [ "$CHECK" = "true" ] && check_dependencies "prod"
            [ "$CLEAN" = "true" ] && clean_services
            start_prod $PORT
            ;;
        "docker")
            log_info "=== Docker 容器启动 ==="
            [ "$CHECK" = "true" ] && check_dependencies "docker"
            [ "$CLEAN" = "true" ] && clean_services
            start_docker $PORT
            ;;
        "backend")
            log_info "=== 后端服务器启动 ==="
            [ "$CHECK" = "true" ] && check_dependencies "backend"
            [ "$CLEAN" = "true" ] && clean_services
            start_backend $PORT
            ;;
        "frontend")
            log_info "=== 前端服务器启动 ==="
            [ "$CHECK" = "true" ] && check_dependencies "frontend"
            start_frontend $PORT
            ;;
        "status")
            show_status $PORT
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            log_error "未知模式: $mode"
            show_help
            exit 1
            ;;
    esac
}

# 脚本入口
main "$@"
