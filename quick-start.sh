#!/bin/bash

# XFRouter API 快速启动脚本
# 最常用的启动命令组合

set -e

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# 显示快速选项
show_quick_menu() {
    cat << EOF
XFRouter API 快速启动

1) 开发环境 - 前端热重载 + 后端开发服务器
2) 生产环境 - Docker 容器部署
3) 仅前端 - 前端开发服务器
4) 仅后端 - 后端开发服务器
5) 停止所有服务
6) 重启服务
7) 检查状态
8) 完全清理

请选择 (1-8): 
EOF
}

# 快速开发环境
quick_dev() {
    log_info "启动开发环境..."
    ./start.sh dev --clean --build --watch
}

# 快速生产环境
quick_prod() {
    log_info "启动生产环境..."
    ./start.sh prod --clean --build
}

# 仅前端
quick_frontend() {
    log_info "启动前端服务器..."
    ./start.sh frontend --build
}

# 仅后端
quick_backend() {
    log_info "启动后端服务器..."
    ./start.sh backend --debug
}

# 停止服务
quick_stop() {
    log_info "停止所有服务..."
    ./stop.sh all
}

# 重启服务
quick_restart() {
    log_info "重启服务..."
    ./stop.sh all
    sleep 2
    ./start.sh prod --build
}

# 检查状态
quick_status() {
    log_info "检查服务状态..."
    ./start.sh status
}

# 完全清理
quick_clean() {
    log_info "完全清理..."
    ./stop.sh clean
    ./build.sh clean
}

# 交互式菜单
interactive_mode() {
    while true; do
        show_quick_menu
        read -p "" choice
        case $choice in
            1)
                quick_dev
                break
                ;;
            2)
                quick_prod
                break
                ;;
            3)
                quick_frontend
                break
                ;;
            4)
                quick_backend
                break
                ;;
            5)
                quick_stop
                break
                ;;
            6)
                quick_restart
                break
                ;;
            7)
                quick_status
                break
                ;;
            8)
                quick_clean
                break
                ;;
            q|Q|exit)
                log_info "退出"
                exit 0
                ;;
            *)
                log_warning "无效选择，请输入 1-8"
                ;;
        esac
    done
}

# 主函数
main() {
    local command=${1:-"interactive"}
    
    case $command in
        "dev"|"1")
            quick_dev
            ;;
        "prod"|"2")
            quick_prod
            ;;
        "frontend"|"3")
            quick_frontend
            ;;
        "backend"|"4")
            quick_backend
            ;;
        "stop"|"5")
            quick_stop
            ;;
        "restart"|"6")
            quick_restart
            ;;
        "status"|"7")
            quick_status
            ;;
        "clean"|"8")
            quick_clean
            ;;
        "interactive"|"menu"|"")
            interactive_mode
            ;;
        "help"|"-h"|"--help")
            echo "XFRouter API 快速启动"
            echo ""
            echo "用法:"
            echo "  ./quick-start.sh [命令]"
            echo ""
            echo "命令:"
            echo "  dev, 1        - 开发环境"
            echo "  prod, 2       - 生产环境"
            echo "  frontend, 3   - 仅前端"
            echo "  backend, 4    - 仅后端"
            echo "  stop, 5       - 停止服务"
            echo "  restart, 6    - 重启服务"
            echo "  status, 7     - 检查状态"
            echo "  clean, 8      - 完全清理"
            echo "  menu, 交互式   - 交互式菜单 (默认)"
            echo ""
            echo "示例:"
            echo "  ./quick-start.sh dev     # 开发环境"
            echo "  ./quick-start.sh prod    # 生产环境"
            echo "  ./quick-start.sh         # 交互式菜单"
            ;;
        *)
            log_warning "未知命令: $command"
            echo "使用 './quick-start.sh help' 查看帮助"
            exit 1
            ;;
    esac
}

# 脚本入口
main "$@"
