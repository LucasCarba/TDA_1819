
-- Entidad "cpu_admin":
-- Descripción: Aquí se define el administrador de la CPU, encargado de, en cada ciclo
-- de reloj, habilitar en primer lugar la ejecución simultánea de todas las etapas del 
-- pipeline (en caso de que la segmentación del procesador se encuentre activada por el 
-- usuario). Luego, antes de que finalice el ciclo de reloj habilitará al banco de 
-- registros internos intermedios de la segmentación para que reciba y almacene de las 
-- etapas "decode", "execute" y "memory access" toda la información que deseen 
-- transmitir especialmente a las siguientes etapas del pipeline que no sean 
-- consecutivas a ellas.
-- Procesos: 
-- StopCPU: Una vez que la unidad de control de la CPU (etapa "decode") decodifique la 
-- instrucción HALT (última instrucción del programa, detiene la ejecución del 
-- procesador), enviará una señal que será recibida por este proceso, el cual se
-- encargará a su vez de detener simultáneamente la máquina de estados y las etapas
-- "fetch", "decode" y "execute", para luego, en el siguiente ciclo de reloj, proseguir
-- con la etapa "memory access", en el posterior, con la etapa "writeback" y por último,
-- en el siguiente, detener el reloj del procesador y notificar al banco de pruebas del 
-- usuario sobre la finalización de la ejecución del programa.
-- Main: En primer lugar, recibe la señal de reloj de la CPU para luego, en cada ciclo,
-- habilitar la ejecución de la máquina de estados del procesador. El resto de las 
-- acciones a realizar dependerá del estado de la segmentación: si se encuentra activada
-- por el usuario, entonces en cada ciclo se habilitarán simultáneamente todas las 
-- etapas del pipeline, por lo cual existirán múltiples instrucciones ejecutándose al
-- mismo tiempo en la CPU (obviamente, cada una en una etapa distinta). También se 
-- habilitará el banco de registros internos intermedios para que reciban información
-- simultáneamente de las etapas "decode", "execute" y "memory access". En cambio, si
-- el usuario desactivó la segmentación, en cada ciclo se habilitará sólo una etapa:
-- aquélla inmediatamente posterior a la ejecutada en el ciclo anterior (por ejemplo,
-- si se ejecutó la etapa "memory access", ahora se ejecutará la "writeback"), hasta
-- completar el ciclo de ejecución de la instrucción actual y comenzar con otra nueva
-- desde el principio (etapa "fetch"). Además, el banco de registros internos 
-- intermedios sólo será habilitado para recibir información de la etapa actualmente
-- en ejecución y únicamente ne caso de que ésta sea "decode", "execute" o "memory
-- access".


library TDA_1819;
use TDA_1819.const_reloj.all;
use TDA_1819.tipos_cpu.all;



library ieee;
use ieee.NUMERIC_STD.all;
use ieee.std_logic_1164.all;
library std;
use std.TEXTIO.all;



entity cpu_admin is	
	
	generic (
		Pipelining		: BOOLEAN);

    port (
		EnableSM		: out std_logic;
		EnableIF		: out std_logic;
		EnableID		: out std_logic;
		EnableEX		: out std_logic;
		EnableMA		: out std_logic;
		EnableWB		: out std_logic;
		EnablePDA_ID	: out std_logic;
		EnablePDA_EX	: out std_logic;
		EnablePDA_MA	: out std_logic;
		StopSM			: out std_logic;
		StopEnd			: out std_logic;
		DoneCpuUser		: out std_logic;
		StallHLT		: in  std_logic;
		StopInit		: in  std_logic;
		Fp				: in  std_logic;
		CLK				: in  std_logic);

end cpu_admin;




architecture cpu_admin_architecture of cpu_admin is		


	SIGNAL StopIF:	std_logic := '0';
	SIGNAL StopID:	std_logic := '0';
	SIGNAL StopEX:	std_logic := '0';
	SIGNAL StopMA:	std_logic := '0';
	SIGNAL StopWB:	std_logic := '0';

	
begin
	
	
	StopCPU: PROCESS
	
	BEGIN 
		StopSM <= '0';
		StopEnd <= '0';
		DoneCpuUser <= '0';
		WAIT UNTIL (rising_edge(StopInit) or rising_edge(StallHLT));
		--WAIT UNTIL falling_edge(CLK);
		if (StallHLT = '1') then
			StopIF <= '1';
			WAIT UNTIL rising_edge(StopInit);
		end if;
		StopSM <= '1';
		StopIF <= '1';
		StopID <= '1';
		StopEX <= '1';
		WAIT UNTIL falling_edge(CLK);
		StopMA <= '1';
		WAIT UNTIL falling_edge(CLK);
		StopWB <= '1';
		WAIT UNTIL falling_edge(CLK);
		StopEnd <= '1';
		WAIT FOR PERIODO / 2;
		DoneCpuUser <= '1';
		WAIT;
	END PROCESS StopCPU;
	
	
	Main: PROCESS
	
	VARIABLE First: BOOLEAN := true;
	VARIABLE cantCiclos: INTEGER := 0;
	VARIABLE cantCiclosEXFP: INTEGER := 0;
	
	BEGIN
		if (First) then
			EnableSM <= '0';
			EnableIF <= '0';
			EnableID <= '0';
			EnableEX <= '0';
			EnableMA <= '0';
			EnableWB <= '0';
			EnablePDA_ID <= '0';
			EnablePDA_EX <= '0';
			EnablePDA_MA <= '0';
			First := false;
		end if;
		WAIT UNTIL rising_edge(CLK);
		EnableSM <= '1';
		if (not Pipelining) then
			CASE (cantCiclos mod 5) IS
				WHEN 0 =>
					EnableIF <= '1' AND (NOT StopIF);
				WHEN 1 =>
					EnableID <= '1' AND (NOT StopID);
					WAIT FOR 20 ns;
					EnablePDA_ID <= '1' AND (NOT StopID); 
				WHEN 2 =>
					if (Fp = '1') then
						cantCiclosEXFP := cantCiclosEXFP + 1;
						if (cantCiclosEXFP = 4) then
							cantCiclosEXFP := 0;
						end if;
					end if;
					EnableEX <= '1' AND (NOT StopEX);
					WAIT FOR 20 ns;
					EnablePDA_EX <= '1' AND (NOT StopEX);	
				WHEN 3 =>
					EnableMA <= '1' AND (NOT StopMA);
					WAIT FOR 20 ns;
					EnablePDA_MA <= '1' AND (NOT StopMA);
				WHEN 4 =>
					EnableWB <= '1' AND (NOT StopWB);
				WHEN OTHERS =>
					report "Error: comprobar el administrador de la CPU"
					severity FAILURE;
			END CASE;
		elsif (cantCiclos < 5) then
			CASE (cantCiclos mod 5) IS
				WHEN 0 => 
					EnableIF <= '1' AND (NOT StopIF);
				WHEN 1 =>
					EnableIF <= '1' AND (NOT StopIF);
					EnableID <= '1' AND (NOT StopID);
					WAIT FOR 20 ns;
					EnablePDA_ID <= '1' AND (NOT StopID);  
				WHEN 2 =>
					EnableIF <= '1' AND (NOT StopIF);
					EnableID <= '1' AND (NOT StopID);
					EnableEX <= '1' AND (NOT StopEX);
					WAIT FOR 20 ns;
					EnablePDA_ID <= '1' AND (NOT StopID);
					EnablePDA_EX <= '1' AND (NOT StopEX);
				WHEN 3 =>
					EnableIF <= '1' AND (NOT StopIF);
				   	EnableID <= '1' AND (NOT StopID);
					EnableEX <= '1' AND (NOT StopEX);
					EnableMA <= '1' AND (NOT StopMA);
					WAIT FOR 20 ns;
					EnablePDA_ID <= '1' AND (NOT StopID);
					EnablePDA_EX <= '1' AND (NOT StopEX);
					EnablePDA_MA <= '1' AND (NOT StopMA);
				WHEN 4 =>
					EnableIF <= '1' AND (NOT StopIF);
					EnableID <= '1' AND (NOT StopID);
					EnableEX <= '1' AND (NOT StopEX);
					EnableMA <= '1' AND (NOT StopMA);
					EnableWB <= '1' AND (NOT StopWB);
					WAIT FOR 20 ns;
					EnablePDA_ID <= '1' AND (NOT StopID);
					EnablePDA_EX <= '1' AND (NOT StopEX);
					EnablePDA_MA <= '1' AND (NOT StopMA);
				WHEN OTHERS =>
					report "Error: comprobar el administrador de la CPU"
					severity FAILURE;
			END CASE;
		else
			EnableIF <= '1' AND (NOT StopIF);
			EnableID <= '1' AND (NOT StopID);
			EnableEX <= '1' AND (NOT StopEX);
			EnableMA <= '1' AND (NOT StopMA);
			EnableWB <= '1' AND (NOT StopWB);
			WAIT FOR 20 ns;
			EnablePDA_ID <= '1' AND (NOT StopID);
			EnablePDA_EX <= '1' AND (NOT StopEX);
			EnablePDA_MA <= '1' AND (NOT StopMA);
		end if;
		WAIT UNTIL falling_edge(CLK);
		EnableSM <= '0';
		if (not Pipelining) then
			CASE (cantCiclos mod 5) IS
				WHEN 0 =>
					EnableIF <= '0';
				WHEN 1 =>
					EnableID <= '0';
					WAIT FOR 20 ns;
					EnablePDA_ID <= '0'; 
				WHEN 2 =>
					EnableEX <= '0';
					WAIT FOR 20 ns;
					EnablePDA_EX <= '0';
				WHEN 3 =>
					EnableMA <= '0';
					WAIT FOR 20 ns;
					EnablePDA_MA <= '0';
				WHEN 4 =>
					EnableWB <= '0';
				WHEN OTHERS =>
					report "Error: comprobar el administrador de la CPU"
					severity FAILURE;
			END CASE;
		elsif (cantCiclos < 5) then
			CASE (cantCiclos mod 5) IS
				WHEN 0 => 
					EnableIF <= '0';
				WHEN 1 =>
					EnableIF <= '0';
					EnableID <= '0';
					WAIT FOR 20 ns;
					EnablePDA_ID <= '0';  
				WHEN 2 =>
					EnableIF <= '0';
					EnableID <= '0';
					EnableEX <= '0';
					WAIT FOR 20 ns;
					EnablePDA_ID <= '0';
					EnablePDA_EX <= '0';
				WHEN 3 =>
					EnableIF <= '0';
				   	EnableID <= '0';
					EnableEX <= '0';
					EnableMA <= '0';
					WAIT FOR 20 ns;
					EnablePDA_ID <= '0';
					EnablePDA_EX <= '0';
					EnablePDA_MA <= '0';
				WHEN 4 =>
					EnableIF <= '0';
					EnableID <= '0';
					EnableEX <= '0';
					EnableMA <= '0';
					EnableWB <= '0';
					WAIT FOR 20 ns;
					EnablePDA_ID <= '0';
					EnablePDA_EX <= '0';
					EnablePDA_MA <= '0';
				WHEN OTHERS =>
					report "Error: comprobar el administrador de la CPU"
					severity FAILURE;
			END CASE;
		else
			EnableIF <= '0';
			EnableID <= '0';
			EnableEX <= '0';
			EnableMA <= '0';
			EnableWB <= '0';
			WAIT FOR 20 ns;
			EnablePDA_ID <= '0';
			EnablePDA_EX <= '0';
			EnablePDA_MA <= '0';
		end if;
		if (cantCiclosEXFP = 0) then
			cantCiclos := cantCiclos + 1;
		end if;
	END PROCESS Main;
	

end cpu_admin_architecture;