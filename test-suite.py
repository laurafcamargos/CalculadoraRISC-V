# APLICAÇÃO PARA TESTES DO PROGRAMA calculadora.asm
# Requisito: comando 

import unittest
import subprocess
import re

command = 'rars'                            # Coloque a chamada para o programa em terminal do rars
                                            # java -jar /posicao/do/rars.jar deve bastar

flags = ['nc', 'se1', 'ae1', 'me']          # nc: evita impressão de copyright do programa
                                            # se1: retorna 1 (erro) caso há alguma coisa de errado na simulação
                                            # ae1: retorna 1 (erro) caso há alguma coisa de errado na compilação

res = []


def do_calc_tsts():
    for k in range(1,9):
        print('calc-tsts/tst' + str(k).zfill(2))
        with open('calc-tsts/tst' + str(k).zfill(2) + '.in', 'r') as file:
            proc = subprocess.Popen([command] + flags + ['calculadora.asm'], stdin=file, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            
            output, err = proc.communicate()

            if proc.returncode != 0:
                print('Erro!!')
                print('err: ' + err.decode('utf-8'))

            else:
                strout = output.decode('utf-8')

                # Tokenização dos resultados das operações
                res = [int(n) for n in re.findall(r"Resultado:\s*(-?\d+)", strout)]
        
        # print(res)
        
        with open('calc-tsts/tst' + str(k).zfill(2) + '.out', 'r') as file:
            count = 0
            for n in file:
                if int(n) == res[count]:
                    print(f'linha [{count+1}] ok!')   
                else:
                    print(f"Erro no resultado {count+1}: part_res = {res[count]}")
                count += 1

if __name__ == '__main__':
    do_calc_tsts()