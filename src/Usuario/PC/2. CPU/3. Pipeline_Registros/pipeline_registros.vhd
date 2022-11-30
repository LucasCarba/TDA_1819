
-- Entidad "pipeline_registros":
-- Descripción: Aquí se define el banco de registros internos intermedios para la
-- segmentación del cauce del procesador. Esta estructura resulta imprescindible para 
-- la transmisión de datos entre etapas no consecutivas conforme avanza la ejecución 
-- de la instrucción actual, ya que en caso contrario, una etapa que haya generado 
-- información requerida para otra que no se ubique inmediatamente después en el
-- cauce se estaría ejecutando nuevamente para atender la siguiente instrucción 
-- antes de que dicha información haya logrado ser procesada por la etapa destino 
-- de la misma, por lo que la misma se perdería y la instrucción original no podría 
-- completarse correctamente. En cambio, aquí existen registros adicionales con la 
-- capacidad para almacenar toda la información originada en la etapa "decode" requerida 
-- para la correcta ejecución de las etapas "memory access" y "writeback"; junto con 
-- el resultado surgido en la etapa "execute" para que pueda ser almacenado en el 
-- banco de registros de la CPU en la etapa "writeback". La existencia de este banco
-- de registros internos intermedios se basa en el concepto de que dicha información 
-- pueda ser trasladada entre los distintos registros del banco conforme avanza el ciclo 
-- de ejecución de la instrucción en cuestión hasta alcanzar la etapa hacia la cual 
-- estaba originalmente destinada, garantizándose así que la misma no se extravíe en 
-- ningún momento de la ejecución.
-- Procesos:
-- InID: Recibe la señal de habilitación desde el administrador de la CPU para luego 
-- comprobar la existencia de atascos en el cauce por dependencias estructurales o WAW. 
-- Si la respuesta es afirmativa, detiene la ejecución temporalmente hasta que el atasco 
-- sea resuelto. En caso contrario, procede a almacenar en el banco de registros internos 
-- intermedios la información originada en la etapa "decode" destinada a las etapas 
-- "memory access" y "writeback".
-- InEX: Recibe la señal de habilitación desde el administrador de la CPU para luego 
-- comprobar la existencia de atascos en el cauce por dependencias estructurales o WAW. 
-- Si la respuesta es afirmativa, detiene la ejecución temporalmente hasta que el atasco 
-- sea resuelto. En caso contrario, procede a almacenar en el banco de registros internos 
-- intermedios el resultado surgido en la etapa "execute" destinado para la etapa 
-- "writeback", añadiéndolo a los datos transmitidos desde la etapa "decode" para la misma
-- etapa "writeback"; también desplaza a través del banco de registros internos intermedios 
-- la información originada en la etapa "decode" para las etapas "memory_access" y "writeback", 
-- transmitiendo a la primera de éstas dos últimas su correspondiente información a fin de 
-- que pueda utilizarla para realizar su ejecución.
-- InMA: Recibe la señal de habilitación desde el administrador de la CPU para luego 
-- proceder a almacenar en el banco de registros internos intermedios el dato surgido en
-- la etapa "memory_access" destinado para la etapa "writeback", añadiéndolo a los datos 
-- transmitidos desde la etapa "decode" para la misma etapa "writeback"; también desplaza a
-- través del banco de registros internos intermedios la información originada en la etapa
-- "decode" para la misma etapa "writeback", transmitiéndole a esta última su correspondiente
-- información a fin de que pueda utilizarla para realizar su ejecución.


library TDA_1819;			 
use TDA_1819.const_cpu.all;
use TDA_1819.tipos_cpu.all;



library ieee;
use ieee.NUMERIC_STD.all;
use ieee.std_logic_1164.all;
library std;
use std.TEXTIO.all;



entity pipeline_registros is

    port (
		RecInMA			: out memaccess_record;
		RecInWB			: out writeback_record;
		PipeFP_4		: out std_logic;
		StallSTRW		: in  std_logic;
		StallSTR		: in  std_logic;
		StallWAWAux		: in  std_logic;
		Fp				: in  std_logic;
		IDtoMA			: in  memaccess_record;
		IDtoWB			: in  writeback_record;
		DataEXtoWB		: in  std_logic_vector(31 downto 0); 
		DataMAtoWB		: in  std_logic_vector(31 downto 0); 
		EnablePDA_ID	: in  std_logic;
		EnablePDA_EX	: in  std_logic;
		EnablePDA_MA	: in  std_logic);

end pipeline_registros;




architecture pipeline_registros_architecture of pipeline_registros is		


	SIGNAL PipeNO:		std_logic_vector(2 downto 0);
	SIGNAL PipeFP:		std_logic_vector(5 downto 0);
	SIGNAL MARecords:	memaccess_records(1 downto 0);
	SIGNAL MAFPRecords: memaccess_records(4 downto 0);
	SIGNAL WBRecords: 	writeback_records(2 downto 0);
	SIGNAL WBFPRecords: writeback_records(5 downto 0);

	
begin	
	
		
	InID: PROCESS
	
	VARIABLE First: BOOLEAN := true;
	
	BEGIN
		if (First) then
			First := false;
			PipeNO <= "ZZZ";
			PipeFP <= "ZZZZZZ";
		end if;
		WAIT UNTIL falling_edge(EnablePDA_ID);
		if ((Fp = '0') or (Fp = 'Z')) then
			PipeNO(2) <= '1';
			PipeFP(5) <= '0';
		else
			PipeNO(2) <= '0';
			PipeFP(5) <= '1';
		end if;
		MARecords(1) <= IDtoMA;
		MAFPRecords(4) <= IDtoMA;
		WBRecords(2) <= IDtoWB;
		WBFPRecords(5) <= IDtoWB;
		WAIT FOR 1 ns;
		if (StallSTR = '1') then
			MARecords(1) <= MARecords(0);
			MAFPRecords(4) <= MAFPRecords(3);
			WBRecords(2) <= WBRecords(1);
			WBFPRecords(5) <= WBFPRecords(4);
			PipeNO(2) <= PipeNO(1);
			PipeFP(5) <= PipeFP(4);
		elsif (StallWAWAux = '1') then 
			MARecords(1) <= MARecords(0);
			MAFPRecords(4) <= MAFPRecords(3);
			WBRecords(2) <= WBRecords(1);
			WBFPRecords(5) <= WBFPRecords(4);
			PipeNO(2) <= PipeNO(1);
			PipeFP(5) <= PipeFP(4);
			WAIT UNTIL falling_edge(StallWAWAux);
			WAIT FOR 1 ns;
			if (StallSTR = '1') then
				WAIT UNTIL rising_edge(EnablePDA_ID);
				WAIT UNTIL rising_edge(EnablePDA_ID);
			else
				WAIT UNTIL rising_edge(EnablePDA_ID);
			end if;
		end if;
	END PROCESS InID;
	
	
	InEX: PROCESS 
	
	VARIABLE First: BOOLEAN := true;
	
	BEGIN 
		if (First) then
			First := false;
			PipeFP_4 <= 'Z';
		end if;
		WAIT UNTIL falling_edge(EnablePDA_EX);
		MARecords(0) <= MARecords(1);
		WBRecords(1) <= WBRecords(2); 
		MAFPRecords(3) <= MAFPRecords(4);  
		MAFPRecords(2) <= MAFPRecords(3);
		MAFPRecords(1) <= MAFPRecords(2);
		MAFPRecords(0) <= MAFPRecords(1);
		WBFPRecords(4) <= WBFPRecords(5);
		WBFPRecords(3) <= WBFPRecords(4);  
		WBFPRecords(2) <= WBFPRecords(3);
		WBFPRecords(1) <= WBFPRecords(2); 
		PipeNO(1) <= PipeNO(2);	
		PipeFP_4 <= PipeFP(5);
		PipeFP(4) <= PipeFP(5);
		PipeFP(3) <= PipeFP(4);
		PipeFP(2) <= PipeFP(3);
		PipeFP(1) <= PipeFP(2);
		--MARecords(0).data.execute <= DataEXtoWB;
		WBRecords(1).data.execute <= DataEXtoWB;
		WBFPRecords(1).data.execute <= DataEXtoWB;
		WAIT FOR 1 ns;
		if ((StallSTRW = '1') or (StallWAWAux = '1')) then 
			MAFPRecords(3) <= MAFPRecords(2);
			MAFPRecords(2) <= MAFPRecords(1);
			WBRecords(1) <= WBRecords(0);
			WBFPRecords(4) <= WBFPRecords(3);
			WBFPRecords(3) <= WBFPRecords(2);
			PipeNO(1) <= PipeNO(0);
			PipeFP_4 <= PipeFP(3);
			PipeFP(4) <= PipeFP(3);
			PipeFP(3) <= PipeFP(2);
			RecInMA.mode <= std_logic_vector(to_unsigned(MEM_NULL, RecInMA.mode'length));
		elsif (PipeFP(1) = '1') then
			RecInMA <= MAFPRecords(0);
		elsif (PipeNO(1) = '1') then
			RecInMA <= MARecords(0);
		else
			RecInMA.mode <= std_logic_vector(to_unsigned(MEM_NULL, RecInMA.mode'length));
			--report "Error al cargar los datos para ejecutar la etapa de acceso a memoria"
			--severity FAILURE;
		end if;
	END PROCESS InEX;
	
	
	InMA: PROCESS
	
	BEGIN  
		WAIT UNTIL falling_edge(EnablePDA_MA);
		WBRecords(0) <= WBRecords(1);
		WBFPRecords(0) <= WBFPRecords(1);
		PipeNO(0) <= PipeNO(1);
		PipeFP(0) <= PipeFP(1);
		--WAIT FOR 1 ns;
		WBRecords(0).data.memaccess <= DataMAtoWB; 
		WBFPRecords(0).data.memaccess <= DataMAtoWB;
		WAIT FOR 1 ns;
		if (PipeFP(0) = '1') then
			RecInWB <= WBFPRecords(0);
		elsif (PipeNO(0) = '1') then
			RecInWB <= WBRecords(0);
		else
			RecInWB.mode <= std_logic_vector(to_unsigned(WB_NULL, RecInWB.mode'length));
			--report "Error al cargar los datos para ejecutar la etapa de almacenamiento en registro"
			--severity FAILURE;
		end if;
	END PROCESS InMA;
	

end pipeline_registros_architecture;