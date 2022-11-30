
-- Paquete "const_cpu":
-- Descripción: Aquí se definen, en primer lugar, la cantidad máxima de instrucciones a 
-- ensamblar y ejecutar para que la máquina de estados de la CPU pueda reservar espacio 
-- de antemano para guardarlas. Luego, el número máximo de instrucciones cuya escritura 
-- en un mismo registro de propósito general del procesador puede encontrarse en estado 
-- pendiente para que el detector de dependencias de tipo WAW pueda reservar espacio de 
-- antemano para almacenarlas. Después, todos los tipos de operaciones posibles a 
-- realizar en la ALU, tanto la normal como la especial para punto flotante, para que la 
-- unidad de control de la CPU pueda definirla de una forma tal que luego la unidad 
-- aritmético-lógica sea capaz de interpretar sin inconvenientes cuál es la próxima 
-- operación a llevar a cabo. A continuación, todos los tipos de dispositivos posibles 
-- que pueden ser accedidos por la CPU durante la etapa "memory access": la memoria de 
-- datos de la PC o uno de los periféricos de entrada/salida (o ninguna de las dos 
-- opciones anteriores), para que, al igual que en el caso anterior, la unidad de
-- control del procesador pueda definirla de una manera tal que luego esta etapa sea
-- capaz de interpretar cuál es el componente de la PC al cual se desea acceder ya sea
-- para realizar una operación de lectura o escritura sobre él. Luego, el valor que la
-- unidad de control le debe enviar a la etapa "writeback" para indicarle que no necesita
-- realizar ninguna acción en caso de que así corresponda según la instrucción ejecutada. 
-- Finalmente, las posibles etapas que sean capaces de generar el valor a escribir tanto 
-- en la etapa "memory access" como en la etapa "writeback", para que éstas pueda saber 
-- exactamente en qué lugar de la información recibida desde la unidad de control deben 
-- buscarlo para poder utilizarlo. 


LIBRARY IEEE;

USE std.textio.all;
USE IEEE.std_logic_1164.all; 


PACKAGE const_cpu is
	
	
	CONSTANT CANT_MAX_INST_COMP:	INTEGER := 100;
	CONSTANT CANT_MAX_INST_EXEC: 	INTEGER := 100;
	
	CONSTANT CANT_MAX_INST_WRPEND:	INTEGER := 10;
	
	CONSTANT EX_NULL:		INTEGER	:= 0;		-- La instrucción actual no requiere la intervención de la ALU
												-- en la etapa Execute 
	CONSTANT EX_TF:			INTEGER := 1;		
	CONSTANT EX_TI:			INTEGER := 2;
	CONSTANT EX_ADD:		INTEGER := 3;		-- La instrucción actual requiere la intervención de la ALU
												-- en la etapa Execute para realizar una suma (ADD)
	CONSTANT EX_SUB:		INTEGER := 4;
	CONSTANT EX_MUL:		INTEGER := 5;
	CONSTANT EX_DIV:		INTEGER := 6;
	CONSTANT EX_SLT:		INTEGER := 7;
	CONSTANT EX_LTF:		INTEGER := 8;
	CONSTANT EX_LEF:		INTEGER := 9;
	CONSTANT EX_EQF:		INTEGER := 10;
	CONSTANT EX_NEG:		INTEGER := 11;
	CONSTANT EX_AND:		INTEGER := 12;
	CONSTANT EX_OR:			INTEGER := 13;
	CONSTANT EX_XOR:		INTEGER := 14;
	CONSTANT EX_NOT:		INTEGER := 15;
	CONSTANT EX_DSL:		INTEGER := 16;
	CONSTANT EX_DSR:		INTEGER := 17;
	CONSTANT EX_BEQ:		INTEGER := 18;
	CONSTANT EX_BNE:		INTEGER := 19;
	CONSTANT EX_BEQZ:		INTEGER := 20;
	CONSTANT EX_BNEZ:		INTEGER := 21;
	CONSTANT EX_BFPT:		INTEGER := 22;
	CONSTANT EX_BFPF:		INTEGER := 23;
	
	CONSTANT MEM_NULL:		INTEGER := 0;		-- La instrucción actual no necesita realizar ninguna 
												-- acción en la etapa Memory Access
	CONSTANT MEM_MEM:		INTEGER := 1;		-- La instrucción actual necesita acceder a memoria
												-- en la etapa Memory Access 
	CONSTANT MEM_PER:		INTEGER := 2;		-- La instrucción actual necesita acceder a un periférico de E/S
												-- en la etapa Memory Access  
	
	CONSTANT MEM_ID:		INTEGER := 0;		-- El dato a escribir en memoria se originó en la etapa Decode
	CONSTANT MEM_EX:		INTEGER := 1;		-- El dato a escribir en memoria se originó en la etapa Execute
	
	CONSTANT WB_NULL:		INTEGER := 0;		-- La instrucción actual no implica almacenar datos o resultados
												-- en ninguno de los registros de uso general en la etapa Writeback																														
											
	CONSTANT WB_ID:			INTEGER := 1;		-- El valor a almacenar en el banco de registros de uso general se originó en la 
												-- etapa Decode
	CONSTANT WB_EX:			INTEGER := 2;		-- El valor a almacenar en el banco de registros de uso general se originó en la 
												-- etapa Execute
	CONSTANT WB_MEM:		INTEGER := 3;		-- El valor a almacenar en el banco de registros de uso general se originó en la 
												-- etapa Memory Access
	
											
END const_cpu;




PACKAGE BODY const_cpu is 
	

END const_cpu;


