
-- Entidad "registros":
-- Descripción: Aquí se definen tanto el banco de registros de propósito general de la 
-- CPU como los registros especiales para uso interno del procesador (Registro de 
-- Instrucción, Puntero de Instrucción, Registros de Banderas FLAGS y FPFLAGS para ALU y FPU
-- respectivamente, Punteros de Base y de Pila y Dirección de Retorno). Su tarea es leer o
-- escribir según corresponda un determinado valor desde o hacia uno de estos registros, 
-- cuyo número estará especificado por la etapa que desee realizar la operación. Si se
-- trata de una lectura, esta entidad transmitirá el valor leído hacia la etapa que lo 
-- haya solicitado. En cambio, en caso de una escritura será la etapa la que deberá enviar 
-- a la entidad el valor a escribir, además del número del registro en particular a 
-- actualizar. Cabe agregar que la única etapa que en ningún momento podría requerir 
-- acceder a esta estructura es "memory access", ya que incluso la etapa "execute" 
-- necesitaría actualizar el registro FLAGS o FPFLAGS en cada ejecución de la ALU o la FPU o 
-- bien el registro Puntero de Instrucción en caso de cumplirse la condición de un salto 
-- condicional.
-- Procesos:
-- U_Fetch_IP: Una vez recibida la señal de la unidad de búsqueda de la CPU (etapa "fetch"),
-- procede a leer el valor actual del Puntero de Instrucción para transmitírselo a la misma 
-- (recordar que el IP contiene la dirección de la próxima instrucción en la memoria de 
-- instrucciones de la PC). 
-- U_Fetch_IR: Una vez recibida la señal de la unidad de búsqueda de la CPU (etapa "fetch"),
-- procede a actualizar el Registro de Instrucción con el dato que ésta le indique, el cual 
-- corresponderá al código de operación de la instrucción a ser próximamente decodificado 
-- por la etapa "decode".
-- U_Control: Una vez recibida la señal de la unidad de control de la CPU (etapa "decode"),
-- procede a leer el valor actual del registro requerido y señalado por la misma para
-- transmitírselo. En una secuencia de decodificación normal de una instrucción, el 
-- primer paso sería solicitar el valor del Registro de Instrucción para obtener y
-- decodificar el código de operación de la instrucción, para luego proceder a requerir
-- el contenido de cada uno de los registros indicados en esta última para utilizarlo en 
-- las siguientes etapas de la misma. 
-- IP_Aux: Una vez recibida la señal de la unidad de búsqueda (etapa "fetch"), de control
-- (etapa "decode") o del administrador de la etapa de ejecución de la segmentación (etapa
-- "execute"), procede a actualizar el Puntero de Instrucción con el valor indicado por el
-- componente que haya impartido la orden. En un flujo de ejecución normal del programa,
-- sólo la unidad de búsqueda debería poder escribir el IP, mientras que los otros dos
-- módulos sólo	lo harían en caso de producirse algún salto debido a la existencia de
-- una instrucción de transferencia de control.
-- ALU_Read: Una vez recibida la señal de la ALU de la CPU (etapa "execute"), procede a 
-- leer el valor actual del registro de banderas FLAGS correspondiente a dicha unidad para 
-- transmitírselo. Normalmente dicho valor sólo será requerido para tomar alguna decisión
-- respecto a una instrucción condicional.
-- ALU_Write: Una vez recibida la señal de la ALU de la CPU (etapa "execute"), procede a 
-- actualizar el registro de banderas FLAGS correspondiente a dicha unidad con el valor 
-- indicado por la misma. Será necesario llevar a cabo esta acción en cada ejecución de 
-- esta ALU para mantener actualizado el estado de la última operación realizada sin 
-- importar su naturaleza particular.
-- FPU_Read: Una vez recibida la señal de la FPU de la CPU (último ciclo de reloj de la 
-- etapa "execute"), procede a leer el valor actual del registro de banderas FPFLAGS 
-- correspondiente a dicha unidad para transmitírselo. Normalmente dicho valor sólo será 
-- requerido para tomar alguna decisión respecto a una instrucción condicional.
-- FPU_Write: Una vez recibida la señal de la FPU de la CPU (último ciclo de reloj de la 
-- etapa "execute"), procede a actualizar el registro de banderas FPFLAGS correspondiente 
-- a dicha unidad con el valor indicado por la misma. Será necesario llevar a cabo esta 
-- acción en cada ejecución de esta FPU para mantener actualizado el estado de la última 
-- operación realizada sin importar su naturaleza particular.
-- Writeback: Una vez recibida la señal de la etapa "writeback", procede a actualizar
-- el registro indicado por la misma con el valor que ésta le envíe para escribir en
-- él. Esta acción podría ser necesaria, por ejemplo, para actualizar alguno de los 
-- registros de propósito general de la CPU en caso de que la instrucción actual así 
-- lo exigiera o bien para sobrescribir el Puntero de Pila si se tratara de una 
-- instrucción de manejo de la pila o la Dirección de Retorno si se estuviera 
-- invocando una subrutina.


library TDA_1819;    
use TDA_1819.const_memoria.all;
use TDA_1819.const_registros.all;

LIBRARY IEEE;
USE std.textio.all;
use ieee.NUMERIC_STD.all;
USE IEEE.std_logic_1164.all; 	  




entity registros is
	
	port (
		DataRegOutIF		: out std_logic_vector(31 downto 0);
		DataRegOutID		: out std_logic_vector(31 downto 0);
		DataRegOutEXALU		: out std_logic_vector(31 downto 0);
		DataRegOutEXFPU		: out std_logic_vector(31 downto 0);
		DataRegFP			: out std_logic_vector(31 downto 0);
		IdRegFP				: out std_logic_vector(7 downto 0);
		EnableRegFP			: out std_logic;
		DataRegInIF			: in  std_logic_vector(31 downto 0);
		DataRegInID			: in  std_logic_vector(31 downto 0);
		DataRegInEXALU		: in  std_logic_vector(31 downto 0);
		DataRegInEXFPU		: in  std_logic_vector(31 downto 0);
		DataRegInWB			: in  std_logic_vector(31 downto 0);
		IdRegID				: in  std_logic_vector(7 downto 0);
		IdRegWB				: in  std_logic_vector(7 downto 0);
		SizeRegID			: in  std_logic_vector(3 downto 0);
		SizeRegWB			: in  std_logic_vector(3 downto 0);
		EnableRegIFIPRd		: in  std_logic;
		EnableRegIFIRWr 	: in  std_logic;
		EnableRegIFIPWr		: in  std_logic;
		EnableRegID			: in  std_logic;
		EnableRegIDIP		: in  std_logic;
		EnableRegEXALURd	: in  std_logic;
		EnableRegEXFPURd	: in  std_logic;
		EnableRegEXALUWr	: in  std_logic;
		EnableRegEXFPUWr	: in  std_logic;
		EnableRegEXALUIP	: in  std_logic;
		EnableRegWB			: in  std_logic);

end registros;




architecture REGISTROS_ARCHITECTURE of registros is


	SIGNAL IR:			std_logic_vector(7 downto 0) := X"00";	
						-- IR = Instruction Register = Registro de Instrucción
	SIGNAL IP:        	std_logic_vector(15 downto 0) := X"2000";
						-- IP = Instruction Pointer = Puntero de Instrucción
	SIGNAL FLAGS:		std_logic_vector(7 downto 0) := "ZZZZZZZZ";
						-- FLAGS = Registro de Flags (Banderas)
	SIGNAL FPFLAGS:		std_logic_vector(7 downto 0) := "ZZZZZZZZ";
						-- FPFLAGS = Registro de Flags para Punto Flotante
	SIGNAL BP: 			std_logic_vector(31 downto 0) := X"0000" & std_logic_vector(to_unsigned(BASE_POINTER, 16));
						-- BP = Base Pointer = Puntero de Base (Pila)
    SIGNAL SP: 			std_logic_vector(31 downto 0) := X"0000" & std_logic_vector(to_unsigned(BASE_POINTER, 16));
						-- SP = Stack Pointer = Puntero de Pila
	SIGNAL RA: 			std_logic_vector(31 downto 0) := X"00000000";
						-- RA = Return Address = Dirección de Retorno (Subrutina)
	
	-- Registros de Uso General	por el Usuario 
	SIGNAL R0:			std_logic_vector(31 downto 0) := X"00000000";
	SIGNAL R1:			std_logic_vector(31 downto 0) := X"00000000";
	SIGNAL R2:			std_logic_vector(31 downto 0) := X"00000000";
	SIGNAL R3:			std_logic_vector(31 downto 0) := X"00000000";
	SIGNAL R4:			std_logic_vector(31 downto 0) := X"00000000";
	SIGNAL R5:			std_logic_vector(31 downto 0) := X"00000000";
	SIGNAL R6:			std_logic_vector(31 downto 0) := X"00000000";
	SIGNAL R7:			std_logic_vector(31 downto 0) := X"00000000";
	SIGNAL R8:			std_logic_vector(31 downto 0) := X"00000000";
	SIGNAL R9:			std_logic_vector(31 downto 0) := X"00000000";
	SIGNAL R10:			std_logic_vector(31 downto 0) := X"00000000";
	SIGNAL R11:			std_logic_vector(31 downto 0) := X"00000000";
	SIGNAL R12:			std_logic_vector(31 downto 0) := X"00000000";
	SIGNAL R13:			std_logic_vector(31 downto 0) := X"00000000";
	SIGNAL R14:			std_logic_vector(31 downto 0) := X"00000000";
	SIGNAL R15:			std_logic_vector(31 downto 0) := X"00000000"; 
	
	
	-- Registros de Uso General	por el Usuario (Punto Flotante) 
	SIGNAL F0:			std_logic_vector(31 downto 0) := X"00000000";
	SIGNAL F1:			std_logic_vector(31 downto 0) := X"00000000";
	SIGNAL F2:			std_logic_vector(31 downto 0) := X"00000000";
	SIGNAL F3:			std_logic_vector(31 downto 0) := X"00000000";
	SIGNAL F4:			std_logic_vector(31 downto 0) := X"00000000";
	SIGNAL F5:			std_logic_vector(31 downto 0) := X"00000000";
	SIGNAL F6:			std_logic_vector(31 downto 0) := X"00000000";
	SIGNAL F7:			std_logic_vector(31 downto 0) := X"00000000";
	SIGNAL F8:			std_logic_vector(31 downto 0) := X"00000000";
	SIGNAL F9:			std_logic_vector(31 downto 0) := X"00000000";
	SIGNAL F10:			std_logic_vector(31 downto 0) := X"00000000";
	SIGNAL F11:			std_logic_vector(31 downto 0) := X"00000000";
	SIGNAL F12:			std_logic_vector(31 downto 0) := X"00000000";
	SIGNAL F13:			std_logic_vector(31 downto 0) := X"00000000";
	SIGNAL F14:			std_logic_vector(31 downto 0) := X"00000000";
	SIGNAL F15:			std_logic_vector(31 downto 0) := X"00000000";

	
begin
	
		
	U_Fetch_IP: PROCESS
	
	BEGIN
		WAIT UNTIL rising_edge(EnableRegIFIPRd);
		DataRegOutIF(31 downto 16) <= "ZZZZZZZZZZZZZZZZ";
		DataRegOutIF(15 downto 0) <= IP;
	END PROCESS U_Fetch_IP;
	
	
	U_Fetch_IR: PROCESS
	
	BEGIN
		WAIT UNTIL rising_edge(EnableRegIFIRWr);
		IR <= DataRegInIF(7 downto 0);
	END PROCESS U_Fetch_IR;
	
	
	U_Control: PROCESS
	
	VARIABLE readSize: INTEGER;
	
	BEGIN
		WAIT UNTIL rising_edge(EnableRegID);
		readSize := to_integer(unsigned(SizeRegID))*8;
		for i in 31 downto readSize loop
			--DataRegOutID(i) <= 'Z';	
			DataRegOutID(i) <= '0';
		end loop;
		CASE to_integer(unsigned(IdRegID)) IS
			WHEN ID_R0 =>
				for i in readSize-1 downto 0 loop
					DataRegOutID(i) <= R0(i);
				end loop;
			WHEN ID_R1 =>
				for i in readSize-1 downto 0 loop
					DataRegOutID(i) <= R1(i);
				end loop;
			WHEN ID_R2 =>
				for i in readSize-1 downto 0 loop
					DataRegOutID(i) <= R2(i);
				end loop;
			WHEN ID_R3 =>
				for i in readSize-1 downto 0 loop
					DataRegOutID(i) <= R3(i);
				end loop;
			WHEN ID_R4 =>
				for i in readSize-1 downto 0 loop
					DataRegOutID(i) <= R4(i);
				end loop;
			WHEN ID_R5 =>
				for i in readSize-1 downto 0 loop
					DataRegOutID(i) <= R5(i);
				end loop;
			WHEN ID_R6 =>
				for i in readSize-1 downto 0 loop
					DataRegOutID(i) <= R6(i);
				end loop;
			WHEN ID_R7 =>
				for i in readSize-1 downto 0 loop
					DataRegOutID(i) <= R7(i);
				end loop;
			WHEN ID_R8 =>
				for i in readSize-1 downto 0 loop
					DataRegOutID(i) <= R8(i);
				end loop;
			WHEN ID_R9 =>
				for i in readSize-1 downto 0 loop
					DataRegOutID(i) <= R9(i);
				end loop;
			WHEN ID_R10 =>
				for i in readSize-1 downto 0 loop
					DataRegOutID(i) <= R10(i);
				end loop;
			WHEN ID_R11 =>
				for i in readSize-1 downto 0 loop
					DataRegOutID(i) <= R11(i);
				end loop;
			WHEN ID_R12 =>
				for i in readSize-1 downto 0 loop
					DataRegOutID(i) <= R12(i);
				end loop;
			WHEN ID_R13 =>
				for i in readSize-1 downto 0 loop
					DataRegOutID(i) <= R13(i);
				end loop;
			WHEN ID_R14 =>
				for i in readSize-1 downto 0 loop
					DataRegOutID(i) <= R14(i);
				end loop;
			WHEN ID_R15 =>
				for i in readSize-1 downto 0 loop
					DataRegOutID(i) <= R15(i);
				end loop; 
			WHEN ID_F0 =>
				for i in readSize-1 downto 0 loop
					DataRegOutID(i) <= F0(i);
				end loop;
			WHEN ID_F1 =>
				for i in readSize-1 downto 0 loop
					DataRegOutID(i) <= F1(i);
				end loop;
			WHEN ID_F2 =>
				for i in readSize-1 downto 0 loop
					DataRegOutID(i) <= F2(i);
				end loop;
			WHEN ID_F3 =>
				for i in readSize-1 downto 0 loop
					DataRegOutID(i) <= F3(i);
				end loop;
			WHEN ID_F4 =>
				for i in readSize-1 downto 0 loop
					DataRegOutID(i) <= F4(i);
				end loop;
			WHEN ID_F5 =>
				for i in readSize-1 downto 0 loop
					DataRegOutID(i) <= F5(i);
				end loop;
			WHEN ID_F6 =>
				for i in readSize-1 downto 0 loop
					DataRegOutID(i) <= F6(i);
				end loop;
			WHEN ID_F7 =>
				for i in readSize-1 downto 0 loop
					DataRegOutID(i) <= F7(i);
				end loop;
			WHEN ID_F8 =>
				for i in readSize-1 downto 0 loop
					DataRegOutID(i) <= F8(i);
				end loop;
			WHEN ID_F9 =>
				for i in readSize-1 downto 0 loop
					DataRegOutID(i) <= F9(i);
				end loop;
			WHEN ID_F10 =>
				for i in readSize-1 downto 0 loop
					DataRegOutID(i) <= F10(i);
				end loop;
			WHEN ID_F11 =>
				for i in readSize-1 downto 0 loop
					DataRegOutID(i) <= F11(i);
				end loop;
			WHEN ID_F12 =>
				for i in readSize-1 downto 0 loop
					DataRegOutID(i) <= F12(i);
				end loop;
			WHEN ID_F13 =>
				for i in readSize-1 downto 0 loop
					DataRegOutID(i) <= F13(i);
				end loop;
			WHEN ID_F14 =>
				for i in readSize-1 downto 0 loop
					DataRegOutID(i) <= F14(i);
				end loop;
			WHEN ID_F15 =>
				for i in readSize-1 downto 0 loop
					DataRegOutID(i) <= F15(i);
				end loop;
			WHEN ID_IR =>
				for i in readSize-1 downto 0 loop
					DataRegOutID(i) <= IR(i);
				end loop;
			WHEN ID_IP =>
				for i in readSize-1 downto 0 loop
					DataRegOutID(i) <= IP(i);
				end loop;
			WHEN ID_FLAGS =>
				for i in readSize-1 downto 0 loop
					DataRegOutID(i) <= FLAGS(i);
				end loop; 
			WHEN ID_FPFLAGS =>
				for i in readSize-1 downto 0 loop
					DataRegOutID(i) <= FPFLAGS(i);
				end loop;
			WHEN ID_BP =>
				for i in readSize-1 downto 0 loop
					DataRegOutID(i) <= BP(i);
				end loop;
			WHEN ID_SP =>
				for i in readSize-1 downto 0 loop
					DataRegOutID(i) <= SP(i);
				end loop;
			WHEN ID_RA =>
				for i in readSize-1 downto 0 loop
					DataRegOutID(i) <= RA(i);
				end loop;
			WHEN OTHERS =>
				NULL;
		END CASE;
	END PROCESS U_Control;
	
	
	IP_Aux: PROCESS
	
	BEGIN	
		WAIT UNTIL (rising_edge(EnableRegIFIPWr) or rising_edge(EnableRegIDIP) or rising_edge(EnableRegEXALUIP));
		if (EnableRegIFIPWr = '1') then
			IP <= DataRegInIF(15 downto 0);
		elsif (EnableRegIDIP = '1') then
			IP <= DataRegInID(15 downto 0);
			WAIT FOR 15 ns;
		else
			IP <= DataRegInEXALU(15 downto 0);
			--WAIT FOR 10 ns;
		end if;	
	END PROCESS IP_Aux;
	
	
	ALU_Read: PROCESS
	
	BEGIN
		WAIT UNTIL rising_edge(EnableRegEXALURd);
		DataRegOutEXALU(7 downto 0) <= FLAGS;
	END PROCESS ALU_Read;
	
	
	ALU_Write: PROCESS
	
	BEGIN
		WAIT UNTIL rising_edge(EnableRegEXALUWr);
		FLAGS <= DataRegInEXALU(7 downto 0);	
	END PROCESS ALU_Write;
	
	
	FPU_Read: PROCESS
	
	BEGIN
		WAIT UNTIL rising_edge(EnableRegEXFPURd);
		DataRegOutEXFPU(7 downto 0) <= FPFLAGS;
	END PROCESS FPU_Read;
	
	
	FPU_Write: PROCESS
	
	BEGIN
		WAIT UNTIL rising_edge(EnableRegEXFPUWr);
		FPFLAGS <= DataRegInEXFPU(7 downto 0);
	END PROCESS FPU_Write;
	
	
	Writeback: PROCESS
	
	VARIABLE First: BOOLEAN := true; 
	VARIABLE writeSize: INTEGER;
	
	BEGIN
		if (First) then
			First := false;
			EnableRegFP <= '0';
			WAIT FOR 1 ns;
		end if;
		WAIT UNTIL rising_edge(EnableRegWB);
		writeSize := to_integer(unsigned(SizeRegWB))*8;
		CASE to_integer(unsigned(IdRegWB)) IS
			WHEN ID_R0 =>
				for i in 31 downto writeSize loop
					--R0(i) <= 'Z';
					R0(i) <= '0';
				end loop;
				for i in writeSize-1 downto 0 loop
					R0(i) <= DataRegInWB(i);
				end loop;
			WHEN ID_R1 =>
				for i in 31 downto writeSize loop
					--R1(i) <= 'Z';
					R1(i) <= '0';
				end loop;
				for i in writeSize-1 downto 0 loop
					R1(i) <= DataRegInWB(i);
				end loop;
			WHEN ID_R2 =>
				for i in 31 downto writeSize loop
					--R2(i) <= 'Z';
					R2(i) <= '0';
				end loop;
				for i in writeSize-1 downto 0 loop
					R2(i) <= DataRegInWB(i);
				end loop;
			WHEN ID_R3 =>
				for i in 31 downto writeSize loop
					--R3(i) <= 'Z';
					R3(i) <= '0';
				end loop;
				for i in writeSize-1 downto 0 loop
					R3(i) <= DataRegInWB(i);
				end loop;
			WHEN ID_R4 =>
				for i in 31 downto writeSize loop
					--R4(i) <= 'Z';
					R4(i) <= '0';
				end loop;
				for i in writeSize-1 downto 0 loop
					R4(i) <= DataRegInWB(i);
				end loop;
			WHEN ID_R5 =>
				for i in 31 downto writeSize loop
					--R5(i) <= 'Z';
					R5(i) <= '0';
				end loop;
				for i in writeSize-1 downto 0 loop
					R5(i) <= DataRegInWB(i);
				end loop;
			WHEN ID_R6 =>
				for i in 31 downto writeSize loop
					--R6(i) <= 'Z';
					R6(i) <= '0';
				end loop;
				for i in writeSize-1 downto 0 loop
					R6(i) <= DataRegInWB(i);
				end loop;
			WHEN ID_R7 =>
				for i in 31 downto writeSize loop
					--R7(i) <= 'Z';
					R7(i) <= '0';
				end loop;
				for i in writeSize-1 downto 0 loop
					R7(i) <= DataRegInWB(i);
				end loop;
			WHEN ID_R8 =>
				for i in 31 downto writeSize loop
					--R8(i) <= 'Z';
					R8(i) <= '0';
				end loop;
				for i in writeSize-1 downto 0 loop
					R8(i) <= DataRegInWB(i);
				end loop;
			WHEN ID_R9 =>
				for i in 31 downto writeSize loop
					--R9(i) <= 'Z';
					R9(i) <= '0';
				end loop;
				for i in writeSize-1 downto 0 loop
					R9(i) <= DataRegInWB(i);
				end loop;
			WHEN ID_R10 =>
				for i in 31 downto writeSize loop
					--R10(i) <= 'Z';
					R10(i) <= '0';
				end loop;
				for i in writeSize-1 downto 0 loop
					R10(i) <= DataRegInWB(i);
				end loop;
			WHEN ID_R11 =>
				for i in 31 downto writeSize loop
					--R11(i) <= 'Z';
					R11(i) <= '0';
				end loop;
				for i in writeSize-1 downto 0 loop
					R11(i) <= DataRegInWB(i);
				end loop;
			WHEN ID_R12 =>
				for i in 31 downto writeSize loop
					--R12(i) <= 'Z';
					R12(i) <= '0';
				end loop;
				for i in writeSize-1 downto 0 loop
					R12(i) <= DataRegInWB(i);
				end loop;
			WHEN ID_R13 =>
				for i in 31 downto writeSize loop
					--R13(i) <= 'Z';
					R13(i) <= '0';
				end loop;
				for i in writeSize-1 downto 0 loop
					R13(i) <= DataRegInWB(i);
				end loop;
			WHEN ID_R14 =>
				for i in 31 downto writeSize loop
					--R14(i) <= 'Z';
					R14(i) <= '0';
				end loop;
				for i in writeSize-1 downto 0 loop
					R14(i) <= DataRegInWB(i);
				end loop;
			WHEN ID_R15 =>
				for i in 31 downto writeSize loop
					--R15(i) <= 'Z';
					R15(i) <= '0';
				end loop;
				for i in writeSize-1 downto 0 loop
					R15(i) <= DataRegInWB(i);
				end loop;  
			WHEN ID_F0 =>
				for i in 31 downto writeSize loop
					--F0(i) <= 'Z';
					F0(i) <= '0';
				end loop;
				for i in writeSize-1 downto 0 loop
					F0(i) <= DataRegInWB(i);
				end loop;
				DataRegFP <= DataRegInWB;
				IdRegFP <= IdRegWB;
				EnableRegFP <= '1';
				WAIT FOR 1 ns;
				EnableRegFP <= '0';
				WAIT FOR 1 ns;
			WHEN ID_F1 =>
				for i in 31 downto writeSize loop
					--F1(i) <= 'Z';
					F1(i) <= '0';
				end loop;
				for i in writeSize-1 downto 0 loop
					F1(i) <= DataRegInWB(i);
				end loop;
				DataRegFP <= DataRegInWB;
				IdRegFP <= IdRegWB;
				EnableRegFP <= '1';
				WAIT FOR 1 ns;
				EnableRegFP <= '0';
				WAIT FOR 1 ns;
			WHEN ID_F2 =>
				for i in 31 downto writeSize loop
					--F2(i) <= 'Z';
					F2(i) <= '0';
				end loop;
				for i in writeSize-1 downto 0 loop
					F2(i) <= DataRegInWB(i);
				end loop;
				DataRegFP <= DataRegInWB;
				IdRegFP <= IdRegWB;
				EnableRegFP <= '1';
				WAIT FOR 1 ns;
				EnableRegFP <= '0';
				WAIT FOR 1 ns;
			WHEN ID_F3 =>
				for i in 31 downto writeSize loop
					--F3(i) <= 'Z';
					F3(i) <= '0';
				end loop;
				for i in writeSize-1 downto 0 loop
					F3(i) <= DataRegInWB(i);
				end loop;
				DataRegFP <= DataRegInWB;
				IdRegFP <= IdRegWB;
				EnableRegFP <= '1';
				WAIT FOR 1 ns;
				EnableRegFP <= '0';
				WAIT FOR 1 ns;
			WHEN ID_F4 =>
				for i in 31 downto writeSize loop
					--F4(i) <= 'Z';
					F4(i) <= '0';
				end loop;
				for i in writeSize-1 downto 0 loop
					F4(i) <= DataRegInWB(i);
				end loop;
				DataRegFP <= DataRegInWB;
				IdRegFP <= IdRegWB;
				EnableRegFP <= '1';
				WAIT FOR 1 ns;
				EnableRegFP <= '0';
				WAIT FOR 1 ns;
			WHEN ID_F5 =>
				for i in 31 downto writeSize loop
					--F5(i) <= 'Z';
					F5(i) <= '0';
				end loop;
				for i in writeSize-1 downto 0 loop
					F5(i) <= DataRegInWB(i);
				end loop; 
				DataRegFP <= DataRegInWB;
				IdRegFP <= IdRegWB;
				EnableRegFP <= '1';
				WAIT FOR 1 ns;
				EnableRegFP <= '0';
				WAIT FOR 1 ns;
			WHEN ID_F6 =>
				for i in 31 downto writeSize loop
					--F6(i) <= 'Z';
					F6(i) <= '0';
				end loop;
				for i in writeSize-1 downto 0 loop
					F6(i) <= DataRegInWB(i);
				end loop;
				DataRegFP <= DataRegInWB;
				IdRegFP <= IdRegWB;
				EnableRegFP <= '1';
				WAIT FOR 1 ns;
				EnableRegFP <= '0';
				WAIT FOR 1 ns;
			WHEN ID_F7 =>
				for i in 31 downto writeSize loop
					--F7(i) <= 'Z';
					F7(i) <= '0';
				end loop;
				for i in writeSize-1 downto 0 loop
					F7(i) <= DataRegInWB(i);
				end loop;	
				DataRegFP <= DataRegInWB;
				IdRegFP <= IdRegWB;
				EnableRegFP <= '1';
				WAIT FOR 1 ns;
				EnableRegFP <= '0';
				WAIT FOR 1 ns;
			WHEN ID_F8 =>
				for i in 31 downto writeSize loop
					--F8(i) <= 'Z';
					F8(i) <= '0';
				end loop;
				for i in writeSize-1 downto 0 loop
					F8(i) <= DataRegInWB(i);
				end loop;
				DataRegFP <= DataRegInWB;
				IdRegFP <= IdRegWB;
				EnableRegFP <= '1';
				WAIT FOR 1 ns;
				EnableRegFP <= '0';
				WAIT FOR 1 ns;
			WHEN ID_F9 =>
				for i in 31 downto writeSize loop
					--F9(i) <= 'Z';
					F9(i) <= '0';
				end loop;
				for i in writeSize-1 downto 0 loop
					F9(i) <= DataRegInWB(i);
				end loop;
				DataRegFP <= DataRegInWB;
				IdRegFP <= IdRegWB;
				EnableRegFP <= '1';
				WAIT FOR 1 ns;
				EnableRegFP <= '0';
				WAIT FOR 1 ns;
			WHEN ID_F10 =>
				for i in 31 downto writeSize loop
					--F10(i) <= 'Z';
					F10(i) <= '0';
				end loop;
				for i in writeSize-1 downto 0 loop
					F10(i) <= DataRegInWB(i);
				end loop;
				DataRegFP <= DataRegInWB;
				IdRegFP <= IdRegWB;
				EnableRegFP <= '1';
				WAIT FOR 1 ns;
				EnableRegFP <= '0';
				WAIT FOR 1 ns;
			WHEN ID_F11 =>
				for i in 31 downto writeSize loop
					--F11(i) <= 'Z';
					F11(i) <= '0';
				end loop;
				for i in writeSize-1 downto 0 loop
					F11(i) <= DataRegInWB(i);
				end loop;
				DataRegFP <= DataRegInWB;
				IdRegFP <= IdRegWB;
				EnableRegFP <= '1';
				WAIT FOR 1 ns;
				EnableRegFP <= '0';
				WAIT FOR 1 ns;
			WHEN ID_F12 =>
				for i in 31 downto writeSize loop
					--F12(i) <= 'Z';
					F12(i) <= '0';
				end loop;
				for i in writeSize-1 downto 0 loop
					F12(i) <= DataRegInWB(i);
				end loop;
				DataRegFP <= DataRegInWB;
				IdRegFP <= IdRegWB;
				EnableRegFP <= '1';
				WAIT FOR 1 ns;
				EnableRegFP <= '0';
				WAIT FOR 1 ns;
			WHEN ID_F13 =>
				for i in 31 downto writeSize loop
					--F13(i) <= 'Z';
					F13(i) <= '0';
				end loop;
				for i in writeSize-1 downto 0 loop
					F13(i) <= DataRegInWB(i);
				end loop;
				DataRegFP <= DataRegInWB;
				IdRegFP <= IdRegWB;
				EnableRegFP <= '1';
				WAIT FOR 1 ns;
				EnableRegFP <= '0';
				WAIT FOR 1 ns;
			WHEN ID_F14 =>
				for i in 31 downto writeSize loop
					--F14(i) <= 'Z';
					F14(i) <= '0';
				end loop;
				for i in writeSize-1 downto 0 loop
					F14(i) <= DataRegInWB(i);
				end loop;
				DataRegFP <= DataRegInWB;
				IdRegFP <= IdRegWB;
				EnableRegFP <= '1';
				WAIT FOR 1 ns;
				EnableRegFP <= '0';
				WAIT FOR 1 ns;
			WHEN ID_F15 =>
				for i in 31 downto writeSize loop
					--F15(i) <= 'Z';
					F15(i) <= '0';
				end loop;
				for i in writeSize-1 downto 0 loop
					F15(i) <= DataRegInWB(i);
				end loop;
				DataRegFP <= DataRegInWB;
				IdRegFP <= IdRegWB;
				EnableRegFP <= '1';
				WAIT FOR 1 ns;
				EnableRegFP <= '0';
				WAIT FOR 1 ns;
			WHEN ID_BP =>
				for i in 31 downto writeSize loop
					BP(i) <= 'Z';
				end loop;
				for i in writeSize-1 downto 0 loop
					BP(i) <= DataRegInWB(i);
				end loop;
			WHEN ID_SP =>
				for i in 31 downto writeSize loop
					SP(i) <= 'Z';
				end loop;
				for i in writeSize-1 downto 0 loop
					SP(i) <= DataRegInWB(i);
				end loop;
			WHEN ID_RA =>
				for i in 31 downto writeSize loop
					RA(i) <= 'Z';
				end loop;
				for i in writeSize-1 downto 0 loop
					RA(i) <= DataRegInWB(i);
				end loop;
			WHEN OTHERS =>
				NULL;
		END CASE;
	END PROCESS Writeback;
		
	
end REGISTROS_ARCHITECTURE;





