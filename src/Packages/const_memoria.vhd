
-- Paquete "const_memoria":
-- Descripción: Aquí se define la dirección inicial para cada una de las distintas
-- secciones que constituyen la memoria principal de la PC: datos, instrucciones,
-- subrutinas y pila. Se reserva una porción de memoria al comienzo de la misma para 
-- operaciones privilegiadas de la CPU/sistema operativo, por lo cual el usuario bajo 
-- ningún concepto podrá acceder a ella durante la ejecución del programa. Éstas 
-- definiciones son útiles para que la unidad de gestión de memoria pueda comprobar en
-- cada intento de acceso por parte de la CPU si la dirección a acceder pertenece
-- efectivamente a la sección de la memoria a la cual el procesador debería estar 
-- accediendo. Por ejemplo, durante la ejecución del programa principal la CPU sólo 
-- debería poder acceder a la memoria de instrucciones durante la etapa de búsqueda 
-- ("fetch") y a la de datos durante la etapa de acceso a memoria ("memory access"), a
-- menos que se esté ejecutando una instrucción de manejo de la pila, en cuyo caso 
-- la etapa de acceso a memoria sólo podrá acceder a la sección de pila de la memoria.  


LIBRARY IEEE;

USE std.textio.all;
use ieee.NUMERIC_STD.all;
USE IEEE.std_logic_1164.all; 


PACKAGE const_memoria is
		
	
	CONSTANT MEMORY_BEGIN:	INTEGER := 16#0000#;
	CONSTANT DATA_BEGIN:	INTEGER := 16#1000#;
	CONSTANT INST_BEGIN:	INTEGER := 16#2000#;
	CONSTANT SUBR_BEGIN:	INTEGER := 16#3000#;
	CONSTANT STACK_BEGIN:	INTEGER := 16#7000#;
	CONSTANT BASE_POINTER:	INTEGER := 16#8000#;
	CONSTANT MEMORY_END:	INTEGER := 16#8000#;	
		
		
END const_memoria;




PACKAGE BODY const_memoria is 
	
	
	
END const_memoria;


