# Evidências: passos 11 a 15 do Ibex

Atualizado em 2026-09-18. Os blocos seguintes transcrevem os trechos finais
fornecidos pelo operador no chat; espaços/formatação foram normalizados.
Não são logs completos. Os números da análise abaixo foram conferidos nos
relatórios locais dos runs, sem executar novos fluxos.

## Trechos de terminal — passos 11 a 14

### ibex-cts

```text
[19:08:40] INFO Flow complete.
Classic - Stage 80 - Report Manufacturability 80/80 0:03:36
[19:08:40] WARNING [Checker.LintWarnings] 134 Lint warnings found.
[19:08:40] WARNING [OpenROAD.GlobalPlacement] [GRT-0281] Net rst_ni has a large fanout of 1674 terminals. (and 1 similar warnings)
[19:08:40] WARNING [OpenROAD.RepairDesignPostGPL] [STA-1140] /opt/pdks/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
line 1, library sky130_fd_sc_hd__tt_025C_1v80 already exists. (and 11 similar warnings)
[19:08:40] WARNING [OpenROAD.RepairDesignPostGPL] [RSZ-0020] found 2 floating nets.
Command being timed: "/home/designer/shared/bin/librelane-local --run-tag ibex-cts --to OpenROAD.CTS experiments/librelane-ibex/config.yaml"
User time (seconds): 294.85
System time (seconds): 6.37
Percent of CPU this job got: 129%
Elapsed (wall clock) time (h:mm:ss or m:ss): 3:52.72
Average shared text size (kbytes): 0
Average unshared data size (kbytes): 0
Average stack size (kbytes): 0
Average total size (kbytes): 0
Maximum resident set size (kbytes): 884260
Average resident set size (kbytes): 0
Major (requiring I/O) page faults: 277
Minor (reclaiming a frame) page faults: 2333468
Voluntary context switches: 32583
Involuntary context switches: 13708
Swaps: 0
File system inputs: 829112
File system outputs: 779016
Socket messages sent: 0
Socket messages received: 0
Signals delivered: 0
Page size (bytes): 4096
Exit status: 0
```

### ibex-postcts

```text
[19:34:04] INFO Flow complete.
Classic - Stage 80 - Report Manufacturability 80/80 0:05:06
[19:34:04] WARNING [Checker.LintWarnings] 134 Lint warnings found.
[19:34:04] WARNING [OpenROAD.GlobalPlacement] [GRT-0281] Net rst_ni has a large fanout of 1674 terminals. (and 1 similar warnings)
[19:34:04] WARNING [OpenROAD.RepairDesignPostGPL] [STA-1140] /opt/pdks/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
line 1, library sky130_fd_sc_hd__tt_025C_1v80 already exists. (and 17 similar warnings)
[19:34:04] WARNING [OpenROAD.RepairDesignPostGPL] [RSZ-0020] found 2 floating nets.
Command being timed: "/home/designer/shared/bin/librelane-local --run-tag ibex-postcts --to OpenROAD.STAMidPNR-2 experiments/librelane-ibex/config.yaml"
User time (seconds): 379.39
System time (seconds): 7.84
Percent of CPU this job got: 119%
Elapsed (wall clock) time (h:mm:ss or m:ss): 5:24.35
Average shared text size (kbytes): 0
Average unshared data size (kbytes): 0
Average stack size (kbytes): 0
Average total size (kbytes): 0
Maximum resident set size (kbytes): 884420
Average resident set size (kbytes): 0
Major (requiring I/O) page faults: 274
Minor (reclaiming a frame) page faults: 3009306
Voluntary context switches: 41742
Involuntary context switches: 12958
Swaps: 0
File system inputs: 797520
File system outputs: 1036960
Socket messages sent: 0
Socket messages received: 0
Signals delivered: 0
Page size (bytes): 4096
Exit status: 0
```

### ibex-global-routing

```text
[21:59:49] INFO Flow complete.
Classic - Stage 80 - Report Manufacturability 80/80 0:05:04
[21:59:49] WARNING [Checker.LintWarnings] 134 Lint warnings found.
[21:59:49] WARNING [OpenROAD.GlobalPlacement] [GRT-0281] Net rst_ni has a large fanout of 1674 terminals. (and 1 similar warnings)
[21:59:49] WARNING [OpenROAD.RepairDesignPostGPL] [STA-1140] /opt/pdks/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
line 1, library sky130_fd_sc_hd__tt_025C_1v80 already exists. (and 17 similar warnings)
[21:59:49] WARNING [OpenROAD.RepairDesignPostGPL] [RSZ-0020] found 2 floating nets.
Command being timed: "/home/designer/shared/bin/librelane-local --run-tag ibex-global-routing --to OpenROAD.GlobalRouting experiments/librelane-ibex/config.yaml"
User time (seconds): 377.90
System time (seconds): 8.40
Percent of CPU this job got: 119%
Elapsed (wall clock) time (h:mm:ss or m:ss): 5:23.26
Average shared text size (kbytes): 0
Average unshared data size (kbytes): 0
Average stack size (kbytes): 0
Average total size (kbytes): 0
Maximum resident set size (kbytes): 884016
Average resident set size (kbytes): 0
Major (requiring I/O) page faults: 274
Minor (reclaiming a frame) page faults: 3114461
Voluntary context switches: 41450
Involuntary context switches: 13953
Swaps: 0
File system inputs: 800368
File system outputs: 1103328
Socket messages sent: 0
Socket messages received: 0
Signals delivered: 0
Page size (bytes): 4096
Exit status: 0
```

### ibex-detailed-routing

```text
Classic - Stage 80 - Report Manufacturability 80/80 0:18:45
[22:51:39] WARNING [Checker.LintWarnings] 134 Lint warnings found.
[22:51:39] WARNING [OpenROAD.GlobalPlacement] [GRT-0281] Net rst_ni has a large fanout of 1674 terminals. (and 1 similar warnings)
[22:51:39] WARNING [OpenROAD.RepairDesignPostGPL] [STA-1140] /opt/pdks/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
line 1, library sky130_fd_sc_hd__tt_025C_1v80 already exists. (and 17 similar warnings)
[22:51:39] WARNING [OpenROAD.RepairDesignPostGPL] [RSZ-0020] found 2 floating nets.
[22:51:39] WARNING [OpenROAD.DiodeInsertion] [GRT-0243] Unable to repair antennas on net with diodes. (and 2 similar warnings)
[22:51:39] WARNING [OpenROAD.DetailedRouting] [DRT-0349] LEF58_ENCLOSURE with no CUTCLASS is not supported. Skipping for layer mcon (and 9 similar warnings)
Command being timed: "/home/designer/shared/bin/librelane-local --run-tag ibex-detailed-routing --to OpenROAD.DetailedRouting experiments/librelane-ibex/config.yaml"
User time (seconds): 3334.82
System time (seconds): 17.78
Percent of CPU this job got: 212%
Elapsed (wall clock) time (h:mm:ss or m:ss): 26:20.44
Average shared text size (kbytes): 0
Average unshared data size (kbytes): 0
Average stack size (kbytes): 0
Average total size (kbytes): 0
Maximum resident set size (kbytes): 2344556
Average resident set size (kbytes): 0
Major (requiring I/O) page faults: 278
Minor (reclaiming a frame) page faults: 4167305
Voluntary context switches: 63856
Involuntary context switches: 449610
Swaps: 0
File system inputs: 807528
File system outputs: 1564496
Socket messages sent: 0
Socket messages received: 0
Signals delivered: 0
Page size (bytes): 4096
Exit status: 0
```

## Trecho de terminal — passo 15 (`ibex-full`)

```text
Final result:
Circuits match uniquely.
.
Logging to file "/home/designer/shared/chipus-soc/mini-SoC/experiments/librelane-ibex/runs/ibex-full/70-netgen-lvs/reports/lvs.netgen.rpt" disabled
LVS Done.
──────────────────────────────────────────────────────────── Layout vs. Schematic Error Checker ────────────────────────────────────────────────────────────
[23:41:29] VERBOSE  Running 'Checker.LVS' at 'experiments/librelane-ibex/runs/ibex-full/71-checker-lvs'…                                        step.py:1138
[23:41:29] INFO     Check for LVS errors clear.                                                                                               checker.py:131
[23:41:29] INFO     Gating variable for step 'Yosys.EQY' set to 'False'- the step will be skipped.                                         sequential.py:362
[23:41:29] INFO     Skipping step 'Equivalence Check'…                                                                                     sequential.py:370
───────────────────────────────────────────────────────────── Setup Timing Violations Checker ──────────────────────────────────────────────────────────────
[23:41:29] VERBOSE  Running 'Checker.SetupViolations' at 'experiments/librelane-ibex/runs/ibex-full/72-checker-setupviolations'…                step.py:1138
[23:41:29] WARNING  Setup violations found in the following corners:                                                                          checker.py:626
                    * max_ss_100C_1v60
                    * nom_ss_100C_1v60
[23:41:29] VERBOSE  No setup violations found                                                                                                 checker.py:628
────────────────────────────────────────────────────────────── Hold Timing Violations Checker ──────────────────────────────────────────────────────────────
[23:41:29] VERBOSE  Running 'Checker.HoldViolations' at 'experiments/librelane-ibex/runs/ibex-full/73-checker-holdviolations'…                  step.py:1138
[23:41:29] VERBOSE  No hold violations found                                                                                                  checker.py:628
───────────────────────────────────────────────────────────── Maximum Slew Violations Checker ──────────────────────────────────────────────────────────────
[23:41:29] VERBOSE  Running 'Checker.MaxSlewViolations' at 'experiments/librelane-ibex/runs/ibex-full/74-checker-maxslewviolations'…            step.py:1138
[23:41:29] WARNING  Max Slew violations found in the following corners:                                                                       checker.py:626
                    * max_ff_n40C_1v95
                    * max_ss_100C_1v60
                    * max_tt_025C_1v80
                    * min_ff_n40C_1v95
                    * min_ss_100C_1v60
                    * min_tt_025C_1v80
                    * nom_ff_n40C_1v95
                    * nom_ss_100C_1v60
                    * nom_tt_025C_1v80
[23:41:29] VERBOSE  No max slew violations found                                                                                              checker.py:628
────────────────────────────────────────────────────────── Maximum Capacitance Violations Checker ──────────────────────────────────────────────────────────
[23:41:29] VERBOSE  Running 'Checker.MaxCapViolations' at 'experiments/librelane-ibex/runs/ibex-full/75-checker-maxcapviolations'…              step.py:1138
[23:41:29] WARNING  Max Cap violations found in the following corners:                                                                        checker.py:626
                    * max_ss_100C_1v60
                    * max_tt_025C_1v80
                    * min_ss_100C_1v60
                    * nom_ss_100C_1v60
                    * nom_tt_025C_1v80
[23:41:29] VERBOSE  No max cap violations found                                                                                               checker.py:628
─────────────────────────────────────────────────────── Report Manufacturability (DRC, LVS, Antenna) ───────────────────────────────────────────────────────
[23:41:29] VERBOSE  Running 'Misc.ReportManufacturability' at 'experiments/librelane-ibex/runs/ibex-full/76-misc-reportmanufacturability'…      step.py:1138
* Antenna
Passed ✅

* LVS
Passed ✅

* DRC
Passed ✅

[23:41:29] INFO     Saving views to '/home/designer/shared/chipus-soc/mini-SoC/experiments/librelane-ibex/runs/ibex-full/final'…                state.py:209
[23:41:30] INFO     Flow complete.                                                                                                         sequential.py:413
Classic - Stage 80 - Report Manufacturability ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 80/80 0:27:04
[23:41:30] WARNING  The following warnings were generated by the flow:                                                                           flow.py:699
[23:41:30] WARNING  [Checker.LintWarnings] 134 Lint warnings found.                                                                              flow.py:701
[23:41:30] WARNING  [OpenROAD.GlobalPlacement] [GRT-0281] Net rst_ni has a large fanout of 1674 terminals. (and 1 similar warnings)              flow.py:701
[23:41:30] WARNING  [OpenROAD.RepairDesignPostGPL] [STA-1140] /opt/pdks/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib   flow.py:701
                    line 1, library sky130_fd_sc_hd__tt_025C_1v80 already exists. (and 17 similar warnings)
[23:41:30] WARNING  [OpenROAD.RepairDesignPostGPL] [RSZ-0020] found 2 floating nets.                                                             flow.py:701
[23:41:30] WARNING  [OpenROAD.DiodeInsertion] [GRT-0243] Unable to repair antennas on net with diodes. (and 2 similar warnings)                  flow.py:701
[23:41:30] WARNING  [OpenROAD.DetailedRouting] [DRT-0349] LEF58_ENCLOSURE with no CUTCLASS is not supported. Skipping for layer mcon (and 9      flow.py:701
                    similar warnings)
[23:41:30] WARNING  [Checker.WireLength] Threshold for Threshold-surpassing long wires is not set. The checker will be skipped.                  flow.py:701
[23:41:30] WARNING  [OpenROAD.IRDropReport] 'VSRC_LOC_FILES' was not given a value, which may make the results of IR drop analysis inaccurate.   flow.py:701
                    If you are not integrating a top-level chip for manufacture, you may ignore this warning, otherwise, see the documentation
                    for 'VSRC_LOC_FILES'.
[23:41:30] WARNING  [Odb.CheckDesignAntennaProperties] Cell 'chipus_ibex_wrapper' has (7) output pin(s) without antenna diffusion information.   flow.py:701
                    They might not be driven.
[23:41:30] WARNING  [Checker.SetupViolations] Setup violations found in the following corners:                                                   flow.py:701
                    * max_ss_100C_1v60
                    * nom_ss_100C_1v60
[23:41:30] WARNING  [Checker.MaxSlewViolations] Max Slew violations found in the following corners:                                              flow.py:701
                    * max_ff_n40C_1v95
                    * max_ss_100C_1v60
                    * max_tt_025C_1v80
                    * min_ff_n40C_1v95
                    * min_ss_100C_1v60
                    * min_tt_025C_1v80
                    * nom_ff_n40C_1v95
                    * nom_ss_100C_1v60
                    * nom_tt_025C_1v80
[23:41:30] WARNING  [Checker.MaxCapViolations] Max Cap violations found in the following corners:                                                flow.py:701
                    * max_ss_100C_1v60
                    * max_tt_025C_1v80
                    * min_ss_100C_1v60
                    * nom_ss_100C_1v60
                    * nom_tt_025C_1v80
        Command being timed: "/home/designer/shared/bin/librelane-local --run-tag ibex-full experiments/librelane-ibex/config.yaml"
        User time (seconds): 4207.03
        System time (seconds): 39.44
        Percent of CPU this job got: 237%
        Elapsed (wall clock) time (h:mm:ss or m:ss): 29:49.31
        Average shared text size (kbytes): 0
        Average unshared data size (kbytes): 0
        Average stack size (kbytes): 0
        Average total size (kbytes): 0
        Maximum resident set size (kbytes): 2313336
        Average resident set size (kbytes): 0
        Major (requiring I/O) page faults: 410
        Minor (reclaiming a frame) page faults: 7501513
        Voluntary context switches: 580057
        Involuntary context switches: 597542
        Swaps: 0
        File system inputs: 1458408
        File system outputs: 4073456
        Socket messages sent: 0
        Socket messages received: 0
        Signals delivered: 0
        Page size (bytes): 4096
        Exit status: 0
```

## Conferência dos relatórios locais

Caminhos relativos a `experiments/librelane-ibex/runs/` (ignorados pelo Git):

- `ibex-postcts/38-openroad-stamidpnr-2/or_metrics_out.json`: TT, setup
  +18,1573 ns; hold +0,300589 ns; zero violações de setup/hold/slew/cap;
  13 de fanout. SS/FF presentes no `final/metrics.json` desse gate são métricas
  herdadas da análise anterior, não uma nova STA pós-CTS nesses cantos.
- `ibex-postcts/37-openroad-resizertimingpostcts/`: 1.723 buffers de hold
  inseridos; total de 4.420 timing repair buffers após os reparos.
- `ibex-global-routing/39-openroad-globalrouting/openroad-globalrouting.log`:
  overflow final zero; uso agregado 35,70%; 16.721 redes; 1.229.959 µm;
  134.863 vias planejadas.
- `ibex-detailed-routing/44-openroad-detailedrouting/openroad-detailedrouting.log`:
  932.198 µm; 137.387 vias; checagem de antena final com zero rede/pino violador.
  `or_metrics_out.json` termina com `route__drc_errors: 0`; resultados
  intermediários repetidos no arquivo não representam o estado final.
- `ibex-full/final/metrics.json`: setup -1,816531 ns em `max_ss_100C_1v60`
  e -0,300858 ns em `nom_ss_100C_1v60`; hold sem violações nos nove cantos.
  Slew viola nos nove cantos (máximo 6.981 em `max_ss`); capacitância em cinco
  (máximo 71 em `max_ss`). Essas contagens não devem ser somadas como redes únicas.
- `ibex-full/final/gds/chipus_ibex_wrapper.gds`: arquivo gerado e localizado;
  isso não confirma que o operador o abriu no KLayout.

Conclusão: RTL -> GDSII executado, DRC/LVS/antena aprovados, mas **sem signoff**.
EQY foi pulado; IR drop e reset ainda têm as limitações descritas no roteiro.
