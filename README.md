# CalculadoraRISC-V
Repositório para guardar relatório e código em assembly (em RISC-V) do primeiro trabalho prático da disciplina SSC0902 - Organização e Arquitetura de Computadores.

## Descrição do funcionamento
Este projeto é de uma calculadora que realiza operações de maneira sequencial, ou seja, realiza operações conforme a ordem em que são inseridas, e mantém uma lista dos resultados obtidos. Esta calculadora suporta os seguintes comandos:
- +: adição
- -: subtração
- *: multiplicação
- /: divisão
- u: undo --- volta ao resultado anterior
- f: termina o programa

Especificações mais detalhadas sobre o projeto se encontram no arquivo relatorio.pdf.

### Exemplo de execução
```java -jar caminho/para/rars.jar nc calculadora.asm```
```
RARS 1.6  Copyright 2003-2019 Pete Sanderson and Kenneth Vollmar

Digite um número: 10
Digite a operação (+, -, *, /, u, f): +
Digite um número: 20
Resultado: 30
Digite a operação (+, -, *, /, u, f): *
Digite um número: 3
Resultado: 90
Digite a operação (+, -, *, /, u, f): u
Operação desfeita. Resultado anterior: 30
Digite a operação (+, -, *, /, u, f): /
Digite um número: 3
Resultado: 10
Digite a operação (+, -, *, /, u, f): /
Digite um número: -2
Resultado: -5
Digite a operação (+, -, *, /, u, f): f

Program terminated by calling exit
```

## Switch de testes
**Requisitos:** python e simulador RARS (executável .jar)

Para testar o funcionamento correto do programa, foi desenvolvido um suíte de testes usando scripts em python. Estes scripts usam o executável .jar do simulador RARS para realizar seus testes. Para rodar a seção padrão de testes, basta executar 

```
python tsts/test-suite.py
```

Para executar um teste singular, basta colocar

```
python tsts/test-suite.py <nome-teste .in e .out>
```

*ex: `python tsts/test-suite.py dir/tst1` e compara resultados obtidos pelo programa com as entradas em `dir/tst1.in` e as compara com as saídas esperadas em `dir/tst1.out`.*

Para transformar uma expressão aritmética (com ordem de resolução da esquerda para a direita) em um caso de teste, basta executar

```
python tsts/expr-to-input.py <expr1> <expr2> ...
```

*Obs. As operações não devem usar parênteses e nem possuirem espaço*


Os resultados esperados (arquivos .out) gerados pelo programa terminam com uma nova linha vazia, é necessário removê-las antes de botá-las no suíte de testes
