FRONTEND_DIR = ./web
BACKEND_DIR = .
VERSION_FILE = ./VERSION

# 颜色输出
GREEN := \033[0;32m
YELLOW := \033[1;33m
NC := \033[0m

.PHONY: all build dev prod docker clean help frontend backend test stop restart status start refresh

# 默认目标
all: build

# 开发环境
dev:
	@echo "$(YELLOW)[DEV]$(NC) 开发环境构建..."
	@./build.sh dev

# 生产环境
prod:
	@echo "$(YELLOW)[PROD]$(NC) 生产环境构建..."
	@./build.sh prod

# 仅构建 Docker 镜像
docker:
	@echo "$(YELLOW)[DOCKER]$(NC) 构建 Docker 镜像..."
	@./build.sh docker

# 停止所有服务
stop:
	@echo "$(YELLOW)[STOP]$(NC) 停止所有服务..."
	@./stop.sh all

# 强制停止
stop-force:
	@echo "$(YELLOW)[STOP-FORCE]$(NC) 强制停止所有服务..."
	@./stop.sh force

# 仅停止 Docker
stop-docker:
	@echo "$(YELLOW)[STOP-DOCKER]$(NC) 停止 Docker 服务..."
	@./stop.sh docker

# 重启服务
restart: stop prod
	@echo "$(GREEN)[SUCCESS]$(NC) 服务重启完成"

# 检查状态
status:
	@echo "$(YELLOW)[STATUS]$(NC) 检查服务状态..."
	@./stop.sh status

# 清理构建产物
clean:
	@echo "$(YELLOW)[CLEAN]$(NC) 清理构建产物..."
	@./build.sh clean

# 完全清理
clean-all: stop clean
	@echo "$(GREEN)[SUCCESS]$(NC) 完全清理完成"

# 启动开发环境
start:
	@echo "$(YELLOW)[START]$(NC) 启动开发环境..."
	@./start.sh dev

# 启动生产环境
start-prod:
	@echo "$(YELLOW)[START-PROD]$(NC) 启动生产环境..."
	@./start.sh prod

# 一键刷新（重建并启动）
refresh:
	@echo "$(YELLOW)[REFRESH]$(NC) 重建并启动服务..."
	@./start.sh prod

# 启动 Docker
start-docker:
	@echo "$(YELLOW)[START-DOCKER]$(NC) 启动 Docker 容器..."
	@./start.sh docker

# 仅启动后端
start-backend:
	@echo "$(YELLOW)[START-BACKEND]$(NC) 启动后端服务器..."
	@./start.sh backend

# 仅启动前端
start-frontend:
	@echo "$(YELLOW)[START-FRONTEND]$(NC) 启动前端服务器..."
	@./start.sh frontend

# 检查服务状态
check-status:
	@echo "$(YELLOW)[CHECK]$(NC) 检查服务状态..."
	@./start.sh status

# 快速启动菜单
quick:
	@echo "$(YELLOW)[QUICK]$(NC) 快速启动菜单..."
	@./quick-start.sh

# 构建前端
frontend:
	@echo "$(YELLOW)[FRONTEND]$(NC) 构建前端..."
	@cd $(FRONTEND_DIR) && \
		if command -v bun >/dev/null 2>&1; then \
			bun install && DISABLE_ESLINT_PLUGIN='true' VITE_REACT_APP_VERSION=$$(cat $(VERSION_FILE)) bun run build; \
		else \
			npm install --prefer-offline --legacy-peer-deps && DISABLE_ESLINT_PLUGIN='true' VITE_REACT_APP_VERSION=$$(cat $(VERSION_FILE)) npm run build; \
		fi
	@echo "$(GREEN)[SUCCESS]$(NC) 前端构建完成"

# 启动后端开发服务器
backend:
	@echo "$(YELLOW)[BACKEND]$(NC) 启动后端开发服务器..."
	@cd $(BACKEND_DIR) && go run .

# 运行测试
test:
	@echo "$(YELLOW)[TEST]$(NC) 运行测试..."
	@go test ./...

# 构建完整项目
build: frontend
	@echo "$(GREEN)[SUCCESS]$(NC) 项目构建完成"

# 显示帮助
help:
	@echo "XFRouter API 完整管理系统"
	@echo ""
	@echo "构建命令:"
	@echo "  make dev         - 开发环境构建"
	@echo "  make prod        - 生产环境构建"
	@echo "  make docker      - 仅构建 Docker 镜像"
	@echo "  make frontend    - 仅构建前端"
	@echo "  make backend     - 启动后端开发服务器"
	@echo "  make test        - 运行测试"
	@echo ""
	@echo "启动命令:"
	@echo "  make start       - 启动开发环境"
	@echo "  make start-prod  - 启动生产环境"
	@echo "  make refresh     - 重建并启动服务"
	@echo "  make start-docker- 启动 Docker 容器"
	@echo "  make start-backend- 仅启动后端"
	@echo "  make start-frontend- 仅启动前端"
	@echo "  make check-status - 检查服务状态"
	@echo ""
	@echo "服务管理:"
	@echo "  make stop        - 停止所有服务"
	@echo "  make stop-force  - 强制停止所有服务"
	@echo "  make stop-docker - 仅停止 Docker 服务"
	@echo "  make restart     - 重启服务"
	@echo "  make status      - 检查服务状态"
	@echo ""
	@echo "清理命令:"
	@echo "  make clean       - 清理构建产物"
	@echo "  make clean-all   - 完全清理"
	@echo ""
	@echo "快捷方式:"
	@echo "  ./build.sh dev    - 同 make dev"
	@echo "  ./build.sh prod   - 同 make prod"
	@echo "  ./build.sh docker - 同 make docker"
	@echo "  ./start.sh dev    - 同 make start"
	@echo "  ./start.sh prod   - 同 make start-prod"
	@echo "  ./stop.sh all     - 同 make stop"
	@echo "  ./stop.sh status  - 同 make status"
