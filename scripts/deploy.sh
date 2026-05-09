#!/usr/bin/env bash
# deploy.sh — vision-toolkit 主部署脚本
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${SCRIPT_DIR}/lib/colors.sh"
source "${SCRIPT_DIR}/config/deploy.conf"
source "${SCRIPT_DIR}/lib/logger.sh"
source "${SCRIPT_DIR}/lib/utils.sh"
source "${SCRIPT_DIR}/lib/preflight.sh"

# ---- defaults ----
DRY_RUN=0
SKIP_TESTS=0
SKIP_BUILD=0
REMOTE_HOST=""

# ---- error handler ----
on_error() {
    local line="${1:-?}"
    log_error "脚本第 ${line} 行出错，部署中止"
    exit 1
}
trap 'on_error ${LINENO}' ERR

# ---- usage ----
usage() {
    cat <<EOF
用法: $(basename "$0") [选项]

vision-toolkit 一键部署脚本 — 构建并启动生产服务。

选项:
  -n, --dry-run        仅打印操作，不真正执行
  -t, --image-tag TAG  指定镜像标签（默认 latest）
  --skip-tests         跳过部署后的冒烟测试
  --skip-build         跳过镜像构建（使用已存在的镜像）
  -r, --remote HOST    远程部署到指定 SSH 主机
  -h, --help           显示此帮助

示例:
  $(basename "$0")                       本地完整部署
  $(basename "$0") --dry-run             预演
  $(basename "$0") -t v1.0 --skip-build  使用 v1.0 标签，跳过构建
  $(basename "$0") -r myserver.com       远程部署
EOF
}

# ---- dry-run wrapper ----
run() {
    if (( DRY_RUN )); then
        log_info "[DRY-RUN] $*"
    else
        "$@"
    fi
}

# ---- business steps ----
step_init() {
    logger_init
    log_step "vision-toolkit 部署开始"
    log_info "项目路径：${PROJECT_ROOT}"
    log_info "镜像标签：${IMAGE_TAG:-latest}"
    (( DRY_RUN )) && log_warn "DRY-RUN 模式：只打印，不执行"
}

step_preflight() {
    run_preflight
}

step_backup() {
    log_step "备份当前运行状态"
    mkdir -p "${BACKUP_DIR}"

    local current
    current=$(docker ps -a --filter "name=${PROJECT_NAME}" --format '{{.Image}}' 2>/dev/null || echo "")

    if [[ -n "${current}" ]]; then
        if (( DRY_RUN )); then
            log_info "[DRY-RUN] 记录镜像：${current}"
        else
            echo "${current}" > "${BACKUP_DIR}/last-image.txt"
            log_ok "已记录当前镜像：${current}"
        fi
    else
        log_info "未发现现有容器，跳过备份"
    fi
}

step_pull_source() {
    if [[ -n "${REMOTE_HOST}" ]]; then
        remote_sync "${REMOTE_HOST}"
    else
        log_info "本地部署，跳过代码同步"
    fi
}

step_build() {
    if (( SKIP_BUILD )); then
        log_warn "--skip-build：跳过镜像构建"
        return 0
    fi

    log_step "构建 Docker 镜像"
    local tag="${IMAGE_TAG:-latest}"
    export IMAGE_TAG="${tag}"
    run docker compose build app
    log_ok "镜像构建完成"
}

step_deploy() {
    log_step "启动服务"
    export SERVICE_PORT="${SERVICE_PORT:-8000}"
    export IMAGE_TAG="${IMAGE_TAG:-latest}"
    run docker compose up -d app
    log_ok "服务已启动"
}

step_wait_healthy() {
    log_step "等待健康检查通过"
    if (( DRY_RUN )); then
        log_info "[DRY-RUN] wait_for_http ${HEALTHCHECK_URL}"
        return 0
    fi
    wait_for_http "${HEALTHCHECK_URL}" "${HEALTHCHECK_TIMEOUT}"
    log_ok "健康检查通过"
}

step_smoke_test() {
    if (( SKIP_TESTS )); then
        log_warn "--skip-tests：跳过冒烟测试"
        return 0
    fi

    log_step "冒烟测试"
    if (( DRY_RUN )); then
        log_info "[DRY-RUN] curl ${HEALTHCHECK_URL}"
        return 0
    fi
    local code
    code=$(curl -sS -o /dev/null -w '%{http_code}' --max-time 5 "${HEALTHCHECK_URL}" 2>/dev/null || echo "000")
    if [[ "${code}" != "200" ]]; then
        log_error "冒烟测试失败：HTTP ${code}"
        return 1
    fi
    log_ok "冒烟测试通过（HTTP 200）"
}

# ---- entry ----
main() {
    while (( $# )); do
        case "$1" in
            -n|--dry-run)   DRY_RUN=1 ;;
            -t|--image-tag) IMAGE_TAG="$2"; shift ;;
            --skip-tests)   SKIP_TESTS=1 ;;
            --skip-build)   SKIP_BUILD=1 ;;
            -r|--remote)    REMOTE_HOST="$2"; shift ;;
            -h|--help)      usage; exit 0 ;;
            *)              log_error "未知选项：$1"; usage >&2; exit 2 ;;
        esac
        shift
    done

    step_init
    step_preflight
    step_backup
    step_pull_source
    step_build
    step_deploy
    step_wait_healthy
    step_smoke_test

    log_step "部署完成"
    echo ""
    log_ok "服务运行在 http://localhost:${SERVICE_PORT}"
    log_info "健康检查：${HEALTHCHECK_URL}"
}

main "$@"
