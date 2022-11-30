
-- Paquete "const_registros":
-- Descripción: Aquí se definen los valores utilizados como identificadores para
-- cada uno de los registros de la CPU, tanto los de propósito general (enteros y de 
-- punto flotante) como los reservados para uso privilegiado del procesador. Estas
-- definiciones son importantes para que todas las unidades de la CPU que 
-- pretendan acceder al banco de registros (unidad de búsqueda, unidad de control, 
-- ALU) puedan indicar unívocamente sobre qué registro pretenden llevar a cabo la 
-- operación deseada de una manera tal que resulte inteligible para el administrador 
-- de dicho banco encargado de gestionar todos los accesos realizados a él.


LIBRARY IEEE;

USE std.textio.all;
use ieee.NUMERIC_STD.all;
USE IEEE.std_logic_1164.all; 


PACKAGE const_registros is
		
	
	CONSTANT ID_R0:			INTEGER := 0;
	CONSTANT ID_R1:			INTEGER := 1;
	CONSTANT ID_R2:			INTEGER := 2;
	CONSTANT ID_R3:			INTEGER := 3;
	CONSTANT ID_R4:			INTEGER := 4;
	CONSTANT ID_R5:			INTEGER := 5;
	CONSTANT ID_R6:			INTEGER := 6;
	CONSTANT ID_R7:			INTEGER := 7;
	CONSTANT ID_R8:			INTEGER := 8;
	CONSTANT ID_R9:			INTEGER := 9;
	CONSTANT ID_R10:		INTEGER := 10;
	CONSTANT ID_R11:		INTEGER := 11;
	CONSTANT ID_R12:		INTEGER := 12;
	CONSTANT ID_R13:		INTEGER := 13;
	CONSTANT ID_R14:		INTEGER := 14;
	CONSTANT ID_R15:		INTEGER := 15;
	CONSTANT ID_F0:			INTEGER := 16;
	CONSTANT ID_F1:			INTEGER := 17;
	CONSTANT ID_F2:			INTEGER := 18;
	CONSTANT ID_F3:			INTEGER := 19;
	CONSTANT ID_F4:			INTEGER := 20;
	CONSTANT ID_F5:			INTEGER := 21;
	CONSTANT ID_F6:			INTEGER := 22;
	CONSTANT ID_F7:			INTEGER := 23;
	CONSTANT ID_F8:			INTEGER := 24;
	CONSTANT ID_F9:			INTEGER := 25;
	CONSTANT ID_F10:		INTEGER := 26;
	CONSTANT ID_F11:		INTEGER := 27;
	CONSTANT ID_F12:		INTEGER := 28;
	CONSTANT ID_F13:		INTEGER := 29;
	CONSTANT ID_F14:		INTEGER := 30;
	CONSTANT ID_F15:		INTEGER := 31;
	CONSTANT ID_IR:			INTEGER := 32;
	CONSTANT ID_IP:			INTEGER := 33;
	CONSTANT ID_FLAGS:		INTEGER := 34;
	CONSTANT ID_FPFLAGS:	INTEGER := 35;
	CONSTANT ID_BP:			INTEGER := 36;
	CONSTANT ID_SP:			INTEGER := 37;
	CONSTANT ID_RA:			INTEGER := 38;
	
	
END const_registros;




PACKAGE BODY const_registros is 
	
	
	
END const_registros;


