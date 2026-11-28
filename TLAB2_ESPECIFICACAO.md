# TLAB2 - Especificação Completa da ALU

> Baseado no enunciado **LSD_2627_TLAB2.pdf** (2026/2027 Inverno)

---

## 1. Estrutura de Arquivos VHDL Necessários (12 arquivos)

```
TLAB2/
├── full_adder.vhd           # Somador completo 1 bit (base)
├── adder4.vhd               # Somador 4 bits (4× full_adder)
├── adder_subtractor4.vhd    # Somador/Subtrator 4 bits (AUOp: 0=soma, 1=sub)
├── flags_unit.vhd           # Flags do AU: CBo, OV
├── au_module.vhd            # Módulo aritmético completo (topo AU do LABc)
├── xor0.vhd                 # Bloco Xor0: A = X (OPA=0) ou "0000" (OPA=1)
├── logic_module.vhd         # Módulo lógico: AND, NAND, LSL (com CY)
├── decode_op.vhd            # Decodificador OP[2:0] → OPA..OPF
├── flags_alu.vhd            # Flags finais ALU: CBo, OV, Z, GE, BE
├── mux2to1_4bit.vhd         # MUX 4 bits: AU_R (SEL=0) ou Logic_R (SEL=1)
├── alu.vhd                  # Entidade topo ALU (estrutural)
└── alu_tb.vhd               # Testbench completo
```

> **Nota**: Todos os 12 arquivos já existem no diretório do projeto.

---

## 2. Especificação Funcional (Figura 1 do PDF)

### 2.1 Operações da ALU

| OP[2:0] | Operação | Descrição | Flags Significativas |
|---------|----------|-----------|---------------------|
| `000` | `X + Y + CBi` | Adição | CBo, OV, Z, GE, BE |
| `001` | `X - Y - CBi` | Subtração | CBo, OV, Z, GE, BE |
| `010` | `Y + CBi` | Transferência/Incremento | CBo, OV, Z, GE, BE |
| `011` | `-Y - CBi` | Simétrico/Complemento | CBo, OV, Z, GE, BE |
| `100` | `X AND Y` | AND bit a bit | Z (outras = don't care) |
| `101` | `X NAND Y` | NAND bit a bit | Z (outras = don't care) |
| `110` | `X LSL Y[1:0]` | Logical Shift Left | CBo=X[4-Y[1:0]], Z (outras = don't care) |
| `111` | `X ASR 1` | Arithmetic Shift Right | CBo=X[0], Z (outras = don't care) |

**Detalhes das operações de deslocamento:**
- **LSL**: Desloca X para esquerda **Y[1:0] posições** (0 a 3), preenche com zeros à direita. Y[3:2] ignorados. Se Y[1:0]=00, R=X.
- **ASR**: Desloca X para direita 1 bit, introduz bit de sinal (X[3]) à esquerda.

### 2.2 Definição das 5 Flags Finais da ALU

| Flag | Nome | Condição de Ativação |
|------|------|---------------------|
| **CBo** | Carry/Borrow Out | **Aritméticas (OP[2]=0):** carry da soma ou borrow da subtração.<br>**LSL (110):** último bit deslocado para fora = `X[4-Y[1:0]]` (0 se Y[1:0]=00).<br>**ASR (111):** bit deslocado para fora = `X[0]`.<br>**Lógicas (100,101):** don't care (qualquer valor). |
| **OV** | Overflow | Resultado excede domínio **signed 4 bits** (-8 a +7). Só significativo em aritméticas (OP[2]=0). |
| **Z** | Zero | `R = "0000"` (ativo para todas as operações). |
| **GE** | Greater or Equal | `X ≥ (Y + CBi)` em **signed** (complemento de 2 / inteiros com sinal). |
| **BE** | Below or Equal | `X ≤ (Y + CBi)` em **unsigned** (números naturais / inteiros sem sinal). |

> **Don't care (�)**: Nas operações lógicas (100, 101) e deslocamento (110, 111), as flags GE, BE, OV (exceto CBo no deslocamento) não têm significado definido — podem assumir 0 ou 1.

---

## 3. Arquitetura Interna (Figura 2 - Diagrama de Blocos)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                                   ALU                                       │
│                                                                             │
│  X[3:0] ──────┐                                                             │
│               │  ┌──────┐    A[3:0]      ┌─────────────┐    AU_R[3:0]     │
│  Y[3:0] ──────┼─►│Xor0  │──────────────►│  AU Module  │────────────────┐ │
│               │  │(OPA) │               │  (AUOp=OPC) │                │ │
│  CBi ─────────┼──►│      │               │             │   ┌────────┐   │ │
│               │  └──────┘               └──────┬──────┘   │ MUX    │   │ │
│                                               │          │(SEL=OP2)     │ │
│  OP[2:0] ──►┌──────────┐                      │          └──────┬─────┘ │ │
│             │Decode OP │                      │                 │       │ │
│             │          │ OPA ─────────────────┘                 ▼       ▼ ▼
│             │          │ OPC ──────────────────────────────► AUOp      R[3:0]
│             │          │ OPD,OPE,OPF ──────────────────────►            │
│             │          │                                             ┌─┴─┐
│             └──────────┘                                             │   │
│                   │                                                  │Logic│
│                   ├─► OPA ─────────────────────────────────────────►│Module│
│                   ├─► OPD,OPE,OPF ────────────────────────────────►│      │
│                   │                                                  └─┬─┘
│                   │                                                    │
│                   └─► OP[2] ──────────────────────────────────────────┘ (SEL)
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                     Flags_ALU                                       │   │
│  │  Entradas: AU_CBo, AU_OV, R[3:0], Logic_CY, X[3:0], Y[3:0],       │   │
│  │            CBi, OP[2:0]                                             │   │
│  │  Saídas:  CBo, OV, Z, GE, BE                                       │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 3.1 Descrição dos Blocos

| Bloco | Função |
|-------|--------|
| **Xor0** | `A = X` se OPA=0, `A = "0000"` se OPA=1 |
| **Decode OP** | Converte `OP[2:0]` nos 6 sinais de controle `OPA..OPF` |
| **AU Module** | Unidade aritmética (soma/subtração) — reutilizada do LABc |
| **Logic Module** | Operações lógicas (AND, NAND) + LSL (com saída CY) |
| **MUX 2→1 (4 bits)** | Seleciona `AU_R` (SEL=0/aritmética) ou `Logic_R` (SEL=1/lógica) |
| **Flags_ALU** | Gera as 5 flags finais combinando sinais do AU, Logic e operandos |

---

## 4. Mapeamento Decode OP (Tabela Verdade)

| OP[2:0] | Operação | OPA | OPC | OPD | OPE | OPF | Comentário |
|---------|----------|-----|-----|-----|-----|-----|------------|
| `000` | X+Y+CBi | 0 | 0 | 0 | 0 | 0 | Soma |
| `001` | X-Y-CBi | 0 | 1 | 0 | 0 | 0 | Subtração |
| `010` | Y+CBi | 1 | 0 | 0 | 0 | 0 | A=0, B=Y, soma |
| `011` | -Y-CBi | 1 | 1 | 0 | 0 | 0 | A=0, B=Y, sub |
| `100` | X AND Y | X | X | 0 | 0 | 0 | AND |
| `101` | X NAND Y | X | X | 0 | 0 | 1 | NAND |
| `110` | X LSL Y[1:0] | X | X | 0 | 1 | 0 | LSL |
| `111` | X ASR 1 | X | X | 1 | 0 | 0 | ASR |

> **X** = don't care (não afeta a operação).  
> **OPC** → `AUOp` do AU Module (0=soma, 1=subtração)  
> **OPD** → Ativa ASR no Logic Module  
> **OPE** → Ativa LSL no Logic Module  
> **OPF** → Seleciona NAND (1) vs AND (0) no Logic Module  
> **OPA** → Controla Xor0 (1=zera entrada A para operações só com Y)

---

## 5. Especificação dos Módulos (Interfaces)

### 5.1 Xor0
```vhdl
entity xor0 is
    Port ( X  : in  STD_LOGIC_VECTOR(3 downto 0);
           OPA : in  STD_LOGIC;
           A  : out STD_LOGIC_VECTOR(3 downto 0));
end xor0;
```

### 5.2 AU Module (do LABc)
```vhdl
entity au_module is
    Port ( A    : in  STD_LOGIC_VECTOR(3 downto 0);
           B    : in  STD_LOGIC_VECTOR(3 downto 0);
           CBi  : in  STD_LOGIC;
           AUOp : in  STD_LOGIC;          -- 0=soma, 1=subtração
           R    : out STD_LOGIC_VECTOR(3 downto 0);
           CBo  : out STD_LOGIC;
           OV   : out STD_LOGIC);
end au_module;
```

### 5.3 Logic Module
```vhdl
entity logic_module is
    Port ( X   : in  STD_LOGIC_VECTOR(3 downto 0);
           Y   : in  STD_LOGIC_VECTOR(3 downto 0);
           OPF : in  STD_LOGIC;           -- 1=NAND, 0=AND
           OPE : in  STD_LOGIC;           -- 1=LSL
           OPD : in  STD_LOGIC;           -- 1=ASR
           R   : out STD_LOGIC_VECTOR(3 downto 0);
           CY  : out STD_LOGIC);          -- Carry do shift (para Flags_ALU)
end logic_module;
```

**Lógica LSL**: `R = X << Y[1:0]`, `CY = X[4-Y[1:0]]` (se Y[1:0]≠00, senão 0)  
**Lógica ASR**: `R = X >>> 1` (aritmético, preserva sinal), `CY = X[0]`

### 5.4 Decode OP
```vhdl
entity decode_op is
    Port ( OP  : in  STD_LOGIC_VECTOR(2 downto 0);
           OPA : out STD_LOGIC;
           OPB : out STD_LOGIC;           -- não usado (reservado)
           OPC : out STD_LOGIC;           -- AUOp
           OPD : out STD_LOGIC;           -- ASR enable
           OPE : out STD_LOGIC;           -- LSL enable
           OPF : out STD_LOGIC);          -- NAND select
end decode_op;
```

### 5.5 MUX 2→1 (4 bits)
```vhdl
entity mux2to1_4bit is
    Port ( AU_R   : in  STD_LOGIC_VECTOR(3 downto 0);
           Logic_R: in  STD_LOGIC_VECTOR(3 downto 0);
           SEL    : in  STD_LOGIC;        -- 0=AU, 1=Logic
           R      : out STD_LOGIC_VECTOR(3 downto 0));
end mux2to1_4bit;
```

### 5.6 Flags_ALU
```vhdl
entity flags_alu is
    Port ( AU_CBo   : in  STD_LOGIC;
           AU_OV    : in  STD_LOGIC;
           R        : in  STD_LOGIC_VECTOR(3 downto 0);
           Logic_CY : in  STD_LOGIC;
           X        : in  STD_LOGIC_VECTOR(3 downto 0);
           Y        : in  STD_LOGIC_VECTOR(3 downto 0);
           CBi      : in  STD_LOGIC;
           OP       : in  STD_LOGIC_VECTOR(2 downto 0);
           CBo      : out STD_LOGIC;
           OV       : out STD_LOGIC;
           Z        : out STD_LOGIC;
           GE       : out STD_LOGIC;
           BE       : out STD_LOGIC);
end flags_alu;
```

**Lógica das flags:**
```vhdl
Z  <= '1' when R = "0000" else '0';

CBo <= AU_CBo           when OP(2) = '0' else   -- Aritméticas
       Logic_CY         when OP = "110" else    -- LSL
       X(0)             when OP = "111" else    -- ASR
       '0';                                      -- Lógicas (don't care)

OV  <= AU_OV            when OP(2) = '0' else '0';

GE  <= '1' when signed(X) >= signed(Y) + CBi else '0';   -- signed
BE  <= '1' when unsigned(X) <= unsigned(Y) + CBi else '0'; -- unsigned
```

### 5.7 ALU (Topo)
```vhdl
entity alu is
    Port ( X  : in  STD_LOGIC_VECTOR(3 downto 0);
           Y  : in  STD_LOGIC_VECTOR(3 downto 0);
           OP : in  STD_LOGIC_VECTOR(2 downto 0);
           CBi: in  STD_LOGIC;
           R  : out STD_LOGIC_VECTOR(3 downto 0);
           CBo: out STD_LOGIC;
           OV : out STD_LOGIC;
           Z  : out STD_LOGIC;
           GE : out STD_LOGIC;
           BE : out STD_LOGIC);
end alu;
```

---

## 6. Testbench (alu_tb.vhd)

### 6.1 Casos de Teste Obrigatórios

| # | OP | CBi | X | Y | Descrição |
|---|----|-----|---|---|-----------|
| 1 | 000 | 0 | 0000 | 1111 | Soma 0 + (-1) = -1 |
| 2 | 000 | 1 | 0000 | 1111 | Soma 0 + (-1) + 1 = 0 |
| 3 | 000 | 1 | --- | 0101 | Soma com X irrelevante |
| 4 | 000 | 1 | 1111 | 1010 | Soma -1 + (-6) + 1 = -6 |
| 5 | 001 | 1 | 0000 | 1111 | Sub 0 - (-1) - 1 = 0 |
| 6 | 001 | 1 | 0001 | 0101 | Sub 1 - 5 - 1 = -5 |
| 7 | 001 | 1 | --- | 1010 | Sub com X irrelevante |
| 8 | 010 | 0 | --- | 0001 | Y+CBi = 1 |
| 9 | 010 | 1 | --- | 0001 | Y+CBi = 2 |
|10 | 010 | 1 | --- | 0111 | Y+CBi = 8 |
|11 | 010 | 1 | --- | 1111 | Y+CBi = 0 (com carry) |
|12 | 011 | 0 | --- | 0000 | -Y = 0 |
|13 | 011 | 0 | --- | 1000 | -(-8) = -8 (overflow) |
|14 | 011 | 1 | --- | 0110 | -6 - 1 = -7 |
|15 | 011 | 1 | --- | 1000 | -(-8) - 1 = 7 |
|16 | 100 | 1 | 0001 | 1100 | AND: 0001 & 1100 = 0000 |
|17 | 100 | 0 | 1101 | 1001 | AND: 1101 & 1001 = 1001 |
|18 | 101 | 0 | 1010 | 1110 | NAND: ~(1010 & 1110) = 0101 |
|19 | 110 | 0 | 1001 | 0110 | LSL: 1001 << 2 = 0100, CY=X[2]=0 |
|20 | 111 | 1 | 1111 | ---- | ASR: 1111 >>> 1 = 1111, CY=X[0]=1 |

> **Linhas 21-24**: Definidas pelo grupo (2 aritméticas + 2 lógicas)

### 6.2 Estratégia de Teste Sugerida
1. **20 linhas do Anexo A** — comparar com valores teóricos
2. **4 linhas extras (#21-24)** — criar casos de borda
3. **Teste exaustivo** — 2⁹ = 512 combinações (X[4], Y[4], OP[3], CBi[1])

---

## 7. Implementação na DE10-Lite (Quartus Prime)

### 7.1 Device
- **FPGA**: `10M50DAF484C7G` (MAX 10, DE10-Lite)

### 7.2 Mapeamento de Pinos (.qsf)

| Sinal ALU | Pinos DE10-Lite | Descrição |
|-----------|-----------------|-----------|
| `X[3:0]` | `SW[3:0]` | Operando X |
| `Y[3:0]` | `SW[7:4]` | Operando Y |
| `OP[1:0]` | `SW[9:8]` | OP menos significativos |
| `OP[2]` | `KEY[0]` | OP mais significativo |
| `CBi` | `KEY[1]` | Carry In |
| `R[3:0]` | `LEDR[3:0]` | Resultado |
| `CBo` | `LEDR[4]` | Carry/Borrow Out |
| `OV` | `LEDR[5]` | Overflow |
| `Z` | `LEDR[6]` | Zero |
| `GE` | `LEDR[7]` | Greater or Equal |
| `BE` | `LEDR[8]` | Below or Equal |

> **Nota**: KEYs são active-low na DE10-Lite — considerar inversão se necessário.

---

## 8. Regras de Implementação VHDL

- ✅ **Estritamente estrutural**: 1 arquivo por entidade, `component` + `port map`
- ✅ **Sem código comportamental** (`process`, `if`, `case`) nas entidades estruturais
- ✅ Use `IEEE.NUMERIC_STD` para comparações `signed`/`unsigned` no `flags_alu`
- ✅ Evite `STD_LOGIC_ARITH` / `STD_LOGIC_UNSIGNED` (pacotes obsoletos)

---

## 9. Checklist de Entrega

- [ ] 12 arquivos VHDL compilam sem erro (ModelSim + Quartus)
- [ ] Testbench testa 20 linhas Anexo A + 4 extras + exaustivo
- [ ] Simulação bate com valores teóricos (sem 'X'/'U' nas saídas)
- [ ] Quartus compila sem erro nem warning crítico (timing OK)
- [ ] Pinout DE10-Lite correto (.qsf)
- [ ] Placa programada e funcionando
- [ ] Anexo A preenchido (teórico + experimental)
- [ ] 4 linhas extras (#21-24) documentadas e validadas na placa
- [ ] Relatório breve (2-3 pág): decisões, problemas, resultados

---

## 10. Referências

- `LSD_2627_TLAB2.pdf` — Enunciado oficial
- `LSD_2627_LABc.pdf` — Laboratório anterior (AU Module)
- `TLAB2_PLAN.md` — Plano passo a passo detalhado
- `ANEXO_A_RESULTADOS.md` — Tabela de resultados para preenchimento

---

*Documento gerado para TLAB2 - LSD 2026/2027 Inverno*  
*ISEL - Licenciatura em Engenharia Informática e de Computadores*