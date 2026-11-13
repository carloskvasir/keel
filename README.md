# Keel

Instância do padrão **Bulkhead**: ambiente de desenvolvimento em que um agente de IA
roda isolado, sem rota para a internet. Todo o tráfego de saída passa pelo Envoy, que
aplica *Default Deny* sobre `allowlist.yaml` e registra cada tentativa em JSON.

## Estrutura

| Caminho | Função |
|---|---|
| `docker-compose.yml` | redes `sealed` (sem gateway) e `egress`; serviços `dev` e `envoy` |
| `docker-compose.podman.yml` | override para Podman rootless (`userns_mode: keep-id`) |
| `allowlist.yaml` | destinos permitidos (editar e `docker compose restart envoy`) |
| `envoy/` | modelo de configuração e *entrypoint* que gera a config a partir da allowlist |
| `.devcontainer/` | imagem do agente (Ruby, Node, Claude Code) e `devcontainer.json` |
| `bin/keel-exec` | injeta um segredo Just-In-Time no processo de um comando |
| `workspace/` | **o projeto do agente** é montado daqui em `/workspace` |

O que o agente enxerga é só `workspace/`. Os arquivos de controle (allowlist, compose,
DevContainer, Envoy) ficam fora do alcance dele. Para outro projeto, defina
`KEEL_WORKSPACE=/caminho/do/projeto`.

## Uso

```bash
touch workspace/.env      # ponto de montagem do /dev/null (o .env fica vazio no contêiner)
docker compose up -d --build
# Podman rootless:
docker compose -f docker-compose.yml -f docker-compose.podman.yml up -d --build

# segredo só no processo do comando (lido do host, nunca gravado em disco):
KEEL_SECRET_MEU_TOKEN_CMD='cat ~/.config/keel/token' bin/keel-exec MEU_TOKEN -- <comando>
```

Os ataques simulados estão em [keel-lab](https://github.com/carloskvasir/keel-lab) (`./redteam.sh`).

## Limitações conhecidas

- Destinos da allowlist (incluindo o provedor do modelo) são canais de saída.
- Um segredo injetado é legível por outros processos do agente enquanto o comando roda.
- O agente grava no `workspace/`: *hooks* do Git, *scripts* e configs de CI que ele
  escrever podem executar depois, fora do contêiner. Revise o que ele alterar.
- O *kernel* é compartilhado com o *host*.
- Validado apenas em Podman rootless; Docker rootful ainda não foi testado.
