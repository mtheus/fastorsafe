#!/bin/bash

# Diretório onde os repositórios foram clonados
TARGET_DIR="repos"
OUTPUT_DIR="logs"

# Criar diretório de saída se não existir
mkdir -p "$OUTPUT_DIR"

# Verificar se o diretório existe
if [ ! -d "$TARGET_DIR" ]; then
    echo "Diretório '$TARGET_DIR' não encontrado! Certifique-se de que os repositórios foram clonados."
    exit 1
fi

# Percorrer cada pasta dentro do diretório TARGET_DIR
for REPO_DIR in "$TARGET_DIR"/*; do
    if [ -d "$REPO_DIR/.git" ]; then
        REPO_NAME=$(basename "$REPO_DIR")
        LOG_FILE="${OUTPUT_DIR}/${REPO_NAME}_logfile.log"
        FILES_CSV="${OUTPUT_DIR}/${REPO_NAME}_all_files.csv"

        echo "Processando $REPO_NAME ..."
        
        # Entrar no diretório do repositório
        cd "$REPO_DIR" || continue
        
        # Gerar o log de commits
        git log --pretty=format:'[%h] %aN %ad %s' --date=iso8601 --numstat > "../../$LOG_FILE"
        
        # Gerar a contagem de linhas dos arquivos
        echo "entity" > "../../$FILES_CSV"
        git ls-files | xargs wc -l >> "../../$FILES_CSV"
        
        # Retornar ao diretório original
        cd - > /dev/null
    fi
done

echo "Processamento concluído! Os arquivos foram salvos no diretório '$OUTPUT_DIR'."
