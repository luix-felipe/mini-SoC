# Rotina de desenvolvimento

Edite no WSL e execute evidências oficiais na imagem
`isaiassh/unic-cass-tools:1.1.0`.

## Iniciar o ambiente

No WSL:

```bash
cd "$HOME/eda/uniccass-icdesign-tools"
make start PDK=sky130A
```

Dentro do contêiner:

```bash
cd /home/designer/shared/chipus-soc/mini-SoC
echo "$PDK"
/home/designer/shared/bin/verificar-ambiente-unicass
```

SKY130 deve ser informado explicitamente porque a imagem inicia por padrão com
IHP.

## Ferramentas por etapa

| Trabalho | Ferramenta |
| --- | --- |
| Simulação/lint RTL | Verilator ou Icarus |
| Firmware | `riscv64-unknown-elf-gcc` |
| Síntese | Yosys |
| Implementação física | LibreLane/OpenROAD |
| DRC/LVS | Magic/KLayout/Netgen |

Os comandos reproduzíveis dos cores estão em [`pipe-clean`](../../pipe-clean/README.md).
Quando `flow/config.yaml` existir, executar:

```bash
/home/designer/shared/bin/librelane-local flow/config.yaml
```

Um resultado oficial deve registrar comando, revisão, versões, PDK/biblioteca,
status, warnings relevantes e o que ainda não foi testado. Builds, caches,
waveforms grandes e runs físicos ficam fora do Git.
