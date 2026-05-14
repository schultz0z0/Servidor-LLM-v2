# Documentação - Nexus-Fullstack

## 1. Como realizar a primeira implantação do zero (Clean Install)

Sempre que precisar criar o servidor do zero em uma VPS nova ou limpar o ambiente atual, **NÃO** utilize os botões de implantação automática por URL dos painéis de hospedagem (pois o arquivo `.env` com as chaves de segurança não é enviado para o GitHub).

Siga os passos pelo **Terminal SSH**:

1. Crie uma pasta limpa para o projeto e acesse-a:
   ```bash
   mkdir ~/nexus-fullstack && cd ~/nexus-fullstack
   ```
2. Baixe a arquitetura do repositório:
   ```bash
   git clone https://github.com/schultz0z0/Servidor-LLM-v2.git .
   ```
3. Crie o arquivo de variáveis de ambiente:
   ```bash
   nano .env
   ```
   *Cole todo o conteúdo do seu arquivo `.env` local (com chaves da API, senhas, portas, etc.). Salve com `CTRL+X`, aperte `Y` e depois `ENTER`.*

4. Suba a infraestrutura construindo os pacotes base (Chromium, Playwright, etc.):
   ```bash
   docker compose up -d --build
   ```

> **Nota:** A conta de admin do Open WebUI é criada automaticamente no primeiro boot pelo script `openwebui-init.sh` usando as variáveis `ADMIN_EMAIL` e `ADMIN_PASSWORD` do `.env`. Basta abrir o navegador e logar diretamente.

## 2. Como mandar atualizações do seu PC para a VPS via Git

Para atualizar seu servidor sempre que fizer alterações no código pelo seu VS Code no Windows:

### No seu Computador (VS Code / Windows)
1. Certifique-se de que não removeu o `.env` do arquivo `.gitignore`.
2. Faça o commit e o push enviando as alterações para o GitHub.

### No Servidor (VPS)
1. Acesse o Terminal SSH e vá até a pasta do projeto:
   ```bash
   cd ~/nexus-fullstack
   ```
2. Baixe as atualizações e recompile os containers que sofreram alterações:
   ```bash
   git pull origin main
   docker compose up -d --build
   ```
> A flag `--build` garante que, se algum `Dockerfile` tiver sido modificado, as dependências internas serão atualizadas antes do container subir.

## 3. Automação e Pacotes Base

Com a nova arquitetura baseada em `Dockerfile`s da pasta `docker/`, você não precisa mais rodar comandos manuais. O Docker instalará automaticamente:
- O **Chromium, Playwright, terminal Hermes e gateways de profiles** no container `hermes`.
- O **Hermes Agent CLI** localmente dentro do orquestrador `paperclip`.
- O **Curl e pacotes base** no `open-webui`.
- As **configurações do formato JSON e limits** dentro do `searxng`.

### Scripts de Inicialização Automática

| Script | Container | Função |
|---|---|---|
| `hermes-all-in-one.sh` | hermes | Sobe o terminal Hermes e os gateways dos profiles no mesmo container |
| `hermes-init.sh` | hermes | Mantém compatibilidade com o init do Hermes |
| `openwebui-init.sh` | open-webui | Cria a conta de admin automaticamente no primeiro boot via API de signup |

---

## 4. Arquitetura de Providers (LLM)

O **Hermes Agent** é o cérebro central da infraestrutura. Ele se conecta ao provider LLM configurado (NVIDIA, Gemini, OpenAI, etc.) e expõe APIs compatíveis com OpenAI nas portas internas configuradas no `.env` (`HERMES_API_PORT_CORE`, `HERMES_API_PORT_ENS` e `HERMES_API_PORT_CLEMENTINO`).

- **Open WebUI** → conecta no Hermes via `http://hermes:8652/v1`
- **Paperclip** → roda o Hermes CLI localmente, compartilhando o mesmo volume de dados

Para trocar de provider/modelo, basta alterar no `.env`:
- `OPENAI_API_BASE` → URL do provider
- `OPENAI_API_KEY` / `NVIDIA_API_KEY` / `GEMINI_API_KEY` → Chave do provider
- `DEFAULT_MODEL` → Modelo padrão

---

## 5. Validar a Integração da API do Hermes com Open WebUI

> **Nota:** A API do Hermes já vem ativada por padrão de forma 100% automática através das variáveis `API_SERVER_*` no arquivo `.env` e pela arquitetura dupla no `docker-compose.yml`. Não é necessário nenhum passo manual para ligá-la.

Para testar se o Open WebUI está conseguindo enxergar a API do Hermes por debaixo dos panos, rode estes testes de saúde:

**1. Testar se a API está online (Ping de dentro do WebUI para o Hermes)**
```bash
docker exec -it llm-stack-open-webui-1 curl http://hermes:8652/health
```
*A resposta esperada é: `{"status":"ok","platform":"hermes-agent"}`*

**2. Testar se a chave está autorizando a listar os modelos**
```bash
docker exec -it llm-stack-open-webui-1 curl http://hermes:8652/v1/models -H "Authorization: Bearer $HERMES_API_KEY_CORE"
```

**3. Verificar se as variáveis do Hermes chegaram no container**
```bash
docker exec -it llm-stack-hermes-1 env | grep HERMES_API_PORT
```

---

## 6. Como provar que os pacotes foram instalados nos containers

Se você quiser auditar e ter certeza absoluta de que o build funcionou e todos os pacotes (Chromium, Playwright, Hermes CLI, etc.) estão rodando nativamente lá dentro, execute estes comandos no terminal da sua VPS:

**1. Testar o Hermes Terminal (Chromium e Playwright)**
```bash
docker exec -it llm-stack-hermes-1 chromium --version
docker exec -it llm-stack-hermes-1 python3 -m playwright --version
```

**2. Testar o Paperclip (Chromium, Playwright e Hermes nativo)**
```bash
docker exec -it llm-stack-paperclip-1 chromium --version
docker exec -it llm-stack-paperclip-1 python3 -m playwright --version
docker exec -it llm-stack-paperclip-1 hermes --help
```

**3. Testar o Open WebUI (Chromium e pacotes base)**
```bash
docker exec -it llm-stack-open-webui-1 chromium --version
docker exec -it llm-stack-open-webui-1 curl --version
```

*Se os comandos retornarem as versões dos programas em vez de `command not found`, significa que a sua arquitetura Docker instalou tudo com perfeição!*

---

## 7. Credenciais Padronizadas

| Serviço | Email / User | Senha |
|---|---|---|
| Open WebUI | raphaelschultz12@gmail.com | Pjrafa12@ |
| Paperclip | raphaelschultz12@gmail.com | Pjrafa12@ |
| Hermes API | — (usa API key) | sk-hrms-9f8e7d6c5b4a3a2b1c0d9e8f7a6b5c4d |

## 8. Reset Total (Apagar tudo e recomeçar)

```bash
cd ~/nexus-fullstack
docker compose down
cd ~
rm -rf ~/nexus-fullstack
```
Depois siga os passos da Seção 1.
