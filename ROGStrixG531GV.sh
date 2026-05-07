#!/usr/bin/env bash
set -euo pipefail

SCRIPT_NAME="$(basename "$0")"
MODE_FILE="/etc/rogauracore-mode"
APPLY_HELPER="/usr/local/bin/rogauracore-apply.sh"
SERVICE_FILE="/etc/systemd/system/rogauracore-persist.service"
VALID_MODES="black white blue green yellow cyan magenta rainbow"

usage() {
	cat <<EOF
Usage:
	./${SCRIPT_NAME} install [mode]
	./${SCRIPT_NAME} set-mode <mode>
	./${SCRIPT_NAME} apply-now
	./${SCRIPT_NAME} status
	./${SCRIPT_NAME} uninstall

Modes: ${VALID_MODES}

Examples:
	./${SCRIPT_NAME} install rainbow
	./${SCRIPT_NAME} set-mode blue
EOF
}

require_ubuntu() {
	if [[ ! -f /etc/os-release ]]; then
		echo "Cannot detect distro: /etc/os-release is missing."
		exit 1
	fi
	# shellcheck source=/etc/os-release
	. /etc/os-release
	if [[ "${ID:-}" != "ubuntu" && "${ID_LIKE:-}" != *"debian"* ]]; then
		echo "This installer currently supports Ubuntu/Debian-based systems only."
		exit 1
	fi
}

require_mode() {
	local mode="$1"
	if ! echo " ${VALID_MODES} " | grep -q " ${mode} "; then
		echo "Invalid mode: ${mode}"
		echo "Valid modes: ${VALID_MODES}"
		exit 1
	fi
}

install_deps() {
	echo "[1/6] Installing build dependencies"
	sudo apt-get update
	sudo apt-get install -y \
		git \
		build-essential \
		autoconf \
		automake \
		libtool \
		pkg-config \
		libusb-1.0-0 \
		libusb-1.0-0-dev
}

install_rogauracore() {
	if command -v rogauracore >/dev/null 2>&1; then
		echo "[2/6] rogauracore already installed at $(command -v rogauracore)"
		return
	fi

	echo "[2/6] Building and installing rogauracore"
	local tmpdir
	tmpdir="$(mktemp -d)"
	trap 'rm -rf "${tmpdir}"' EXIT
	git clone https://github.com/wroberts/rogauracore.git "${tmpdir}/rogauracore"
	cd "${tmpdir}/rogauracore"
	autoreconf -i
	./configure
	make -j"$(nproc)"
	sudo make install
	cd - >/dev/null
}

write_mode() {
	local mode="$1"
	echo "[3/6] Writing persistent RGB mode (${mode})"
	echo "${mode}" | sudo tee "${MODE_FILE}" >/dev/null
}

install_apply_helper() {
	echo "[4/6] Installing apply helper"
	sudo tee "${APPLY_HELPER}" >/dev/null <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

mode="$(cat /etc/rogauracore-mode 2>/dev/null || echo rainbow)"

# Some desktop sessions leave keyboard backlight at 0 after login.
if [[ -w /sys/class/leds/asus::kbd_backlight/brightness ]]; then
	echo 3 > /sys/class/leds/asus::kbd_backlight/brightness || true
fi

if command -v rogauracore >/dev/null 2>&1; then
	rogauracore "${mode}" || true
fi
EOF
	sudo chmod +x "${APPLY_HELPER}"
}

install_service() {
	echo "[5/6] Installing systemd service (runs after desktop starts)"
	sudo tee "${SERVICE_FILE}" >/dev/null <<'EOF'
[Unit]
Description=Apply ROG Aura keyboard RGB after graphical login
After=graphical.target
Wants=graphical.target

[Service]
Type=oneshot
ExecStartPre=/bin/sleep 8
ExecStart=/usr/local/bin/rogauracore-apply.sh
RemainAfterExit=yes

[Install]
WantedBy=graphical.target
EOF
}

enable_and_apply() {
	echo "[6/6] Enabling service and applying now"
	sudo systemctl daemon-reload
	sudo systemctl enable rogauracore-persist.service
	sudo systemctl restart rogauracore-persist.service
}

cmd_install() {
	local mode="${1:-rainbow}"
	require_mode "${mode}"
	require_ubuntu
	install_deps
	install_rogauracore
	write_mode "${mode}"
	install_apply_helper
	install_service
	enable_and_apply

	echo "Done. Current mode: ${mode}"
}

cmd_set_mode() {
	local mode="${1:-}"
	if [[ -z "${mode}" ]]; then
		echo "set-mode requires a mode argument."
		usage
		exit 1
	fi
	require_mode "${mode}"
	write_mode "${mode}"
	sudo systemctl restart rogauracore-persist.service
	echo "Mode updated to: ${mode}"
}

cmd_apply_now() {
	if [[ ! -x "${APPLY_HELPER}" ]]; then
		echo "Apply helper missing: ${APPLY_HELPER}"
		echo "Run install first."
		exit 1
	fi
	sudo "${APPLY_HELPER}"
	echo "Applied current mode now."
}

cmd_status() {
	echo "rogauracore: $(command -v rogauracore || echo 'not installed')"
	echo "mode file: ${MODE_FILE}"
	if [[ -f "${MODE_FILE}" ]]; then
		echo "current mode: $(cat "${MODE_FILE}")"
	fi
	echo "helper: ${APPLY_HELPER}"
	echo "service: rogauracore-persist.service"
	sudo systemctl status rogauracore-persist.service --no-pager -l || true
}

cmd_uninstall() {
	echo "Disabling and removing service/helper/mode file"
	sudo systemctl disable --now rogauracore-persist.service || true
	sudo rm -f "${SERVICE_FILE}" "${APPLY_HELPER}" "${MODE_FILE}"
	sudo systemctl daemon-reload
	echo "Uninstall complete. rogauracore binary was kept installed."
}

ACTION="${1:-install}"
ARG1="${2:-}"

case "${ACTION}" in
	install)
		cmd_install "${ARG1:-rainbow}"
		;;
	set-mode)
		cmd_set_mode "${ARG1}"
		;;
	apply-now)
		cmd_apply_now
		;;
	status)
		cmd_status
		;;
	uninstall)
		cmd_uninstall
		;;
	-h|--help|help)
		usage
		;;
	*)
		echo "Unknown action: ${ACTION}"
		usage
		exit 1
		;;
esac
