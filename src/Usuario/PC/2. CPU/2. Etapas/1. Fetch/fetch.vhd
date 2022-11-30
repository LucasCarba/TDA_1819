
-- Entidad "fetch":
-- Descripción: Aquí se define la etapa de búsqueda de la segmentación del procesador:
-- obtiene del Puntero de Instrucciones (IP) la dirección de la próxima instrucción a
-- ser ejecutada, accede a dicha dirección en la memoria de instrucciones de la PC para
-- obtener a partir de ella el código de operación y, si correspondiera, la información
-- vinculada a los operandos, escribiendo el primero en el Registro de Instrucción (IR) 
-- y transmitiendo la última directamente a la etapa "decode" para que pueda hacer 
-- uso de ella como lo disponga. Finalmente, actualiza el registro IP para que apunte 
-- a la dirección de la siguiente instrucción a ser ejecutada.
-- Procesos:
-- Main: En primer lugar, recibe la señal del administrador de la CPU para comenzar la
-- etapa de búsqueda de una nueva instrucción. Luego, en la primera mitad del ciclo de
-- reloj comprueba si existen actualmente atascos de algún tipo en el cauce, deteniendo 
-- temporalmente la ejecución en caso afirmativo. Finalmente, en la segunda mitad del 
-- ciclo lleva a cabo la búsqueda propiamente dicha, accediendo para leer tanto al 
-- registro IP como a la memoria de instrucciones y actualizando los registros IP e IR 
-- y las señales enviadas a la etapa "decode" que contienen la información de los 
-- operandos de la próxima instrucción a decodificar.


library TDA_1819;	
use TDA_1819.const_buses.all;
use TDA_1819.tipos_cpu.all;


library ieee;
use ieee.NUMERIC_STD.all;
use ieee.std_logic_1164.all;
library std;
use std.TEXTIO.all;



entity fetch is
   
    port (
		IFtoID				: out decode_record;
		InstAddrBusCpu		: out std_logic_vector(15 downto 0);
		InstDataBusOutCpu	: out std_logic_vector(31 downto 0);
		InstSizeBusCpu		: out std_logic_vector(3 downto 0);
		InstCtrlBusCpu		: out std_logic_vector(1 downto 0);
		EnableRegIFIPRd		: out std_logic;
		EnableRegIFIRWr		: out std_logic;		
		EnableRegIFIPWr		: out std_logic;
		EnableCpuToInstMem	: out std_logic;
		DataRegInIF			: out std_logic_vector(31 downto 0);
		DataRegOutIF		: in  std_logic_vector(31 downto 0);
		InstDataBusInCpu	: in  std_logic_vector(31 downto 0);
		StallSTR			: in  std_logic;
		StallRAW			: in  std_logic;
		StallWAWAux			: in  std_logic;
		StallBrEX			: in  std_logic;
		EnableInInstCpu		: in  std_logic;
		EnableIF			: in  std_logic);
		
end fetch;




architecture fetch_architecture of fetch is		
		
	
begin
		
		
	Main: PROCESS  
	
	VARIABLE First: 		BOOLEAN := true;
	VARIABLE Local_IP: 		INTEGER;
	VARIABLE InstSize:		INTEGER;
	VARIABLE SizeBus:		INTEGER;
	VARIABLE SizeDataID:	INTEGER;
	
	BEGIN 
		WAIT UNTIL rising_edge(EnableIF);
		--report "Fetch" severity WARNING;
		if (First) then
			First := false;		
			EnableRegIFIPRd <= '0';
			EnableRegIFIRWr <= '0';
			EnableRegIFIPWr	<= '0';
			EnableCpuToInstMem <= '0';
			WAIT FOR 1 ns;
		end if;	   
		if (StallRAW = '1') then							  
			WAIT UNTIL falling_edge(StallRAW);
			WAIT UNTIL rising_edge(EnableIF);
			WAIT UNTIL rising_edge(EnableIF);
			--último cambio	 
			if (StallBrEX = '1') then
				WAIT UNTIL rising_edge(EnableIF);
			end if;
		elsif (StallBrEX = '1') then
			if (StallSTR = '1') then
				WAIT UNTIL falling_edge(StallSTR);
				WAIT UNTIL rising_edge(EnableIF);
				WAIT UNTIL rising_edge(EnableIF);
			elsif (StallWAWAux = '1') then
				WAIT UNTIL falling_edge(StallWAWAux);
				WAIT UNTIL rising_edge(EnableIF);
				if (StallSTR = '1') then
					WAIT UNTIL rising_edge(EnableIF);
					WAIT UNTIL rising_edge(EnableIF);
				else
					WAIT UNTIL rising_edge(EnableIF);
				end if;
			elsif (SizeBus > 0) then
				WAIT FOR 1 ns;
				if (StallWAWAux = '1') then
					WAIT UNTIL falling_edge(StallWAWAux);
					WAIT UNTIL rising_edge(EnableIF);
					if (StallSTR = '1') then
						WAIT UNTIL rising_edge(EnableIF);
					end if;
				--else
				elsif (StallBrEX = '1') then					
					WAIT UNTIL rising_edge(EnableIF);
					if (StallSTR = '1') then
						WAIT UNTIL rising_edge(EnableIF);
					end if;
				end if;
			end if;
		elsif (StallSTR = '1') then	
			WAIT UNTIL falling_edge(StallSTR);
			if (StallWAWAux = '1') then
				WAIT UNTIL falling_edge(StallWAWAux);
			end if;
			WAIT UNTIL rising_edge(EnableIF);
		elsif (StallWAWAux = '1') then
			WAIT UNTIL falling_edge(StallWAWAux);
			WAIT FOR 1 ns;
			if (StallSTR = '1') then
				WAIT UNTIL rising_edge(EnableIF);
				WAIT UNTIL rising_edge(EnableIF);
			else
				WAIT UNTIL rising_edge(EnableIF);
			end if;
		end if;	
		WAIT UNTIL falling_edge(EnableIF);
		EnableRegIFIPRd <= '1';
		WAIT FOR 1 ns;
		EnableRegIFIPRd <= '0';
		WAIT FOR 1 ns;
		Local_IP := to_integer(unsigned(DataRegOutIF(15 downto 0)));
		InstAddrBusCpu <= std_logic_vector(to_unsigned(Local_IP, InstAddrBusCpu'length));
		InstSizeBusCpu <= std_logic_vector(to_unsigned(1, InstSizeBusCpu'length));
		InstCtrlBusCpu <= READ_MEMORY; 
		EnableCpuToInstMem <= '1';
		WAIT FOR 1 ns;
		EnableCpuToInstMem <= '0';	
		--WAIT UNTIL rising_edge(EnableInInstCpu);
		WAIT FOR 1 ns;
		if (InstDataBusInCpu(7 downto 0) = "UUUUUUUU") then
			InstSize := 0;
		else
			InstSize := to_integer(unsigned(InstDataBusInCpu(7 downto 0)));
		end if;
		SizeBus := InstSize - 1;
		SizeDataID := InstSize - 2;	 
		if ((SizeBus > 0) or (StallBrEX = '0')) then
			if (SizeBus <= 4) then
				if (SizeBus <= 0) then
					WAIT UNTIL rising_edge(EnableIF);
				end if;
				InstAddrBusCpu <= std_logic_vector(to_unsigned(Local_IP+1, InstAddrBusCpu'length));
				InstSizeBusCpu <= std_logic_vector(to_unsigned(SizeBus, InstSizeBusCpu'length));
				InstCtrlBusCpu <= READ_MEMORY;
				EnableCpuToInstMem <= '1';
				WAIT FOR 1 ns;
				EnableCpuToInstMem <= '0';	
				--WAIT UNTIL rising_edge(EnableInInstCpu); 
				WAIT FOR 1 ns;
				DataRegInIF(31 downto 8) <= "ZZZZZZZZZZZZZZZZZZZZZZZZ";
				DataRegInIF(7 downto 0) <= InstDataBusInCpu(7 downto 0);
				EnableRegIFIRWr <= '1';
				WAIT FOR 1 ns;
				EnableRegIFIRWr <= '0';
				WAIT FOR 1 ns;
				if (SizeDataID > 0) then
					for i in 31 downto SizeDataID*8 loop
						IFtoID.package1(i) <= 'Z';
					end loop;
					for i in SizeDataID*8-1 downto 0 loop
						IFtoID.package1(i) <= InstDataBusInCpu(i+8);
					end loop;
				end if;
			else
				InstAddrBusCpu <= std_logic_vector(to_unsigned(Local_IP+1, InstAddrBusCpu'length));
				InstSizeBusCpu <= std_logic_vector(to_unsigned(4, InstSizeBusCpu'length));
				SizeBus := SizeBus - 4;
				InstCtrlBusCpu <= READ_MEMORY;
				EnableCpuToInstMem <= '1';
				WAIT FOR 1 ns;
				EnableCpuToInstMem <= '0';	
				--WAIT UNTIL rising_edge(EnableInInstCpu); 
				WAIT FOR 1 ns;
				DataRegInIF(31 downto 8) <= "ZZZZZZZZZZZZZZZZZZZZZZZZ";
				DataRegInIF(7 downto 0) <= InstDataBusInCpu(7 downto 0);
				EnableRegIFIRWr <= '1';
				WAIT FOR 1 ns;
				EnableRegIFIRWr <= '0';
				WAIT FOR 1 ns;
				for i in 31 downto 24 loop
					IFtoID.package1(i) <= 'Z';
				end loop;
				for i in 23 downto 0 loop
					IFtoID.package1(i) <= InstDataBusInCpu(i+8);
				end loop;
				SizeDataID := SizeDataID - 3;
				InstAddrBusCpu <= std_logic_vector(to_unsigned(Local_IP+5, InstAddrBusCpu'length));
				InstSizeBusCpu <= std_logic_vector(to_unsigned(SizeBus, InstSizeBusCpu'length));
				InstCtrlBusCpu <= READ_MEMORY;
				EnableCpuToInstMem <= '1';
				WAIT FOR 1 ns;
				EnableCpuToInstMem <= '0';	 
				--WAIT UNTIL rising_edge(EnableInInstCpu);
				WAIT FOR 1 ns;
				for i in 31 downto SizeDataID*8 loop
					IFtoID.package2(i) <= 'Z';
				end loop;
				for i in SizeDataID*8-1 downto 0 loop
					IFtoID.package2(i) <= InstDataBusInCpu(i);
				end loop;
			end if;
			Local_IP := Local_IP + InstSize;
			DataRegInIF(31 downto 16) <= "ZZZZZZZZZZZZZZZZ";
			DataRegInIF(15 downto 0) <= std_logic_vector(to_unsigned(Local_IP, DataRegInIF(15 downto 0)'length));  
			EnableRegIFIPWr <= '1';
			WAIT FOR 1 ns;
			EnableRegIFIPWr <= '0';
			WAIT FOR 1 ns;
		end if;
	END PROCESS Main;		
				
	
end fetch_architecture;