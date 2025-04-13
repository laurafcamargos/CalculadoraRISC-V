.data
.align 0

# Strings para auxiliar a entender o programa
division_by_zero_error:     .asciz "Erro: divisão por zero\n"
invalid_operation_error:    .asciz "Erro: operação inválida\n"
invalid_number_error:       .asciz "Erro: valor não é um número inteiro válido\n"
undo_error_msg:             .asciz "Erro: sem operações a serem desfeitas\n"
result_str:                 .asciz "Resultado: "
newline:                    .asciz "\n"
number_prompt:              .asciz "Digite um número: "
operation_prompt:           .asciz "Digite a operação (+, -, *, /, u, f): "
undo_message:               .asciz "Operação desfeita. Resultado anterior: "
undo_last_message:          .asciz "Operação desfeita. Nenhum resultado salvo.\n"
input_buffer:               .space 16 # Buffer para leitura temporária de string

.align 2
list_head: .word 0 # Ponteiro para o primeiro elemento da lista

.text
.align 2
.globl main

# Estrutura de cada nó da lista
# Offset | Tamanho | Conteúdo
# 0-3    | 4 bytes | Resultado da operação atual (inteiro)
# 4-7    | 4 bytes | Ponteiro para o próximo nó ou NULL

# Registradores:
# s0 : resultado atual
# s11 : -1 (NULL)

.eqv NODE_SIZE, 8
.eqv NULL, -1

main:
    # Inicialização de list_head
    li s11, NULL
    la t0, list_head
    sw s11, 0(t0)

    # Lê primeiro operando e salva em s0
    jal read_valid_integer
    mv s0, a0

main_loop:
    jal read_operator # operador em a0 (char)

    # Parâmetros: a0 = operador
    jal perform_operation

    j main_loop

#-----------------------------------------------------------
# Função: store_result
# Parâmetro: a0 = valor a ser armazenado
# Descrição: coloca no topo da lista encadeada o resultado em a0
#-----------------------------------------------------------
store_result:
    mv t0, a0           # Salva o valor a ser armazenado

    # Alocar memória para novo nó
    li a0, NODE_SIZE
    li a7, 9
    ecall               # a0 agora tem endereço do novo nó

    # Configurar novo nó
    sw t0, 0(a0)        # Armazena o resultado
    lw t1, list_head    # Pega endereço atual da cabeça
    sw t1, 4(a0)        # Armazena como próximo nó

    # Atualizar cabeça da lista
    la t2, list_head
    sw a0, 0(t2)        # Novo nó é agora a cabeça

    jr ra

#-----------------------------------------------------------
# Função: read_valid_integer
# Retorna: a0 = valor lido (validado)
#-----------------------------------------------------------
read_valid_integer:
    addi sp, sp, -16    # Reserva espaço na pilha
    sw ra, 0(sp)        # Salva endereço de retorno
    sw s0, 4(sp)        # Salva registrador s0
    sw s1, 8(sp)        # Salva registrador s1
    sw s2, 12(sp)       # Salva registrador s2

read_integer_again:
    # Mostra prompt
    li a7, 4
    la a0, number_prompt
    ecall

    # Lê string temporariamente
    li a7, 8
    la a0, input_buffer
    li a1, 16
    ecall

    # Configurações iniciais
    la s0, input_buffer # s0 = ponteiro para string
    li s1, 0            # s1 = sinal (0 = positivo, 1 = negativo)
    li s2, 0            # s2 = contador de dígitos
    li t2, 0            # t2 = resultado acumulado
    li t3, 10           # t3 = 10 (base decimal)

    # Verifica sinal negativo
    lb t0, 0(s0)
    li t1, '-'
    bne t0, t1, check_first_digit
    li s1, 1            # marca como negativo
    addi s0, s0, 1      # avança para próximo caractere

check_first_digit:
    lb t0, 0(s0)        # primeiro caractere após sinal
    li t1, 10           # ASCII para newline
    beq t0, t1, invalid_input # string vazia
    li t1, '0'
    blt t0, t1, invalid_input
    li t1, '9'
    bgt t0, t1, invalid_input

process_digits:
    lb t0, 0(s0)        # carrega próximo caractere
    li t1, 10           # ASCII para newline
    beq t0, t1, validation_done # fim da string
    
    # Verifica se é dígito (0-9)
    li t1, '0'
    blt t0, t1, invalid_input
    li t1, '9'
    bgt t0, t1, invalid_input

    # Converte para valor numérico
    addi t0, t0, -48

    # Multiplica acumulador por 10 e adiciona novo dígito
    mul t2, t2, t3
    add t2, t2, t0

    addi s0, s0, 1      # próximo caractere
    addi s2, s2, 1      # incrementa contador de dígitos
    li t4, 11           # máximo de dígitos
    bge s2, t4, invalid_input # muito longo
    j process_digits

validation_done:
    # Verifica se teve pelo menos 1 dígito
    beqz s2, invalid_input

    # Aplica sinal negativo se necessário
    beqz s1, positive_number
    neg t2, t2

positive_number:
    mv a0, t2           # retorna valor convertido
    lw ra, 0(sp)        # Restaura endereço de retorno
    lw s0, 4(sp)        # Restaura s0
    lw s1, 8(sp)        # Restaura s1
    lw s2, 12(sp)       # Restaura s2
    addi sp, sp, 16     # Libera espaço na pilha
    jr ra               # Retorna

invalid_input:
    # Mostra mensagem de erro
    li a7, 4
    la a0, invalid_number_error
    ecall
    
    # Volta a pedir o número
    j read_integer_again

#-----------------------------------------------------------
# Função: read_operator
# Retorna: a0 = operador lido
#-----------------------------------------------------------
read_operator:
    addi sp, sp, -4
    sw ra, 0(sp)

read_operator_loop:
    li a7, 4
    la a0, operation_prompt
    ecall

    li a7, 12
    ecall

    # Verifica se é um operador válido
    li t0, '+'
    beq a0, t0, valid_operator
    li t0, '-'
    beq a0, t0, valid_operator
    li t0, '*'
    beq a0, t0, valid_operator
    li t0, '/'
    beq a0, t0, valid_operator
    li t0, 'u'
    beq a0, t0, valid_operator
    li t0, 'f'
    beq a0, t0, valid_operator

    # Operador inválido
    li a7, 4
    la a0, invalid_operation_error
    ecall
    j read_operator_loop

valid_operator:
    lw ra, 0(sp)
    addi sp, sp, 4
    jr ra

#-----------------------------------------------------------
# Função: perform_operation
# Parâmetros: a0 = operador
#-----------------------------------------------------------
perform_operation:
    li t0, '+'
    beq a0, t0, operation_add

    li t0, '-'
    beq a0, t0, operation_subtract

    li t0, '*'
    beq a0, t0, operation_multiply

    li t0, '/'
    beq a0, t0, operation_divide

    li t0, 'u'
    beq a0, t0, undo_operation

    li t0, 'f'
    beq a0, t0, exit_program

    j invalid_operation

invalid_operation:
    la a0, invalid_operation_error
    li a7, 4
    ecall
    jr ra

operation_add:
    addi sp, sp, -4
    sw ra, 0(sp)

    jal read_valid_integer
    add t0, s0, a0

    lw ra, 0(sp)
    addi sp, sp, 4
    j operation_done

operation_subtract:
    addi sp, sp, -4
    sw ra, 0(sp)

    jal read_valid_integer
    sub t0, s0, a0

    lw ra, 0(sp)
    addi sp, sp, 4
    j operation_done

operation_multiply:
    addi sp, sp, -4
    sw ra, 0(sp)

    jal read_valid_integer
    mul t0, s0, a0

    lw ra, 0(sp)
    addi sp, sp, 4
    j operation_done

operation_divide:
    addi sp, sp, -4
    sw ra, 0(sp)

    jal read_valid_integer

    lw ra, 0(sp)
    addi sp, sp, 4

    beqz a0, division_by_zero
    div t0, s0, a0
    j operation_done

division_by_zero:
    la a0, division_by_zero_error
    li a7, 4
    ecall
    jr ra

operation_done:
    addi sp, sp, -4
    sw ra, 0(sp)

    mv s0, t0           # Atualiza resultado

    mv a0, s0
    jal store_result

    # Mostra resultado
    la a0, result_str
    li a7, 4
    ecall

    mv a0, s0
    li a7, 1
    ecall

    la a0, newline
    li a7, 4
    ecall

    lw ra, 0(sp)
    addi sp, sp, 4
    jr ra

#-----------------------------------------------------------
# Função: undo_operation
# Descrição: Desfaz a última operação.
#            Se for a última, volta o programa ao estado inicial
#-----------------------------------------------------------
undo_operation:
    la t0, list_head
    lw t1, 0(t0)        # Pega cabeça atual
    beq t1, s11, undo_error_case # Lista vazia

    lw t2, 4(t1)        # Pega próximo nó

    # Se t2 é NULL, é a única operação - volta ao main
    beq t2, s11, undo_last_operation

    # Caso normal: tem mais operações na lista
    sw t2, 0(t0)        # Atualiza cabeça para o próximo nó
    lw s0, 0(t2)        # Atualiza resultado para o valor anterior

    # Mostra mensagem de undo
    li a7, 4
    la a0, undo_message
    ecall

    li a7, 1
    mv a0, s0
    ecall

    li a7, 4
    la a0, newline
    ecall

    jr ra

undo_last_operation:
    # Remove o nó (limpa a lista)
    sw s11, 0(t0)

    # Mostra mensagem
    li a7, 4
    la a0, undo_last_message
    ecall

    # Volta ao estado inicial pulando para main
    j main

undo_error_case:
    li a7, 4
    la a0, undo_error_msg
    ecall
    jr ra

exit_program:
    li a7, 10
    ecall
