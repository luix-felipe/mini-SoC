# Documentação do projeto

Este diretório centraliza a documentação de arquitetura, referências e fluxos de trabalho do projeto.

## Regra de escrita

- registrar somente decisão, evidência, comando e pendência útil;
- preferir tabelas e links em vez de repetir explicações;
- manter logs detalhados em `experiments/*/evidence/`;
- atualizar o documento existente, sem criar outro para o mesmo assunto.

## Organização

- `docs/architecture/` — ambiente, candidatos e decisões;
- `docs/ip-manifest.md` — origem, revisão, licença e estado de qualificação dos IPs avaliados;
- `docs/verification/riscv-core-test-plan.md` — tipos de teste, situação validada e próximos gates para Ibex e Croc;
- `docs/references/` — índice das fontes do projeto;
- `docs/workflows/` — instalação e rotina operacional;
- `experiments/` — qualificação reproduzível dos cores;
- `pipe-clean/` — entrada simplificada para localizar os clones externos e reproduzir a qualificação dos cores.

Os documentos devem usar `$HOME`, variáveis de ambiente e placeholders como `<NOME_DO_PROJETO>`. Não devem conter nomes pessoais, caminhos locais absolutos, credenciais, IPs privados ou informações de cliente.

## Checklist antes de publicar

- confirmar ausência de senhas, tokens, chaves e conteúdo de `.env`;
- substituir nomes de usuário e caminhos locais por variáveis;
- anonimizar responsáveis por função;
- verificar URLs, anexos e metadados;
- revisar `git diff --cached` antes do commit.
