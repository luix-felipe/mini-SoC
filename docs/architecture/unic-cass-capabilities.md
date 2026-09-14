# Ambiente UNIC-CASS

## Papel no projeto

O UNIC-CASS fornece uma imagem Docker reproduzível com ferramentas digitais,
analógicas e PDKs. Ele não fornece um Mini-SoC pronto nem qualifica
automaticamente os IPs encontrados no ambiente.

Baseline do projeto:

- imagem: `isaiassh/unic-cass-tools:1.1.0`;
- PDK: `sky130A`;
- biblioteca digital inicial: `sky130_fd_sc_hd`;
- o PDK padrão da imagem é `ihp-sg13g2`; selecionar SKY130 explicitamente.

## Ferramentas úteis agora

| Etapa | Ferramentas |
| --- | --- |
| Simulação e lint RTL | Verilator 5.026, Icarus Verilog |
| Build HDL | FuseSoC 2.4.3, Bender quando exigido pelo IP |
| Síntese | Yosys |
| RTL até GDSII | LibreLane 3.0.0rc1 e OpenROAD |
| Verificação física | Magic, KLayout e Netgen |
| Analógico | Xschem e Ngspice |

O LibreLane está em `/home/designer/.nix-profile/bin/librelane`; os PDKs ficam
em `/opt/pdks`. O wrapper compartilhado executa o fluxo com PDK manual:

```bash
make start PDK=sky130A
/home/designer/shared/bin/librelane-local --smoke-test
```

## Fluxo digital

```text
RTL -> simulação -> síntese -> floorplan -> placement -> CTS -> routing
    -> STA/DRC/LVS -> GDSII
```

LibreLane coordena síntese e implementação física; Verilator/Icarus executam a
simulação RTL. Gerar GDSII, isoladamente, não significa signoff.

## Estado e próximos passos

- Ibex já passou em elaboração e smoke funcional no Verilator.
- Croc compila e apresenta atividade funcional, mas não termina seu smoke.
- Nenhum core foi sintetizado ou implementado em SKY130.
- `flow/config.yaml` ainda precisa definir top, fontes, clock e área inicial.
- O primeiro gate físico deve usar um bloco pequeno; depois, o top escolhido.

O ambiente aberto não garante UVM completo, UPF, scan/ATPG, MBIST ou signoff
comercial. Cada resultado deve registrar versões, comando, PDK, biblioteca e
limitações.
