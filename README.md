# README - Calculadora Sequencial em RISC-V

## Descrição

Este projeto implementa uma calculadora sequencial em Assembly RISC-V, conforme especificado no trabalho prático da disciplina SSC0902 - Organização e Arquitetura de Computadores. A calculadora realiza operações aritméticas básicas com **números inteiros** (adição, subtração, multiplicação e divisão) e oferece a funcionalidade de desfazer uma operação.

## Funcionalidades

- **Operações Aritméticas**:
  - `+`: Adição
  - `-`: Subtração
  - `*`: Multiplicação
  - `/`: Divisão inteira (com tratamento de divisão por zero)
- **Operações Especiais**:
  - `u`: Desfaz a última operação (undo)
  - `f`: Finaliza a execução da calculadora
- **Tratamento de Erros**:
  - Divisão por zero
  - Operação inválida
  - Número inválido (float ou string)
  - Tentativa de desfazer operação quando não há operações anteriores

## Estrutura do Código

- **`calculadora.s`**: Contém o código Assembly RISC-V da calculadora.
- **Lista Encadeada**: Utilizada para armazenar os resultados das operações e permitir a funcionalidade de undo.
- **Makefile**: Facilita a execução e teste do programa.

## Como Executar

### Pré-requisitos

- Java instalado (para executar o RARS)
- Comando `diff` (para comparação nos casos de teste)

### Comandos

1. **Compilar e Executar**:

   ```bash
   make
   ```

   - Isso executará o programa no RARS.

2. **Executar Testes**:

   ```bash
   make test-all
   ```

   - Executa todos os testes disponíveis na pasta `tests/`.

3. **Executar um Teste Específico**:

   ```bash
   make test TEST_NUM=<número_do_teste>
   ```

   - Substitua `<número_do_teste>` pelo número do teste desejado (ex: `1` para `test1.in`).

4. **Limpar Arquivos Temporários**:
   ```bash
   make clean
   ```

## Exemplo de Uso

1. Inicie a calculadora:
   ```bash
   make
   ```
2. Siga os prompts para inserir números e operações:
   - Digite um número quando solicitado.
   - Digite a operação desejada (`+`, `-`, `*`, `/`, `u`, ou `f`).
3. O resultado será exibido após cada operação válida.

```
Digite um número: 10
Digite a operação (+, -, *, /, u, f): -
Digite um número: 2
Resultado: 8
Digite a operação (+, -, *, /, u, f): *
Digite um número: 0
Resultado: 0
Digite a operação (+, -, *, /, u, f): u
Operação desfeita. Resultado anterior: 8
Digite a operação (+, -, *, /, u, f): /
Digite um número: 3
Resultado: 2
Digite a operação (+, -, *, /, u, f): f
```

## Relatório

O relatório do projeto inclui:

- Explicação do funcionamento do código.
- Decisões de implementação.
- Prints de tela demonstrando a execução.
- Dificuldades encontradas durante o desenvolvimento.

---

Este projeto foi desenvolvido como parte da disciplina SSC0902 - Organização e Arquitetura de Computadores, sob a orientação da professora Sarita Mazzini Bruschi e da monitora Catarina Moreira Lima.
