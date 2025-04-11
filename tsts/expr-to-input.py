# Programa que transforma as expressoes no arquivo test-exprs em entradas (arquivos .in) para a calculadora
# e em saidas (arquivos .out) com os resultados parciais esperados

import re
import sys
import os

operations = ['+','-','*','/']
op = ''

abs_dir = os.path.dirname(__file__)

def make_calc_tst(tst_name,expr):
    tst_in = open(tst_name + '.in', 'w')
    tst_out = open(tst_name + '.out', 'w')
    
    part_res = 0
    start_flag = True

    for tkn in re.split(r'([+ \- \* /])', expr.rstrip()):
        if start_flag:
            part_res = int(tkn)
            start_flag = False
        
        elif tkn.isdecimal():
            op_res = {'+':part_res+int(tkn), '-':part_res-int(tkn), '*':part_res*int(tkn), '/':int(part_res/int(tkn))}
            part_res = op_res[op]
            tst_out.write('Resultado: ' + str(part_res) + '\n')
        
        elif tkn in operations:
            op = tkn

        else:
            raise Exception('Operação inválida')


        tst_in.write(tkn + '\n')
    
    # Escrever finalizador
    tst_in.write('f')

    tst_in.close()
    tst_out.close()

def make_all():
    with open(abs_dir + '/tsts/test-exprs', 'r') as test_exprs:
        n = 1
        for expr in test_exprs:
            make_calc_tst(abs_dir + '/tsts/calc-tsts/tst' + str(n).zfill(2), expr)
            n += 1

if __name__ == '__main__':
    if len(sys.argv) <= 1:
        make_all()
    else:
        n = 1
        for expr in sys.argv[1::]:
            make_calc_tst('tst' + str(n).zfill(2), expr)
            n += 1