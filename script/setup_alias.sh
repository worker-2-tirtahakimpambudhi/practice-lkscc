#!/bin/bash

# Path ke bashrc
BASHRC="$HOME/.bashrc"

# Alias yang ingin ditambahkan
ALIASES=$(cat <<'EOF'
# Custom systemctl aliases
alias sy="sudo systemctl"
alias syd="sudo systemctl daemon-reload"
alias sye="sudo systemctl enable"
alias syi="sudo systemctl disable"
alias sys="sudo systemctl start"
alias syr="sudo systemctl restart"
alias syt="sudo systemctl stop"
alias syts="sudo systemctl status"
EOF
)

# Mengecek apakah alias sudah ada di .bashrc
if ! grep -q "alias sy=" "$BASHRC"; then
  echo -e "\n$ALIASES" >> "$BASHRC"
  echo "Alias berhasil ditambahkan ke $BASHRC."
  echo "Silakan jalankan: source ~/.bashrc"
else
  echo "Alias sudah ada di $BASHRC, tidak ada perubahan."
fi
