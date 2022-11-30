
-- Entidad "memoria":
-- Descripción: Aquí se define la memoria principal de la PC, tanto la sección de datos
-- como la de instrucciones. Su función es recibir simultáneamente desde el 
-- administrador de los buses de la PC información sobre las operaciones a realizar en 
-- los próximos accesos a memoria de datos y de instrucciones: en el bus de control,
-- el tipo de operación (lectura o escritura), en el bus de direcciones, la dirección en
-- memoria de datos o instrucciones a partir de la cual se llevará a cabo la operación,
-- y finalmente en el bus de datos el valor a escribir en memoria (sólo si se tratara
-- de una operación de escritura). Luego, comprobará que la dirección indicada en el 
-- bus de direcciones pertenezca efectivamente a la sección de memoria a la cual se 
-- pretende acceder. Después, en caso de ser una operación de lectura deberá leer el 
-- valor desde la sección de memoria requerida a partir de la dirección indicada en el 
-- bus de direcciones para finalmente cargarlo en el bus de datos y transmitirlo hacia 
-- el administrador de los buses para que éste a su vez lo haga llegar al dispositivo 
-- que haya solicitado la lectura (unidad de búsqueda o etapa "memory access"). En 
-- cambio, si fuera una operación de escritura tendrá que escribir el valor contenido en 
-- el bus de datos en la sección de memoria requerida a partir de la dirección señalada 
-- en el bus de direcciones, sin necesidad de realizar ninguna nueva transmisión hacia 
-- el componente que haya pedido la operación de escritura.
-- Procesos:
-- DataMemory: Gestiona el acceso a la memoria de datos de la PC, recibiendo en primer 
-- lugar la señal del administrador de los buses para comenzar un nuevo acceso a la
-- misma. Luego obtiene del bus de direcciones la dirección de memoria a acceder y del
-- bus de control el tipo de operación a realizar (lectura o escritura), para después
-- comprobar que dicha dirección efectivamente pertenezca a la sección de datos de la 
-- memoria principal. Si la comprobación fue exitosa, entonces procede a realizar el 
-- acceso propiamente dicho a la memoria de datos ya sea a fin de leer a partir de la 
-- dirección obtenida el valor contenido en ella (operación de lectura), o bien para 
-- escribir a partir de dicha dirección el valor contenido en el bus de datos recibido 
-- del administrador de los buses (operación de escritura). Finalmente, en caso de 
-- tratarse de una operación de lectura deberá cargar en el bus de datos el valor leído 
-- y luego transmitirlo hacia el administrador de los buses para que éste a su vez lo 
-- haga llegar al dispositivo que haya solicitado la lectura (etapa "memory access").
-- InstMemory: Gestiona el acceso a la memoria de instrucciones de la PC, recibiendo en
-- primer lugar la señal del administrador de los buses para comenzar un nuevo acceso a
-- la misma. Luego obtiene del bus de direcciones la dirección de memoria a acceder y del
-- bus de control el tipo de operación a realizar (lectura o escritura), para después
-- comprobar que dicha dirección efectivamente pertenezca a la sección de instrucciones
-- de la memoria principal. Si la comprobación fue exitosa, entonces procede a realizar 
-- el acceso propiamente dicho a la memoria de instrucciones ya sea a fin de leer a 
-- partir de la dirección obtenida el valor contenido en ella (operación de lectura), o 
-- bien para escribir a partir de dicha dirección el valor contenido en el bus de datos 
-- recibido del administrador de los buses (operación de escritura). Finalmente, en caso 
-- de tratarse de una operación de lectura deberá cargar en el bus de datos el valor 
-- leído y luego transmitirlo	hacia el administrador de los buses para que éste a su 
-- vez lo haga llegar al dispositivo que haya solicitado la lectura (unidad de búsqueda 
-- de la CPU).
-- FullMemory: Éste es un proceso auxiliar encargado de mantener actualizada la memoria
-- general de la PC con los últimos valores cargados tanto en la memoria de datos como
-- en la de instrucciones. Ésta "memoria general" solamente existe para que el usuario
-- pueda estar al tanto del contenido actual de toda la memoria principal de la PC a
-- partir de una única señal, pero no posee ninguna utilidad práctica para la computadora 
-- diseñada para este proyecto.


library TDA_1819;
use TDA_1819.const_memoria.all;
use TDA_1819.tipos_memoria.all;
use TDA_1819.const_buses.all;

LIBRARY IEEE;

USE std.textio.all;
use ieee.NUMERIC_STD.all;
USE IEEE.std_logic_1164.all; 




entity memoria is
	
	port (
		DataDataBusOutMem	: out std_logic_vector(31 downto 0);
		InstDataBusOutMem	: out std_logic_vector(31 downto 0);
		EnableDataMemToCpu	: out std_logic;
		EnableInstMemToCpu	: out std_logic;
		DataAddrBusMem		: in  std_logic_vector(15 downto 0);
		DataDataBusInMem	: in  std_logic_vector(31 downto 0);
		DataSizeBusMem		: in  std_logic_vector(3 downto 0);
		DataCtrlBusMem		: in  std_logic_vector(1 downto 0);
		InstAddrBusMem		: in  std_logic_vector(15 downto 0);
		InstDataBusInMem	: in  std_logic_vector(31 downto 0);
		InstSizeBusMem		: in  std_logic_vector(3 downto 0);
		InstCtrlBusMem		: in  std_logic_vector(1 downto 0);	
		EnableInDataMem		: in  std_logic;
		EnableInInstMem		: in  std_logic);

end memoria;




architecture MEMORIA_ARCHITECTURE of memoria is


	SIGNAL Memory:			type_memory(MEMORY_BEGIN to MEMORY_END);
	SIGNAL Data_Memory:		type_memory(DATA_BEGIN to INST_BEGIN-1);
	SIGNAL Inst_Memory:		type_memory(INST_BEGIN to SUBR_BEGIN-1);
	SIGNAL Subr_Memory:		type_memory(SUBR_BEGIN to STACK_BEGIN-1);
	SIGNAL Stack_Memory:	type_memory(STACK_BEGIN to MEMORY_END);

	
begin

	
	DataMemory: PROCESS
	
	VARIABLE First: BOOLEAN := true;
	VARIABLE intAddress: INTEGER; 
	VARIABLE accessSize: INTEGER;
	VARIABLE iDataBus: INTEGER;
	
	BEGIN
		WAIT UNTIL rising_edge(EnableInDataMem);
		if (First) then
			First := false;
			EnableDataMemToCpu <= '0';
			WAIT FOR 1 ps;
		end if;
		intAddress := to_integer(unsigned(DataAddrBusMem)); 
		accessSize := to_integer(unsigned(DataSizeBusMem));
		iDataBus := 0;
		if ((intAddress < DATA_BEGIN) or (intAddress > INST_BEGIN-1)) then
			report "Error: la dirección seleccionada no pertenece a la memoria de datos"
			severity FAILURE;
		end if;
		if (DataCtrlBusMem = READ_MEMORY) then
			for i in 0 to accessSize-1 loop
				for j in 0 to Data_Memory(intAddress)'LENGTH-1 loop
					DataDataBusOutMem(iDataBus) <= Data_Memory(intAddress)(j);
					iDataBus := iDataBus + 1;
				end loop;
				intAddress := intAddress + 1;
			end loop;
			EnableDataMemToCpu <= '1';
			WAIT FOR 1 ps;
			EnableDataMemToCpu <= '0';
		elsif (DataCtrlBusMem = WRITE_MEMORY) then 
			for i in 0 to accessSize-1 loop
				for j in 0 to Data_Memory(intAddress)'LENGTH-1 loop
					Data_Memory(intAddress)(j) <= DataDataBusInMem(iDataBus);
					--Memory(intAddress)(j) <= DataDataBusInMem(iDataBus);
					iDataBus := iDataBus + 1;
				end loop;
				intAddress := intAddress + 1;
			end loop;
		else
			report "Error: el bus de control de la memoria de datos no posee un valor válido"
			severity FAILURE;
		end if;
	END PROCESS DataMemory;
	
	
	InstMemory: PROCESS
	
	VARIABLE First: BOOLEAN := true;
	VARIABLE intAddress: INTEGER; 
	VARIABLE accessSize: INTEGER;
	VARIABLE iDataBus: INTEGER;
	
	BEGIN
		WAIT UNTIL rising_edge(EnableInInstMem);
		if (First) then
			First := false;
			EnableInstMemToCpu <= '0';
			WAIT FOR 1 ps;
		end if;
		intAddress := to_integer(unsigned(InstAddrBusMem)); 
		accessSize := to_integer(unsigned(InstSizeBusMem));
		iDataBus := 0;
		if ((intAddress < INST_BEGIN) or (intAddress > SUBR_BEGIN-1)) then
			report "Error: la dirección seleccionada no pertenece a la memoria de instrucciones"
			severity FAILURE;
		end if;
		if (InstCtrlBusMem = READ_MEMORY) then
			for i in 0 to accessSize-1 loop
				for j in 0 to Inst_Memory(intAddress)'LENGTH-1 loop
					InstDataBusOutMem(iDataBus) <= Inst_Memory(intAddress)(j);
					iDataBus := iDataBus + 1;
				end loop;
				intAddress := intAddress + 1;
			end loop;
			EnableInstMemToCpu <= '1';
			WAIT FOR 1 ps;
			EnableInstMemToCpu <= '0'; 
		elsif (InstCtrlBusMem = WRITE_MEMORY) then
			for i in 0 to accessSize-1 loop
				for j in 0 to Data_Memory(intAddress)'LENGTH-1 loop
					Inst_Memory(intAddress)(j) <= InstDataBusInMem(iDataBus);
					--Memory(intAddress)(j) <= InstDataBusInMem(iDataBus);
					iDataBus := iDataBus + 1;
				end loop;
				intAddress := intAddress + 1;
			end loop;
		else
			report "Error: el bus de control de la memoria de instrucciones no posee un valor válido"
			severity FAILURE;
		end if;
	END PROCESS InstMemory;	 
	
	
	FullMemory: PROCESS	  
	
	VARIABLE intAddress: INTEGER; 
	VARIABLE accessSize: INTEGER;
	VARIABLE iDataBus: INTEGER;
	
	BEGIN
		WAIT UNTIL (rising_edge(EnableInDataMem) OR rising_edge(EnableInInstMem)); 
		if ((EnableInDataMem = '1') and (DataCtrlBusMem = WRITE_MEMORY)) then
			intAddress := to_integer(unsigned(DataAddrBusMem)); 
			accessSize := to_integer(unsigned(DataSizeBusMem));
			iDataBus := 0;
			for i in 0 to accessSize-1 loop
				for j in 0 to Data_Memory(intAddress)'LENGTH-1 loop
					Memory(intAddress)(j) <= DataDataBusInMem(iDataBus);
					iDataBus := iDataBus + 1;
				end loop;
				intAddress := intAddress + 1;
			end loop;
		elsif ((EnableInInstMem = '1') and (InstCtrlBusMem = WRITE_MEMORY)) then 
			intAddress := to_integer(unsigned(InstAddrBusMem)); 
			accessSize := to_integer(unsigned(InstSizeBusMem));
			iDataBus := 0;
			for i in 0 to accessSize-1 loop
				for j in 0 to Data_Memory(intAddress)'LENGTH-1 loop	   
					Memory(intAddress)(j) <= InstDataBusInMem(iDataBus);
					iDataBus := iDataBus + 1;
				end loop;
				intAddress := intAddress + 1;
			end loop;
		end if;
	END PROCESS FullMemory;
				
		
end MEMORIA_ARCHITECTURE;





