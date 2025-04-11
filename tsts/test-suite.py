# APLICAÇÃO PARA TESTES DO PROGRAMA calculadora.asm
# Requisito: java e rars

import sys
import subprocess
import re

# Cores para impressão
class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'


command = 'rars'                            # Coloque a chamada para o programa em command line do rars
                                            # java -jar /posicao/do/rars.jar deve bastar

flags = ['nc', 'se1', 'ae1', 'me']          # nc: evita impressão de copyright do programa
                                            # se1: retorna 1 (erro) caso há alguma coisa de errado na simulação
                                            # ae1: retorna 1 (erro) caso há alguma coisa de errado na compilação

res = []

# Testa um caso individual
# tst_name: nome dos arquivos tst_name.in (entrada) e tst_name.out (saida) para comparar os casos
# 
# O arquivo .in recebe as entradas como o programa normalmente receberia, enquanto que o .out, mostra cada
# linha de resultado esperado pelo programa
def do_tst_case(tst_name):
    ok = True

    print('case: ' + tst_name + '...')
    with open(tst_name + '.in', 'r') as file:
        # Roda o programa calculadora.rars por meio da interface de linha de comando do rars
        proc = subprocess.Popen([command] + flags + ['calculadora.asm'], stdin=file, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        
        output, err = proc.communicate()

        if proc.returncode != 0:
            print('Erro!!')
            print('err: ' + err.decode('utf-8'))
            ok = False

        else:
            strout = output.decode('utf-8')

            # Tokenização dos resultados das operações
            res = re.findall(r"(Resultado(?: anterior)?:\s*-?\d+|Erro:.*)", strout)
    
    with open(tst_name + '.out', 'r') as file:
        count = 0
        # Comparacao dos resultados obtidos e esperados
        for line in file:
            if line.rstrip() == res[count]:
                print(f'[{count+1}]: ' + bcolors.OKGREEN + 'ok!' + bcolors.ENDC)
            else:
                print(f"[{count+1}]: " + bcolors.WARNING + f"Erro: '{res[count]}' != '{line.rstrip()}'" + bcolors.ENDC)
                ok = False
            count += 1
    
    return ok

# Testa todos os casos sobre a corretude dos calculos (sem erros)
def do_calc_tsts():
    for k in range(1,9):
        do_tst_case('tsts/calc-tsts/tst' + str(k).zfill(2))

# Testa todos os casos sobre a funcionalidade undo e alguns erros
def do_undo_tsts():
    for k in range(1,4):
        do_tst_case('tsts/undo-tsts/tst' + str(k).zfill(2))  

if __name__ == '__main__':
    if len(sys.argv) <= 1:
        do_calc_tsts()
        do_undo_tsts()
    else:
        for tst in sys.argv[1::]:
            do_tst_case(tst)