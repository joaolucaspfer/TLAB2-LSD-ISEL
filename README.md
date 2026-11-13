# TLAB2 - ALU de 4 bits

Implementação do Trabalho Laboratorial 2 da unidade curricular de Lógica e
Sistemas Digitais do ISEL, realizado por:

- **João Ferreira** - 56012
- **André Granja** - 56010

**Docente:** Pedro Miguens

## Objetivo

Desenvolver uma unidade aritmética e lógica (ALU) de 4 bits em VHDL
estrutural, simular o circuito e implementá-lo na placa DE10-Lite.

## Operações

| `OP` | Operação |
|---|---|
| `000` | `X + Y + CBi` |
| `001` | `X - Y - CBi` |
| `010` | `Y + CBi` |
| `011` | `-Y - CBi` |
| `100` | `X AND Y` |
| `101` | `X NAND Y` |
| `110` | `X LSL Y[1:0]` |
| `111` | `X ASR 1` |

A ALU produz o resultado `R` e as flags `CBo`, `OV`, `Z`, `GE` e `BE`.

## Estrutura

- `full_adder.vhd`, `adder4.vhd`: somadores;
- `adder_subtractor4.vhd`, `flags_unit.vhd`, `au_module.vhd`: unidade
  aritmética reutilizada do LABc;
- `xor0.vhd`: seleciona `X` ou zero para a entrada da AU;
- `logic_module.vhd`: AND, NAND, LSL e ASR;
- `decode_op.vhd`: descodificador da operação;
- `mux2to1_4bit.vhd`: seleciona o resultado aritmético ou lógico;
- `flags_alu.vhd`: gera as flags finais;
- `alu.vhd`: entidade de topo;
- `alu_tb.vhd`: testbench;
- `DE10_Lite_Pinout.qsf`: atribuição dos pinos da placa;
- `ANEXO_A_RESULTADOS.md`: resultados teóricos do Anexo A.

## Simulação

É necessário ter o ModelSim/QuestaSim instalado. Na pasta do projeto,
executar:

```text
vsim -do simulate.do
```

O testbench verifica as 24 linhas do Anexo A e testa exaustivamente as
4096 combinações possíveis de `X`, `Y`, `OP` e `CBi`.

## DE10-Lite

| Sinal | Placa |
|---|---|
| `X[3:0]` | `SW[3:0]` |
| `Y[3:0]` | `SW[7:4]` |
| `OP[1:0]` | `SW[9:8]` |
| `OP[2]` | `KEY[0]` |
| `CBi` | `KEY[1]` |
| `R[3:0]` | `LEDR[3:0]` |
| `CBo` | `LEDR[4]` |
| `OV` | `LEDR[5]` |
| `Z` | `LEDR[6]` |
| `GE` | `LEDR[7]` |
| `BE` | `LEDR[8]` |

Para implementar na placa:

1. Criar um projeto no Quartus Prime;
2. Selecionar o dispositivo `10M50DAF484C7G`;
3. Adicionar os ficheiros VHDL;
4. Definir `alu` como entidade de topo;
5. Aplicar as atribuições de `DE10_Lite_Pinout.qsf`;
6. Compilar e programar através do USB-Blaster.

## Relatório

O relatório está disponível em:

```text
Template_Relatorio/LSD_2627_template/report.tex
Template_Relatorio/LSD_2627_template/report.pdf
```

