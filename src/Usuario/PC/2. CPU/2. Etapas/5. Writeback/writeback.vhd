
-- Entidad "writeback":
-- Descripción: Aquí se define la última etapa de la segmentación del procesador: la
-- del almacenamiento en registro, la cual recibe del banco de registros internos
-- intermedios del pipeline toda la información originada en la etapa "decode" necesaria 
-- para gestionar esta tarea: tipo de acceso a registro (número de registro a acceder, 
-- o nulo si no es necesario actualizar el banco de registros), tamaño del dato a escribir 
-- (8, 16 ó 32 bits), origen del dato (etapa "decode", "execute" o "memory access") y 
-- finalmente el dato propiamente dicho. Con esta información, procede a acceder 
-- efectivamente al banco de registros del procesador para actualizar el registro que
-- corresponda con el valor indicado por la instrucción actual. Obviamente, si dicha
-- instrucción no necesita sobrescribir alguno de estos registros (tipo de acceso 
-- nulo), entonces no se llevará a cabo ningún tipo de acción en esta etapa. De esta 
-- manera concluiría finalmente el ciclo de ejecución de una instrucción en la CPU 
-- diseñada para este proyecto.
-- Procesos:
-- Main: En primer lugar, recibe la señal del administrador de la CPU para comenzar la
-- etapa de almacenamiento en registro de una nueva instrucción. Luego, en la primera 
-- mitad del ciclo de reloj comprueba si existen actualmente atascos de algún tipo en el 
-- cauce, deteniendo temporalmente la ejecución en caso afirmativo. Finalmente, en la 
-- segunda mitad del ciclo lleva a cabo el almacenamiento en registro propiamente 
-- dicho, determinando a partir de la información recibida del banco de registros 
-- internos del pipeline si es necesario acceder al banco de registros y, en caso 
-- afirmativo, cuál es exactamente el registro a sobrescribir y el dato involucrado en
-- la operación de escritura, para luego proceder a acceder a dicho banco y realizar 
-- efectivamente la actualización de dicho registro.
-- Procedimientos y funciones:
-- InitializeRecInWBAux() y InitializeRecInWBAux2(): Inicializan señales internas de esta etapa 
-- que estarían cumpliendo una función similar a la señal recibida del banco de registros 
-- intermedios de la segmentación con toda la información necesaria para gestionar esta etapa del
-- pipeline, con la salvedad de que estas señales sólo serán utilizadas en caso de que se 
-- encuentren involucrados atascos de tipo WAW o estructurales en esta etapa cuya consecuencia 
-- haya sido que la información ya no pueda provenir directamente del banco de registros 
-- intermedios de la segmentación sino de una ejecución anterior de la etapa "writeback" o bien 
-- del detector de dependencias de datos RAW y WAW incluido en este procesador según corresponda.


library TDA_1819;	
use TDA_1819.const_buses.all;
use TDA_1819.const_cpu.all; 
use TDA_1819.tipos_cpu.all; 


LIBRARY IEEE;

USE std.textio.all;
use ieee.NUMERIC_STD.all;
USE IEEE.std_logic_1164.all; 




entity writeback is
	
	port (
		DataRegInWB			: out std_logic_vector(31 downto 0);
		IdRegWB				: out std_logic_vector(7 downto 0);
		SizeRegWB			: out std_logic_vector(3 downto 0);
		EnableRegWB			: out std_logic;
		WbRegCheckWAW		: out writeback_record;
		IdRegDecWrPend		: out std_logic_vector(7 downto 0);
		DoneSTRW 			: out std_logic;
		EnableCheckWAW		: out std_logic;
		EnableDecWrPend		: out std_logic;
		WbRegDoneWAW		: in  writeback_record;
		DoneWAW				: in  std_logic;
		StallWAW			: in  std_logic;
		StallSTR			: in  std_logic;
		RecInWB				: in  writeback_record;
		EnableWB			: in  std_logic);

end writeback;




architecture WRITEBACK_ARCHITECTURE of writeback is


	SIGNAL RecInWBAct: writeback_record;
	SIGNAL RecInWBAux: writeback_record;
	SIGNAL RecInWBAux2: writeback_record;
	SIGNAL IdRecWAW: std_logic_vector(7 downto 0);

	
begin
	
	
	Main: PROCESS 
	
	VARIABLE First: BOOLEAN := true;
	VARIABLE Mode: INTEGER;
	VARIABLE Source: INTEGER;
	VARIABLE SizeBits: INTEGER;
	
	PROCEDURE InitializeRecInWBAux IS
	
	BEGIN
		RecInWBAux.mode <= std_logic_vector(to_unsigned(WB_NULL, RecInWBAux.mode'length));
		RecInWBAux.id <= "ZZZZZZZZ";
		RecInWBAux.datasize <= "ZZZZ";
		RecInWBAux.source <= "ZZZZ";
		RecInWBAux.data.decode <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	END InitializeRecInWBAux;
	
	PROCEDURE InitializeRecInWBAux2 IS
	
	BEGIN
		RecInWBAux2.mode <= std_logic_vector(to_unsigned(WB_NULL, RecInWBAux.mode'length));
		RecInWBAux2.id <= "ZZZZZZZZ";
		RecInWBAux2.datasize <= "ZZZZ";
		RecInWBAux2.source <= "ZZZZ";
		RecInWBAux2.data.decode <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	END InitializeRecInWBAux2;
	
	BEGIN 
		if (First) then
			First := false;
			IdRecWAW <= "ZZZZZZZZ";
			DoneSTRW <= '0';
			EnableRegWB <= '0';
			EnableCheckWAW <= '0';
			EnableDecWrPend <= '0';
			InitializeRecInWBAux;
			InitializeRecInWBAux2;
			WAIT FOR 1 ns;
		end if;
		WAIT UNTIL rising_edge(EnableWB);
		WbRegCheckWAW <= RecInWB;
		EnableCheckWAW <= '1';
		WAIT FOR 1 ns;
		EnableCheckWAW <= '0';
		if (StallWAW = '0') then
			if (to_integer(unsigned(RecInWBAux.mode)) = WB_NULL) then
				if (IdRecWAW /= "ZZZZZZZZ") then
					if (RecInWB.id < IdRecWAW) then	
						IdRegDecWrPend <= RecInWB.mode;
						EnableDecWrPend <= '1';
						WAIT FOR 1 ns;
						EnableDecWrPend <= '0';
						RecInWBAct <= RecInWB;
						Mode := to_integer(unsigned(RecInWB.mode));
						--Source := to_integer(unsigned(RecInWB.source));
						--SizeBits := to_integer(unsigned(RecInWB.datasize))*8;
					else
						Mode := WB_NULL;
						RecInWBAux2 <= RecInWB;
					end if;
				elsif (to_integer(unsigned(RecInWBAux2.mode)) /= WB_NULL) then
					IdRegDecWrPend <= RecInWBAux2.mode;
					EnableDecWrPend <= '1';
					WAIT FOR 1 ns;
					EnableDecWrPend <= '0';
					RecInWBAct <= RecInWBAux2;
					Mode := to_integer(unsigned(RecInWBAux2.mode));
					--Source := to_integer(unsigned(RecInWBAux2.source));
					--SizeBits := to_integer(unsigned(RecInWBAux2.datasize))*8;
					InitializeRecInWBAux2;
				else
					IdRegDecWrPend <= RecInWB.mode;
					EnableDecWrPend <= '1';
					WAIT FOR 1 ns;
					EnableDecWrPend <= '0';
					RecInWBAct <= RecInWB;
					Mode := to_integer(unsigned(RecInWB.mode));
					--Source := to_integer(unsigned(RecInWB.source));
					--SizeBits := to_integer(unsigned(RecInWB.datasize))*8;
				end if;
			elsif (StallSTR = '1') then
				DoneSTRW <= '1';
				if (to_integer(unsigned(RecInWBAux2.mode)) /= WB_NULL) then
					IdRegDecWrPend <= RecInWBAux.mode;
					EnableDecWrPend <= '1';
					WAIT FOR 1 ns;
					EnableDecWrPend <= '0';
					DoneSTRW <= '0';
					RecInWBAct <= RecInWBAux;
					Mode := to_integer(unsigned(RecInWBAux.mode));
					--Source := to_integer(unsigned(RecInWBAux.source));
					--SizeBits := to_integer(unsigned(RecInWBAux.datasize))*8;
					InitializeRecInWBAux;
				elsif (RecInWB.id < RecInWBAux.id) then
					IdRegDecWrPend <= RecInWB.mode;
					EnableDecWrPend <= '1';
					WAIT FOR 1 ns;
					EnableDecWrPend <= '0';
					RecInWBAct <= RecInWB;
					Mode := to_integer(unsigned(RecInWB.mode));
					--Source := to_integer(unsigned(RecInWB.source));
					--SizeBits := to_integer(unsigned(RecInWB.datasize))*8;
				else
					IdRegDecWrPend <= RecInWBAux.mode;
					EnableDecWrPend <= '1';
					WAIT FOR 1 ns;
					EnableDecWrPend <= '0';
					DoneSTRW <= '0';
					RecInWBAct <= RecInWBAux;
					Mode := to_integer(unsigned(RecInWBAux.mode));
					--Source := to_integer(unsigned(RecInWBAux.source));
					--SizeBits := to_integer(unsigned(RecInWBAux.datasize))*8;
					InitializeRecInWBAux;
				end if;
			else
				IdRegDecWrPend <= RecInWBAux.mode;
				EnableDecWrPend <= '1';
				WAIT FOR 1 ns;
				EnableDecWrPend <= '0';
				DoneSTRW <= '0';
				RecInWBAct <= RecInWBAux;
				Mode := to_integer(unsigned(RecInWBAux.mode));
				--Source := to_integer(unsigned(RecInWBAux.source));
				--SizeBits := to_integer(unsigned(RecInWBAux.datasize))*8;
				InitializeRecInWBAux;
			end if;
			if (DoneWAW = '1') then
				RecInWBAux <= WbRegDoneWAW;
				IdRecWAW <= "ZZZZZZZZ";
			end if;
		else
			Mode := WB_NULL;
			IdRecWAW <= RecInWB.id;
		end if;
		WAIT UNTIL falling_edge(EnableWB);
		if (Mode /= WB_NULL) then												 
			Source := to_integer(unsigned(RecInWBAct.source));
			SizeBits := to_integer(unsigned(RecInWBAct.datasize))*8;
			IdRegWB <= std_logic_vector(to_unsigned(Mode-1, IdRegWB'length));	 
			SizeRegWB <= RecInWBAct.datasize;
			DataRegInWB <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
			--for i in DataRegInWB'length-1 downto SizeBits loop
				--DataRegInWB(i) <= '0';
			--end loop;
			CASE Source IS
				WHEN WB_ID =>
					for i in SizeBits-1 downto 0 loop
						DataRegInWB(i) <= RecInWBAct.data.decode(i);
					end loop;
				WHEN WB_EX =>
					for i in SizeBits-1 downto 0 loop
						DataRegInWB(i) <= RecInWBAct.data.execute(i);
					end loop;
				WHEN WB_MEM =>
					for i in SizeBits-1 downto 0 loop
						DataRegInWB(i) <= RecInWBAct.data.memaccess(i);
					end loop;
				WHEN OTHERS =>
					report "Error: la configuración de la etapa de almacenamiento en registro no es válida"
					severity FAILURE;
			END CASE;
			EnableRegWB <= '1';
			WAIT FOR 1 ns;
			EnableRegWB <= '0';
			WAIT FOR 1 ns;
		end if;
		--IdRegDecWrPend <= RecInWB.mode;
		--EnableDecWrPend <= '1';
		--WAIT FOR 1 ns;
		--EnableDecWrPend <= '0';
	END PROCESS Main; 
	
	
end WRITEBACK_ARCHITECTURE;





