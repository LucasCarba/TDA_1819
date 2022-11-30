
-- Paquete "const_ensamblador":
-- Descripción: Aquí se definen todos los sistemas de representación válidos soportados 
-- por el ensamblador (decimal, binario y hexadecimal) para asignar valores tanto a las
-- variables del programa como a los operandos inmediatos. También se incluyen todos 
-- los dígitos posibles que posee cada sistema para que el ensamblador pueda verificar
-- su adecuada utilización por parte del usuario. Además, se encuentran especificados 
-- todos los tipos de datos válidos para que el ensamblador pueda comprobar su correcta 
-- definición en el programa; el tamaño en memoria de cada tipo de datos para poder 
-- almacenar los valores de sus respectivas variables en la memoria de datos; y por 
-- último los nombres de todas las instrucciones posibles del repertorio soportado por 
-- este procesador junto con su código de operación y el tamaño total de cada 
-- instrucción en memoria a fin de que el ensamblador verifique si existen errores de 
-- sintaxis en su definición por parte del usuario y luego pueda almacenar en la 
-- memoria de instrucciones tanto el opcode como los operandos de dicha instrucción. 


library TDA_1819;
use TDA_1819.tipos_ensamblador.all;
use TDA_1819.repert_cpu.all;

LIBRARY IEEE;

USE std.textio.all;
USE IEEE.std_logic_1164.all; 


PACKAGE const_ensamblador is
	
	
	CONSTANT CANT_REGISTROS:	INTEGER := 16;
	CONSTANT CANT_TIPOS:		INTEGER := 9;
	CONSTANT CANT_LABELS:		INTEGER := 10;
	CONSTANT CANT_VARIABLES:	INTEGER := 10;
	CONSTANT CANT_OFFSETS:		INTEGER := 10;
	CONSTANT CANT_INSTTD:		INTEGER := 13;
	CONSTANT CANT_INSTAR:		INTEGER := 20;
	CONSTANT CANT_INSTLD:		INTEGER := 16;
	CONSTANT CANT_INSTTC:		INTEGER := 7;
	CONSTANT CANT_INSTCT:		INTEGER := 2;
	
	CONSTANT IS_STRING: 		INTEGER := 1;
	CONSTANT IS_STRINGZ:		INTEGER := 2;
	CONSTANT IS_INTEGER: 		INTEGER := 3;
	CONSTANT IS_UINTEGER:		INTEGER := 4;
	CONSTANT IS_FLOAT: 			INTEGER := 5; 
	
	CONSTANT IS_DEC:			INTEGER := 1;
	CONSTANT IS_HEX:			INTEGER := 2;
	CONSTANT IS_BIN:			INTEGER := 3;
	
	CONSTANT SIZE_ASCII:		INTEGER := 1;
	CONSTANT SIZE_FLOAT:		INTEGER := 4;  
	
	CONSTANT CANT_DEC:			INTEGER	:= 10;
	CONSTANT CANT_HEX:			INTEGER := 16;
	CONSTANT CANT_BIN:			INTEGER := 2;
	
	CONSTANT DIGITS_DEC: 		STRING(1 to CANT_DEC) := "0123456789";
	CONSTANT DIGITS_HEX:		STRING(1 to CANT_HEX) := "0123456789ABCDEF";
	CONSTANT DIGITS_BIN:		STRING(1 to CANT_BIN) := "01";
	
	CONSTANT DATA_NAMES:		data_name_array(1 to CANT_TIPOS) := (".ascii ", ".asciiz", ".byte  ", ".ubyte ", ".hword ", ".uhword", ".word  ", ".uword ", ".float "); 
	CONSTANT DATA_TYPES:		data_type_array(1 to CANT_TIPOS) := (IS_STRING, IS_STRINGZ, IS_INTEGER, IS_UINTEGER, IS_INTEGER, IS_UINTEGER, IS_INTEGER, IS_UINTEGER, IS_FLOAT);
	CONSTANT DATA_SIZES:		data_size_array(1 to CANT_TIPOS) := (-1, -1, 1, 1, 2, 2, 4, 4, 4);
	
	CONSTANT INSTTD_NAMES: 		insttd_name_array(1 to CANT_INSTTD) := ("lb ", "sb ", "lh ", "sh ", "lw ", "sw ", "lf ", "sf ", "mff", "mfr", "mrf", "tf ", "ti ");
	CONSTANT INSTTD_CODES:		insttd_code_array(1 to CANT_INSTTD) := (LB, SB, LH, SH, LW, SW, TDA_1819.repert_cpu.LF, SF, MFF, MFR, MRF, TF, TI);
	CONSTANT INSTTD_SIZES:		insttd_size_array(1 to CANT_INSTTD) := (6, 6, 6, 6, 6, 6, 6, 6, 4, 4, 4, 4, 4);	
	
	CONSTANT INSTAR_NAMES: 		instar_name_array(1 to CANT_INSTAR) := ("dadd  ", "daddi ", "daddu ", "daddui", "addf  ", "dsub  ", "dsubu ", "subf  ", "dmul  ", "dmulu ", "mulf  ", "ddiv  ", "ddivu ", "divf  ", "slt   ", "slti  ", "ltf   ", "lef   ", "eqf   ", "neg   ");
	CONSTANT INSTAR_CODES:		instar_code_array(1 to CANT_INSTAR) := (DADD, DADDI, DADDU, DADDUI, ADDF, DSUB, DSUBU, SUBF, DMUL, DMULU, MULF, DDIV, DDIVU, DIVF, SLT, SLTI, LTF, LEF, EQF, NEGR);
	CONSTANT INSTAR_SIZES:		instar_size_array(1 to CANT_INSTAR) := (5, 8, 5, 8, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 8, 4, 4, 4, 4);
	
	CONSTANT INSTLD_NAMES: 		instld_name_array(1 to CANT_INSTLD) := ("and  ", "andi ", "or   ", "ori  ", "xor  ", "xori ", "not  ", "dsl  ", "dsli ", "dsr  ", "dsri ", "dsls ", "dslsi", "dsrs ", "dsrsi", "xnorr");
	CONSTANT INSTLD_CODES:		instld_code_array(1 to CANT_INSTLD) := (ANDR, ANDI, ORR, ORI, XORR, XORI, NOTR, DSL, DSLI, DSR, DSRI, DSLS, DSLSI, DSRS, DSRSI, XNORR);
	CONSTANT INSTLD_SIZES:		instld_size_array(1 to CANT_INSTLD) := (5, 8, 5, 8, 5, 8, 5, 5, 8, 5, 8, 5, 8, 5, 8, 8);
	
	CONSTANT INSTTC_NAMES: 		insttc_name_array(1 to CANT_INSTTC) := ("jmp ", "beq ", "bne ", "beqz", "bnez", "bfpt", "bfpf");
	CONSTANT INSTTC_CODES:		insttc_code_array(1 to CANT_INSTTC) := (JMP, BEQ, BNE, BEQZ, BNEZ, BFPT, BFPF);
	CONSTANT INSTTC_SIZES:		insttc_size_array(1 to CANT_INSTTC) := (4, 6, 6, 5, 5, 4, 4);
	
	CONSTANT INSTCT_NAMES: 		instct_name_array(1 to CANT_INSTCT) := ("nop ", "halt");
	CONSTANT INSTCT_CODES:		instct_code_array(1 to CANT_INSTCT) := (NOP, HALT);
	CONSTANT INSTCT_SIZES:		instct_size_array(1 to CANT_INSTCT) := (2, 2);
	
	
END const_ensamblador;




PACKAGE BODY const_ensamblador is 
	

END const_ensamblador;


