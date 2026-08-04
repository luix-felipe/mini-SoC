# Capacidades do UNIC-CASS para o Mini-SoC

**Status:** levantamento inicial para discussão.  
**Data:** 2026-08-04.  
**Origem:** relação técnica fornecida pelo responsável local e conferência da lista de ferramentas no `README.md`, `Dockerfile` e `Makefile` locais do UNIC-CASS.  
**Regra de uso:** candidatos e recomendações deste documento não substituem ADRs nem decisões do gestor e do time.

As referências a `README.md`, `Dockerfile` e `Makefile` neste documento apontam para `$HOME/eda/uniccass-icdesign-tools`, a raiz convencional do repositório de ferramentas, e não para a raiz local do projeto.

## 1. Conclusão objetiva

O UNIC-CASS oferece ambiente de ferramentas, fluxos de projeto e designs de referência. Ele não é uma biblioteca única de IPs prontos para montar o SoC.

A base digital mais concreta encontrada é o Croc SoC, com núcleo CVE2/CV32E20, barramento OBI, SRAM parametrizada e periféricos básicos. Parte importante dos exemplos, macros e projetos analógicos usa IHP SG13G2. Como a baseline operacional discutida para o projeto é `sky130A`, esses materiais servem como referência metodológica e exigem porte, substituição ou nova validação.

## 2. Matriz de blocos e referências

| Bloco necessário | Referência identificada | Situação para o projeto |
| --- | --- | --- |
| RISC-V de 32 bits | Croc com CVE2/CV32E20 | Melhor base digital interna identificada; candidato, não selecionado |
| Interconexão | OBI Crossbar do Croc | Candidato natural se Croc/CVE2 for adotado; protocolo ainda aberto |
| SRAM lógica | Wrapper `tc_sram_impl` do Croc | Interface e parametrização reaproveitáveis após validação |
| SRAM física em Sky130 | OpenRAM | Caminho candidato; deve ser qualificado na configuração exata do PDK |
| UART, GPIO, timer e CLINT | Croc | Disponíveis como referência; inclusão no escopo final deve ser decidida |
| Debug/JTAG e boot ROM | Croc | Disponíveis como referência; dependem da estratégia de boot/teste |
| DMA | iDMA opcional do Croc | Provavelmente fora do escopo inicial |
| SPI | Não identificado na configuração principal do Croc | Importar ou desenvolver |
| I2C | Não identificado na configuração principal do Croc | Importar ou desenvolver |
| SAR ADC | Referência síncrona de 8 bits em IHP | Portar para o PDK escolhido e ampliar para 10 bits |
| Bandgap | Exemplo all-CMOS em IHP | Reutilizar metodologia, não dimensões ou layout |
| OTA e comparador | Exemplos analógicos do UNIC-CASS | Pontos de partida para estudo e redimensionamento |
| LDO | Nenhum projeto completo identificado | Projetar ou buscar IP externo |
| UPF/power-gating | Nenhum controlador pronto | Definir arquitetura e validar no fluxo apropriado |
| Scan, ATPG e boundary scan | Nenhum fluxo aberto completo identificado | Planejar com TestMAX/Synopsys ou alternativa qualificada |
| MBIST | Nomes de macros IHP contendo `bm_bist` | Não comprovam controlador MBIST; requisito continua aberto |

## 3. Croc e CVE2 como candidatos

O Croc é descrito como um SoC educacional com:

- núcleo CVE2/CV32E20;
- SRAM e crossbar OBI;
- UART, GPIO, timer, CLINT e debug/JTAG;
- boot ROM e registradores de controle;
- iDMA opcional;
- `user_domain` para extensão.

O CVE2/CV32E20 é uma implementação SystemVerilog de 32 bits, com pipeline de dois estágios e configurações RV32EC ou RV32IMC. A configuração RV32IMC foi sugerida no levantamento como equilíbrio inicial entre área e funcionalidade, mas ainda precisa ser comparada com Ibex, CV32E40P e outros candidatos.

Há um alerta operacional: o tutorial do Croc informa que o exemplo não funciona diretamente na imagem atual sem ajustes ou instalações adicionais. Antes de adotá-lo, deve ser executado um spike reproduzível que registre dependências, patches e resultados.

## 4. SRAM

A configuração Croc usada como referência possui:

- 2 bancos;
- 512 palavras por banco;
- 32 bits por palavra;
- capacidade total de 4 KiB.

As macros físicas observadas no exemplo são específicas de IHP SG13G2 e não podem ser usadas diretamente em layout Sky130. A proposta inicial de `1024 × 32` bits, porta `1RW` e 4 KiB por OpenRAM deve permanecer candidata até serem validados:

- suporte à configuração e ao PDK exatos;
- Liberty, LEF, GDS, SPICE e modelo Verilog gerados;
- corners e caracterização;
- interface, latência, byte enables e comportamento de leitura durante escrita;
- estratégia de MBIST;
- integração no LibreLane/OpenROAD.

O wrapper do SoC deve isolar o modelo comportamental da macro física e aceitar somente configurações físicas qualificadas.

## 5. Blocos analógicos

### SAR ADC

A referência identificada é um SAR ADC síncrono de 8 bits para IHP SG13G2. Ela inclui comparador dinâmico, chaves, lógica SAR, DAC capacitivo, testbench e referência de layout.

Para cumprir o requisito de 10 bits será necessário, no mínimo:

- ampliar a lógica e o registrador SAR;
- redimensionar ou segmentar o C-DAC;
- reavaliar comparador, chaves, ruído, capacitância e área;
- substituir e redimensionar dispositivos para o PDK escolhido;
- repetir corners, mismatch, Monte Carlo, DRC, LVS e PEX;
- produzir interface digital e modelo comportamental/RNM.

### Bandgap e LDO

O exemplo de bandgap IHP fornece topologia, startup, metodologia gm/Id, simulações e organização de layout. W/L, resistores, tensões, modelos e layout não são portáveis diretamente.

Não foi identificado LDO completo pronto para integração. O LDO deve ser projetado ou obtido externamente, com licença e views físicas adequadas.

## 6. Ferramentas declaradas no ambiente

| Ferramenta | Função principal | Evidência local |
| --- | --- | --- |
| LibreLane | Fluxo RTL-to-GDSII | `README.md` e instalação Nix no `Dockerfile` |
| Yosys | Síntese RTL | `README.md` |
| OpenROAD | Floorplan, placement, CTS e routing | `README.md` e `Dockerfile` |
| OpenSTA | STA integrado ao fluxo | Componente do fluxo LibreLane/OpenROAD; validar comando/versão |
| Icarus Verilog | Simulação Verilog/SystemVerilog básica | `README.md` e `Dockerfile` |
| Verilator | Simulação compilada e lint | `README.md` e `Dockerfile` |
| Xschem | Captura de esquemáticos | `README.md` e `Dockerfile` |
| Ngspice | Simulação elétrica SPICE | `README.md` e `Dockerfile` |
| Magic | Layout, DRC e extração | `README.md` e `Dockerfile` |
| KLayout | Visualização, edição e verificações de layout | `README.md` e instalação da imagem |
| Netgen | LVS/comparação de netlists | `README.md` e `Dockerfile` |
| CVC | Circuit Validity Checker | `README.md` e `Dockerfile` |
| CACE | Caracterização de circuitos | `README.md` |
| OpenVAF | Compilação Verilog-A para OSDI | `README.md` e `Dockerfile` |
| gdsfactory | Geração programática de layouts | `README.md` |
| glayout | Automação de layout independente de PDK | `README.md` |
| pygmid | Dimensionamento sistemático de circuitos | `README.md` |
| Nix | Gerenciamento reproduzível do ambiente | Integração do LibreLane no `README.md`/`Dockerfile` |

A imagem declara suporte a `sky130A`, `ihp-sg13g2` e `gf180mcuD`. O `Makefile` local define `ihp-sg13g2` como PDK padrão. Selecionar `sky130A` explicitamente é obrigatório enquanto essa for a baseline do projeto, inclusive ao iniciar o contêiner com `make start PDK=sky130A`. O wrapper `librelane-local` herda o valor de `PDK` já presente no ambiente.

### Fonte e identificação do SKY130

A documentação upstream do SkyWater SKY130 PDK está em `https://skywater-pdk.readthedocs.io/en/main/` e deve ser consultada como fonte primária para:

- status e versionamento do PDK;
- regras e stack de camadas;
- dispositivos e modelos SPICE;
- bibliotecas digitais, SRAM e I/O;
- informações de DRC, LVS e extração parasitária;
- fluxos documentados de simulação e implementação.

O nome `sky130A` usado no ambiente identifica a instalação/integração preparada por `open_pdks`, não uma versão completa e inequívoca do conteúdo upstream. Para reprodutibilidade, todo relatório deve registrar, quando disponível:

- `PDK` e `PDK_ROOT`;
- destino real do link ou diretório `/opt/pdks/sky130A`;
- versão/commit de `open_pdks` e do SKY130 upstream;
- biblioteca de standard cells e corners;
- decks de DRC, LVS e PEX efetivamente usados.

A documentação oficial declara que está em desenvolvimento e caracteriza a liberação aberta como preview experimental, sem garantia para uso produtivo. Isso é compatível com o objetivo educacional/test chip do projeto, mas impede tratar uma execução limpa como garantia automática de fabricabilidade ou signoff comercial.

Antes de congelar a matriz, capturar dentro da imagem `isaiassh/unic-cass-tools:1.1.0`:

- versão ou commit de cada ferramenta usada;
- PDK ativo e `PDK_ROOT`;
- versões das bibliotecas de standard cells;
- comandos mínimos de smoke test;
- limitações observadas de SystemVerilog e cobertura.

## 7. Limites atuais do ambiente

Não considerar resolvidos apenas pela disponibilidade das ferramentas:

- UVM completo e cobertura funcional/código;
- RNM e co-simulação mixed-signal definitiva;
- UPF e power-aware verification;
- scan insertion e test point insertion;
- ATPG e boundary scan;
- controlador MBIST;
- padframe e integração física final;
- signoff comercial.

## 8. Classificação para planejamento

### Pode ser usado como base de estudo imediata

- Croc, CVE2/CV32E20 e OBI;
- wrapper parametrizado de SRAM;
- UART, GPIO, timer, CLINT e debug/JTAG do Croc;
- fluxo RTL-to-GDSII;
- OpenRAM como candidato para SRAM Sky130;
- arquiteturas de SAR ADC, bandgap, comparador e OTA.

### Requer adaptação e validação

- Croc de IHP para Sky130;
- SRAM física para OpenRAM/Sky130;
- SAR ADC de 8 para 10 bits e porte de PDK;
- bandgap para o PDK escolhido;
- mapa de endereços e interfaces;
- integração analógico-digital;
- firmware e boot.

### Não está resolvido pelo UNIC-CASS

- SPI e I2C;
- LDO completo;
- UPF/power-gating;
- scan, ATPG e boundary scan;
- controlador MBIST;
- modelo RNM final;
- padframe e integração física completa do SoC.

## 9. Baseline candidata para discussão

O levantamento sugere a seguinte configuração apenas para comparação na reunião:

| Item | Candidato |
| --- | --- |
| CPU | CVE2/CV32E20 em RV32IMC |
| Barramento | OBI |
| Memória | 4 KiB, `1024 × 32`, `1RW`, candidata a geração por OpenRAM |
| Periféricos reaproveitados | UART, GPIO, timer, CLINT e JTAG/debug |
| Periféricos externos | SPI e I2C |
| Analógico | SAR ADC de 10 bits derivado da referência de 8 bits; bandgap redimensionado |
| Fluxo inicial | Verilator/Icarus → Yosys → LibreLane/OpenROAD → Magic/KLayout → Netgen/Ngspice |

Nenhum item desta tabela deve ser consolidado em RTL ou constraints definitivos antes da decisão arquitetural correspondente.

## 10. Referência externa: RISC-V_RTL2GDSII

Repositório: `https://github.com/ShekharShwetank/RISC-V_RTL2GDSII`

O projeto de Shekhar Shwetank registra uma trajetória educacional de RTL até GDSII com ferramentas open-source. A parte mais relevante para o Mini-SoC é o fluxo físico do VSDBabySoC em Sky130 por OpenROAD-flow-scripts.

### Conteúdo útil como referência

- sequência de síntese, floorplan, PDN, placement, CTS, routing, SPEF e verificações finais;
- estrutura de `config.mk`, SDC, ordem de pinos e posicionamento de macros;
- integração de macros analógicos de PLL e DAC usando LEF, GDS e Liberty;
- análise de STA e múltiplos corners PVT;
- diagnóstico de congestionamento e acesso físico aos pinos de macros;
- scripts de extração e visualização de métricas de timing;
- uso de Yosys, OpenROAD, OpenSTA, Magic, Ngspice, Icarus e GTKWave com Sky130.

Um aprendizado diretamente aplicável é que baixa utilização não impede falhas de roteamento. No exemplo, obstruções e pinos em camadas sem acesso legal causaram congestionamento; a correção exigiu revisar LEF, shapes de acesso, `OBS`, halo e posicionamento dos macros. Esse caso deve orientar a futura interface física de SRAM, ADC, bandgap e LDO.

### Limites de reutilização

- o design é VSDBabySoC, não o SoC definido pelo escopo vigente;
- o núcleo demonstrado e partes do fluxo usam dependências próprias, incluindo TL-Verilog/SandPiper;
- a configuração é de OpenROAD-flow-scripts e precisa ser traduzida para LibreLane quando aplicável;
- PLL e DAC do exemplo não substituem SAR ADC, bandgap ou LDO do projeto;
- os resultados de PPA e timing não são previsões para o Mini-SoC;
- o repositório não resolve SPI, I2C, UPF, DFT ou MBIST;
- não foi identificada licença explícita na página principal durante a revisão de 2026-08-04.

Até a licença ser esclarecida, usar o repositório apenas para leitura e aprendizado. Qualquer importação futura deve registrar URL, commit fixado, licença, arquivos usados, modificações e testes conforme as regras de importação de IP do projeto.
