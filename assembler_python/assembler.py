#!/usr/bin/env python3
import sys


def is_instruction(word):
    instructions = (
        'add', 'sub', 'and', 'or', 'xor', 'nor', 'slt', 'sll', 'sra', 'srl', 'jr', 'j', 'jal', 'addi', 'andi', 'ori',
        'xori', 'slti', 'lui', 'lw', 'lh', 'lb', 'sw', 'sh', 'sb', 'beq', 'bne', 'nop','syscall','laddri',
        'ldatai','ldata','dreq','rst','rstb','siow','riow','sior','rior','smemw','rmemw','smemr','rmemr','sdm','srf','memio','iomem','lbus'
        ,'strtdma','endma','sdemand','rdemand')
    if word in instructions:
        return True
    else:
        return False

def is_register(word):
    registerss = (
        '$zero', '$at', '$v0', '$v1', '$a0', '$a1', '$a2', '$a3', '$t0', '$t1', '$t2', '$t3', '$t4', '$t5', '$t6',
        '$t7',
        '$s0', '$s1', '$s2', '$s3', '$s4', '$s5', '$s6', '$s7', '$t8', '$t9', '$k0', '$k1', '$gp', '$sp', '$fp', '$ra', '$0'
	,'$1', '$2', '$3', '$4', '$5', '$6', '$7', '$8', '$9', '$10', '$11', '$12', '$13', '$14', '$15', '$16', '$17', '$18'
	,'$19', '$20', '$21', '$22', '$23', '$24', '$25', '$26', '$27', '$28', '$29', '$30', '$31')
    if word in registerss:
        return True
    else:
        return False

def is_dmaOperation(word):
    registerss = ('laddri',
        'ldatai','ldata','dreq','rst','rstb','siow','riow','sior',
        'rior','smemw','rmemw','smemr','rmemr','sdm','srf','memio','iomem','lbus'
        ,'strtdma','endma','sdemand','rdemand')
    if word in registerss:
        return True
    else:
        return False

def is_dmaReg(word):
    registerss = ('$CAR0','$CAR1','$CAR2','$CAR3','$CCR0','$CCR1','$CCR2','$CCR3','$COMMAND',
                  '$MODE0', '$MODE1', '$MODE2', '$MODE3', '$MASK', '$STATE')
    if word in registerss:
        return True
    else:
        return False

def is_r(word):
    instructions = ('add', 'sub', 'and', 'or', 'xor', 'nor', 'slt', 'sll', 'sra', 'srl', 'jr')
    if word in instructions:
        return True
    else:
        return False


def is_r_arithmetic(word):
    instructions = ('add', 'sub', 'and', 'or', 'xor', 'nor', 'slt')
    if word in instructions:
        return True
    else:
        return False


def is_r_shift(word):
    instructions = ('sll', 'sra', 'srl')
    if word in instructions:
        return True
    else:
        return False


def is_r_jump(word):
    return word == "jr"


def is_i_arithmetic_memory(word):
    instructions = ('addi', 'andi', 'ori', 'xori', 'slti', 'lui', 'lw', 'lh', 'lb', 'sw', 'sh', 'sb')
    if word in instructions:
        return True
    else:
        return False


def is_i_branch(word):
    instructions = ('beq', 'bne')
    if word in instructions:
        return True
    else:
        return False

def is_syscall(word):
    instructions = ('syscall')
    if word in instructions:
        return True
    else:
        return False


def is_j(word):
    instructions = ('j', 'jal')
    if word in instructions:
        return True
    else:
        return False


def is_jump(word):
    if word[-1] == ":":
        return True
    else:
        return False


def is_number(word):
    if word[0] == "-":
        return word[1:].isnumeric()
    else:
        return word.isnumeric()


def decimal_to_binary5(decimal):
    return '{0:05b}'.format(int(decimal))


def decimal_to_binary16(decimal):
    result = ('{0:016b}'.format(int(decimal)))
    if int(result) < 0:
        result1 = ""
        result = "0" + result[1:]
        flag = False
        for letter in result[::-1]:
            if letter == "0" and flag == False:
                result1 += letter
            elif letter == "0" and flag == True:
                result1 += "1"
            elif letter == "1" and flag == False:
                result1 += letter
                flag = True
            elif letter == "1" and flag == True:
                result1 += "0"
        return result1[::-1]
    return result

tobin = lambda x, count=8: "".join(map(lambda y:str((x>>y)&1), range(count-1, -1, -1)))

def decimal_to_binary26(decimal):
    return '{0:026b}'.format(int(decimal))


def decimal_to_binary32(decimal):
    return '{0:032b}'.format(int(decimal))

def write_code(full_code,file_name):
    file = open(file_name, "w")
    file.write("\n")
    for index in range(int(len(full_code)/8)):
        file.write(full_code[index*8:index*8+8])
        file.write("\n")
    file.close()

instruction_to_op = {
    'add': "000000",
    'sub': "000000",
    'and': "000000",
    'or': "000000",
    'xor': "000000",
    'nor': "000000",
    'slt': "000000",
    'sll': "000000",
    'sra': "000000",
    'srl': "000000",
    'jr': "000000",
    'nop': "000000",
    'j': "000010",
    'jal': "000011",
    'addi': "001000",
    'andi': "001100",
    'ori': "001101",
    'xori': "001110",
    'slti': "001010",
    'lui': "001111",
    'lw': "100011",
    'sw': "101011",
    'beq': "000100",
    'bne': "000101",
    'syscall': "111110",

    'laddri' : "110010",	#50
    'ldatai' : "110011",
    'ldata' : "100111",
    'dreq' : "110100",
    'rst' : "110110",
    'rstb' : "110111",
    'siow' : "101000",
    'riow' : "101100",
    'sior' : "101001",
    'rior' : "101101",
    'smemw': "101010",
    'rmemw': "101110",
    'smemr': "110000",
    'rmemr': "101111",
    'sdm'  : "110001",
    'srf'  : "111010",
    'memio': "111101",
    'iomem': "111100",
    'lbus' : "111011",
    'strtdma' : "111000",
    'endma' : "111001",
    'sdemand' : "100110",
    'rdemand' : "100101"
}

instruction_to_funct = {
    'add': "100000",
    'sub': "100010",
    'and': "100100",
    'or': "100101",
    'xor': "100110",
    'nor': "100111",
    'slt': "101010",
    'sll': "000000",
    'sra': "000011",
    'srl': "000010",
    'jr': "001000"
}

register_to_code = {
    '$zero': '00000',
    '$0': '00000',
    '$at': '00001',
    '$v0': '00010',
    '$v1': '00011',
    '$a0': '00100',
    '$a1': '00101',
    '$a2': '00110',
    '$a3': '00111',
    '$t0': '01000',
    '$t1': '01001',
    '$t2': '01010',
    '$t3': '01011',
    '$t4': '01100',
    '$t5': '01101',
    '$t6': '01110',
    '$t7': '01111',
    '$s0': '10000',
    '$s1': '10001',
    '$s2': '10010',
    '$s3': '10011',
    '$s4': '10100',
    '$s5': '10101',
    '$s6': '10110',
    '$s7': '10111',
    '$t8': '11000',
    '$t9': '11001',
    '$k0': '11010',
    '$k1': '11011',
    '$gp': '11100',
    '$sp': '11101',
    '$fp': '11110',
    '$ra': '11111',
    '$0': '00000',
    '$1': '00001',
    '$2': '00010',
    '$3': '00011',
    '$4': '00100',
    '$5': '00101',
    '$6': '00110',
    '$7': '00111',
    '$8': '01000',
    '$9': '01001',
    '$10': '01010',
    '$11': '01011',
    '$12': '01100',
    '$13': '01101',
    '$14': '01110',
    '$15': '01111',
    '$16': '10000',
    '$17': '10001',
    '$18': '10010',
    '$19': '10011',
    '$20': '10100',
    '$21': '10101',
    '$22': '10110',
    '$23': '10111',
    '$24': '11000',
    '$25': '11001',
    '$26': '11010',
    '$27': '11011',
    '$28': '11100',
    '$29': '11101',
    '$30': '11110',
    '$31': '11111',
}

dmaRegister_to_code = {
    '$CAR0' :    '0000000000000000',
    '$CAR1' :    '0000000000000010',
    '$CAR2' :    '0000000000000100',
    '$CAR3' :    '0000000000000110',
    '$CCR0' :    '0000000000000001',
    '$CCR1' :    '0000000000000011',
    '$CCR2' :    '0000000000000101',
    '$CCR3' :    '0000000000000111',
    '$COMMAND' : '0000000000001000',
    '$MODE0' :   '0000000000001011',
    '$MODE1' :   '0000000000001100', 
    '$MODE2' :   '0000000000001101',
    '$MODE3' :   '0000000000001110', 
    '$MASK' :    '0000000000001010', 
}

instructions_and_jumps = []
jumps = []
registers = []
numbers = []
dmaRegs = []
file_name = ""
if len(sys.argv) > 1:
    file_name = sys.argv[1]
else:
    file_name = "test.txt"
lines = [line.rstrip('\n') for line in open(file_name)]
for line in lines:
    line = line.replace(',', ' ')
    line = line.replace('\n', ' ')
    line = line.replace('(', ' ')
    line = line.replace(')', ' ')
    line = line.replace(';', ' ')
    words = line.split()
    for word in words:
        if is_register(word):
            registers.append(word)
        elif is_dmaReg(word):
            dmaRegs.append(word)
        elif is_number(word):
            numbers.append(word)
        elif is_instruction(word):
            instructions_and_jumps.append(word)
        elif word[-1] == ":":
            instructions_and_jumps.append(word)
        else:
            jumps.append(word)
number_pointer = 0
jump_pointer = 0
register_pointer = 0
dmareg_pointer = 0
print(dmaRegs)
full_code = ""
for index, word in enumerate(instructions_and_jumps):
    if is_instruction(word):
        full_code += instruction_to_op[word]
        if word == 'nop':
            full_code += "00000000000000000000000000"
            print("nop")
        elif is_dmaOperation(word):
            if not(word == 'lbus') and not(word == 'ldata'):
                full_code += '00000'
                full_code += "00000"
            if(word == 'laddri'):
                full_code += str(tobin(int(numbers[number_pointer]),16))
                number_pointer += 1
            elif(word == 'ldatai'):
                full_code += '00000000'
                full_code += str(tobin(int(numbers[number_pointer]),8))
                number_pointer += 1
            elif(word == 'srf'):
                full_code += '000000'
                full_code += '00000'
                full_code += register_to_code[registers[register_pointer]]
                print(registers[register_pointer],register_to_code[registers[register_pointer]])
                print(full_code)
                register_pointer += 1
            elif(word == 'sdm'):
                full_code += str(tobin(int(numbers[number_pointer]),16))
                number_pointer += 1
            elif(word == 'lbus'):
                print(full_code)
                full_code += '00'
                print(full_code)
                full_code += str(tobin(int(numbers[number_pointer]),8))
                print(full_code) 
                print("number is ",int(numbers[number_pointer])," : ", str(tobin(int(numbers[number_pointer]),8)))
                full_code += dmaRegister_to_code[dmaRegs[dmareg_pointer]]
                print(full_code)
                number_pointer += 1
                dmareg_pointer += 1
            elif(word == 'dreq'):
                print("dreq")
                print(full_code)
                full_code += str(tobin(int(numbers[number_pointer]),16))
                print(full_code)
                number_pointer += 1
            elif(word == 'ldata'):
                full_code += register_to_code[registers[register_pointer]]
                register_pointer += 1
                full_code += "00000"
                full_code += "00000"
                full_code += "00000"
                full_code += "000000"
            else :
                full_code += "00000"
                full_code += "00000"
                full_code += "000000"
            print("dma op")
        elif is_syscall(word):
            full_code += '00100'
            full_code += '00101'
            full_code += "00000"
            full_code += "00000"
            full_code += "000000"
            print("syscall")
        elif is_r_arithmetic(word):
            full_code += register_to_code[registers[register_pointer + 1]]
            full_code += register_to_code[registers[register_pointer + 2]]
            full_code += register_to_code[registers[register_pointer]]
            full_code += "00000"
            full_code += instruction_to_funct[word]
            register_pointer += 3
            print("r type arth")
        elif is_r_shift(word):
            full_code += "00000"
            full_code += register_to_code[registers[register_pointer + 1]]
            full_code += register_to_code[registers[register_pointer]]
            full_code += decimal_to_binary5(numbers[number_pointer])
            full_code += instruction_to_funct[word]
            register_pointer += 2
            number_pointer += 1
            print("r type shift")
        elif is_r_jump(word):
            full_code += register_to_code[registers[register_pointer]]
            full_code += "00000"
            full_code += "00000"
            full_code += "00000"
            full_code += instruction_to_funct[word]
            register_pointer += 1
            print("r type jump")
        elif word == "lui":
            full_code += "00000"
            full_code += register_to_code[registers[register_pointer]]
            full_code += decimal_to_binary16(numbers[number_pointer])
            register_pointer += 1
            number_pointer += 1
        elif is_i_arithmetic_memory(word):
            full_code += register_to_code[registers[register_pointer + 1]]
            full_code += register_to_code[registers[register_pointer]]
            full_code += str(tobin(int(numbers[number_pointer]),16))
            register_pointer += 2
            number_pointer += 1
        elif is_i_branch(word):
            full_code += register_to_code[registers[register_pointer]]
            full_code += register_to_code[registers[register_pointer + 1]]
            jump_position = instructions_and_jumps.index(jumps[jump_pointer] + ":")
            counter = 0
            if index > jump_position:
                for i in range(jump_position, index + 1):
                    if is_instruction(instructions_and_jumps[i]):
                        counter += 1
                counter = -counter
            elif index < jump_position:
                for i in range(index + 1, jump_position + 1):
                    if is_instruction(instructions_and_jumps[i]):
                        counter += 1
            else:
                counter = -1
            full_code += decimal_to_binary16(counter)
            register_pointer += 2
            jump_pointer += 1
        elif is_j(word):
            counter = 0
            print(jumps)
            jump_position = instructions_and_jumps.index(jumps[jump_pointer] + ":")
            for word in instructions_and_jumps[:jump_position]:
                if is_instruction(word):
                    counter += 1
            counter *= 4
            full_code += decimal_to_binary32(counter)[4:30]
            jump_pointer += 1
full_code += "111111111111111111111111111111111"
file_name = ""
if (len(sys.argv) == 3):
    file_name = sys.argv[2]
else:
    file_name = "result.txt"
write_code(full_code,file_name)
print("Done")
