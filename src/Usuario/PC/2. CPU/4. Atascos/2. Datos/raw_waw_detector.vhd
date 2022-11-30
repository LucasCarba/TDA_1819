
-- Entidad "raw_waw_detector":
-- Descripción: Aquí se define el detector para posibles atascos por dependencias
-- de datos, ya sea debido a que una instrucción necesita leer un dato del banco de registros
-- de propósito general antes de que otra anterior a ella haya logrado escribirlo en él (RAW, 
-- dependencia verdadera) o bien porque una instrucción requiere escribir un dato en uno de
-- los registros de próposito general antes de que otra anterior a ella haya podido escribir
-- su propio dato en él, por lo que dicho registro terminaría conteniendo el valor de la 
-- instrucción anterior en lugar de la actual (WAW, dependencia de salida). Por lo tanto, la
-- tarea de este detector es analizar si efectivamente existen dichas dependencias a partir 
-- de información proporcionada por el administrador de la etapa de ejecución de la 
-- segmentación, la etapa "decode" (unidad de control de la CPU) y la etapa "writeback". En 
-- caso afirmativo, transmitirá la correspondiente señal a todas las etapas del pipeline que 
-- la necesiten para detener temporalmente su ejecución hasta que la dependencia sea 
-- resuelta.
-- Procesos:
-- Main: Puede realizar varias tareas simultáneamente, en función de la señal recibida y de
-- la etapa que la transmita:
-- "Decode": número de registro de propósito general pendiente de escribir en la etapa
-- "writeback" de la ejecución actual (este proceso incrementará la cantidad de escrituras
-- pendientes para este registro); escritura pendiente en el registro FLAGS de la ALU especial
-- para punto flotante (este proceso incrementará la cantidad de escrituras pendientes para 
-- este registro) y/o número de registro de propósito general a leer en esta etapa cuyo valor
-- será utilizado en las etapas siguientes del pipeline (este proceso verificará si existen
-- escrituras pendientes en él, en caso afirmativo existirá una dependencia de datos de tipo
-- RAW, cuyo respectivo atasco deberá ser reportado a todas las etapas afectadas del pipeline
-- para que detengan su ejecución hasta que la dependencia se resuelva).
-- "Execute" (administrador de la etapa de ejecución): acción de escritura en el registro
-- FLAGS de la ALU especial para punto flotante (este proceso decrementará la cantidad de
-- escrituras pendientes para este registro y, en caso de existir un atasco RAW debido a un
-- conflicto por este registro y sólo en caso de corresponder hacerlo, determinará la 
-- finalización de dicho atasco para que todas las etapas del pipeline afectadas puedan
-- reanudar su ejecución).
-- "Writeback": número de registro de propósito general a escribir en esta etapa. En primer
-- lugar, este proceso verifica si existen escrituras pendientes en él por parte de 
-- instrucciones anteriores, en caso afirmativo existirá una dependencia de datos de tipo WAW, 
-- cuyo respectivo atasco deberá ser reportado a todas las etapas afectadas del pipeline para 
-- que detengan su ejecución hasta que la dependencia sea resuelta. Luego, si no fue detectada
-- ninguna dependencia, decrementará la cantidad de escrituras pendientes para dicho registro
-- y, en caso de existir un atasco RAW y/o WAW debido a un conflicto por este registro y sólo
-- en caso de corresponder hacerlo, determinará la finalización de dicho atasco para que 
-- todas las etapas del pipeline afectadas puedan reanudar su ejecución.
-- SetStallWAWAux: Este proceso se ejecuta únicamente cuando se detecta una dependencia de 
-- datos de tipo WAW y activa una señal auxiliar que permanecerá en este estado hasta que el
-- atasco se resuelva. Esta señal es necesaria para notificar a todas las etapas del pipeline
-- afectadas a fin de que detengan temporalmente su ejecución. En cambio, la señal de atasco
-- WAW original solamente permanecerá activa el tiempo necesario para cancelar la ejecución
-- de la etapa "writeback" de la instrucción responsable de provocar dicho atasco.
-- Procedimientos y funciones: 
-- InitializeWbRegWAW(): En caso de producirse un atasco de tipo WAW, la ejecución actual de
-- la etapa "writeback" deberá ser cancelada, por lo cual toda la información utilizada por
-- ella para cumplir su tarea (número de registro a escribir, tamaño y fuente del dato, el 
-- valor propiamente dicho, etc.) debería ser preservada en una señal auxiliar para que
-- no se pierda cuando dicha etapa vuelva a ser ejecutada para completar la siguiente 
-- instrucción, ya que la información deberá ser necesaria para el momento en el cual la
-- dependencia se resuelva y la ejecución cancelada deba repetirse, esta vez sin 
-- interrupciones hasta el final. Este detector incluye la mencionada señal auxiliar como una 
-- señal interna para transmitir su contenido a la etapa "writeback" cuando sea necesario. Por
-- su parte, este procedimiento se encarga de inicializar esta señal con valores nulos a la
-- espera de que ocurra un atasco WAW que la cargue con datos válidos provenientes de la etapa
-- "writeback" cuya ejecución debió ser cancelada.
-- CheckRAW(): Verifica si el registro a leer a continuación por la instrucción actual en la 
-- etapa "decode" todavía posee en este momento escrituras pendientes por parte de instrucciones 
-- anteriores. En caso afirmativo, informará la existencia de una dependencia de datos de tipo 
-- RAW a todas las etapas del pipeline afectadas para que detengan temporalmente su ejecución 
-- hasta que el atasco sea resuelto.
-- IncWrPending(): Incrementa en uno la cantidad de escrituras pendientes para el registro de 
-- propósito general de la CPU que será actualizado próximamente durante la ejecución de la 
-- etapa "writeback" de la instrucción actual. El número del registro a escribir es obtenido
-- a partir de información recibida de la etapa "decode".
-- IncFPWrPending(): Incrementa en uno la cantidad de escrituras pendientes para el registro
-- FLAGS correspondiente a la ALU especial para punto flotante, el cual será actualizado
-- próximamente durante el último ciclo de reloj de la ejecución de la etapa "execute" de la
-- instrucción actual.
-- CheckWAW(): Verifica si el próximo registro a actualizar por la instrucción actual en la
-- etapa "writeback" todavía posee en este momento escrituras pendientes por parte de
-- instrucciones anteriores. En caso afirmativo, informará la existencia de una dependencia de
-- datos de tipo WAW a todas las etapas del pipeline afectadas para que detengan temporalmente
-- su ejecución hasta que el atasco sea resuelto.
-- DecWrPending(): Decrementa en uno la cantidad de escrituras pendientes para el registro de
-- propósito general de la CPU que será actualizado a continuación durante la ejecución de
-- la etapa "writeback" de la instrucción actual. El número del registro a escribir es 
-- obtenido a partir de información recibida de la etapa "writeback". Este proceso también
-- verifica la existencia de dependencias RAW y/o WAW detectadas previamente y aún no 
-- resueltas y, en caso afirmativo, si el registro en conflicto llegara a ser precisamente el 
-- mismo que será escrito en este ciclo de reloj y sólo si no hubiera otras escrituras 
-- pendientes para el mismo por parte de instrucciones anteriores a aquélla que provocó el 
-- atasco, determinará la finalización de este último para que todas las etapas del pipeline 
-- afectadas puedan reanudar su ejecución.
-- DecFPWrPending(): Decrementa en uno la cantidad de escrituras pendientes para el registro
-- FLAGS correspondiente a la ALU especial para punto flotante, el cual será actualizado 
-- a continuación durante el último ciclo de reloj de la ejecución de la etapa "execute" de la
-- instrucción actual. Este proceso también verifica la existencia de dependencias RAW 
-- detectadas previamente y aún no resueltas y, en caso afirmativo, si el registro en 
-- conflicto llegara a ser precisamente este registro FLAGS en particular y sólo si no hubiera
-- otras escrituras pendientes para el mismo por parte de instrucciones anteriores a aquélla
-- que provocó el atasco, determinará la finalización de este último para que todas las etapas
-- del pipeline afectadas puedan reanudar su ejecución.


library TDA_1819; 
use TDA_1819.const_registros.all;
use TDA_1819.const_cpu.all; 
use TDA_1819.tipos_cpu.all;

LIBRARY IEEE;

USE std.textio.all;
use ieee.NUMERIC_STD.all;
USE IEEE.std_logic_1164.all; 




entity raw_waw_detector is
	
	generic (
		Pipelining	: BOOLEAN);
	
	port ( 
		WbRegDoneWAW		: out 	writeback_record;
		StallWAWAux			: out 	std_logic;
		DoneWAW				: inout	std_logic;
		StallWAW			: inout std_logic;
		StallRAW			: inout std_logic;
		IdRegID				: in    std_logic_vector(7 downto 0);
		IdInstIncWrPend		: in	std_logic_vector(7 downto 0);
		IdRegIncWrPend		: in    std_logic_vector(7 downto 0);
		WbRegCheckWAW		: in	writeback_record;
		IdRegDecWrPend		: in    std_logic_vector(7 downto 0);
		EnableRegID			: in    std_logic;
		EnableIncWrPend		: in    std_logic;
		EnableIncFPWrPend	: in    std_logic;
		EnableCheckWAW		: in 	std_logic;
		EnableDecWrPend		: in    std_logic;
		EnableDecFPWrPend	: in	std_logic);

end raw_waw_detector;




architecture RAW_WAW_DETECTOR_ARCHITECTURE of raw_waw_detector is


	SIGNAL IdRegRAW:			std_logic_vector(7 downto 0);
	SIGNAL WbRegWAW:			writeback_record;
	SIGNAL F0_IdWrPending:		idwrpending_records(1 to CANT_MAX_INST_WRPEND);
	SIGNAL F1_IdWrPending:		idwrpending_records(1 to CANT_MAX_INST_WRPEND);
	SIGNAL F2_IdWrPending:		idwrpending_records(1 to CANT_MAX_INST_WRPEND);
	SIGNAL F3_IdWrPending:		idwrpending_records(1 to CANT_MAX_INST_WRPEND);
	SIGNAL F4_IdWrPending:		idwrpending_records(1 to CANT_MAX_INST_WRPEND);
	SIGNAL F5_IdWrPending:		idwrpending_records(1 to CANT_MAX_INST_WRPEND);
	SIGNAL F6_IdWrPending:		idwrpending_records(1 to CANT_MAX_INST_WRPEND);
	SIGNAL F7_IdWrPending:		idwrpending_records(1 to CANT_MAX_INST_WRPEND);
	SIGNAL F8_IdWrPending:		idwrpending_records(1 to CANT_MAX_INST_WRPEND);
	SIGNAL F9_IdWrPending:		idwrpending_records(1 to CANT_MAX_INST_WRPEND);
	SIGNAL F10_IdWrPending:		idwrpending_records(1 to CANT_MAX_INST_WRPEND);
	SIGNAL F11_IdWrPending:		idwrpending_records(1 to CANT_MAX_INST_WRPEND);
	SIGNAL F12_IdWrPending:		idwrpending_records(1 to CANT_MAX_INST_WRPEND);
	SIGNAL F13_IdWrPending:		idwrpending_records(1 to CANT_MAX_INST_WRPEND);
	SIGNAL F14_IdWrPending:		idwrpending_records(1 to CANT_MAX_INST_WRPEND);
	SIGNAL F15_IdWrPending:		idwrpending_records(1 to CANT_MAX_INST_WRPEND);
	SIGNAL R0_WrPending:		UNSIGNED(3 downto 0) := B"0000";
	SIGNAL R1_WrPending:		UNSIGNED(3 downto 0) := B"0000";
	SIGNAL R2_WrPending:		UNSIGNED(3 downto 0) := B"0000";
	SIGNAL R3_WrPending:		UNSIGNED(3 downto 0) := B"0000";
	SIGNAL R4_WrPending:		UNSIGNED(3 downto 0) := B"0000";
	SIGNAL R5_WrPending:		UNSIGNED(3 downto 0) := B"0000";
	SIGNAL R6_WrPending:		UNSIGNED(3 downto 0) := B"0000";
	SIGNAL R7_WrPending:		UNSIGNED(3 downto 0) := B"0000";
	SIGNAL R8_WrPending:		UNSIGNED(3 downto 0) := B"0000";
	SIGNAL R9_WrPending:		UNSIGNED(3 downto 0) := B"0000";
	SIGNAL R10_WrPending:		UNSIGNED(3 downto 0) := B"0000";
	SIGNAL R11_WrPending:		UNSIGNED(3 downto 0) := B"0000";
	SIGNAL R12_WrPending:		UNSIGNED(3 downto 0) := B"0000";
	SIGNAL R13_WrPending:		UNSIGNED(3 downto 0) := B"0000";
	SIGNAL R14_WrPending:		UNSIGNED(3 downto 0) := B"0000";
	SIGNAL R15_WrPending:		UNSIGNED(3 downto 0) := B"0000";  
	SIGNAL F0_WrPending:		UNSIGNED(3 downto 0) := B"0000";
	SIGNAL F1_WrPending:		UNSIGNED(3 downto 0) := B"0000";
	SIGNAL F2_WrPending:		UNSIGNED(3 downto 0) := B"0000";
	SIGNAL F3_WrPending:		UNSIGNED(3 downto 0) := B"0000";
	SIGNAL F4_WrPending:		UNSIGNED(3 downto 0) := B"0000";
	SIGNAL F5_WrPending:		UNSIGNED(3 downto 0) := B"0000";
	SIGNAL F6_WrPending:		UNSIGNED(3 downto 0) := B"0000";
	SIGNAL F7_WrPending:		UNSIGNED(3 downto 0) := B"0000";
	SIGNAL F8_WrPending:		UNSIGNED(3 downto 0) := B"0000";
	SIGNAL F9_WrPending:		UNSIGNED(3 downto 0) := B"0000";
	SIGNAL F10_WrPending:		UNSIGNED(3 downto 0) := B"0000";
	SIGNAL F11_WrPending:		UNSIGNED(3 downto 0) := B"0000";
	SIGNAL F12_WrPending:		UNSIGNED(3 downto 0) := B"0000";
	SIGNAL F13_WrPending:		UNSIGNED(3 downto 0) := B"0000";
	SIGNAL F14_WrPending:		UNSIGNED(3 downto 0) := B"0000";
	SIGNAL F15_WrPending:		UNSIGNED(3 downto 0) := B"0000";
	SIGNAL FPFLAGS_WrPending:	UNSIGNED(3 downto 0) := B"0000";

	
begin
	

	Main: PROCESS
	
	PROCEDURE InitializeWbRegWAW IS
	
	BEGIN
		WbRegWAW.mode <= "ZZZZZZZZ";
		WbRegWAW.id <= "ZZZZZZZZ";
		WbRegWAW.datasize <= "ZZZZ";
		WbRegWAW.source <= "ZZZZ";
		WbRegWAW.data.decode <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	END InitializeWbRegWAW;
	
	PROCEDURE CheckRAW IS
	
	BEGIN
		CASE to_integer(unsigned(IdRegID)) IS
			WHEN ID_R0 =>
				if (R0_WrPending > 0) then
					StallRAW <= '1';
					IdRegRAW <= IdRegID;
				end if;
			WHEN ID_R1 =>
				if (R1_WrPending > 0) then
					StallRAW <= '1';
					IdRegRAW <= IdRegID;
				end if;
			WHEN ID_R2 =>
				if (R2_WrPending > 0) then
					StallRAW <= '1';
					IdRegRAW <= IdRegID;
				end if;
			WHEN ID_R3 =>
				if (R3_WrPending > 0) then
					StallRAW <= '1';
					IdRegRAW <= IdRegID;
				end if;
			WHEN ID_R4 =>
				if (R4_WrPending > 0) then
					StallRAW <= '1';
					IdRegRAW <= IdRegID;
				end if;
			WHEN ID_R5 =>
				if (R5_WrPending > 0) then
					StallRAW <= '1';
					IdRegRAW <= IdRegID;
				end if;
			WHEN ID_R6 =>
				if (R6_WrPending > 0) then
					StallRAW <= '1';
					IdRegRAW <= IdRegID;
				end if;
			WHEN ID_R7 =>
				if (R7_WrPending > 0) then
					StallRAW <= '1';
					IdRegRAW <= IdRegID;
				end if;
			WHEN ID_R8 =>
				if (R8_WrPending > 0) then
					StallRAW <= '1';
					IdRegRAW <= IdRegID;
				end if;
			WHEN ID_R9 =>
				if (R9_WrPending > 0) then
					StallRAW <= '1';
					IdRegRAW <= IdRegID;
				end if;
			WHEN ID_R10 =>
				if (R10_WrPending > 0) then
					StallRAW <= '1';
					IdRegRAW <= IdRegID;
				end if;
			WHEN ID_R11 =>
				if (R11_WrPending > 0) then
					StallRAW <= '1';
					IdRegRAW <= IdRegID;
				end if;
			WHEN ID_R12 =>
				if (R12_WrPending > 0) then
					StallRAW <= '1';
					IdRegRAW <= IdRegID;
				end if;
			WHEN ID_R13 =>
				if (R13_WrPending > 0) then
					StallRAW <= '1';
					IdRegRAW <= IdRegID;
				end if;
			WHEN ID_R14 =>
				if (R14_WrPending > 0) then
					StallRAW <= '1';
					IdRegRAW <= IdRegID;				  
				end if;
			WHEN ID_R15 =>
				if (R15_WrPending > 0) then
					StallRAW <= '1';
					IdRegRAW <= IdRegID; 
				end if;
			WHEN ID_F0 =>
				if (F0_WrPending > 0) then
					StallRAW <= '1';
					IdRegRAW <= IdRegID;
				end if;
			WHEN ID_F1 =>
				if (F1_WrPending > 0) then
					StallRAW <= '1';
					IdRegRAW <= IdRegID;
				end if;
			WHEN ID_F2 =>
				if (F2_WrPending > 0) then
					StallRAW <= '1';
					IdRegRAW <= IdRegID;
				end if;
			WHEN ID_F3 =>
				if (F3_WrPending > 0) then
					StallRAW <= '1';
					IdRegRAW <= IdRegID;		   
				end if;
			WHEN ID_F4 =>
				if (F4_WrPending > 0) then
					StallRAW <= '1';
					IdRegRAW <= IdRegID;						
				end if;
			WHEN ID_F5 =>
				if (F5_WrPending > 0) then
					StallRAW <= '1';
					IdRegRAW <= IdRegID;						  
				end if;
			WHEN ID_F6 =>
				if (F6_WrPending > 0) then
					StallRAW <= '1';
					IdRegRAW <= IdRegID;						
				end if;
			WHEN ID_F7 =>
				if (F7_WrPending > 0) then
					StallRAW <= '1';
					IdRegRAW <= IdRegID;						  
				end if;
			WHEN ID_F8 =>
				if (F8_WrPending > 0) then
					StallRAW <= '1';
					IdRegRAW <= IdRegID;						  
				end if;
			WHEN ID_F9 =>
				if (F9_WrPending > 0) then
					StallRAW <= '1';
					IdRegRAW <= IdRegID;						  
				end if;
			WHEN ID_F10 =>
				if (F10_WrPending > 0) then
					StallRAW <= '1';
					IdRegRAW <= IdRegID;						   
				end if;
			WHEN ID_F11 =>
				if (F11_WrPending > 0) then
					StallRAW <= '1';
					IdRegRAW <= IdRegID;						   
				end if;
			WHEN ID_F12 =>
				if (F12_WrPending > 0) then
					StallRAW <= '1';
					IdRegRAW <= IdRegID;						   
				end if;
			WHEN ID_F13 =>
				if (F13_WrPending > 0) then
					StallRAW <= '1';
					IdRegRAW <= IdRegID;							
				end if;
			WHEN ID_F14 =>
				if (F14_WrPending > 0) then
					StallRAW <= '1';
					IdRegRAW <= IdRegID;						  
				end if;
			WHEN ID_F15 =>
				if (F15_WrPending > 0) then
					StallRAW <= '1';
					IdRegRAW <= IdRegID; 						   
				end if;
			WHEN ID_IR =>
				NULL;
			WHEN ID_IP =>
				NULL;
			WHEN ID_FLAGS =>
				NULL;  
			WHEN ID_FPFLAGS =>
				if (FPFLAGS_WrPending > 0) then
					StallRAW <= '1';
					IdRegRAW <= IdRegID; 							  
				end if;
			WHEN ID_BP =>
				NULL;
			WHEN ID_SP =>
				NULL;
			WHEN ID_RA =>
				NULL;
			WHEN OTHERS =>
				NULL;
		END CASE;
	END CheckRAW;
	
	PROCEDURE IncWrPending IS
	
	VARIABLE RegIncWrPend: INTEGER := to_integer(unsigned(IdRegIncWrPend));
	
	BEGIN
		if (RegIncWrPend /= WB_NULL) then 
			CASE (RegIncWrPend-1) IS
				WHEN ID_R0 =>
					R0_WrPending <= R0_WrPending + 1;
				WHEN ID_R1 =>
					R1_WrPending <= R1_WrPending + 1;
				WHEN ID_R2 =>
					R2_WrPending <= R2_WrPending + 1;
				WHEN ID_R3 =>
					R3_WrPending <= R3_WrPending + 1;
				WHEN ID_R4 =>
					R4_WrPending <= R4_WrPending + 1;
				WHEN ID_R5 =>
					R5_WrPending <= R5_WrPending + 1;
				WHEN ID_R6 =>
					R6_WrPending <= R6_WrPending + 1;
				WHEN ID_R7 =>
					R7_WrPending <= R7_WrPending + 1;
				WHEN ID_R8 =>
					R8_WrPending <= R8_WrPending + 1;
				WHEN ID_R9 =>
					R9_WrPending <= R9_WrPending + 1;
				WHEN ID_R10 =>
					R10_WrPending <= R10_WrPending + 1;
				WHEN ID_R11 =>
					R11_WrPending <= R11_WrPending + 1;
				WHEN ID_R12 =>
					R12_WrPending <= R12_WrPending + 1;
				WHEN ID_R13 =>
					R13_WrPending <= R13_WrPending + 1;
				WHEN ID_R14 =>
					R14_WrPending <= R14_WrPending + 1;
				WHEN ID_R15 =>
					R15_WrPending <= R15_WrPending + 1;	
				WHEN ID_F0 =>
					F0_WrPending <= F0_WrPending + 1;
					F0_IdWrPending(to_integer(F0_WrPending+1)) <= IdInstIncWrPend;
				WHEN ID_F1 =>
					F1_WrPending <= F1_WrPending + 1;
					F1_IdWrPending(to_integer(F1_WrPending+1)) <= IdInstIncWrPend;
				WHEN ID_F2 =>
					F2_WrPending <= F2_WrPending + 1;
					F2_IdWrPending(to_integer(F2_WrPending+1)) <= IdInstIncWrPend;
				WHEN ID_F3 =>
					F3_WrPending <= F3_WrPending + 1;  
					F3_IdWrPending(to_integer(F3_WrPending+1)) <= IdInstIncWrPend;
				WHEN ID_F4 =>
					F4_WrPending <= F4_WrPending + 1;  
					F4_IdWrPending(to_integer(F4_WrPending+1)) <= IdInstIncWrPend;
				WHEN ID_F5 =>
					F5_WrPending <= F5_WrPending + 1;
					F5_IdWrPending(to_integer(F5_WrPending+1)) <= IdInstIncWrPend;
				WHEN ID_F6 =>
					F6_WrPending <= F6_WrPending + 1;  
					F6_IdWrPending(to_integer(F6_WrPending+1)) <= IdInstIncWrPend;
				WHEN ID_F7 =>
					F7_WrPending <= F7_WrPending + 1;
					F7_IdWrPending(to_integer(F7_WrPending+1)) <= IdInstIncWrPend;
				WHEN ID_F8 =>
					F8_WrPending <= F8_WrPending + 1; 
				 	F8_IdWrPending(to_integer(F8_WrPending+1)) <= IdInstIncWrPend;
				WHEN ID_F9 =>
					F9_WrPending <= F9_WrPending + 1;
					F9_IdWrPending(to_integer(F9_WrPending+1)) <= IdInstIncWrPend;
				WHEN ID_F10 =>
					F10_WrPending <= F10_WrPending + 1;
					F10_IdWrPending(to_integer(F10_WrPending+1)) <= IdInstIncWrPend;
				WHEN ID_F11 =>
					F11_WrPending <= F11_WrPending + 1;	 
					F11_IdWrPending(to_integer(F11_WrPending+1)) <= IdInstIncWrPend;
				WHEN ID_F12 =>
					F12_WrPending <= F12_WrPending + 1;
					F12_IdWrPending(to_integer(F12_WrPending+1)) <= IdInstIncWrPend;
				WHEN ID_F13 =>
					F13_WrPending <= F13_WrPending + 1;
					F13_IdWrPending(to_integer(F13_WrPending+1)) <= IdInstIncWrPend;
				WHEN ID_F14 =>
					F14_WrPending <= F14_WrPending + 1;
					F14_IdWrPending(to_integer(F14_WrPending+1)) <= IdInstIncWrPend;
				WHEN ID_F15 =>
					F15_WrPending <= F15_WrPending + 1;	
					F15_IdWrPending(to_integer(F15_WrPending+1)) <= IdInstIncWrPend;
				WHEN ID_IR =>
					NULL;
				WHEN ID_IP =>
					NULL;
				WHEN ID_FLAGS =>
					NULL;
				WHEN ID_FPFLAGS =>
					NULL;
				WHEN ID_BP =>
					NULL;
				WHEN ID_SP =>
					NULL;
				WHEN ID_RA =>
					NULL;
				WHEN OTHERS =>
					NULL;
			END CASE; 
		end if;
	END IncWrPending;
	
	PROCEDURE IncFPWrPending IS	
	
	BEGIN					   
		FPFLAGS_WrPending <= FPFLAGS_WrPending + 1;
	END IncFPWrPending;
	
	PROCEDURE CheckWAW IS
	
	VARIABLE RegCheckWAW: INTEGER := to_integer(unsigned(WbRegCheckWAW.mode));
	
	BEGIN
		if (RegCheckWAW /= WB_NULL) then
			CASE (RegCheckWAW-1) IS
				WHEN ID_R0 =>
					NULL;
				WHEN ID_R1 =>
					NULL;
				WHEN ID_R2 =>
					NULL;
				WHEN ID_R3 =>
					NULL;
				WHEN ID_R4 =>
					NULL;
				WHEN ID_R5 =>
					NULL;
				WHEN ID_R6 =>
					NULL;
				WHEN ID_R7 =>
					NULL;
				WHEN ID_R8 =>
					NULL;
				WHEN ID_R9 =>
					NULL;
				WHEN ID_R10 =>
					NULL;
				WHEN ID_R11 =>
					NULL;
				WHEN ID_R12 =>
					NULL;
				WHEN ID_R13 =>
					NULL;
				WHEN ID_R14 =>
					NULL;
				WHEN ID_R15 =>
					NULL;
				WHEN ID_F0 =>
					if (F0_IdWrPending(1) /= WbRegCheckWAW.id) then
						StallWAW <= '1';
						WbRegWAW <= WbRegCheckWAW;
						--for i in 1 to to_integer(F0_WrPending) loop
							--F0_IdWrPending(i) <= F0_IdWrPending(i+1);
						--end loop;
					end if;
				WHEN ID_F1 =>
					if (F1_IdWrPending(1) /= WbRegCheckWAW.id) then
						StallWAW <= '1';
						WbRegWAW <= WbRegCheckWAW;
						--for i in 1 to to_integer(F1_WrPending) loop
							--F1_IdWrPending(i) <= F1_IdWrPending(i+1);
						--end loop;
					end if;
				WHEN ID_F2 =>
					if (F2_IdWrPending(1) /= WbRegCheckWAW.id) then
						StallWAW <= '1';
						WbRegWAW <= WbRegCheckWAW;
						--for i in 1 to to_integer(F2_WrPending) loop
							--F2_IdWrPending(i) <= F2_IdWrPending(i+1);
						--end loop;
					end if;
				WHEN ID_F3 =>
					if (F3_IdWrPending(1) /= WbRegCheckWAW.id) then
						StallWAW <= '1';
						WbRegWAW <= WbRegCheckWAW;
						--for i in 1 to to_integer(F3_WrPending) loop
							--F3_IdWrPending(i) <= F3_IdWrPending(i+1);
						--end loop;
					end if;
				WHEN ID_F4 =>
					if (F4_IdWrPending(1) /= WbRegCheckWAW.id) then
						StallWAW <= '1';
						WbRegWAW <= WbRegCheckWAW;
						--for i in 1 to to_integer(F4_WrPending) loop
							--F4_IdWrPending(i) <= F4_IdWrPending(i+1);
						--end loop;
					end if;
				WHEN ID_F5 =>
					if (F5_IdWrPending(1) /= WbRegCheckWAW.id) then
						StallWAW <= '1';
						WbRegWAW <= WbRegCheckWAW;
						--for i in 1 to to_integer(F5_WrPending) loop
							--F5_IdWrPending(i) <= F5_IdWrPending(i+1);
						--end loop;
					end if;
				WHEN ID_F6 =>
					if (F6_IdWrPending(1) /= WbRegCheckWAW.id) then
						StallWAW <= '1';
						WbRegWAW <= WbRegCheckWAW;
						--for i in 1 to to_integer(F6_WrPending) loop
							--F6_IdWrPending(i) <= F6_IdWrPending(i+1);
						--end loop;
					end if;
				WHEN ID_F7 =>
					if (F7_IdWrPending(1) /= WbRegCheckWAW.id) then
						StallWAW <= '1';
						WbRegWAW <= WbRegCheckWAW;
						--for i in 1 to to_integer(F7_WrPending) loop
							--F7_IdWrPending(i) <= F7_IdWrPending(i+1);
						--end loop;
					end if;
				WHEN ID_F8 =>
					if (F8_IdWrPending(1) /= WbRegCheckWAW.id) then
						StallWAW <= '1';
						WbRegWAW <= WbRegCheckWAW;
						--for i in 1 to to_integer(F8_WrPending) loop
							--F8_IdWrPending(i) <= F8_IdWrPending(i+1);
						--end loop;
					end if;
				WHEN ID_F9 =>
					if (F9_IdWrPending(1) /= WbRegCheckWAW.id) then
						StallWAW <= '1';
						WbRegWAW <= WbRegCheckWAW;
						--for i in 1 to to_integer(F9_WrPending) loop
							--F9_IdWrPending(i) <= F9_IdWrPending(i+1);
						--end loop;
					end if;
				WHEN ID_F10 =>
					if (F10_IdWrPending(1) /= WbRegCheckWAW.id) then
						StallWAW <= '1';
						WbRegWAW <= WbRegCheckWAW;
						--for i in 1 to to_integer(F10_WrPending) loop
							--F10_IdWrPending(i) <= F10_IdWrPending(i+1);
						--end loop;
					end if;
				WHEN ID_F11 =>
					if (F11_IdWrPending(1) /= WbRegCheckWAW.id) then
						StallWAW <= '1';
						WbRegWAW <= WbRegCheckWAW;
						--for i in 1 to to_integer(F11_WrPending) loop
							--F11_IdWrPending(i) <= F11_IdWrPending(i+1);
						--end loop;
					end if;
				WHEN ID_F12 =>
					if (F12_IdWrPending(1) /= WbRegCheckWAW.id) then
						StallWAW <= '1';
						WbRegWAW <= WbRegCheckWAW;
						--for i in 1 to to_integer(F12_WrPending) loop
							--F12_IdWrPending(i) <= F12_IdWrPending(i+1);
						--end loop;
					end if;
				WHEN ID_F13 =>
					if (F13_IdWrPending(1) /= WbRegCheckWAW.id) then
						StallWAW <= '1';
						WbRegWAW <= WbRegCheckWAW;
						--for i in 1 to to_integer(F13_WrPending) loop
							--F13_IdWrPending(i) <= F13_IdWrPending(i+1);
						--end loop;
					end if;
				WHEN ID_F14 =>
					if (F14_IdWrPending(1) /= WbRegCheckWAW.id) then
						StallWAW <= '1';
						WbRegWAW <= WbRegCheckWAW;
						--for i in 1 to to_integer(F14_WrPending) loop
							--F14_IdWrPending(i) <= F14_IdWrPending(i+1);
						--end loop;
					end if;
				WHEN ID_F15 =>
					if (F15_IdWrPending(1) /= WbRegCheckWAW.id) then
						StallWAW <= '1';
						WbRegWAW <= WbRegCheckWAW;
						--for i in 1 to to_integer(F15_WrPending) loop
							--F15_IdWrPending(i) <= F15_IdWrPending(i+1);
						--end loop;
					end if;
				WHEN ID_IR =>
					NULL;
				WHEN ID_IP =>
					NULL;
				WHEN ID_FLAGS =>
					NULL;  
				WHEN ID_FPFLAGS =>
					NULL;
				WHEN ID_BP =>
					NULL;
				WHEN ID_SP =>
					NULL;
				WHEN ID_RA =>
					NULL;
				WHEN OTHERS =>
					NULL;
			END CASE;
		end if;
	END CheckWAW;
	
	PROCEDURE DecWrPending IS
	
	VARIABLE RegDecWrPend: INTEGER := to_integer(unsigned(IdRegDecWrPend));
	
	BEGIN
		if (RegDecWrPend /= WB_NULL) then
			CASE (RegDecWrPend-1) IS
				WHEN ID_R0 =>
					if ((R0_WrPending = 1) and (StallRAW = '1') and (to_integer(unsigned(IdRegRAW)) = ID_R0)) then
						StallRAW <= '0';
					end if;	 
					R0_WrPending <= R0_WrPending - 1;
				WHEN ID_R1 =>
					if ((R1_WrPending = 1) and (StallRAW = '1') and (to_integer(unsigned(IdRegRAW)) = ID_R1)) then
						StallRAW <= '0';
					end if;
					R1_WrPending <= R1_WrPending - 1;
				WHEN ID_R2 => 
					if ((R2_WrPending = 1) and (StallRAW = '1') and (to_integer(unsigned(IdRegRAW)) = ID_R2)) then
						StallRAW <= '0';
					end if;
					R2_WrPending <= R2_WrPending - 1;
				WHEN ID_R3 =>
					if ((R3_WrPending = 1) and (StallRAW = '1') and (to_integer(unsigned(IdRegRAW)) = ID_R3)) then
						StallRAW <= '0';
					end if;
					R3_WrPending <= R3_WrPending - 1;
				WHEN ID_R4 =>
					if ((R4_WrPending = 1) and (StallRAW = '1') and (to_integer(unsigned(IdRegRAW)) = ID_R4)) then
						StallRAW <= '0';
					end if;
					R4_WrPending <= R4_WrPending - 1;
				WHEN ID_R5 =>
					if ((R5_WrPending = 1) and (StallRAW = '1') and (to_integer(unsigned(IdRegRAW)) = ID_R5)) then
						StallRAW <= '0';
					end if;
					R5_WrPending <= R5_WrPending - 1;
				WHEN ID_R6 => 
					if ((R6_WrPending = 1) and (StallRAW = '1') and (to_integer(unsigned(IdRegRAW)) = ID_R6)) then
						StallRAW <= '0';
					end if;
					R6_WrPending <= R6_WrPending - 1;
				WHEN ID_R7 =>
					if ((R7_WrPending = 1) and (StallRAW = '1') and (to_integer(unsigned(IdRegRAW)) = ID_R7)) then
						StallRAW <= '0';
					end if;
					R7_WrPending <= R7_WrPending - 1;
				WHEN ID_R8 => 
					if ((R8_WrPending = 1) and (StallRAW = '1') and (to_integer(unsigned(IdRegRAW)) = ID_R8)) then
						StallRAW <= '0';
					end if;
					R8_WrPending <= R8_WrPending - 1;
				WHEN ID_R9 => 
					if ((R9_WrPending = 1) and (StallRAW = '1') and (to_integer(unsigned(IdRegRAW)) = ID_R9)) then
						StallRAW <= '0';
					end if;
					R9_WrPending <= R9_WrPending - 1;
				WHEN ID_R10 => 
					if ((R10_WrPending = 1) and (StallRAW = '1') and (to_integer(unsigned(IdRegRAW)) = ID_R10)) then
						StallRAW <= '0';
					end if;
					R10_WrPending <= R10_WrPending - 1;
				WHEN ID_R11 => 
					if ((R11_WrPending = 1) and (StallRAW = '1') and (to_integer(unsigned(IdRegRAW)) = ID_R11)) then
						StallRAW <= '0';
					end if;
					R11_WrPending <= R11_WrPending - 1;
				WHEN ID_R12 =>	
					if ((R12_WrPending = 1) and (StallRAW = '1') and (to_integer(unsigned(IdRegRAW)) = ID_R12)) then
						StallRAW <= '0';
					end if;
					R12_WrPending <= R12_WrPending - 1;
				WHEN ID_R13 =>
					if ((R13_WrPending = 1) and (StallRAW = '1') and (to_integer(unsigned(IdRegRAW)) = ID_R13)) then
						StallRAW <= '0';
					end if;
					R13_WrPending <= R13_WrPending - 1;
				WHEN ID_R14 =>
					if ((R14_WrPending = 1) and (StallRAW = '1') and (to_integer(unsigned(IdRegRAW)) = ID_R14)) then
						StallRAW <= '0';
					end if;
					R14_WrPending <= R14_WrPending - 1;
				WHEN ID_R15 => 
					if ((R15_WrPending = 1) and (StallRAW = '1') and (to_integer(unsigned(IdRegRAW)) = ID_R15)) then
						StallRAW <= '0';
					end if;
					R15_WrPending <= R15_WrPending - 1;
				WHEN ID_F0 =>
					if ((F0_WrPending = 1) and (StallRAW = '1') and (to_integer(unsigned(IdRegRAW)) = ID_F0)) then
						StallRAW <= '0';
					end if;
					if ((F0_WrPending = 2) and (to_integer(unsigned(WbRegWAW.mode))-1 = ID_F0)) then
						WbRegDoneWAW <= WbRegWAW;
						DoneWAW <= '1';
						InitializeWbRegWAW;
					end if;
					for i in 1 to to_integer(F0_WrPending) loop
						F0_IdWrPending(i) <= F0_IdWrPending(i+1);
					end loop;
					F0_WrPending <= F0_WrPending - 1;
				WHEN ID_F1 =>
					if ((F1_WrPending = 1) and (StallRAW = '1') and (to_integer(unsigned(IdRegRAW)) = ID_F1)) then
						StallRAW <= '0';
					end if;	
					if ((F1_WrPending = 2) and (to_integer(unsigned(WbRegWAW.mode))-1 = ID_F1)) then
						WbRegDoneWAW <= WbRegWAW;
						DoneWAW <= '1';
						InitializeWbRegWAW;
					end if;
					for i in 1 to to_integer(F1_WrPending) loop
						F1_IdWrPending(i) <= F1_IdWrPending(i+1);
					end loop;	
					F1_WrPending <= F1_WrPending - 1;
				WHEN ID_F2 => 
					if ((F2_WrPending = 1) and (StallRAW = '1') and (to_integer(unsigned(IdRegRAW)) = ID_F2)) then
						StallRAW <= '0';
					end if;
					if ((F2_WrPending = 2) and (to_integer(unsigned(WbRegWAW.mode))-1 = ID_F2)) then
						WbRegDoneWAW <= WbRegWAW;
						DoneWAW <= '1';
						InitializeWbRegWAW;
					end if;
					for i in 1 to to_integer(F2_WrPending) loop
						F2_IdWrPending(i) <= F2_IdWrPending(i+1);
					end loop;
					F2_WrPending <= F2_WrPending - 1;
				WHEN ID_F3 =>
					if ((F3_WrPending = 1) and (StallRAW = '1') and (to_integer(unsigned(IdRegRAW)) = ID_F3)) then
						StallRAW <= '0';
					end if;
					if ((F3_WrPending = 2) and (to_integer(unsigned(WbRegWAW.mode))-1 = ID_F3)) then
						WbRegDoneWAW <= WbRegWAW;
						DoneWAW <= '1';
						InitializeWbRegWAW;
					end if;
					for i in 1 to to_integer(F3_WrPending) loop
						F3_IdWrPending(i) <= F3_IdWrPending(i+1);
					end loop;
					F3_WrPending <= F3_WrPending - 1;
				WHEN ID_F4 =>
					if ((F4_WrPending = 1) and (StallRAW = '1') and (to_integer(unsigned(IdRegRAW)) = ID_F4)) then
						StallRAW <= '0';
					end if;
					if ((F4_WrPending = 2) and (to_integer(unsigned(WbRegWAW.mode))-1 = ID_F4)) then
						WbRegDoneWAW <= WbRegWAW;
						DoneWAW <= '1';
						InitializeWbRegWAW;
					end if;
					for i in 1 to to_integer(F4_WrPending) loop
						F4_IdWrPending(i) <= F4_IdWrPending(i+1);
					end loop;
					F4_WrPending <= F4_WrPending - 1;
				WHEN ID_F5 =>
					if ((F5_WrPending = 1) and (StallRAW = '1') and (to_integer(unsigned(IdRegRAW)) = ID_F5)) then
						StallRAW <= '0';
					end if;
					if ((F5_WrPending = 2) and (to_integer(unsigned(WbRegWAW.mode))-1 = ID_F5)) then
						WbRegDoneWAW <= WbRegWAW;
						DoneWAW <= '1';
						InitializeWbRegWAW;
					end if;
					for i in 1 to to_integer(F5_WrPending) loop
						F5_IdWrPending(i) <= F5_IdWrPending(i+1);
					end loop;
					F5_WrPending <= F5_WrPending - 1;
				WHEN ID_F6 => 
					if ((F6_WrPending = 1) and (StallRAW = '1') and (to_integer(unsigned(IdRegRAW)) = ID_F6)) then
						StallRAW <= '0';
					end if;
					if ((F6_WrPending = 2) and (to_integer(unsigned(WbRegWAW.mode))-1 = ID_F6)) then
						WbRegDoneWAW <= WbRegWAW;
						DoneWAW <= '1';
						InitializeWbRegWAW;
					end if;
					for i in 1 to to_integer(F6_WrPending) loop
						F6_IdWrPending(i) <= F6_IdWrPending(i+1);
					end loop;
					F6_WrPending <= F6_WrPending - 1;
				WHEN ID_F7 =>
					if ((F7_WrPending = 1) and (StallRAW = '1') and (to_integer(unsigned(IdRegRAW)) = ID_F7)) then
						StallRAW <= '0';
					end if;	
					if ((F7_WrPending = 2) and (to_integer(unsigned(WbRegWAW.mode))-1 = ID_F7)) then
						WbRegDoneWAW <= WbRegWAW;
						DoneWAW <= '1';
						InitializeWbRegWAW;
					end if;
					for i in 1 to to_integer(F7_WrPending) loop
						F7_IdWrPending(i) <= F7_IdWrPending(i+1);
					end loop;
					F7_WrPending <= F7_WrPending - 1;
				WHEN ID_F8 => 
					if ((F8_WrPending = 1) and (StallRAW = '1') and (to_integer(unsigned(IdRegRAW)) = ID_F8)) then
						StallRAW <= '0';
					end if;
					if ((F8_WrPending = 2) and (to_integer(unsigned(WbRegWAW.mode))-1 = ID_F8)) then
						WbRegDoneWAW <= WbRegWAW;
						DoneWAW <= '1';
						InitializeWbRegWAW;
					end if;
					for i in 1 to to_integer(F8_WrPending) loop
						F8_IdWrPending(i) <= F8_IdWrPending(i+1);
					end loop;
					F8_WrPending <= F8_WrPending - 1;
				WHEN ID_F9 => 
					if ((F9_WrPending = 1) and (StallRAW = '1') and (to_integer(unsigned(IdRegRAW)) = ID_F9)) then
						StallRAW <= '0';
					end if;	
					if ((F9_WrPending = 2) and (to_integer(unsigned(WbRegWAW.mode))-1 = ID_F9)) then
						WbRegDoneWAW <= WbRegWAW;
						DoneWAW <= '1';
						InitializeWbRegWAW;
					end if;
					for i in 1 to to_integer(F9_WrPending) loop
						F9_IdWrPending(i) <= F9_IdWrPending(i+1);
					end loop;
					F9_WrPending <= F9_WrPending - 1;
				WHEN ID_F10 => 
					if ((F10_WrPending = 1) and (StallRAW = '1') and (to_integer(unsigned(IdRegRAW)) = ID_F10)) then
						StallRAW <= '0';
					end if;
					if ((F10_WrPending = 2) and (to_integer(unsigned(WbRegWAW.mode))-1 = ID_F10)) then
						WbRegDoneWAW <= WbRegWAW;
						DoneWAW <= '1';
						InitializeWbRegWAW;
					end if;
					for i in 1 to to_integer(F10_WrPending) loop
						F10_IdWrPending(i) <= F10_IdWrPending(i+1);
					end loop;
					F10_WrPending <= F10_WrPending - 1;
				WHEN ID_F11 => 
					if ((F11_WrPending = 1) and (StallRAW = '1') and (to_integer(unsigned(IdRegRAW)) = ID_F11)) then
						StallRAW <= '0';
					end if;
					if ((F11_WrPending = 2) and (to_integer(unsigned(WbRegWAW.mode))-1 = ID_F11)) then
						WbRegDoneWAW <= WbRegWAW;
						DoneWAW <= '1';
						InitializeWbRegWAW;
					end if;
					for i in 1 to to_integer(F11_WrPending) loop
						F11_IdWrPending(i) <= F11_IdWrPending(i+1);
					end loop;
					F11_WrPending <= F11_WrPending - 1;
				WHEN ID_F12 =>	
					if ((F12_WrPending = 1) and (StallRAW = '1') and (to_integer(unsigned(IdRegRAW)) = ID_F12)) then
						StallRAW <= '0';
					end if;	
					if ((F12_WrPending = 2) and (to_integer(unsigned(WbRegWAW.mode))-1 = ID_F12)) then
						WbRegDoneWAW <= WbRegWAW;
						DoneWAW <= '1';
						InitializeWbRegWAW;
					end if;
					for i in 1 to to_integer(F12_WrPending) loop
						F12_IdWrPending(i) <= F12_IdWrPending(i+1);
					end loop;
					F12_WrPending <= F12_WrPending - 1;
				WHEN ID_F13 =>
					if ((F13_WrPending = 1) and (StallRAW = '1') and (to_integer(unsigned(IdRegRAW)) = ID_F13)) then
						StallRAW <= '0';
					end if;
					if ((F13_WrPending = 2) and (to_integer(unsigned(WbRegWAW.mode))-1 = ID_F13)) then
						WbRegDoneWAW <= WbRegWAW;
						DoneWAW <= '1';
						InitializeWbRegWAW;
					end if;
					for i in 1 to to_integer(F13_WrPending) loop
						F13_IdWrPending(i) <= F13_IdWrPending(i+1);
					end loop;
					F13_WrPending <= F13_WrPending - 1;
				WHEN ID_F14 =>
					if ((F14_WrPending = 1) and (StallRAW = '1') and (to_integer(unsigned(IdRegRAW)) = ID_F14)) then
						StallRAW <= '0';
					end if;
					if ((F14_WrPending = 2) and (to_integer(unsigned(WbRegWAW.mode))-1 = ID_F14)) then
						WbRegDoneWAW <= WbRegWAW;
						DoneWAW <= '1';
						InitializeWbRegWAW;
					end if;
					for i in 1 to to_integer(F14_WrPending) loop
						F14_IdWrPending(i) <= F14_IdWrPending(i+1);
					end loop;
					F14_WrPending <= F14_WrPending - 1;
				WHEN ID_F15 => 
					if ((F15_WrPending = 1) and (StallRAW = '1') and (to_integer(unsigned(IdRegRAW)) = ID_F15)) then
						StallRAW <= '0';
					end if;
					if ((F15_WrPending = 2) and (to_integer(unsigned(WbRegWAW.mode))-1 = ID_F15)) then
						WbRegDoneWAW <= WbRegWAW;
						DoneWAW <= '1';
						InitializeWbRegWAW;
					end if;
					for i in 1 to to_integer(F15_WrPending) loop
						F15_IdWrPending(i) <= F15_IdWrPending(i+1);
					end loop;
					F15_WrPending <= F15_WrPending - 1;
				WHEN ID_IR =>
					NULL;
				WHEN ID_IP =>
					NULL;
				WHEN ID_FLAGS =>
					NULL;
				WHEN ID_FPFLAGS =>
					if ((FPFLAGS_WrPending = 1) and (StallRAW = '1') and (to_integer(unsigned(IdRegRAW)) = ID_FPFLAGS)) then
						StallRAW <= '0';
					end if;
					FPFLAGS_WrPending <= FPFLAGS_WrPending - 1;
				WHEN ID_BP =>
					NULL;
				WHEN ID_SP =>
					NULL;
				WHEN ID_RA =>
					NULL;
				WHEN OTHERS =>
					NULL;
			END CASE;
		end if;
	END DecWrPending;
	
	PROCEDURE DecFPWrPending IS	
	
	BEGIN					   
		if ((FPFLAGS_WrPending = 1) and (StallRAW = '1') and (to_integer(unsigned(IdRegRAW)) = ID_FPFLAGS)) then
			StallRAW <= '0';
		end if;
		FPFLAGS_WrPending <= FPFLAGS_WrPending - 1;
	END DecFPWrPending;
	
	VARIABLE First: BOOLEAN := true;
	
	BEGIN
		if (First) then
			First := false;
			StallRAW <= '0';
			StallWAW <= '0';
			DoneWAW <= '0';
			InitializeWbRegWAW;
			WAIT FOR 1 ns;
		end if;
		WAIT UNTIL ((Pipelining) AND (rising_edge(EnableRegID) OR rising_edge(EnableIncWrPend) OR rising_edge(EnableIncFPWrPend) OR rising_edge(EnableCheckWAW) OR rising_edge(EnableDecWrPend) OR rising_edge(EnableDecFPWrPend)));
		StallWAW <= '0';
		DoneWAW <= '0';
		if (EnableRegID = '1') then
			CheckRAW;
		end if;
		if (EnableIncWrPend = '1') then
			if (StallRAW = '0') then
				IncWrPending;
			end if;
		end if;
		if ((EnableIncFPWrPend = '1') and (EnableDecFPWrPend = '0')) then
			if (StallRAW = '0') then
				IncFPWrPending;
			end if;
		end if;
		if (EnableCheckWAW = '1') then
			CheckWAW;
		end if;
		if (EnableDecWrPend = '1') then
			DecWrPending;
		end if;
		if ((EnableDecFPWrPend = '1') and (EnableIncFPWrPend = '0')) then
			DecFPWrPending;
		end if;
	END PROCESS Main; 
	
	
	SetStallWAWAux: PROCESS
	
	VARIABLE First: BOOLEAN := true;
	
	BEGIN
		if (First) then
			First := false;
			StallWAWAux <= '0';
			WAIT FOR 1 ns;
		end if;	
		WAIT UNTIL rising_edge(StallWAW);
		StallWAWAux <= '1';
		WAIT UNTIL rising_edge(DoneWAW);
		StallWAWAux <= '0';
	END PROCESS SetStallWAWAux;
		
	
end RAW_WAW_DETECTOR_ARCHITECTURE;





