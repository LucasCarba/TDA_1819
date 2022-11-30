
-- Paquete "tipos_ensamblador":
-- Descripción: Aquí se definen los tipos de datos necesarios para declarar las
-- constantes que contienen tanto los nombres como los códigos de operación y 
-- los tamaños en memoria para todas las instrucciones incluidas en el repertorio 
-- soportado por el procesador (paquete "const_ensamblador"). También se encuentran
-- incorporadas en este paquete las declaraciones de las estructuras de los 
-- registros utilizados por el ensamblador para almacenar durante el proceso de 
-- ensamblaje toda la información correspondiente a las distintas variables, 
-- etiquetas e instrucciones de salto definidas por el usuario para el programa.


LIBRARY IEEE;
USE std.textio.all;	
USE IEEE.std_logic_1164.all; 


PACKAGE tipos_ensamblador is
	
	
	TYPE data_name_array IS ARRAY (POSITIVE RANGE <>) OF STRING(1 to 7);
	TYPE data_type_array IS ARRAY (POSITIVE RANGE <>) OF INTEGER;
	TYPE data_size_array IS ARRAY (POSITIVE RANGE <>) OF INTEGER;
	
	TYPE insttd_name_array IS ARRAY (POSITIVE RANGE <>) OF STRING(1 to 3);
	TYPE insttd_code_array IS ARRAY (POSITIVE RANGE <>) OF STD_LOGIC_VECTOR(7 downto 0);
	TYPE insttd_size_array IS ARRAY (POSITIVE RANGE <>) OF INTEGER;
	
	TYPE instar_name_array IS ARRAY (POSITIVE RANGE <>) OF STRING(1 to 6);
	TYPE instar_code_array IS ARRAY (POSITIVE RANGE <>) OF STD_LOGIC_VECTOR(7 downto 0);
	TYPE instar_size_array IS ARRAY (POSITIVE RANGE <>) OF INTEGER;	
	
	TYPE instld_name_array IS ARRAY (POSITIVE RANGE <>) OF STRING(1 to 5);
	TYPE instld_code_array IS ARRAY (POSITIVE RANGE <>) OF STD_LOGIC_VECTOR(7 downto 0);
	TYPE instld_size_array IS ARRAY (POSITIVE RANGE <>) OF INTEGER;
	
	TYPE insttc_name_array IS ARRAY (POSITIVE RANGE <>) OF STRING(1 to 4);
	TYPE insttc_code_array IS ARRAY (POSITIVE RANGE <>) OF STD_LOGIC_VECTOR(7 downto 0);
	TYPE insttc_size_array IS ARRAY (POSITIVE RANGE <>) OF INTEGER;	
	
	TYPE instct_name_array IS ARRAY (POSITIVE RANGE <>) OF STRING(1 to 4);
	TYPE instct_code_array IS ARRAY (POSITIVE RANGE <>) OF STD_LOGIC_VECTOR(7 downto 0);
	TYPE instct_size_array IS ARRAY (POSITIVE RANGE <>) OF INTEGER;
	
	TYPE variable_record IS RECORD
		name: string(1 to 10);
		namelength: integer;
		address: integer;
		datatype: integer; 
		size: integer;
		strvalue: string(1 to 30);
		strvaluelength: integer;
	END RECORD;
	
	TYPE variable_records IS ARRAY (POSITIVE RANGE <>) OF variable_record; 	
	
	TYPE label_record IS RECORD
		name: string(1 to 10);
		namelength: integer;
		address: integer;
		num_linea: integer;
	END RECORD;
	
	TYPE label_records IS ARRAY (POSITIVE RANGE <>) OF label_record;   
	
	TYPE offset_record IS RECORD
		name: string(1 to 10);
		namelength: integer;
		address: integer;
		num_linea: integer;
		isJmp: boolean;
	END RECORD;
	
	TYPE offset_records IS ARRAY (POSITIVE RANGE <>) OF offset_record; 
		 

END tipos_ensamblador;




PACKAGE BODY tipos_ensamblador is 
	

END tipos_ensamblador;


