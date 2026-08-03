#!/usr/bin/env bash
# Configura a NVIDIA_API_KEY para o OpenCode
# Uso: source ~/.opencode/bin/nvidia-setup.sh
# Busca a chave no .env do DefesAi e exporta para o shell

NVIDIA_KEY=$(grep -r "NVIDIA_API_KEY" /home/lg/workspace/projects/DefesAi/.env 2>/dev/null | head -1 | cut -d= -f2- | tr -d '"')

if [ -n "$NVIDIA_KEY" ]; then
  export NVIDIA_API_KEY="$NVIDIA_KEY"
  echo "✔ NVIDIA_API_KEY configurada para o shell atual"
else
  echo "⚠ NVIDIA_API_KEY não encontrada. Exporte manualmente:"
  echo "  export NVIDIA_API_KEY='nvapi-...'"
fi
