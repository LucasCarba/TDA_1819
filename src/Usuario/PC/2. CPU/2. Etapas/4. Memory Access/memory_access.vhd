
-- Entidad "memory_access":
-- Descripción: Aquí se define la etapa de acceso a memoria de la segmentación del 
-- procesador, la cual recibe del banco de registros internos del pipeline toda la 
-- información originada en la etapa "decode" necesaria para llevar a cabo dicha 
-- operación de acceso: tipo de acceso (nulo, a memoria o a un periférico de E/S), 
-- modo de acceso (lectura o escritura), dirección de memoria o puerto del periférico
-- a partir de la cual deberá realizarse el acceso, ya sea para leer o escribir en él, 
-- tamaño del operando involucrado en la operación (8, 16 ó 32 bits), y finalmente el 
-- dato propiamente dicho (en caso de tratarse de una escritura). Con esta información,
-- procede a acceder a la memoria de datos de la PC o al periférico de E/S según 
-- corresponda y obtiene o actualiza el valor requerido por la instrucción actual.
-- Finalmente, sólo en caso de tratarse de una operación de lectura, esta etapa
-- transmitirá el dato leído al banco de registros internos del pipeline para que éste
-- a su vez lo haga llegar a la etapa "writeback" a fin de que ésta lo utilice para
-- actualizar el banco de registros de la CPU. Obviamente, si la instrucción actual
-- no requiere acceder a memoria (tipo de acceso nulo), entonces no se llevará a cabo 
-- ningún tipo de acción en esta etapa.
-- Procesos:
-- Main: En primer lugar, recibe la señal del administrador de la CPU para comenzar la
-- etapa de acceso a memoria de una nueva instrucción. Aquí no se lleva a cabo ningún
-- tipo de detección de atascos en el cauce ya que todos los detectores implementados
-- tanto en las etapas anteriores del pipeline como en el banco de registros internos
-- de la segmentación garantizan que no se realizarán accesos indebidos a memoria en
-- caso de que el cauce se encuentre atascado debido a alguna dependencia estructural,
-- de datos o de control. Por lo tanto, este proceso se encarga simplemente de, en la
-- segunda mitad del ciclo de reloj, comprobar el tipo y el modo de acceso para 
-- determinar, en primer lugar, si efectivamente debe realizarse alguna acción en esta
-- etapa del pipeline y luego, en caso afirmativo, a qué dispositivo necesita acceder:
-- memoria de datos o un periférico de E/S, transmitiendo a través del bus de datos de 
-- la PC el dato a escribir e impartiendo la orden de escritura mediante el bus de 
-- control (si se trata de una escritura); o bien emitiendo la orden de lectura	a 
-- través del bus de control y recibiendo en el bus de datos el dato leído (si se trata
-- de una lectura). Nótese que en ambos casos será necesario escribir en el bus de 
-- direcciones la dirección en memoria de datos o el puerto del periférico de E/S a 
-- partir del cual se efectuará el acceso. Por último, sólo si se hubiera tratado de 
-- una operación de lectura, el dato leído será transmitido al banco de registros 
-- internos del pipeline ya que indudablemente deberá ser utilizado para actualizar el 
-- banco de registros de la CPU, de lo cual se ocupará la última etapa de la 
-- segmentación: "writeback".


library TDA_1819;	
use TDA_1819.const_buses.all;
use TDA_1819.const_cpu.all;
use TDA_1819.tipos_cpu.all; 


LIBRARY IEEE;

USE std.textio.all;
use ieee.NUMERIC_STD.all;
USE IEEE.std_logic_1164.all; 




entity memory_access is
	
	port (
		DataAddrBusCpu		: out std_logic_vector(15 downto 0);
		DataDataBusOutCpu	: out std_logic_vector(31 downto 0);
		DataSizeBusCpu		: out std_logic_vector(3 downto 0);
		DataCtrlBusCpu		: out std_logic_vector(1 downto 0);
		EnableCpuToDataMem	: out std_logic;
		DataMAtoWB			: out std_logic_vector(31 downto 0);
		RecInMA				: in  memaccess_record;
		DataDataBusInCpu	: in  std_logic_vector(31 downto 0);
		EnableInDataCpu		: in  std_logic;
		EnableMA			: in  std_logic);

end memory_access;




architecture MEMORY_ACCESS_ARCHITECTURE of memory_access is


	
begin
	
	
	Main: PROCESS  
	
	VARIABLE First: BOOLEAN := true;
	VARIABLE Mode: INTEGER;
	VARIABLE Source: INTEGER;
	VARIABLE SizeBits: INTEGER;
	
	BEGIN 
		WAIT UNTIL rising_edge(EnableMA);
		if (First) then
			First := false;
			EnableCpuToDataMem <= '0';
			WAIT FOR 1 ns;
		end if;
		WAIT UNTIL falling_edge(EnableMA);
		Mode := to_integer(unsigned(RecInMA.mode));
		CASE Mode IS
			WHEN MEM_NULL =>
				NULL;
			WHEN MEM_MEM =>	
				SizeBits := to_integer(unsigned(RecInMA.datasize))*8;
				DataAddrBusCpu <= RecInMA.address;
				DataSizeBusCpu <= RecInMA.datasize;
				DataDataBusOutCpu <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"; 
				if (RecInMA.read = '1') then
					DataCtrlBusCpu <= READ_MEMORY;
					EnableCpuToDataMem <= '1';
					WAIT FOR 1 ns;
					EnableCpuToDataMem <= '0';
					WAIT FOR 1 ns;
					--WAIT UNTIL rising_edge(EnableInDataCpu);
					for i in 31 downto SizeBits loop
						DataMAtoWB(i) <= 'Z';
					end loop;
					for i in SizeBits-1 downto 0 loop
						DataMAtoWB(i) <= DataDataBusInCpu(i);
					end loop;
				elsif (RecInMA.write = '1') then
					Source := to_integer(unsigned(RecInMA.source));
					if (Source = MEM_ID) then
						for i in SizeBits-1 downto 0 loop
							DataDataBusOutCpu(i) <= RecInMA.data.decode(i);
						end loop;
					elsif (Source = MEM_EX) then
						for i in SizeBits-1 downto 0 loop
							DataDataBusOutCpu(i) <= RecInMA.data.execute(i);
						end loop;
					end if;
					DataCtrlBusCpu <= WRITE_MEMORY;
					EnableCpuToDataMem <= '1';
					WAIT FOR 1 ns;
					EnableCpuToDataMem <= '0';
					WAIT FOR 1 ns;
				else
					report "Error: el modo de acceso a memoria no es válido"
					severity FAILURE;
				end if;
			WHEN MEM_PER =>
				NULL;
			WHEN OTHERS =>
				report "Error: la configuración de la etapa de acceso a memoria no es válida"
				severity FAILURE;
		END CASE;
	END PROCESS Main; 
	
	
end MEMORY_ACCESS_ARCHITECTURE;





