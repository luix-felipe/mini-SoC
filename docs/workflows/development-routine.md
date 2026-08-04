# Rotina de desenvolvimento do Mini-SoC

**Status:** rotina operacional recomendada.  
**Data:** 2026-08-04.  
**Ambiente de referência:** WSL2 como host e imagem `isaiassh/unic-cass-tools:1.1.0` como ambiente oficial de ferramentas.

Para preparar uma nova máquina, seguir primeiro `docs/workflows/unic-cass-wsl-installation.md`.

## 1. Princípio de execução

O código é editado no WSL e montado no contêiner pelo diretório `shared_xserver`. Testes rápidos podem ser executados no host, mas qualquer resultado usado como evidência do projeto deve ser repetido no Docker.

Essa separação evita que diferenças de versão entre máquinas sejam confundidas com falhas ou sucessos do design.

## 2. Abrir o projeto no VS Code

No terminal WSL, fora do contêiner:

```bash
export UNICCASS_ROOT="$HOME/eda/uniccass-icdesign-tools"
export PROJECT_NAME="<NOME_DO_PROJETO>"
cd "$UNICCASS_ROOT/shared_xserver/$PROJECT_NAME"
code .
```

Organização principal:

| Diretório | Conteúdo |
| --- | --- |
| `rtl/` | RTL sintetizável em SystemVerilog/Verilog |
| `tb/` | Testbenches, modelos e artefatos de verificação |
| `firmware/` | Firmware e programas RISC-V |
| `analog/` | Esquemáticos, modelos e simulações analógicas |
| `flow/` | Configurações do LibreLane e fluxos auxiliares |
| `docs/` | Arquitetura, interfaces, decisões e procedimentos |
| `results/` | Resultados gerados localmente; ignorados pelo Git |

No WSL ficam preferencialmente:

- VS Code e Git;
- edição e organização do repositório;
- toolchain de firmware RISC-V;
- testes RTL rápidos com ferramentas locais;
- inspeção de VCD com WaveTrace ou visualizador disponível.

A presença do compilador `riscv64-unknown-elf-gcc` foi observada no host em 2026-08-04. Arquitetura ISA, ABI, linker script e comandos de firmware ainda devem ser definidos antes de estabelecer um build canônico.

## 3. Iniciar o contêiner

Em outro terminal WSL:

```bash
cd "$HOME/eda/uniccass-icdesign-tools"
make start PDK=sky130A
```

O argumento `PDK=sky130A` é necessário enquanto Sky130 for a baseline provisória. O `Makefile` atual usa `ihp-sg13g2` como padrão quando o argumento é omitido.

Dentro do contêiner:

```bash
export PROJECT_NAME="<NOME_DO_PROJETO>"
cd "/home/designer/shared/$PROJECT_NAME"
echo "PDK=$PDK"
/home/designer/shared/bin/verificar-ambiente-unicass
```

O script de verificação confere as ferramentas centrais, os três PDKs declarados e o wrapper local do LibreLane. Uma falha deve ser registrada antes de executar validações oficiais.

No Docker ficam:

- LibreLane, Yosys, OpenROAD e OpenSTA integrado;
- Icarus Verilog e Verilator;
- Xschem, Ngspice e OpenVAF;
- Magic, KLayout, Netgen, CACE e CVC-RV;
- acesso padronizado aos PDKs.

## 4. Compilar e simular RTL

Os comandos abaixo são modelos. Eles passam a ser executáveis quando `rtl/modulo.sv` e `tb/modulo_tb.sv` existirem.

### Icarus Verilog

Dentro do contêiner e na raiz do projeto:

```bash
iverilog -g2012 \
  -o results/simulacao \
  rtl/modulo.sv \
  tb/modulo_tb.sv

vvp results/simulacao
```

O testbench deve retornar código diferente de zero ou emitir falha inequívoca quando detectar comportamento incorreto. Apenas gerar um VCD ou terminar a simulação não caracteriza aprovação.

### Verilator

Para lint inicial:

```bash
verilator --lint-only -Wall rtl/*.sv
```

Warnings devem ser analisados. Supressões precisam de justificativa registrada.

### Yosys

Para uma síntese exploratória independente de biblioteca:

```bash
yosys -p "read_verilog -sv rtl/*.sv; hierarchy -check; synth; stat"
```

Esse comando verifica elaborabilidade e produz estatísticas genéricas. Ele não substitui síntese mapeada, constraints, STA ou implementação física.

À medida que o projeto crescer, listas explícitas de fontes e scripts versionados devem substituir globs e comandos manuais.

## 5. Executar o fluxo físico

O wrapper validado no workspace é:

```text
/home/designer/shared/bin/librelane-local
```

Ele chama LibreLane com PDK manual, usa `PDK_ROOT` — ou `/opt/pdks` quando ausente — e herda `PDK` do ambiente. Por isso, confirmar `PDK=sky130A` antes da execução enquanto essa for a baseline.

Quando `flow/config.yaml` tiver sido criado e revisado:

```bash
cd "/home/designer/shared/$PROJECT_NAME"
/home/designer/shared/bin/librelane-local \
  "/home/designer/shared/$PROJECT_NAME/flow/config.yaml"
```

No estado observado em 2026-08-04, `flow/config.yaml` ainda não existe. Ele só deve ser criado depois de definir, no mínimo, top-level, fontes RTL, clock, período, área inicial, biblioteca e PDK.

O fluxo esperado compreende:

```text
RTL
  → síntese
  → floorplan
  → posicionamento
  → CTS
  → roteamento
  → STA e verificações físicas
  → GDSII
```

Um término bem-sucedido do LibreLane deve ser acompanhado da revisão de warnings, violações, timing, área e relatórios de DRC/LVS. A geração de GDSII isoladamente não significa signoff.

## 6. Critério para resultados oficiais

Um teste ou execução pode ser reportado como oficial quando:

- foi executado na imagem e no PDK registrados;
- usou fontes, configuração e constraints identificáveis;
- registrou o comando ou script executado;
- terminou sem erros não aceitos;
- teve warnings e relatórios relevantes revisados;
- produziu um relatório-resumo reproduzível.

Resultados rápidos do WSL devem ser identificados como locais ou exploratórios até serem repetidos no Docker.
