#!/bin/bash

# Obtém a lista de dependências Maven
dependencies=$(./mvnw dependency:list -DincludeScope=compile -DoutputFile=/dev/stdout | grep ":" | awk '{print $1}')

for dependency in $dependencies; do
    # Extrai grupo e artefato corretamente
    groupId=$(echo $dependency | cut -d':' -f1)
    artifactId=$(echo $dependency | cut -d':' -f2)

    # Converte grupoId para formato de URL (substitui '.' por '%2E')
    search_groupId=$(echo $groupId | sed 's/\./%2E/g')

    # URL da API do Maven Central
    search_url="https://search.maven.org/solrsearch/select?q=g:${search_groupId}+AND+a:${artifactId}&rows=1&wt=json"

    # Faz a requisição e extrai a resposta JSON
    response=$(curl -s "$search_url")

    # Verifica se a resposta é válida antes de passar para o jq
    if [[ -z "$response" || "$response" == "null" ]]; then
        echo "$dependency -> Não encontrado na API do Maven Central"
        continue
    fi

    # Extrai o SCM (Source Control Management) se disponível
    scm_url=$(echo "$response" | jq -r '.response.docs[0].scm' 2>/dev/null)
    repository_url=$(echo "$response" | jq -r '.response.docs[0].repository' 2>/dev/null)

    # Se encontrar um repositório Git, imprime
    if [[ $scm_url == http* ]]; then
        echo "$dependency -> $scm_url"
    elif [[ $repository_url == http* ]]; then
        echo "$dependency -> $repository_url"
    else
        # Caso a API não forneça, tenta buscar no POM do Maven local
        local_pom=$(./mvnw help:evaluate -Dexpression=project.scm.url -q -DforceStdout -Dartifact=$groupId:$artifactId)

        if [[ $local_pom == http* ]]; then
            echo "$dependency -> $local_pom"
        else
            echo "$dependency -> Repositório não encontrado"
        fi
    fi
done