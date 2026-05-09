#!/usr/bin/env bash
# rollback.sh — vision-toolkit 回滚脚本
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${SCRIPT_DIR}/lib/colors.sh"
source "${SCRIPT_DIR}/config/deploy.conf"
source "${SCRIPT_DIR}/lib/logger.sh"
source "${SCRIPT_DIR}/lib/utils.sh"

usage() {
    cat <<EOF
用法: $(basename "$0") [镜像标签]

将服务回滚到先前版本。不指定镜像时使用备份记录中的最后一次镜像。

示例:
  $(basename "$0")           使用备份记录回滚
  $(basename "$0") v1.0.0    回滚到指定镜像
  $(basename "$0") vision-toolkit:latest
EOF
}

main() {
    if [[ "${1:-}" =~ ^(-h|--help)$ ]]; then
        usage; exit 0
    fi

    logger_init

    local target="${1:-}"

    # 未指定则读备份
    if [[ -z "${target}" ]]; then
        if [[ -f "${BACKUP_DIR}/last-image.txt" ]]; then
            target="$(cat "${BACKUP_DIR}/last-image.txt")"
            log_info "从备份读取目标镜像：${target}"
        else
            log_error "未找到备份记录（${BACKUP_DIR}/last-image.txt）"
            log_error "请手动指定镜像：$(basename "$0") <镜像标签>"
            exit 1
        fi
    fi

    log_step "准备回滚到：${target}"

    # 检查镜像是否存在
    log_info "检查镜像是否可用..."
    if ! docker image inspect "${target}" >/dev/null 2>&1; then
        log_error "本地镜像不存在：${target}"
        log_error "可用镜像列表："
        docker images --format '  {{.Repository}}:{{.Tag}}' | sort
        exit 1
    fi
    log_ok "镜像存在"

    # 确认
    if ! confirm "确认将 app 服务回滚到 ${target}？"; then
        log_info "已取消"
        exit 0
    fi

    # 执行回滚
    export IMAGE_TAG="${target}"
    export SERVICE_PORT="${SERVICE_PORT:-8000}"

    log_step "停止当前服务"
    docker compose stop app 2>/dev/null || true
    docker compose rm -f app 2>/dev/null || true

    log_step "启动回滚版本"
    docker compose up -d app

    log_step "等待健康检查"
    wait_for_http "${HEALTHCHECK_URL}" "${HEALTHCHECK_TIMEOUT}" || {
        log_error "回滚失败：健康检查未通过"
        exit 1
    }

    log_ok "回滚成功，当前运行：${target}"
    echo "${target}" > "${BACKUP_DIR}/last-image.txt"
}

main "$@"
