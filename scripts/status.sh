#!/usr/bin/env bash
# status.sh — vision-toolkit 服务状态查看
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${SCRIPT_DIR}/lib/colors.sh"
source "${SCRIPT_DIR}/config/deploy.conf"
source "${SCRIPT_DIR}/lib/logger.sh"

usage() {
    cat <<EOF
用法: $(basename "$0") [--json]

查看 ${PROJECT_NAME} 服务运行状态。退出码对 systemd 友好（0=健康，非0=异常）。

示例:
  $(basename "$0")         文本格式状态
  $(basename "$0") --json  JSON 格式状态
EOF
}

get_container_info() {
    docker ps --filter "name=${PROJECT_NAME}" --format '{{.ID}}|{{.Image}}|{{.Status}}|{{.Ports}}' 2>/dev/null || echo ""
}

check_http() {
    curl -sS -o /dev/null -w '%{http_code}' --max-time 3 "${HEALTHCHECK_URL}" 2>/dev/null || echo "000"
}

print_text_status() {
    local info="$1" http_code="$2"

    echo ""
    echo -e "${C_BOLD}=== ${PROJECT_NAME} 状态 ===${C_RESET}"
    echo ""

    if [[ -z "${info}" ]]; then
        echo -e "  ${C_RED}状态：未运行${C_RESET}"
        echo ""
        return 1
    fi

    IFS='|' read -r id image status ports <<< "${info}"

    echo "  容器 ID：    ${id:0:12}"
    echo "  镜像：       ${image}"
    echo "  运行状态：   ${status}"
    echo "  端口映射：   ${ports:-未暴露}"
    echo "  HTTP 状态：  ${http_code}"

    if [[ "${http_code}" == "200" ]]; then
        echo -e "  ${C_GREEN}结论：      HEALTHY${C_RESET}"
    else
        echo -e "  ${C_RED}结论：      UNHEALTHY${C_RESET}"
    fi
    echo ""
    [[ "${http_code}" == "200" ]]
}

print_json_status() {
    local info="$1" http_code="$2"

    if [[ -z "${info}" ]]; then
        echo '{"status":"not_running","healthy":false}'
        return 1
    fi

    IFS='|' read -r id image status ports <<< "${info}"
    local healthy="false"
    [[ "${http_code}" == "200" ]] && healthy="true"

    printf '{\n'
    printf '  "status": "running",\n'
    printf '  "container_id": "%s",\n' "${id:0:12}"
    printf '  "image": "%s",\n' "${image}"
    printf '  "docker_status": "%s",\n' "${status}"
    printf '  "ports": "%s",\n' "${ports:-none}"
    printf '  "health_check_url": "%s",\n' "${HEALTHCHECK_URL}"
    printf '  "http_code": %s,\n' "${http_code}"
    printf '  "healthy": %s\n' "${healthy}"
    printf '}\n'
    [[ "${http_code}" == "200" ]]
}

main() {
    local json=0
    while (( $# )); do
        case "$1" in
            --json)     json=1 ;;
            -h|--help)  usage; exit 0 ;;
            *)          log_error "未知选项：$1"; usage >&2; exit 2 ;;
        esac
        shift
    done

    local info http_code
    info="$(get_container_info)"
    http_code="$(check_http)"

    if (( json )); then
        print_json_status "${info}" "${http_code}" && exit 0 || exit 1
    else
        print_text_status "${info}" "${http_code}" && exit 0 || exit 1
    fi
}

main "$@"
