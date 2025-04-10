	.data
	.align 0
#Strings para auxiliar a entender o programa
div_by_zero_error:	 .asciz "Erro: divisão por zero\n"
invalid_op_error:    .asciz "Erro: operação inválida\n"
int_error:	         .asciz "Erro: insira um número inteiro\n"
undo_error:			 .asciz "Erro: sem operações a serem desfeitas\n"
result_str:          .asciz "Resultado: "
newline:             .asciz "\n"
prompt_num:    	     .asciz "Digite um número: "
prompt_op:           .asciz "Digite a operação (+, -, *, /, u, f): "
undo_msg:            .asciz "Operação desfeita. Resultado anterior: "
	
	.align 2
head:	.word		# PONTEIRO para o primeiro elemento da lista


	.text
	.align 2	#instruções de 32 bits
	.globl main
	
	#Estrutura de cada nó da lista
	#Offset | Tamanho | Conteúdo
	#0-3    | 4 bytes | Resultado da operação atual (inteiro)
	#4-7	| 4 bytes | Ponteiro para o endereço do próximo nó ou NULL(word)
	

	# s0  : resultado atual
	# s11 : -1 (NULL)

.eqv TAM_NO 8
.eqv NULL -1

main:
	# Inicialização de head
	li s11, NULL # s11 = -1
	la t0,head
	sw s11,0(t0)
	
	# Le primeiro operando e salva em s0
	jal ler_int
	mv s0, a0

main_loop:
    jal ler_operador      # operador em a0 (char)

	# Parametros: a0 = operador
	jal realizar_operacao
	
	j main_loop



#-----------------------------------------------------------
# Função: armazenar_resultado
# Parâmetro: a0 = valor a ser armazenado
#
# Descricao: coloca no topo da lista encadeada (apontada
# por head), o resultado em a0
#-----------------------------------------------------------
armazenar_resultado:
	mv t0,a0			# Salva o valor a ser armazenado em t0

	# t0  : valor a ser armazenado
	# t1  : endereco para a label head
	# t2  : valor guardado na label head (endereco para o topo da lista)
	# a0 : endereço da memoria alocada

	###### Alocar memória ######
	li a0, TAM_NO # a0 = 8
	addi a7, zero, 9
	ecall 				# aloca 8 bytes na heap

	la t1,head			# t1 = addr(head)
	lw t2,head			# t2 = valor(head)
	sw t0,0(a0)			# Armazena o resultado no nó (posicao 0)
	sw t2,4(a0)			# Armazena o endereco da cabeca atual da lista no nó (posicao 4)
	sw a0,0(t1)			# Atualiza a cabeca da lista para o novo nó

	jr ra



#-----------------------------------------------------------
# Função: ler_int
# Retorna: a0 = valor lido
#-----------------------------------------------------------
ler_int:
	li a7, 4
	la a0, prompt_num # "Digite um número: "
	ecall
    
	li a7, 5          # Read int
	ecall             # Retorno em a0
    
	jr ra             # Retorno



#-----------------------------------------------------------
# Função: ler_operador
# Retorna: a0 = operador lido
#-----------------------------------------------------------
ler_operador:
	li a7, 4
	la a0, prompt_op  # "Digite a operação (+, -, *, /, u, f): "
	ecall

	li a7, 12         # Read Char
	ecall             # Retorno em a0

	jr ra


#-----------------------------------------------------------
# Função: realizar_operacao
# Parâmetros: a0 = operador
# Obs: Mudei o realizar_operacao para ler outro 
# inteiro caso ele seja uma op. arit.
#-----------------------------------------------------------
realizar_operacao:
	li t0, 43          # t0 = '+'
	beq a0, t0, op_add
    
	li t0, 45          # t0 = '-'
	beq a0, t0, op_sub
    
	li t0, 42          # t0 = '*'
	beq a0, t0, op_mul
    
	li t0, 47          # t0 = '/'
	beq a0, t0, op_div
    
	li t0, 117         # t0 = 'u'
	beq a0, t0, undo
    
	li t0, 102         # t0 = 'f'
	beq a0, t0, fim_programa
	
	# Proxima linha ja eh o op_invalida, nao precisa do jump
	# j op_invalida # Operação inválida (default)

op_invalida:
	la a0, invalid_op_error 	# "Erro: operação inválida\n"
	li a7, 4           			# Print string
	ecall
	jr ra

op_add:
	# t0  : Resultado da operacao (tmp)

	# Salva endereco de retorno na stack
	addi sp,sp,-4
	sw ra,0(sp)

	# Atribui em a0 o valor lido na entrada
	jal ler_int

	add t0,s0,a0

	# Resgata o endereco de retorno na stack
	lw ra,0(sp)
	addi sp,sp,4

	j fim_operacao

op_sub:
	# t0  : Resultado da operacao (tmp)

	# Salva endereco de retorno na stack
	addi sp,sp,-4
	sw ra,0(sp)

	# Atribui em a0 o valor lido na entrada
	jal ler_int

	sub t0,s0,a0

	# Resgata o endereco de retorno na stack
	lw ra,0(sp)
	addi sp,sp,4

	j fim_operacao

op_mul:
	# t0  : Resultado da operacao (tmp)

	# Salva endereco de retorno na stack
	addi sp,sp,-4
	sw ra,0(sp)

	# Atribui em a0 o valor lido na entrada
	jal ler_int

	mul t0,s0,a0

	# Resgata o endereco de retorno na stack
	lw ra,0(sp)
	addi sp,sp,4

	j fim_operacao

op_div:
	# t0  : Resultado da operacao (tmp)

	# Salva endereco de retorno na stack
	addi sp,sp,-4
	sw ra,0(sp)

	# Atribui em a0 o valor lido na entrada
	jal ler_int
	
	# Resgata o endereco de retorno na stack
	lw ra,0(sp)
	addi sp,sp,4

	beqz a0, erro_div_zero

	div t0,s0,a0

	j fim_operacao

erro_div_zero:
	la a0, div_by_zero_error # "Erro: divisão por zero\n"
	li a7, 4           # Print string
  	ecall
  	
  	jr ra

fim_operacao:
	# t0 : resultado da operacao

	# Guarda na stack o endereco de retorno e o resultado da operacao
	addi sp,sp,-4
	sw ra,0(sp)

	mv s0,t0			# Atualiza o resultado em s0

	mv a0,s0			# a0 = resultado
	# Args: a0 = valor a ser armazenado
	jal armazenar_resultado 
	

	la a0, result_str  	# "Resultado: "
	li a7, 4           	# Print string
	ecall
	
	# Imprime o resultado (guardado em s0)
	mv a0,s0
	li a7, 1           	# Print int
	ecall
	
	la a0, newline     	# "\n"
	li a7, 4			# Print string
	ecall

	lw ra,0(sp)
	addi sp,sp,4

	jr ra


fim_programa:
 	li a7,10
 	ecall


#-----------------------------------------------------------
# Função: undo (implementação básica)
#-----------------------------------------------------------
undo:
	# t0  : endereco da label head
	# t1  : valor em head -- endereco para o nó cabeca da lista
	# t2  : endereco do sucessor da cabeca da lista
	

	la t0,head
	lw t1,0(t0)
	beq t1,s11, erro_undo	# Cancela se lista vazia

	lw t2,4(t1)
	beq t2,s11, erro_undo	# Cancela se a lista tem somente 1 elemento (nao quero setar o resultado como zero)

	sw t2,0(t0)			# Atualiza a cabeca da lista para o proximo nó (atualiza o valor da label head)
	lw s0,0(t2)			# Atualiza o resultado para o anterior

    # Imprime mensagem
    li a7, 4
    la a0, undo_msg
    ecall

    li a7, 1
    mv a0, s0
    ecall

    li a7, 4
    la a0, newline
    ecall
	j fim_undo

erro_undo:
	li a7, 4
    la a0, undo_error
    ecall


fim_undo:
    jr ra
