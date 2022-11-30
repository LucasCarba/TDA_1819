
-- Paquete "repert_cpu":
-- Descripción: Aquí se define el repertorio de instrucciones soportado por el procesador
-- diseñado para este proyecto, junto con el código de operación asignado a cada una de 
-- las mismas a fin de que el ensamblador pueda codificarla de manera tal que resulte 
-- inteligible para la unidad de control de la CPU, la cual se encargará de interpretarlo 
-- y, a partir de él, determinar las acciones a realizar a continuación para que el 
-- procesador pueda ejecutar dicha instrucción. Téngase en cuenta que todas las 
-- instrucciones vinculadas al manejo de subrutinas, interrupciones, pila y periféricos 
-- de entrada/salida aún no han sido implementadas, pero está previsto incorporarlas para 
-- una futura versión del proyecto.


LIBRARY IEEE;

USE std.textio.all;
USE IEEE.std_logic_1164.all; 


PACKAGE repert_cpu is


-- Transferencia de Datos 

	-- LB rd, Inm(ri)
	CONSTANT LB:			std_logic_vector(7 downto 0) := "00000100";
	-- SB rf, Inm(ri)
	CONSTANT SB:			std_logic_vector(7 downto 0) := "00000101";
	-- LH rd, Inm(ri)
	CONSTANT LH:			std_logic_vector(7 downto 0) := "00000110";
	-- SH rf, Inm(ri)
	CONSTANT SH:			std_logic_vector(7 downto 0) := "00000111";
	-- LW rd, Inm(ri)
	CONSTANT LW:			std_logic_vector(7 downto 0) := "00001000";
	-- SW rf, Inm(ri)
	CONSTANT SW:			std_logic_vector(7 downto 0) := "00001001";
	-- LF fd, Inm(ri)
	CONSTANT LF:			std_logic_vector(7 downto 0) := "00001010";
	-- SF ff, Inm(ri)
	CONSTANT SF:			std_logic_vector(7 downto 0) := "00001011";
	-- MFF fd, ff
	CONSTANT MFF:			std_logic_vector(7 downto 0) := "00001100";
	-- MFR fd, rf
	CONSTANT MFR:			std_logic_vector(7 downto 0) := "00001101";
	-- MRF rd, ff
	CONSTANT MRF:			std_logic_vector(7 downto 0) := "00001110";
	-- TF fd, ff
	CONSTANT TF:			std_logic_vector(7 downto 0) := "00001111";
	-- TI fd, ff
	CONSTANT TI:			std_logic_vector(7 downto 0) := "00010000";

	
-- Aritméticas

	-- DADD rd, rf, rg	
	CONSTANT DADD:			std_logic_vector(7 downto 0) := "00011000";
	-- DADDI rd, rf, N
	CONSTANT DADDI:			std_logic_vector(7 downto 0) := "00011001";
	-- DADDU rd, rf, rg
	CONSTANT DADDU:			std_logic_vector(7 downto 0) := "00011010";
	-- DADDUI rd, rf, N
	CONSTANT DADDUI:		std_logic_vector(7 downto 0) := "00011011";
	-- ADDF fd, ff, fg
	CONSTANT ADDF:			std_logic_vector(7 downto 0) := "00011100";
	-- DSUB rd, rf, rg
	CONSTANT DSUB:			std_logic_vector(7 downto 0) := "00011101";
	-- DSUBU rd, rf, rg
	CONSTANT DSUBU:			std_logic_vector(7 downto 0) := "00011110";	
	-- SUBF fd, ff, fg
	CONSTANT SUBF:			std_logic_vector(7 downto 0) := "00011111";
	-- DMUL rd, rf, rg
	CONSTANT DMUL:			std_logic_vector(7 downto 0) := "00100000";
	-- DMULU rd, rf, rg											   	
	CONSTANT DMULU:			std_logic_vector(7 downto 0) := "00100001";
	-- MULF fd, ff, fg
	CONSTANT MULF:			std_logic_vector(7 downto 0) := "00100010";
	-- DDIV rd, rf, rg
	CONSTANT DDIV:			std_logic_vector(7 downto 0) := "00100011";
	-- DDIVU rd, rf, rg
	CONSTANT DDIVU:			std_logic_vector(7 downto 0) := "00100100";
	-- DIVF fd, ff, fg
	CONSTANT DIVF:			std_logic_vector(7 downto 0) := "00100101";
	-- SLT rd, rf, rg
	CONSTANT SLT:			std_logic_vector(7 downto 0) := "00100110";
	-- SLTI rd, rf, N
	CONSTANT SLTI:			std_logic_vector(7 downto 0) := "00100111";	
	-- LTF ff, fg
	CONSTANT LTF:			std_logic_vector(7 downto 0) :=	"00101000";
	-- LEF ff, fg
	CONSTANT LEF:			std_logic_vector(7 downto 0) :=	"00101001";
	-- EQF ff, fg
	CONSTANT EQF:			std_logic_vector(7 downto 0) := "00101010";
	-- NEG rd, rf 
	CONSTANT NEGR:			std_logic_vector(7 downto 0) := "00101011";	   
	-- DSUBI rd, rf, N 		  
	CONSTANT DSUBI:			std_logic_vector(7 downto 0) := "00101100";

	  
-- Lógicas 

	-- AND rd, rf, rg
	CONSTANT ANDR:			std_logic_vector(7 downto 0) := "00110000";		
	-- ANDI rd, rf, N
	CONSTANT ANDI:			std_logic_vector(7 downto 0) := "00110001";
	-- OR rd, rf, rg
	CONSTANT ORR:			std_logic_vector(7 downto 0) := "00110010";
	-- ORI rd, rf, N
	CONSTANT ORI:			std_logic_vector(7 downto 0) := "00110011";
	-- XOR rd, rf, rg
	CONSTANT XORR:			std_logic_vector(7 downto 0) := "00110100";
	-- XORI rd, rf, N
	CONSTANT XORI:			std_logic_vector(7 downto 0) := "00110101";
	-- NOT rd, rf
	CONSTANT NOTR:			std_logic_vector(7 downto 0) := "00110110";	  
	--xnorr rd, rf, rg 
	CONSTANT XNORR:			std_logic_vector(7 downto 0) := "00110111";	 

-- Desplazamiento de bits

	-- DSL rd, rf, rN
	CONSTANT DSL:			std_logic_vector(7 downto 0) := "01000000";
	-- DSLI rd, rf, N
	CONSTANT DSLI:			std_logic_vector(7 downto 0) := "01000001";
	-- DSR rd, rf, rN
	CONSTANT DSR:			std_logic_vector(7 downto 0) := "01000010";
	-- DSRI rd, rf, N
	CONSTANT DSRI:			std_logic_vector(7 downto 0) := "01000011";
	-- DSLS rd, rf, rN
	CONSTANT DSLS:			std_logic_vector(7 downto 0) := "01000100";
	-- DSLSI rd, rf, N
	CONSTANT DSLSI:			std_logic_vector(7 downto 0) := "01000101";
	-- DSRS rd, rf, rN
	CONSTANT DSRS:			std_logic_vector(7 downto 0) := "01000110";
	-- DSRSI rd, rf, N
	CONSTANT DSRSI:			std_logic_vector(7 downto 0) := "01000111";
	
	
-- Transferencia de Control

	-- JMP offN
	CONSTANT JMP:			std_logic_vector(7 downto 0) := "01001000";
	-- BEQ rf, rg, offN
	CONSTANT BEQ:			std_logic_vector(7 downto 0) := "01001001";
	-- BNE rf, rg, offN
	CONSTANT BNE:			std_logic_vector(7 downto 0) := "01001010";
	-- BEQZ rf, offN
	CONSTANT BEQZ:			std_logic_vector(7 downto 0) := "01001011";
	-- BNEZ rf, offN
	CONSTANT BNEZ:			std_logic_vector(7 downto 0) := "01001100";
	-- BFPT offN
	CONSTANT BFPT:			std_logic_vector(7 downto 0) := "01001101";
	-- BFPF offN
	CONSTANT BFPF:			std_logic_vector(7 downto 0) := "01001110";

	
-- Subrutinas  

	-- CALL offN
	CONSTANT CALL:			std_logic_vector(7 downto 0) := "01010000";
	-- RET
	CONSTANT RET:			std_logic_vector(7 downto 0) := "01010001";

	
-- Manejo de Interrupciones

	-- INT N
	CONSTANT INT:			std_logic_vector(7 downto 0) := "01010100";
	-- IRET
	CONSTANT IRET:			std_logic_vector(7 downto 0) := "01010101";
	-- CLI
	CONSTANT CLI:			std_logic_vector(7 downto 0) := "01010110";
	-- STI
	CONSTANT STI:			std_logic_vector(7 downto 0) := "01010111";
	
	
-- Manejo de la Pila (Stack) 

	-- PUSHB rf
	CONSTANT PUSHB:			std_logic_vector(7 downto 0) := "01100000";
	-- POPB rd
	CONSTANT POPB:			std_logic_vector(7 downto 0) := "01100001";
	-- PUSHH rf
	CONSTANT PUSHH:			std_logic_vector(7 downto 0) := "01100010";
	-- POPH rd
	CONSTANT POPH:			std_logic_vector(7 downto 0) := "01100011";
	-- PUSHW rf
	CONSTANT PUSHW:			std_logic_vector(7 downto 0) := "01100100";
	-- POPW rd
	CONSTANT POPW:			std_logic_vector(7 downto 0) := "01100101";
	-- PUSHFL
	CONSTANT PUSHFL:		std_logic_vector(7 downto 0) := "01100110";
	-- POPFL
	CONSTANT POPFL:			std_logic_vector(7 downto 0) :=	"01100111";
	-- PUSHFP
	CONSTANT PUSHFP:		std_logic_vector(7 downto 0) := "01101000";
	-- POPFP
	CONSTANT POPFP:			std_logic_vector(7 downto 0) := "01101001";
	-- PUSHRA
	CONSTANT PUSHRA:		std_logic_vector(7 downto 0) := "01101010";
	-- POPRA
	CONSTANT POPRA:			std_logic_vector(7 downto 0) := "01101011";

	
-- Entrada/Salida 

	-- INB rd, offN
	CONSTANT INB:			std_logic_vector(7 downto 0) := "01110000";
	-- OUTB rf, offN
	CONSTANT OUTB:			std_logic_vector(7 downto 0) := "01110001";
	-- INH rd, offN
	CONSTANT INH:			std_logic_vector(7 downto 0) := "01110010";
	-- OUTH rf, offN
	CONSTANT OUTH:			std_logic_vector(7 downto 0) := "01110011";
	-- INW rd, offN
	CONSTANT INW:			std_logic_vector(7 downto 0) := "01110100";
	-- OUTW rf, offN
	CONSTANT OUTW:			std_logic_vector(7 downto 0) := "01110101";
	
		
-- Control del Procesador

	-- NOP
	CONSTANT NOP:			std_logic_vector(7 downto 0) := "10000000";
	-- HALT
	CONSTANT HALT:			std_logic_vector(7 downto 0) := "10000001";
	

END repert_cpu;




PACKAGE BODY repert_cpu is 
	

END repert_cpu;


