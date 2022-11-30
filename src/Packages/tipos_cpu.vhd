
-- Paquete "tipos_cpu":	
-- Descripción: Aquí se definen las estructuras de los registros utilizados por
-- los distintos componentes de la CPU (máquina de estados, unidad de control, 
-- ALU, etapas "memory access" y "writeback", etc.) para almacenar, transmitir y 
-- procesar toda la información necesaria para el correcto desempeño de sus 
-- correspondientes tareas. También se incluye la declaración de un tipo de 
-- datos enumerativo que lista taxativamente todos los valores (estados) 
-- posibles que puede adoptar la máquina de estados de la CPU.


LIBRARY IEEE;

USE std.textio.all;
USE IEEE.std_logic_1164.all; 


PACKAGE tipos_cpu is  
	
	
	TYPE state_branch IS RECORD
		branch_taken: std_logic;
		enable: std_logic;
	END RECORD;
	
	TYPE state_comp IS RECORD
		num_linea: INTEGER;
		name_inst: STRING(1 to 6);
		num_linea_branch_taken_ID: INTEGER; 
		num_linea_branch_taken_EX: INTEGER;
	END RECORD;
	
	TYPE state_values IS (B, 
						  F_STR, F_RAW, F_WAW, F_END, F, 
						  D_HLT, D_STR, D_RAW, D_WAW, D_BRX, D_END, D, 
						  X_STR, X_WAW, X_FP1_STR, X_FP1_WAW, X_FP1, X_FP2_STR, X_FP2_WAW, X_FP2, X_FP3_STR, X_FP3_WAW, X_FP3, X_FP4_STR, X_FP4_WAW, X_FP4, X_END, X, 
						  M_STR, M_WAW, M_END, M, 
						  W_STR, W_WAW, W_END, W, 
						  E);
	
	TYPE state_detail IS RECORD
		num_linea: INTEGER;
		name_inst: STRING(1 to 6);
		num_inst: INTEGER; 
		num_linea_branch_taken_ID: INTEGER;
		num_linea_branch_taken_EX: INTEGER;
	END RECORD;
		
	TYPE state_record IS RECORD
		id: INTEGER;
		state: state_values;
		detail: state_detail;
	END RECORD;	
	
	TYPE state_records IS ARRAY (POSITIVE RANGE <>) OF state_record;
	
	TYPE decode_record IS RECORD 
		package1: std_logic_vector(31 downto 0);
		package2: std_logic_vector(31 downto 0);
	END RECORD;
	
	TYPE execute_record IS RECORD
		empty: std_logic;
		op: std_logic_vector(7 downto 0);
		fp: std_logic;
		sign: std_logic;
		op1: std_logic_vector(31 downto 0);
		op2: std_logic_vector(31 downto 0);
		address: std_logic_vector(15 downto 0);
	END RECORD;
	
	TYPE memaccess_data IS RECORD
		decode: std_logic_vector(31 downto 0);
		execute: std_logic_vector(31 downto 0);
	END RECORD;
	
	TYPE memaccess_record IS RECORD
		mode: std_logic_vector(7 downto 0);
		read: std_logic;
		write: std_logic;
		datasize: std_logic_vector(3 downto 0);
		source: std_logic_vector(3 downto 0);
		address: std_logic_vector(15 downto 0);
		data: memaccess_data;
	END RECORD;	
	
	TYPE writeback_data	IS RECORD
		decode: std_logic_vector(31 downto 0);
		execute: std_logic_vector(31 downto 0);
		memaccess: std_logic_vector(31 downto 0);
	END RECORD;
	
	TYPE writeback_record IS RECORD
		mode: std_logic_vector(7 downto 0);
		id: std_logic_vector(7 downto 0);
		datasize: std_logic_vector(3 downto 0);
		source: std_logic_vector(3 downto 0);
		data: writeback_data;
	END RECORD;
	
	TYPE execute_records IS ARRAY (NATURAL RANGE <>) OF execute_record;
	
	TYPE memaccess_records IS ARRAY (NATURAL RANGE <>) OF memaccess_record;
	
	TYPE writeback_records IS ARRAY (NATURAL RANGE <>) OF writeback_record;	
	
	TYPE idwrpending_records IS ARRAY (NATURAL RANGE <>) OF std_logic_vector(7 downto 0);
	
	 
END tipos_cpu;




PACKAGE BODY tipos_cpu is 
	

END tipos_cpu;


