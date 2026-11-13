# TLAB2 - Resumo dos Arquivos Criados

## Arquivos VHDL (12 arquivos)

### Módulos do AU (reutilizados do LABc)
| Arquivo | Descrição |
|---------|-----------|
| `full_adder.vhd` | Somador completo 1 bit |
| `adder4.vhd` | Somador 4 bits (4 full adders) |
| `adder_subtractor4.vhd` | Somador/Subtrator 4 bits com AUOp |
| `flags_unit.vhd` | Unidade de flags (CBo, OV) do AU |
| `au_module.vhd` | Módulo aritmético completo (topo do AU) |

### Módulos novos para TLAB2
| Arquivo | Descrição |
|---------|-----------|
| `xor0.vhd` | Seleciona X ou 0 para entrada A do AU |
| `logic_module.vhd` | Módulo lógico (AND, NAND, LSL, ASR) |
| `decode_op.vhd` | Decodificador OP[2:0] → OPA..OPF |
| `flags_alu.vhd` | Unidade de flags final (CBo, OV, Z, GE, BE) |
| `mux2to1_4bit.vhd` | MUX 4 bits (AU vs Logic) |
| `alu.vhd` | Entidade de topo ALU (estrutural) |
| `alu_tb.vhd` | Testbench completo (Anexo A + 4 extras + exaustivo) |

## Arquivos de Suporte
| Arquivo | Descrição |
|---------|-----------|
| `simulate.do` | Script ModelSim para compilação e simulação |
| `DE10_Lite_Pinout.qsf` | Mapeamento de pinos para Quartus |
| `TLAB2_PLAN.md` | Plano detalhado passo a passo |
| `FILES_SUMMARY.md` | Este arquivo |

---

## Como Simular (ModelSim/QuestaSim)

```bash
# No terminal, na pasta do projeto:
vsim -do simulate.do
```

Ou abra o ModelSim GUI:
1. File → Change Directory → pasta do projeto
2. File → Execute Macro → selecione `simulate.do`

---

## Como Implementar no Quartus Prime

1. **Novo Projeto**: File → New Project Wizard
   - Device: `10M50DAF484C7G` (DE10-Lite)
   - Adicione todos os 12 arquivos `.vhd`

2. **Pinout**: Assignments → Pin Planner
   - Importe `DE10_Lite_Pinout.qsf` ou configure manualmente conforme tabela

3. **Compilar**: Processing → Start Compilation
   - Verificar: 0 errors, timing OK

4. **Programar**: Tools → Programmer
   - Hardware: USB-Blaster
   - Start → Program

---

## Mapeamento de Pinos DE10-Lite

| Sinal ALU | Pino FPGA | Componente Placa |
|-----------|-----------|------------------|
| X[3:0] | SW[3:0] | Switches 0-3 |
| Y[3:0] | SW[7:4] | Switches 4-7 |
| OP[1:0] | SW[9:8] | Switches 8-9 |
| OP[2] | KEY[0] | Botão KEY0 |
| CBi | KEY[1] | Botão KEY1 |
| R[3:0] | LEDR[3:0] | LEDs vermelhos 0-3 |
| CBo | LEDR[4] | LED vermelho 4 |
| OV | LEDR[5] | LED vermelho 5 |
| Z | LEDR[6] | LED vermelho 6 |
| GE | LEDR[7] | LED vermelho 7 |
| BE | LEDR[8] | LED vermelho 8 |

---

## Tabela de Operações (OP[2:0])

| OP | Operação | Descrição |
|----|----------|-----------|
| 000 | X + Y + CBi | Adição |
| 001 | X - Y - CBi | Subtração |
| 010 | Y + CBi | Transferência/Incremento |
| 011 | Y - CBi | Simétrico/Complemento |
| 100 | X AND Y | AND bit a bit |
| 101 | X NAND Y | NAND bit a bit |
| 110 | X LSL Y[1:0] | Logical Shift Left |
| 111 | X ASR 1 | Arithmetic Shift Right |

---

## Flags de Saída

| Flag | Significado | Ativa quando... |
|------|-------------|-----------------|
| **CBo** | Carry/Borrow Out | Aritméticas: carry/borrow; LSL: último bit deslocado; ASR: X[0] |
| **OV** | Overflow | Resultado excede domínio signed (-8 a +7) |
| **Z** | Zero | R = "0000" |
| **GE** | Greater or Equal | X ≥ (Y+CBi) em signed |
| **BE** | Below or Equal | X ≤ (Y+CBi) em unsigned |

---

