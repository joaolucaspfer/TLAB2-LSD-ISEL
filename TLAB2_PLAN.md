# TLAB2 - Plano Passo a Passo Detalhado

## Visão Geral
O objetivo é projetar uma **ALU (Arithmetic and Logic Unit)** de 4 bits em VHDL estrutural, simulá-la com testbench, e implementá-la na placa **DE10-Lite** da Intel.

---

## Estrutura do Projeto (Arquivos VHDL a Criar)

```
TLAB2/
├── full_adder.vhd          # Somador completo 1 bit
├── adder4.vhd              # Somador 4 bits (4 full adders)
├── adder_subtractor4.vhd   # Somador/Subtrator 4 bits
├── flags_unit.vhd          # Unidade de flags (CBo, OV) do AU
├── au_module.vhd           # Módulo aritmético completo (AU) - do LABc
├── xor0.vhd                # Bloco Xor0 (seleciona X ou 0 para entrada A do AU)
├── logic_module.vhd        # Módulo lógico (AND, NAND, LSL)
├── decode_op.vhd           # Decodificador OP[2:0] → OPA..OPF
├── flags_alu.vhd           # Unidade de flags final da ALU (CBo, OV, Z, GE, BE)
├── mux2to1_4bit.vhd        # MUX 4 bits (seleciona resultado AU ou Logic)
├── alu.vhd                 # Entidade de topo ALU
├── alu_tb.vhd              # Testbench
└── DE10_Lite_Pinout.qsf    # Mapeamento de pinos (criado pelo Quartus)
```

---

## Passo 1: Entender a Especificação da ALU

### Operações da ALU (Tabela da Figura 1)

| OP[2:0] | Operação | Descrição | Flags Significativas |
|---------|----------|-----------|---------------------|
| 000 | X + Y + CBi | Adição | CBo, OV, Z, GE, BE |
| 001 | X - Y - CBi | Subtração | CBo, OV, Z, GE, BE |
| 010 | Y + CBi | Transferência/Incremento | CBo, OV, Z, GE, BE |
| 011 | -Y - CBi | Simétrico/Complemento | CBo, OV, Z, GE, BE |
| 100 | X AND Y | AND com negação | Z (outras = don't care) |
| 101 | X NAND Y | NAND | Z (outras = don't care) |
| 110 | X LSL Y[1:0] | Logical Shift Left | CBo=X[4-Y[1:0]], Z (outras = don't care) |
| 111 | X ASR 1 | Arithmetic Shift Right | CBo=X[0], Z (outras = don't care) |

### Definição das Flags Finais (ALU)

| Flag | Nome | Ativa quando... |
|------|------|-----------------|
| **CBo** | Carry/Borrow Out | **Aritméticas:** carry da soma ou borrow da subtração. **LSL:** último bit deslocado para fora (X[4-Y[1:0]]). **ASR:** bit deslocado para fora (X[0]). |
| **OV** | Overflow | Resultado excede domínio de inteiros com sinal (-8 a +7 para 4 bits) |
| **Z** | Zero | Resultado R = "0000" |
| **GE** | Greater or Equal | X ≥ (Y + CBi) em **complemento de 2** (inteiros com sinal) |
| **BE** | Below or Equal | X ≤ (Y + CBi) em **unsigned** (números naturais) |

---

## Passo 2: Reutilizar o AU Module do LABc

O **AU Module** (Unidade Aritmética) já foi desenvolvido no LABc. Ele contém:
- `full_adder` (1 bit)
- `adder4` (4 bits)
- `adder_subtractor4` (4 bits com AUOp)
- `flags_unit` (gera CBo e OV)
- `au_module` (topo do AU)

### O que o AU Module faz:
- Entradas: `A[3:0]`, `B[3:0]`, `CBi`, `AUOp` (0=soma, 1=subtração)
- Saídas: `R[3:0]`, `CBo`, `OV`

### **Ação**: Copie os arquivos do LABc para esta pasta e renomeie se necessário:
- `full_adder.vhd`
- `adder4.vhd`  
- `adder_subtractor4.vhd`
- `flags_unit.vhd`
- `au_module.vhd`

---

## Passo 3: Criar o Bloco Xor0

**Função**: Coloca na entrada A do AU o operando X ou o valor 0, conforme sinal OPA.

### Tabela Verdade:
| OPA | A[3:0] (saída) |
|-----|----------------|
| 0   | X[3:0]         |
| 1   | "0000"         |

### Implementação:
```vhdl
entity xor0 is
    Port ( X : in  STD_LOGIC_VECTOR(3 downto 0);
           OPA : in  STD_LOGIC;
           A : out STD_LOGIC_VECTOR(3 downto 0));
end xor0;

architecture Behavioral of xor0 is
begin
    A <= X when OPA = '0' else "0000";
end Behavioral;
```

---

## Passo 4: Criar o Módulo Lógico (Logic Module)

Baseia-se no LABb + operação **LSL (Logical Shift Left)**.

### Operações:
| OPF OPE OPD | Operação | Descrição |
|-------------|----------|-----------|
| 0 0 0 | X AND Y | AND bit a bit |
| 0 0 1 | X NAND Y | NAND bit a bit |
| 0 1 0 | X LSL Y[1:0] | Shift left lógico por Y[1:0] posições |
| Outros | Don't care | - |

### LSL Detalhes:
- Desloca X para esquerda **Y[1:0] posições** (0 a 3)
- Preenche com zeros à direita
- **CY (Carry do Logic)** = último bit deslocado para fora = `X[4 - Y[1:0]]` (se Y[1:0] ≠ 00), senão 0
- Y[3:2] são ignorados

### Entradas/Saídas:
```vhdl
entity logic_module is
    Port ( X : in  STD_LOGIC_VECTOR(3 downto 0);
           Y : in  STD_LOGIC_VECTOR(3 downto 0);
           OPF, OPE, OPD : in  STD_LOGIC;  -- Sinais de controle
           R : out STD_LOGIC_VECTOR(3 downto 0);
           CY : out STD_LOGIC);            -- Carry do shift (para Flags)
end logic_module;
```

---

## Passo 5: Criar o Decode OP

**Função**: Converte `OP[2:0]` nos sinais internos `OPA, OPB, OPC, OPD, OPE, OPF`

### Mapeamento (deduzido da Figura 2 e tabela de operações):

| OP[2:0] | Operação | OPA | OPB | OPC | OPD | OPE | OPF |
|---------|----------|-----|-----|-----|-----|-----|-----|
| 000 | X+Y+CBi | 0 | 0 | 0 | 0 | 0 | 0 |
| 001 | X-Y-CBi | 0 | 0 | 1 | 0 | 0 | 0 |
| 010 | Y+CBi | 1 | 0 | 0 | 0 | 0 | 0 |
| 011 | -Y-CBi | 1 | 0 | 1 | 0 | 0 | 0 |
| 100 | X AND Y | X | X | X | 0 | 0 | 0 |
| 101 | X NAND Y | X | X | X | 0 | 0 | 1 |
| 110 | X LSL Y[1:0] | X | X | X | 0 | 1 | 0 |
| 111 | X ASR 1 | X | X | X | 1 | 0 | 0 |

**Nota**: `X` = don't care. OPC controla soma/subtração no AU. OPD/OPE/OPF controlam o Logic Module. OPA controla Xor0.

### Lógica do Decoder:
```vhdl
entity decode_op is
    Port ( OP : in  STD_LOGIC_VECTOR(2 downto 0);
           OPA, OPB, OPC, OPD, OPE, OPF : out STD_LOGIC);
end decode_op;

architecture Behavioral of decode_op is
begin
    -- OPA = '1' quando OP[2:0] = 010 ou 011 (Y+CBi, Y-CBi)
    OPA <= '1' when OP = "010" or OP = "011" else '0';
    
    -- OPB: não usado explicitamente? Verificar Figura 2
    OPB <= '0';  -- Placeholder
    
    -- OPC = '1' para subtração (001, 011)
    OPC <= '1' when OP = "001" or OP = "011" else '0';
    
    -- OPD = '1' para ASR (111)
    OPD <= '1' when OP = "111" else '0';
    
    -- OPE = '1' para LSL (110)
    OPE <= '1' when OP = "110" else '0';
    
    -- OPF = '1' para NAND (101)
    OPF <= '1' when OP = "101" else '0';
end Behavioral;
```

---

## Passo 6: Criar a Unidade Flags Final (Flags_ALU)

**Entradas**:
- Flags do AU: `AU_CBo`, `AU_OV`
- Resultado final: `R[3:0]`
- Carry do Logic: `Logic_CY`
- Operando X: `X[3:0]`
- Operando Y: `Y[3:0]`
- CBi
- OP[2:0] (para saber qual operação gerou o resultado)

**Saídas**: `CBo`, `OV`, `Z`, `GE`, `BE`

### Lógica de cada flag:

```vhdl
Z  <= '1' when R = "0000" else '0';

-- CBo: depende da operação
CBo <= AU_CBo           when OP(2) = '0' else  -- Aritméticas (000-011)
       Logic_CY         when OP = "110" else   -- LSL
       X(0)             when OP = "111" else   -- ASR
       '0';                                      -- Lógicas (100, 101)

-- OV: só tem significado em aritméticas
OV  <= AU_OV            when OP(2) = '0' else '0';

-- GE: X >= (Y + CBi) em complemento de 2 (signed)
-- Comparação signed: X[3] == (Y+CBi)[3] ? X >= Y+CBi : X[3] == '0'
GE  <= '1' when (signed(X) >= signed(Y) + CBi) else '0';

-- BE: X <= (Y + CBi) em unsigned
BE  <= '1' when (unsigned(X) <= unsigned(Y) + CBi) else '0';
```

---

## Passo 7: Criar o MUX 2-para-1 (4 bits)

**Função**: Seleciona entre resultado do AU (`AU_R`) e resultado do Logic (`Logic_R`)

```vhdl
entity mux2to1_4bit is
    Port ( AU_R : in  STD_LOGIC_VECTOR(3 downto 0);
           Logic_R : in  STD_LOGIC_VECTOR(3 downto 0);
           SEL : in  STD_LOGIC;  -- '0' = AU, '1' = Logic
           R : out STD_LOGIC_VECTOR(3 downto 0));
end mux2to1_4bit;

architecture Behavioral of mux2to1_4bit is
begin
    R <= AU_R when SEL = '0' else Logic_R;
end Behavioral;
```

**Sinal SEL**: `'1'` para operações lógicas (OP[2] = '1'), `'0'` para aritméticas.

---

## Passo 8: Montar a Entidade Topo ALU

```vhdl
entity alu is
    Port ( X : in  STD_LOGIC_VECTOR(3 downto 0);
           Y : in  STD_LOGIC_VECTOR(3 downto 0);
           OP : in  STD_LOGIC_VECTOR(2 downto 0);
           CBi : in  STD_LOGIC;
           R : out STD_LOGIC_VECTOR(3 downto 0);
           CBo, OV, Z, GE, BE : out STD_LOGIC);
end alu;

architecture Structural of alu is
    -- Componentes
    component xor0 ... end component;
    component au_module ... end component;
    component logic_module ... end component;
    component decode_op ... end component;
    component flags_alu ... end component;
    component mux2to1_4bit ... end component;
    
    -- Sinais internos
    signal A : STD_LOGIC_VECTOR(3 downto 0);
    signal AU_R : STD_LOGIC_VECTOR(3 downto 0);
    signal Logic_R : STD_LOGIC_VECTOR(3 downto 0);
    signal AU_CBo, AU_OV : STD_LOGIC;
    signal Logic_CY : STD_LOGIC;
    signal OPA, OPB, OPC, OPD, OPE, OPF : STD_LOGIC;
    signal MUX_SEL : STD_LOGIC;
begin
    -- Instanciação dos componentes
    U_XOR0: xor0 port map(X, OPA, A);
    U_DECODE: decode_op port map(OP, OPA, OPB, OPC, OPD, OPE, OPF);
    U_AU: au_module port map(A, Y, CBi, OPC, AU_R, AU_CBo, AU_OV);
    U_LOGIC: logic_module port map(X, Y, OPF, OPE, OPD, Logic_R, Logic_CY);
    U_MUX: mux2to1_4bit port map(AU_R, Logic_R, OP(2), R);
    U_FLAGS: flags_alu port map(AU_CBo, AU_OV, R, Logic_CY, X, Y, CBi, OP, 
                                CBo, OV, Z, GE, BE);
end Structural;
```

---

## Passo 9: Criar Testbench (alu_tb.vhd)

### Estratégia de teste:
1. **Teste das 20 linhas da Tabela Anexo A** (valores teóricos conhecidos)
2. **Teste das 4 combinações adicionais** (linhas #21-#24)
3. **Teste exaustivo** de todos os 2⁹ = 512 combinações (X[4], Y[4], OP[3], CBi[1])

### Template do Testbench:
```vhdl
entity alu_tb is
end alu_tb;

architecture Behavioral of alu_tb is
    component alu ... end component;
    
    signal X, Y, R : STD_LOGIC_VECTOR(3 downto 0);
    signal OP : STD_LOGIC_VECTOR(2 downto 0);
    signal CBi, CBo, OV, Z, GE, BE : STD_LOGIC;
    
    -- Clock para sincronismo (opcional)
    constant CLK_PERIOD : time := 10 ns;
begin
    UUT: alu port map(X, Y, OP, CBi, R, CBo, OV, Z, GE, BE);
    
    stim_proc: process
    begin
        -- Teste linha 1: OP=000, CBi=0, X=0000, Y=1111
        OP <= "000"; CBi <= '0'; X <= "0000"; Y <= "1111"; wait for CLK_PERIOD;
        assert (R = "1111" and CBo = '0' and OV = '0' and Z = '0' and GE = '1' and BE = '0')
            report "Linha 1 falhou" severity error;
        
        -- ... repetir para todas as 24 linhas ...
        
        -- Teste exaustivo
        for i in 0 to 511 loop
            -- Gerar combinações
            wait for CLK_PERIOD;
        end loop;
        
        wait;
    end process;
end Behavioral;
```

---

## Passo 10: Simulação no ModelSim/QuestaSim

1. Abrir ModelSim
2. Criar projeto novo
3. Adicionar todos os `.vhd` files
4. Compilar (Compile → Compile All)
5. Simular `alu_tb`
6. Adicionar sinais ao Wave: `X, Y, OP, CBi, R, CBo, OV, Z, GE, BE`
7. Run simulation (ex: `run 2 us`)
8. Verificar waveform comparando com Anexo A

### Checklist de Verificação:
- [ ] Linhas 1-20 batem com resultado teórico
- [ ] Flags don't care (marcadas com `�`) podem ser 0 ou 1
- [ ] Linhas 21-24 (criadas pelo grupo) fazem sentido
- [ ] Nenhum 'X' ou 'U' nas saídas (metavalores)

---

## Passo 11: Implementação na DE10-Lite (Quartus Prime)

### 1. Criar projeto Quartus
- File → New Project Wizard
- Device: **10M50DAF484C7G** (DE10-Lite)
- Adicionar todos os `.vhd` files

### 2. Mapeamento de Pinos (Pin Planner / .qsf)

| Sinal ALU | Pinos DE10-Lite | Descrição |
|-----------|-----------------|-----------|
| X[3:0]    | SW[3:0]         | Operando X |
| Y[3:0]    | SW[7:4]         | Operando Y |
| OP[1:0]   | SW[9:8]         | OP menos significativos |
| OP[2]     | KEY[0]          | OP mais significativo |
| CBi       | KEY[1]          | Carry In |
| R[3:0]    | LEDR[3:0]       | Resultado |
| CBo       | LEDR[4]         | Carry/Borrow Out |
| OV        | LEDR[5]         | Overflow |
| Z         | LEDR[6]         | Zero |
| GE        | LEDR[7]         | Greater or Equal |
| BE        | LEDR[8]         | Below or Equal |

### 3. Compilar (Processing → Start Compilation)
- Verificar: **0 errors**, timing OK

### 4. Programar a Placa
- Tools → Programmer
- Hardware Setup → USB-Blaster
- Start → Program

---

## Passo 12: Validação Experimental (Anexo A + 4 linhas extras)

### Preparação:
- Preencher tabela Anexo A com **Resultado Experimental**
- Definir 4 linhas extras (#21 a #24):
  - **#21, #22**: Operações aritméticas (ex: 000 e 001 com valores diferentes)
  - **#23, #24**: Operações lógicas (ex: 100 e 110 com valores diferentes)

### Procedimento para cada linha:
1. Configurar SW e KEYs conforme tabela
2. Observar LEDs
3. Anotar R[3:0] e flags em binário
4. Converter para Natural (N) e Inteiro (Z)
5. Comparar com teórico

### Exemplo de linhas extras sugeridas:

| # | OP | CBi | X | Y | Justificativa |
|---|-----|-----|---|---|---------------|
| 21 | 000 | 1 | 0111 (7) | 0111 (7) | Soma com carry: 7+7+1=15 (overflow signed) |
| 22 | 001 | 0 | 1000 (-8) | 0001 (1) | Subtração: -8-1=-9 (overflow signed) |
| 23 | 100 | 0 | 1010 | 1100 | AND: 1010 & 1100 = 1000 |
| 24 | 110 | 0 | 0011 | 0010 | LSL: 0011 << 2 = 1100, CY=X[2]=0 |

---

## Cronograma Sugerido (Grupo de 3-4 pessoas)

| Semana | Atividades | Responsável |
|--------|------------|-------------|
| 1 | Entender especificação, copiar AU do LABc, criar Xor0, Decode OP | Todos |
| 2 | Criar Logic Module (incluindo LSL), Flags_ALU, MUX, ALU top | Pessoa 1-2 |
| 3 | Testbench completo, simulação, debug | Pessoa 2-3 |
| 4 | Quartus: compilar, pinout, programar DE10-Lite | Pessoa 3-4 |
| 5 | Validação experimental, preencher Anexo A, relatório | Todos |

---

## Dicas Importantes

### VHDL Estrutural
- Use **component declaration** + **port map** para todas as instâncias
- Evite código comportamental (process/if) nas entidades estruturais
- Um arquivo por entidade

### Debug Comum
| Problema | Causa Provável |
|----------|----------------|
| Saídas 'U'/'X' | Sinais não inicializados, port map errado |
| Flags erradas | Lógica de signed/unsigned invertida |
| LSL errado | Y[1:0] não usado corretamente, CY errado |
| GE/BE errados | Comparação signed vs unsigned trocada |

### Signed vs Unsigned em VHDL
```vhdl
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;  -- Para signed/unsigned

-- Conversão:
signed(X)      -- Interpreta X como complemento de 2
unsigned(X)    -- Interpreta X como natural
```

---

## Entregáveis Finais

1. **Código VHDL** (11+ arquivos)
2. **Testbench** funcional
3. **Waveforms** da simulação (prints ou .wlf)
4. **Projeto Quartus** compilado
5. **Tabela Anexo A** preenchida (teórico + experimental)
6. **Relatório** breve (2-3 páginas): decisões de projeto, problemas, resultados

---

## Checklist Final Antes da Entrega

- [ ] Todos os 11+ arquivos VHDL compilam sem erro
- [ ] Testbench testa todas as 24 linhas + exaustivo
- [ ] Simulação bate com valores teóricos
- [ ] Quartus compila sem erro nem warning crítico
- [ ] Pinout DE10-Lite correto
- [ ] Placa programada e funcionando
- [ ] Anexo A preenchido completamente
- [ ] 4 linhas extras (#21-#24) documentadas e testadas
- [ ] Relatório escrito

---

*Plano criado para TLAB2 - LSD 2026/2027 Inverno*
*Baseado em: LSD_2627_TLAB2.pdf e LSD_2627_LABc.pdf*