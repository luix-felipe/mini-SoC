# Documentação do projeto

Este diretório centraliza a documentação de arquitetura, referências e fluxos de trabalho do projeto.

## Organização

- `docs/architecture/` — capacidades, alternativas e decisões arquiteturais;
- `docs/references/` — índice e localização das fontes do projeto;
- `docs/workflows/development-routine.md` — rotina diária de desenvolvimento;
- `docs/workflows/unic-cass-wsl-installation.md` — preparação automatizada do ambiente.

Os documentos devem usar `$HOME`, variáveis de ambiente e placeholders como `<NOME_DO_PROJETO>`. Não devem conter nomes pessoais, caminhos locais absolutos, credenciais, IPs privados ou informações de cliente.

## Checklist antes de publicar

- confirmar ausência de senhas, tokens, chaves e conteúdo de `.env`;
- substituir nomes de usuário e caminhos locais por variáveis;
- anonimizar responsáveis por função;
- verificar URLs, anexos e metadados;
- revisar `git diff --cached` antes do commit.
