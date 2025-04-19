#!/bin/bash

# Fungsi untuk validasi input tidak kosong
validate_not_empty() {
    local input=$1
    local message=$2
    
    if [ -z "$input" ]; then
        echo -e "\e[31mError: $message\e[0m"
        return 1
    fi
    return 0
}

echo -e "\e[1;34m=== PEMBUAT SERVICE SYSTEMD ===\e[0m"

# Meminta input untuk SERVICE_NAME
while true; do
    read -p "Masukkan nama service: " SERVICE_NAME
    if validate_not_empty "$SERVICE_NAME" "Nama service tidak boleh kosong!"; then
        break
    fi
done

# Meminta input untuk SERVICE_FILE_NAME
while true; do
    read -p "Masukkan nama file service (tanpa ekstensi .service): " SERVICE_FILE_NAME
    if validate_not_empty "$SERVICE_FILE_NAME" "Nama file service tidak boleh kosong!"; then
        break
    fi
done

# Meminta input untuk SERVICE_DESCRIPTION
while true; do
    read -p "Masukkan deskripsi service: " SERVICE_DESCRIPTION
    if validate_not_empty "$SERVICE_DESCRIPTION" "Deskripsi service tidak boleh kosong!"; then
        break
    fi
done

# Meminta input untuk BINARY_PATH
while true; do
    read -p "Masukkan path lengkap ke binary/executable: " BINARY_PATH
    if validate_not_empty "$BINARY_PATH" "Path binary tidak boleh kosong!"; then
        # Cek apakah file binary ada
        if [ ! -f "$BINARY_PATH" ]; then
            echo -e "\e[33mPeringatan: File binary tidak ditemukan di path tersebut. Lanjutkan? (y/n): \e[0m"
            read confirm
            if [[ "$confirm" =~ ^[Yy] ]]; then
                break
            fi
        else
            break
        fi
    fi
done

# Meminta input untuk USER
while true; do
    read -p "Masukkan user untuk menjalankan service: " USER
    if validate_not_empty "$USER" "User tidak boleh kosong!"; then
        # Cek apakah user ada
        if ! id "$USER" &>/dev/null; then
            echo -e "\e[33mPeringatan: User tidak ditemukan. Lanjutkan? (y/n): \e[0m"
            read confirm
            if [[ "$confirm" =~ ^[Yy] ]]; then
                break
            fi
        else
            break
        fi
    fi
done

# Meminta input untuk GROUP
while true; do
    read -p "Masukkan group untuk menjalankan service: " GROUP
    if validate_not_empty "$GROUP" "Group tidak boleh kosong!"; then
        # Cek apakah group ada
        if ! getent group "$GROUP" &>/dev/null; then
            echo -e "\e[33mPeringatan: Group tidak ditemukan. Lanjutkan? (y/n): \e[0m"
            read confirm
            if [[ "$confirm" =~ ^[Yy] ]]; then
                break
            fi
        else
            break
        fi
    fi
done

# Meminta input untuk WORK_DIR
while true; do
    read -p "Masukkan working directory: " WORK_DIR
    if validate_not_empty "$WORK_DIR" "Working directory tidak boleh kosong!"; then
        # Cek apakah direktori ada
        if [ ! -d "$WORK_DIR" ]; then
            echo -e "\e[33mPeringatan: Direktori tidak ditemukan. Lanjutkan? (y/n): \e[0m"
            read confirm
            if [[ "$confirm" =~ ^[Yy] ]]; then
                break
            fi
        else
            break
        fi
    fi
done

# Loop untuk environment variables
ENV_VARS=""
echo -e "\e[1;34m=== KONFIGURASI ENVIRONMENT VARIABLES ===\e[0m"
echo "Masukkan environment variables (format: KEY=VALUE)."
echo "Ketik 'selesai' untuk mengakhiri input environment variables."

while true; do
    read -p "Environment variable (atau 'selesai' untuk berhenti): " env_entry
    
    # Kondisi untuk keluar dari loop
    if [ "$env_entry" == "selesai" ]; then
        break
    fi
    
    # Validasi format environment variable
    if [[ "$env_entry" =~ ^[A-Za-z0-9_]+=.+$ ]]; then
        ENV_VARS="${ENV_VARS}Environment=${env_entry}\n"
    else
        echo -e "\e[31mFormat tidak valid! Gunakan format KEY=VALUE\e[0m"
    fi
done

# Membuat file service
SERVICE_FILE="/tmp/${SERVICE_FILE_NAME}.service"
cat > "$SERVICE_FILE" << EOF
[Unit]
Description=${SERVICE_DESCRIPTION}
After=network.target

[Service]
ExecStart=${BINARY_PATH}
Restart=always
User=${USER}
Group=${GROUP}
WorkingDirectory=${WORK_DIR}
$(echo -e "$ENV_VARS")
StandardOutput=journal
StandardError=journal
SyslogIdentifier=${SERVICE_NAME}

[Install]
WantedBy=multi-user.target
EOF

echo -e "\e[1;32m=== SERVICE FILE BERHASIL DIBUAT ===\e[0m"
echo "File service telah dibuat di: $SERVICE_FILE"
echo -e "\nUntuk menginstall service:"
echo "1. sudo cp $SERVICE_FILE /etc/systemd/system/"
echo "2. sudo systemctl daemon-reload"
echo "3. sudo systemctl enable ${SERVICE_FILE_NAME}.service"
echo "4. sudo systemctl start ${SERVICE_FILE_NAME}.service"
echo -e "\nUntuk memeriksa status service:"
echo "sudo systemctl status ${SERVICE_FILE_NAME}.service"

# Tanya pengguna apakah ingin langsung menginstall service
echo -e "\nApakah Anda ingin menginstall service sekarang? (y/n): "
read install_now

if [[ "$install_now" =~ ^[Yy] ]]; then
    echo "Menginstall service..."
    sudo cp "$SERVICE_FILE" /etc/systemd/system/ && \
    sudo systemctl daemon-reload && \
    sudo systemctl enable "${SERVICE_FILE_NAME}.service" && \
    sudo systemctl start "${SERVICE_FILE_NAME}.service" && \
    echo -e "\e[1;32mService berhasil diinstall dan dijalankan!\e[0m" || \
    echo -e "\e[31mGagal menginstall service. Cek pesan error di atas.\e[0m"
fi