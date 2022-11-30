
-- Paquete "const_buses":
-- Descripción: Aquí se definen los posibles valores que pueden ser asignados al bus
-- de control de la PC para determinar el tipo de operación a realizar sobre la memoria
-- principal: lectura o escritura.


LIBRARY IEEE;

USE std.textio.all;
USE IEEE.std_logic_1164.all; 


PACKAGE const_buses is
	
	
	CONSTANT READ_MEMORY:	std_logic_vector(1 downto 0) := B"10";
	CONSTANT WRITE_MEMORY:	std_logic_vector(1 downto 0) := B"01";
	

END const_buses;




PACKAGE BODY const_buses is 
	

END const_buses;


