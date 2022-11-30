
-- Entidad "execute":
-- Descripción: Aquí se define el administrador para la etapa de ejecución de la segmentación 
-- del procesador, el cual recibe de la etapa de decodificación	toda la información necesaria 
-- para poder trabajar: el tipo de operación (nula, suma, resta, and, or, salto condicional, 
-- etc.) a realizar, el tipo de operandos (entero o punto flotante, con o sin signo) y los 
-- operandos propiamente dichos. Luego, si correspondiera, habilita en función del tipo de 
-- operandos la unidad de ejecución más adecuada: ALU (unidad aritmético-lógica) para operandos
-- enteros o FPU (unidad de punto flotante) para operandos en punto flotante, y le proporciona 
-- exactamente la misma información recibida de la etapa "decode" para que pueda realizar la 
-- operación aritmético-lógica requerida. Finalmente, si es necesario envía el resultado de la 
-- unidad habilitada al banco de registros internos para la segmentación a fin de que éste se 
-- encargue de transmitirlo a la etapa "writeback", la cual a su vez se ocupará de escribirlo 
-- en el banco de registros del procesador. Cabe agregar que, mientras la ejecución de una 
-- operación en la ALU requiere un único ciclo de reloj para completarse, en la FPU, al ser más 
-- compleja, necesita cuatro ciclos para ser llevada a cabo sin importar su naturaleza (suma, 
-- resta, multiplicación, división, etc.).
-- Procesos:
-- Main: En primer lugar, recibe la señal del administrador de la CPU para comenzar la
-- etapa de ejecución de una nueva instrucción. Luego, en la primera mitad del ciclo de
-- reloj comprueba si existen actualmente atascos de algún tipo en el cauce, deteniendo
-- temporalmente la ejecución en caso afirmativo. Finalmente, en la segunda mitad del ciclo 
-- lleva a cabo la ejecución propiamente dicha, habilitando la unidad de ejecución que 
-- corresponda en función del tipo de los operandos (o no habilitando ninguna en caso de que 
-- la instrucción no requiera la ejecución de una operación aritmético-lógica) y 
-- proporcionándole la información recibida de la etapa "decode" para que pueda trabajar 
-- correctamente, y luego obteniendo el resultado devuelto por la misma para enviárselo al 
-- banco de registros internos para la segmentación.
-- Procedimientos y funciones:
-- InitializeIDtoEX(): Configura y carga toda la información inicial a enviar a las dos unidades 
-- disponibles, antes de que una de ellas sea modificada durante la ejecución de esta etapa 
-- del pipeline: operaciones nulas, operandos y direcciones vacías, etc.
-- InitializeAllIDtoEX(): Este procedimiento se invoca una única vez durante la primera 
-- ejecución de este administrador para asignar valores iniciales válidos y nulos a todas sus 
-- señales internas auxiliares encargadas de almacenar información recibida de la etapa de
-- decodificación a fin de que no ocurra ningún inconveniente durante la ejecución de la
-- simulación por intentar leer señales que aún no hayan sido previamente inicializadas.


library TDA_1819;
use TDA_1819.const_cpu.all;
use TDA_1819.const_flags.all;
use TDA_1819.tipos_cpu.all;

LIBRARY IEEE;

USE std.textio.all;
use ieee.NUMERIC_STD.all;
USE IEEE.std_logic_1164.all; 

library ieee_proposed;
use ieee_proposed.float_pkg.all;




entity execute is
	
	port ( 
		BranchEXALUtoSM		: out 	state_branch;
		DataRegInEXALU		: out 	std_logic_vector(31 downto 0);
		DataRegInEXFPU		: out 	std_logic_vector(31 downto 0);
		EnableRegEXALURd	: out 	std_logic;
		EnableRegEXFPURd	: out 	std_logic;
		EnableRegEXALUWr	: out 	std_logic;
		EnableRegEXFPUWr	: out 	std_logic;
		EnableRegEXALUIP	: out 	std_logic;
		EnableDecFPWrPend	: out 	std_logic;
		DataEXtoWB			: out 	std_logic_vector(31 downto 0);
		EnableCheckSTRM		: out 	std_logic;
		EXFPUPending		: out	std_logic;
		EnableEXALU			: inout std_logic;
		EnableEXFPU			: inout std_logic;
		StallSTR			: in  	std_logic;
		StallWAWAux			: in	std_logic;
		IDtoEX				: in  	execute_record;
		DataRegOutEXALU		: in  	std_logic_vector(31 downto 0);
		DataRegOutEXFPU		: in  	std_logic_vector(31 downto 0);
		EnableEX			: in  	std_logic);

end execute;




architecture EXECUTE_ARCHITECTURE of execute is


	-- Component declaration of the tested unit
	component execute_alu
		port ( 
			BranchEXALUtoSM		: out state_branch;
			DataRegInEXALU		: out std_logic_vector(31 downto 0);
			EnableRegEXALURd	: out std_logic;
			EnableRegEXALUWr	: out std_logic;
			EnableRegEXALUIP	: out std_logic; 
			DoneEXALU			: out std_logic;
			DataEXALUtoWB		: out std_logic_vector(31 downto 0);
			IDtoEXALU			: in  execute_record;
			DataRegOutEXALU		: in  std_logic_vector(31 downto 0);
			EnableEXALU			: in  std_logic);
	end component;
	
	component execute_fpu
		port ( 
			DataRegInEXFPU		: out std_logic_vector(31 downto 0);
			EnableRegEXFPURd	: out std_logic;
			EnableRegEXFPUWr	: out std_logic;
			DoneEXFPU			: out std_logic;
			DataEXFPUtoWB		: out std_logic_vector(31 downto 0);
			IDtoEXFPU			: in  execute_record;
			DataRegOutEXFPU		: in  std_logic_vector(31 downto 0);
			EnableEXFPU			: in  std_logic);
	end component;
	
	
	FOR UUT1: execute_alu USE ENTITY WORK.execute_alu(execute_alu_architecture);
	FOR UUT2: execute_fpu USE ENTITY WORK.execute_fpu(execute_fpu_architecture);
		
	
	-- Add your code here ...	
	SIGNAL IDtoEXFPURecords:	execute_records(3 downto 0);
	SIGNAL DataEXALUtoWB: 		std_logic_vector(31 downto 0);
	SIGNAL DataEXFPUtoWB: 		std_logic_vector(31 downto 0);
	SIGNAL IDtoEXALU: 			execute_record;
	SIGNAL IDtoEXFPU: 			execute_record;	
	SIGNAL DoneEXALU:			std_logic;
	SIGNAL DoneEXFPU:			std_logic;
	
	
begin
	
	
	-- Unit Under Test port map
		
	UUT1: execute_alu
		port map (
			BranchEXALUtoSM		=> BranchEXALUtoSM,
			DataRegInEXALU		=> DataRegInEXALU,
			EnableRegEXALURd	=> EnableRegEXALURd,
			EnableRegEXALUWr	=> EnableRegEXALUWr,
			EnableRegEXALUIP	=> EnableRegEXALUIP,
			DoneEXALU			=> DoneEXALU,
			DataEXALUtoWB		=> DataEXALUtoWB,
			IDtoEXALU			=> IDtoEXALU,
			DataRegOutEXALU		=> DataRegOutEXALU,
			EnableEXALU			=> EnableEXALU);
	
	UUT2: execute_fpu
		port map (
			DataRegInEXFPU		=> DataRegInEXFPU,
			EnableRegEXFPURd	=> EnableRegEXFPURd,
			EnableRegEXFPUWr	=> EnableRegEXFPUWr,
			DoneEXFPU			=> DoneEXFPU,
			DataEXFPUtoWB		=> DataEXFPUtoWB,
			IDtoEXFPU			=> IDtoEXFPU,
			DataRegOutEXFPU		=> DataRegOutEXFPU,
			EnableEXFPU			=> EnableEXFPU);
	
			
	-- Add your stimulus here ...
	
	Main: PROCESS 
	
	PROCEDURE InitializeIDtoEX IS
	
	BEGIN 
		IDtoEXALU.op <= std_logic_vector(to_unsigned(EX_NULL, IDtoEXALU.op'length)); 
		IDtoEXALU.fp <= 'Z';
		IDtoEXALU.sign <= 'Z';
		IDtoEXALU.op1 <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
		IDtoEXALU.op2 <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
		IDtoEXALU.address <= "ZZZZZZZZZZZZZZZZ";
		IDtoEXFPURecords(3).op <= std_logic_vector(to_unsigned(EX_NULL, IDtoEXFPURecords(3).op'length)); 
		IDtoEXFPURecords(3).fp <= 'Z';
		IDtoEXFPURecords(3).sign <= 'Z';
		IDtoEXFPURecords(3).op1 <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
		IDtoEXFPURecords(3).op2 <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
		IDtoEXFPURecords(3).address <= "ZZZZZZZZZZZZZZZZ";
	End InitializeIDtoEX;
	
	PROCEDURE InitializeAllIDtoEX IS
	
	BEGIN 
		IDtoEXALU.op <= std_logic_vector(to_unsigned(EX_NULL, IDtoEXALU.op'length)); 
		IDtoEXALU.fp <= 'Z';
		IDtoEXALU.sign <= 'Z';
		IDtoEXALU.op1 <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
		IDtoEXALU.op2 <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
		IDtoEXALU.address <= "ZZZZZZZZZZZZZZZZ";	
		for i in IDtoEXFPURecords'length-1 downto 0 loop
			IDtoEXFPURecords(i).op <= std_logic_vector(to_unsigned(EX_NULL, IDtoEXFPURecords(3).op'length)); 
			IDtoEXFPURecords(i).fp <= 'Z';
			IDtoEXFPURecords(i).sign <= 'Z';
			IDtoEXFPURecords(i).op1 <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
			IDtoEXFPURecords(i).op2 <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
			IDtoEXFPURecords(i).address <= "ZZZZZZZZZZZZZZZZ";
		end loop;
	End InitializeAllIDtoEX;
	
	VARIABLE First: BOOLEAN := true;
	VARIABLE Empty: STD_LOGIC;
	VARIABLE Op: INTEGER;			 
	VARIABLE Fp: STD_LOGIC;
	VARIABLE wasSTR: BOOLEAN := false;
	VARIABLE wasSTRW: BOOLEAN := false;
	VARIABLE varEXFPUPending: BOOLEAN := false;
	
	BEGIN 
		if (First) then
			First := false;
			EXFPUPending <= '0';
			EnableCheckSTRM <= '0';
			EnableDecFPWrPend <= '0'; 
			EnableEXALU <= '0'; 
			EnableEXFPU <= '0';
			InitializeAllIDtoEX;
			WAIT FOR 1 ns;
		end if;
		WAIT UNTIL rising_edge(EnableEX);
		EnableCheckSTRM <= '0';
		if (StallSTR = '1') then
			IDtoEXFPURecords(3) <= IDtoEXFPURecords(2);
			if (not wasSTR) then
				wasSTR := true;
			else
				wasSTR := false;
				InitializeIDtoEX;
			end if;
			WAIT FOR 2 ns;
			if (StallSTR = '0') then
				wasSTRW := true;
			end if;
		elsif (StallWAWAux = '1') then
			--for i in IDtoEXFPURecords'length-1 downto 2 loop
				--IDtoEXFPURecords(i) <= IDtoEXFPURecords(i-1);
			--end loop;
			--IDtoEXFPURecords(3) <= IDtoEXFPURecords(2);
			--InitializeIDtoEX;
			--WAIT UNTIL rising_edge(EnableEX);
			--WAIT UNTIL rising_edge(EnableEX);
			WAIT UNTIL falling_edge(StallWAWAux);
			DataEXtoWB <= DataEXALUtoWB;
			WAIT FOR 1 ns;
			if (StallSTR = '1') then
				WAIT UNTIL rising_edge(EnableEX);
				WAIT UNTIL rising_edge(EnableEX);
			else
				WAIT UNTIL rising_edge(EnableEX);
			end if;
		end if;
		EnableEXALU <= '1'; 
		EnableEXFPU <= '1';
		Op := to_integer(unsigned(IDtoEXFPURecords(1).op));
		if (Op /= EX_NULL) then
			EnableDecFPWrPend <= '1';
			WAIT FOR 1 ns;
			EnableDecFPWrPend <= '0';
		end if;	
		WAIT UNTIL falling_edge(EnableEX);
		InitializeIDtoEX;
		Empty := IDtoEX.empty;
		if (Empty = '0') then
			Fp := IDtoEX.fp;
			if (not wasSTRW) then
				if ((Fp = '0') or (Fp = 'Z')) then
					if (StallSTR = '0') then
						IDtoEXALU <= IDtoEX;
						EnableEXALU <= '0';
						--WAIT FOR 1 ns;
					end if;
				else
					IDtoEXFPURecords(3) <= IDtoEX;
				end if;
			else
				wasSTRW := false;
			end if;
		end if;
		IDtoEXFPURecords(2) <= IDtoEXFPURecords(3);
		IDtoEXFPURecords(1) <= IDtoEXFPURecords(2);
		IDtoEXFPURecords(0) <= IDtoEXFPURecords(1);
		WAIT FOR 1 ns;
		for i in 1 to IDtoEXFPURecords'length-1 loop
			Op := to_integer(unsigned(IDtoEXFPURecords(i).op));
			if (Op /= EX_NULL) then
				varEXFPUPending := true;
				exit;
			end if;
		end loop;
		if (varEXFPUPending) then
			EXFPUPending <= '1';
			varEXFPUPending := false;
		else
			EXFPUPending <= '0';
		end if;
		Op := to_integer(unsigned(IDtoEXFPURecords(0).op));
		if (Op /= EX_NULL) then
			IDtoEXFPU <= IDtoEXFPURecords(0);
			EnableEXFPU <= '0';
			WAIT FOR 1 ns;
		end if;
		if ((StallSTR = '0') or (EnableEXFPU = '1')) then
			EnableCheckSTRM <= '1';
		end if;
		if (EnableEXALU = '0') then
			Op := to_integer(unsigned(IDtoEXALU.op));
			if (Op /= EX_NULL) then
				WAIT UNTIL (DoneEXALU = '1');
				DataEXtoWB <= DataEXALUtoWB;
			end if;
		end if;
		if (EnableEXFPU = '0') then
			if (DoneEXFPU = '0') then
				WAIT UNTIL rising_edge(DoneEXFPU);
			end if;
			DataEXtoWB <= DataEXFPUtoWB;
		end if;
		if ((EnableEXALU = '1') and (EnableEXFPU = '1')) then
			WAIT FOR 1 ns;
			if (StallSTR = '0') then
				DataEXtoWB <= DataEXALUtoWB;
			end if;
		end if;
	END PROCESS Main;
	
	
end EXECUTE_ARCHITECTURE;





