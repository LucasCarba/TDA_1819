
-- Paquete "const_reloj":
-- Descripción: Aquí se define el valor correspondiente al período de reloj de la
-- CPU. Durante la primera mitad de cada ciclo la señal de reloj adoptará un valor
-- lógico alto, mientras que durante la segunda mitad tendrá un valor bajo. Se
-- recomienda no intentar disminuir manualmente el valor aquí determinado ya que en
-- tal caso la CPU podría presentar un comportamiento anómalo.


LIBRARY IEEE;

USE std.textio.all;
USE IEEE.std_logic_1164.all; 


PACKAGE const_reloj is
	
	
	CONSTANT PERIODO:	time := 50 ns;
	

END const_reloj;




PACKAGE BODY const_reloj is 
	

END const_reloj;


