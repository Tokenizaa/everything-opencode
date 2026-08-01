#!/usr/bin/env bash
# ============================================================================
# everything-opencode — Instalador
# Instala agents, skills e configuração genérica do OpenCode.
# Uso: bash install.sh [--design] [--force]
#   --design  baixa a biblioteca de design (153 marcas, 81MB) — opcional
#   --force   sobrescreve arquivos existentes
# ============================================================================
set -euo pipefail

# Cores
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
ok()  { echo -e "${GREEN}✔ $1${NC}"; }
warn(){ echo -e "${YELLOW}⚠ $1${NC}"; }
err() { echo -e "${RED}✘ $1${NC}"; exit 1; }

# Diretórios
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
AGENTS_DST="$CONFIG_DIR/agents"
SKILLS_DST="$CONFIG_DIR/skills"
DESIGN_DST="$CONFIG_DIR/design"
FORCE=false
WITH_DESIGN=false

# Backup do config existente (SEMPRE antes de qualquer escrita)
backup_cfg() {
  if [ -f "$CFG_FILE" ]; then
    local bak="${CFG_FILE}.bak.$(date +%Y%m%d%H%M%S)"
    cp "$CFG_FILE" "$bak"
    ok "Backup do config: $bak"
  fi
}

# Parse args
for arg in "$@"; do
  case "$arg" in
    --force) FORCE=true ;;
    --design) WITH_DESIGN=true ;;
  esac
done

echo "=============================================="
echo "  everything-opencode — Instalador"
echo "  Destino: $CONFIG_DIR"
echo "=============================================="
echo ""

# 0. Verificar opencode instalado
if ! command -v opencode >/dev/null 2>&1; then
  warn "OpenCode não encontrado no PATH. Instale: curl -fsSL https://opencode.ai/install | bash"
fi

# 1. Instalar agents
echo "→ Instalando agents..."
mkdir -p "$AGENTS_DST"
count=0
for f in "$SCRIPT_DIR"/agents/*.md; do
  name="$(basename "$f")"
  if [ -f "$AGENTS_DST/$name" ] && [ "$FORCE" = false ]; then
    warn "  $name existe (use --force para sobrescrever)"
    continue
  fi
  cp "$f" "$AGENTS_DST/" && count=$((count+1))
done
ok "$count agents instalados em $AGENTS_DST"

# 2. Instalar skills
echo "→ Instalando skills..."
mkdir -p "$SKILLS_DST"
count=0
for d in "$SCRIPT_DIR"/skills/*/; do
  name="$(basename "$d")"
  if [ -d "$SKILLS_DST/$name" ] && [ "$FORCE" = false ]; then
    warn "  $name existe (use --force para sobrescrever)"
    continue
  fi
  cp -r "$d" "$SKILLS_DST/" && count=$((count+1))
done
ok "$count skills instaladas em $SKILLS_DST"

# 3. Config opencode.jsonc (NUNCA sobrescrever sem backup explícito)
echo "→ Configurando opencode.jsonc..."
CFG_FILE="$CONFIG_DIR/opencode.jsonc"
if [ -f "$CFG_FILE" ]; then
  warn "$CFG_FILE já existe — PRESERVANDO seu config (MCPs, providers, agents)."
  warn "Os agents/skills já foram instalados; registre os agents no seu config manualmente."
  backup_cfg
else
  # Template de config base (sem secrets)
  cat > "$CFG_FILE" << 'JSONEOF'
{
  "$schema": "https://opencode.ai/config.json",
  "model": "9router/combo",
  "provider": {
    "9router": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Local 9Router",
      "options": { "baseURL": "http://localhost:20128/v1" },
      "models": { "combo": { "name": "combo" } }
    }
  }
}
JSONEOF
  ok "Config base criado em $CFG_FILE (adicione seus MCPs e agentes)"
fi

# 4. AGENTS.md
echo "→ AGENTS.md..."
AM_FILE="$CONFIG_DIR/../opencode/AGENTS.md"
mkdir -p "$(dirname "$AM_FILE")"
if [ -f "$AM_FILE" ] && [ "$FORCE" = false ]; then
  warn "AGENTS.md existe — preservando. Use --force para substituir (com backup)."
else
  backup_cfg
  cp "$SCRIPT_DIR/AGENTS.md" "$AM_FILE" 2>/dev/null || true
  ok "AGENTS.md criado"
fi

# 5. Biblioteca de design (opcional)
if [ "$WITH_DESIGN" = true ]; then
  echo "→ Baixando biblioteca de design (153 marcas, ~81MB)..."
  mkdir -p "$DESIGN_DST"
  if [ -d "$DESIGN_DST/design-systems" ]; then
    warn "design/ já existe — pulando download."
  else
    git clone --depth 1 https://github.com/nexu-io/open-design.git /tmp/od-design 2>/dev/null
    cp -r /tmp/od-design/design-systems "$DESIGN_DST/"
    cp -r /tmp/od-design/design-templates "$DESIGN_DST/"
    cp -r /tmp/od-design/prompt-templates "$DESIGN_DST/"
    rm -rf /tmp/od-design
    ok "Biblioteca de design instalada"
  fi
else
  warn "Biblioteca de design pulada (use --design para baixar)"
fi

echo ""
echo "=============================================="
ok "Instalação concluída!"
echo "  Reinicie o OpenCode e use Tab ou @ para os agents."
echo "=============================================="
