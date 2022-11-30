
-- Paquete "const_flags":
-- Descripción: Aquí se definen todas las banderas que constituyen el registro
-- FLAGS tanto de la ALU normal como de la especial para punto flotante, junto 
-- con la posición que cada una de ellas ocupa dentro de él, a fin de que 
-- cuando su respectiva ALU necesite accederlo para realizar una operación de 
-- lectura o escritura de alguno de sus flags pueda identificar cuál de todos 
-- los bits que forman parte de dicho registro lo representa.


LIBRARY IEEE;

USE std.textio.all;
use ieee.NUMERIC_STD.all;
USE IEEE.std_logic_1164.all; 


PACKAGE const_flags is
		
	
	CONSTANT FLAG_F:	INTEGER := 7;		-- Floating Point
	CONSTANT FLAG_I:	INTEGER := 6;		-- Interrupt
	CONSTANT FLAG_Z:	INTEGER := 5;		-- Zero
	CONSTANT FLAG_S:	INTEGER := 4;		-- Sign
	CONSTANT FLAG_O:	INTEGER := 3;		-- Overflow
	CONSTANT FLAG_C:	INTEGER := 2;		-- Carry
	CONSTANT FLAG_A:	INTEGER := 1;		-- Auxiliary Carry
	CONSTANT FLAG_P:	INTEGER := 0;		-- Parity
		
		
END const_flags;




PACKAGE BODY const_flags is 
	
	
	
END const_flags;


