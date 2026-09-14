# Pipe clean dos cores RISC-V

Ponto de entrada para qualificar os clones externos:

```text
chipus-soc/
├── ip-candidates/riscv/{ibex,croc}/  # não pertencem ao Git do mini-SoC
└── mini-SoC/
    ├── pipe-clean/                    # comandos
    └── experiments/riscv-core-qualification/ # scripts e evidências
```

## Comandos

Na raiz `chipus-soc/`:

```bash
make -C mini-SoC/pipe-clean show
make -C mini-SoC/pipe-clean ibex-core
make -C mini-SoC/pipe-clean ibex-wrapper
make -C mini-SoC/pipe-clean ibex-smoke
make -C mini-SoC/pipe-clean croc-smoke
```

| Alvo | O que verifica | Onde iniciar |
| --- | --- | --- |
| `ibex-core` | elaboração do `ibex_top` | WSL ou UNIC-CASS |
| `ibex-wrapper` | elaboração do wrapper CHIPUS + `ibex_top` | WSL ou UNIC-CASS |
| `ibex-smoke` | firmware no Simple System | WSL |
| `croc-smoke` | build e smoke do Croc | WSL |

Os dois últimos criam contêineres efêmeros com dependências extras. O
`ibex-core` detecta quando já está dentro do UNIC-CASS e evita Docker aninhado.

Abra a raiz `chipus-soc/` no VS Code para enxergar simultaneamente os clones e o
repositório `mini-SoC`. Somente arquivos do `mini-SoC` devem ser commitados.
