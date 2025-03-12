#!/bin/bash

# Diretórios
LOGS_DIR="logs"
ANALYSIS_DIR="analysis"
CODE_MAAT_JAR="code-maat-1.0.4-standalone.jar"

# Lista de comandos para executar
COMMANDS=("abs-churn" "age" "author-churn" "authors" "communication" "coupling" "entity-churn" 
          "entity-effort" "entity-ownership" "fragmentation" "identity" "main-dev" "main-dev-by-revs" 
          "refactoring-main-dev" "revisions" "soc" "summary")

# Criar diretório de análise se não existir
mkdir -p "$ANALYSIS_DIR"

# Iterar sobre todos os arquivos .log em logs/
for LOG_FILE in "$LOGS_DIR"/*.log; do
    if [ -f "$LOG_FILE" ]; then
        TASK_ID=$(basename "$LOG_FILE" .log)  # Remove extensão .log para usar como ID
        echo "Processando $TASK_ID ..."

        # Executar todas as análises
        for COMMAND_ID in "${COMMANDS[@]}"; do
            OUTPUT_FILE="$ANALYSIS_DIR/${TASK_ID}-${COMMAND_ID}.csv"
            echo "Executando $COMMAND_ID para $TASK_ID..."
            java -jar "$CODE_MAAT_JAR" -l "$LOG_FILE" -c git -a "$COMMAND_ID" > "$OUTPUT_FILE"
        done
    fi
done

echo "Todas as análises foram concluídas!"
