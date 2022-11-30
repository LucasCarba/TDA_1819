
-- Entidad "execute_alu":
-- Descripción: Aquí se define la funcionalidad correspondiente a la unidad aritmético-lógica
-- (ALU) dentro de la etapa de ejecución del pipeline, por lo que en esta ALU se ejecutarán 
-- todas las operaciones aritmético-lógicas que no involucren operandos en punto flotante: 
-- sumas, restas, multiplicaciones y divisiones enteras, saltos condicionales, operaciones and, 
-- or, not y xor, comparaciones y desplazamiento de bits. Una vez finalizada la operación en 
-- cuestión, accederá al Registro de Banderas del procesador asociado a esta ALU (FLAGS) con el 
-- objetivo de actualizarlo con el estado de la última operación ejecutada. A continuación, si 
-- llegara a ser necesario, se dirige nuevamente a este registro para obtener de él toda la 
-- información requerida para determinar algún rumbo en particular entre dos acciones posibles. 
-- Por ejemplo, en caso de un salto condicional, indudablemente alguna de las banderas será 
-- crucial para decidir si efectivamente dicho salto debe ser tomado o el programa puede 
-- continuar con su ejecución normal. También cuenta con la capacidad de poder acceder al 
-- Puntero de Instrucciones para actualizarlo si llegara a ocurrir una alteración en el flujo de 
-- ejecución normal del programa (salto tomado). Finalmente, si correspondiera, envía al 
-- administrador de la etapa de ejecución del pipeline el resultado final de la operación 
-- aritmético-lógica llevada a cabo en esta ALU para que éste disponga de él como juzgue 
-- conveniente y necesario. Recordar que, independientemente de la naturaleza de la operación en 
-- cuestión, una ejecución completa en esta unidad requerirá solamente un ciclo de reloj.
-- Procesos:
-- Main: En primer lugar, recibe la señal del administrador de la etapa de ejecución del
-- pipeline para comenzar la ejecución de la operación aritmético-lógica requerida por la
-- instrucción actual. También obtendrá toda la información necesaria para determinar el tipo
-- de operación a realizar y, en consecuencia, los procedimientos a invocar: si la operación
-- es nula, directamente cancelará el uso de la ALU para esta instrucción; en caso contrario,
-- llevará a cabo la operación y actualizará el Registro FLAGS para luego, si llegara a ser
-- necesario, leerlo para adoptar alguna decisión en función de su estado (actualizar un 
-- registro con un determinado valor, tomar un salto, etc.). Finalmente, si no se tratara de
-- una instrucción de salto condicional, este proceso enviará al administrador el resultado
-- de la operación para que éste a su vez lo haga llegar a las siguientes etapas del pipeline
-- según sea necesario.
-- Procedimientos y funciones:
-- alu(): Este procedimiento lleva a cabo la tarea fundamental de esta ALU: ejecutar la
-- operación aritmético-lógica requerida por la instrucción actual (suma, resta, multiplicación,
-- división, or, and, not, xor, desplazamiento de bits, etc.), ya sea para posteriormente 
-- escribir su resultado en el banco de registros en la etapa "writeback" o bien para utilizarlo 
-- internamente para un salto condicional o una comparación.
-- setFlagsRegister(): Actualiza algunas de las banderas del registro FLAGS con los atributos
-- del estado correspondiente a la última operación aritmético-lógica ejecutada: cero (flag Z), 
-- negativo (flag S), overflow (flag O), acarreo (flag C), acarreo auxiliar (flag A) y paridad 
-- (flag P). Dichas banderas pueden ser muy importantes para tomar una eventual decisión
-- respecto a un salto condicional o una comparación (por ejemplo, el flag Z permitiría determinar
-- si los operandos de la última operación ejecutada eran iguales; el flag S, si el primero era
-- menor al segundo; etc.).
-- getAndUseFlagsRegister(): Lee las banderas del registro FLAGS para obtener los atributos del
-- estado correspondiente a la última operación aritmético-lógica, ya actualizados en el
-- procedimiento anterior. A partir de los datos leídos, se tomará aquí la decisión en cuestión en
-- función de la instrucción ejecutada: si es una comparación, se le enviará al administrador el
-- valor que corresponda con el cual la etapa "writeback" deberá actualizar el registro indicado
-- en la instrucción; en cambio, si es una instrucción de transferencia de control, deberá 
-- determinarse si el salto será efectivamente tomado, en caso afirmativo se deberá acceder al 
-- Puntero de Instrucciones para actualizarlo con la dirección de salto para que el programa pueda 
-- continuar su ejecución desde allí, en caso contrario no será necesario realizar ninguna acción, 
-- permitiendo que el programa prosiga ejecutándose normalmente.


library TDA_1819;
use TDA_1819.const_cpu.all;
use TDA_1819.const_flags.all;
use TDA_1819.tipos_cpu.all;

LIBRARY IEEE;

USE std.textio.all;
use ieee.NUMERIC_STD.all;
USE IEEE.std_logic_1164.all; 




entity execute_alu is
	
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

end execute_alu;




architecture EXECUTE_ALU_ARCHITECTURE of execute_alu is


	
begin
	
	
	Main: PROCESS
	
	VARIABLE First: BOOLEAN := true; 
	VARIABLE Op: INTEGER;			 
	VARIABLE Sign: STD_LOGIC;
	VARIABLE Uop1: UNSIGNED(31 downto 0);
	VARIABLE Uop2: UNSIGNED(31 downto 0);
	VARIABLE Sop1: SIGNED(31 downto 0);
	VARIABLE Sop2: SIGNED(31 downto 0);
	VARIABLE Ures: UNSIGNED(31 downto 0);
	VARIABLE Sres: SIGNED(31 downto 0);
	VARIABLE ResBin: STD_LOGIC_VECTOR(31 downto 0);
	VARIABLE needFlags: BOOLEAN;
	VARIABLE isJumpOp: BOOLEAN;
	VARIABLE jumpAddress: STD_LOGIC_VECTOR(15 downto 0);
	
	PROCEDURE alu IS  
	
	BEGIN  
		jumpAddress := IDtoEXALU.address;
		needFlags := false;
		isJumpOp := false;
		Sign := IDtoEXALU.sign;
		if (Sign = '0') then
			Uop1 := unsigned(IDtoEXALU.op1);
			Uop2 := unsigned(IDtoEXALU.op2);
			CASE Op IS
				WHEN EX_NULL =>
					NULL;
				WHEN EX_ADD =>
					Ures := Uop1 + Uop2;
				WHEN EX_SUB =>
					Ures := Uop1 - Uop2;
				WHEN EX_MUL =>
					Ures := resize(Uop1 * Uop2, Ures'length);
				WHEN EX_DIV =>
					Ures := Uop1 / Uop2;
				WHEN EX_SLT =>
					Ures := Uop1 - Uop2;
					needFlags := true; 
				WHEN EX_NEG =>
					Ures := not(Uop1) + 1;
				WHEN EX_AND =>
					Ures := Uop1 and Uop2;
				WHEN EX_OR =>
					Ures := Uop1 or Uop2;
				WHEN EX_XOR =>
					Ures := Uop1 xor Uop2;
				WHEN EX_NOT =>
					Ures := not(Uop1);
				WHEN EX_DSL =>
					Ures := shift_left(Uop1, to_integer(Uop2));
					Ures((to_integer(Uop2)-1) downto 0) := Uop1(31 downto 31-(to_integer(Uop2)-1));
				WHEN EX_DSR =>
					Ures := shift_right(Uop1, to_integer(Uop2));
					Ures(31 downto 31-(to_integer(Uop2)-1)) := Uop1((to_integer(Uop2)-1) downto 0);
				WHEN EX_BEQ =>
					Ures := Uop1 - Uop2;
					needFlags := true;
					isJumpOp := true;
				WHEN EX_BNE =>
					Ures := Uop1 - Uop2;
					needFlags := true;
					isJumpOp := true;
				WHEN EX_BEQZ =>
					Ures := Uop1;
					needFlags := true;
					isJumpOp := true;
				WHEN EX_BNEZ =>
					Ures := Uop1;
					needFlags := true;
					isJumpOp := true;
				WHEN EX_BFPT =>	
					Ures := Uop1;
					needFlags := true;
					isJumpOp := true;
				WHEN EX_BFPF =>	
					Ures := Uop1;
					needFlags := true;
					isJumpOp := true;
				WHEN OTHERS =>
					report "Error: la operación a ejecutar en la ALU no es válida"
					severity FAILURE;
			END CASE;
		elsif (Sign = '1') then	
			Sop1 := signed(IDtoEXALU.op1);
			Sop2 := signed(IDtoEXALU.op2);
			CASE Op IS
				WHEN EX_NULL =>
					NULL;
				WHEN EX_ADD =>
					Sres := Sop1 + Sop2;
				WHEN EX_SUB =>
					Sres := Sop1 - Sop2;
				WHEN EX_MUL =>
					Sres := resize((Sop1 * Sop2), Sres'length);
				WHEN EX_DIV =>
					Sres := Sop1 / Sop2;
				WHEN EX_SLT =>
					Sres := Sop1 - Sop2;
					needFlags := true;
				WHEN EX_NEG =>
					Sres := not(Sop1) + 1;
				WHEN EX_AND =>
					Sres := Sop1 and Sop2;
				WHEN EX_OR =>
					Sres := Sop1 or Sop2;
				WHEN EX_XOR =>
					Sres := Sop1 xor Sop2;
				WHEN EX_NOT =>
					Sres := not(Sop1);
				WHEN EX_DSL => 
					Sres(30 downto 0) := shift_left(Sop1(30 downto 0), to_integer(Sop2));
					Sres(31) := Sop1(31);
					Sres((to_integer(Sop2)-1) downto 0) := Sop1(30 downto 30-(to_integer(Sop2)-1));
				WHEN EX_DSR => 
					Sres(30 downto 0) := shift_right(Sop1(30 downto 0), to_integer(Sop2));
					Sres(31) := Sop1(31);
					Sres(30 downto 30-(to_integer(Sop2)-1)) := Sop1((to_integer(Sop2)-1) downto 0);
				WHEN EX_BEQ =>
					Sres := Sop1 - Sop2;
					needFlags := true;
					isJumpOp := true;
				WHEN EX_BNE =>
					Sres := Sop1 - Sop2;
					needFlags := true;
					isJumpOp := true;
				WHEN EX_BEQZ =>
					Sres := Sop1;
					needFlags := true;
					isJumpOp := true;
				WHEN EX_BNEZ =>
					Sres := Sop1;
					needFlags := true;
					isJumpOp := true; 
				WHEN EX_BFPT =>
					Sres := Sop1;
					needFlags := true;
					isJumpOp := true;
				WHEN EX_BFPF =>	
					Sres := Sop1;
					needFlags := true;
					isJumpOp := true;
				WHEN OTHERS =>
					report "Error: la operación a ejecutar en la ALU no es válida"
					severity FAILURE;
			END CASE;
		else
			report "Error: el signo de la operación a ejecutar en la ALU no es válido"
			severity FAILURE;
		end if;
		if (Sign = '0') then
			ResBin := std_logic_vector(Ures);
		elsif (Sign = '1') then
			ResBin := std_logic_vector(Sres);
		else
			report "Error: el signo de la operación ejecutada en la ALU no es válido"
			severity FAILURE;
		end if;
	END alu;
	
	PROCEDURE setFlagsRegister IS
	
	VARIABLE cant1s: INTEGER := 0;
	
	BEGIN
		DataRegInEXALU <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
		if (Sign = '0') then
			CASE Op IS
				WHEN EX_NULL =>
					NULL;
				WHEN EX_ADD =>
					if (to_integer(unsigned(ResBin(31 downto 0))) = 0) then
						DataRegInEXALU(FLAG_Z) <= '1';
					else
						DataRegInEXALU(FLAG_Z) <= '0';
					end if;
					DataRegInEXALU(FLAG_S) <= '0';
					DataRegInEXALU(FLAG_O) <= '0';
					--DataRegInEXALU(FLAG_C) <= ResBin(32);
					DataRegInEXALU(FLAG_C) <= '0';
					if ((Uop1(4) = '0') OR (Uop2(4) = '0')) then
						if ((Uop1(4) OR Uop2(4)) /= ResBin(4)) then
							DataRegInEXALU(FLAG_A) <= '1';
						else
							DataRegInEXALU(FLAG_A) <= '0';
						end if;
					else
						if (ResBin(4) /= '0') then
							DataRegInEXALU(FLAG_A) <= '1';
						else
							DataRegInEXALU(FLAG_A) <= '0';
						end if;
					end if;
					for i in 31 downto 0 loop
						if (ResBin(i) = '1') then
							cant1s := cant1s + 1;
						end if;
					end loop;
					if (cant1s MOD 2 = 0) then
						DataRegInEXALU(FLAG_P) <= '1';
					else
						DataRegInEXALU(FLAG_P) <= '0';
					end if;
					EnableRegEXALUWr <= '1';
					WAIT FOR 1 ns;
					EnableRegEXALUWr <= '0';
					WAIT FOR 1 ns;
				WHEN EX_SUB =>
					if (to_integer(unsigned(ResBin(31 downto 0))) = 0) then
						DataRegInEXALU(FLAG_Z) <= '1';
					else
						DataRegInEXALU(FLAG_Z) <= '0';
					end if;
					DataRegInEXALU(FLAG_S) <= '0';
					DataRegInEXALU(FLAG_O) <= '0';
					if (to_integer(Uop1) < to_integer(Uop2)) then
						DataRegInEXALU(FLAG_C) <= '1';
					else
						DataRegInEXALU(FLAG_C) <= '0';
					end if;
					if (to_integer(Uop1(3 downto 0)) < to_integer(Uop2(3 downto 0))) then
						DataRegInEXALU(FLAG_A) <= '1';
					else
						DataRegInEXALU(FLAG_A) <= '0';
					end if;
					for i in 31 downto 0 loop
						if (ResBin(i) = '1') then
							cant1s := cant1s + 1;
						end if;
					end loop;
					if (cant1s MOD 2 = 0) then
						DataRegInEXALU(FLAG_P) <= '1';
					else
						DataRegInEXALU(FLAG_P) <= '0';
					end if;
					EnableRegEXALUWr <= '1';
					WAIT FOR 1 ns;
					EnableRegEXALUWr <= '0';
					WAIT FOR 1 ns;
				WHEN EX_MUL =>
					if (to_integer(unsigned(ResBin(31 downto 0))) = 0) then
						DataRegInEXALU(FLAG_Z) <= '1';
					else
						DataRegInEXALU(FLAG_Z) <= '0';
					end if;
					DataRegInEXALU(FLAG_S) <= '0';
					DataRegInEXALU(FLAG_O) <= '0';
					DataRegInEXALU(FLAG_C) <= 'Z';
					DataRegInEXALU(FLAG_A) <= 'Z';
					for i in 31 downto 0 loop
						if (ResBin(i) = '1') then
							cant1s := cant1s + 1;
						end if;
					end loop;
					if (cant1s MOD 2 = 0) then
						DataRegInEXALU(FLAG_P) <= '1';
					else
						DataRegInEXALU(FLAG_P) <= '0';
					end if;
					EnableRegEXALUWr <= '1';
					WAIT FOR 1 ns;
					EnableRegEXALUWr <= '0';
					WAIT FOR 1 ns;
				WHEN EX_DIV =>
					if (to_integer(unsigned(ResBin(31 downto 0))) = 0) then
						DataRegInEXALU(FLAG_Z) <= '1';
					else
						DataRegInEXALU(FLAG_Z) <= '0';
					end if;
					DataRegInEXALU(FLAG_S) <= '0';
					DataRegInEXALU(FLAG_O) <= '0';
					DataRegInEXALU(FLAG_C) <= 'Z';
					DataRegInEXALU(FLAG_A) <= 'Z';
					for i in 31 downto 0 loop
						if (ResBin(i) = '1') then
							cant1s := cant1s + 1;
						end if;
					end loop;
					if (cant1s MOD 2 = 0) then
						DataRegInEXALU(FLAG_P) <= '1';
					else
						DataRegInEXALU(FLAG_P) <= '0';
					end if;
					EnableRegEXALUWr <= '1';
					WAIT FOR 1 ns;
					EnableRegEXALUWr <= '0';
					WAIT FOR 1 ns;
				WHEN EX_SLT =>
					if (to_integer(unsigned(ResBin(31 downto 0))) = 0) then
						DataRegInEXALU(FLAG_Z) <= '1';
					else
						DataRegInEXALU(FLAG_Z) <= '0';
					end if;
					DataRegInEXALU(FLAG_S) <= '0';
					DataRegInEXALU(FLAG_O) <= '0';
					if (to_integer(Uop1) < to_integer(Uop2)) then
						DataRegInEXALU(FLAG_C) <= '1';
					else
						DataRegInEXALU(FLAG_C) <= '0';
					end if;
					if (to_integer(Uop1(3 downto 0)) < to_integer(Uop2(3 downto 0))) then
						DataRegInEXALU(FLAG_A) <= '1';
					else
						DataRegInEXALU(FLAG_A) <= '0';
					end if;
					for i in 31 downto 0 loop
						if (ResBin(i) = '1') then
							cant1s := cant1s + 1;
						end if;
					end loop;
					if (cant1s MOD 2 = 0) then
						DataRegInEXALU(FLAG_P) <= '1';
					else
						DataRegInEXALU(FLAG_P) <= '0';
					end if;
					EnableRegEXALUWr <= '1';
					WAIT FOR 1 ns;
					EnableRegEXALUWr <= '0';
					WAIT FOR 1 ns;
				WHEN EX_NEG =>
					if (to_integer(unsigned(ResBin(31 downto 0))) = 0) then
						DataRegInEXALU(FLAG_Z) <= '1';
					else
						DataRegInEXALU(FLAG_Z) <= '0';
					end if;
					DataRegInEXALU(FLAG_S) <= '0';
					DataRegInEXALU(FLAG_O) <= '0';
					--DataRegInEXALU(FLAG_C) <= ResBin(32);
					DataRegInEXALU(FLAG_C) <= '0';
					if ((Uop1(4) = '0') OR (Uop2(4) = '0')) then
						if ((Uop1(4) OR Uop2(4)) /= ResBin(4)) then
							DataRegInEXALU(FLAG_A) <= '1';
						else
							DataRegInEXALU(FLAG_A) <= '0';
						end if;
					else
						if (ResBin(4) /= '0') then
							DataRegInEXALU(FLAG_A) <= '1';
						else
							DataRegInEXALU(FLAG_A) <= '0';
						end if;
					end if;
					for i in 31 downto 0 loop
						if (ResBin(i) = '1') then
							cant1s := cant1s + 1;
						end if;
					end loop;
					if (cant1s MOD 2 = 0) then
						DataRegInEXALU(FLAG_P) <= '1';
					else
						DataRegInEXALU(FLAG_P) <= '0';
					end if;
					EnableRegEXALUWr <= '1';
					WAIT FOR 1 ns;
					EnableRegEXALUWr <= '0';
					WAIT FOR 1 ns; 
				WHEN EX_AND to EX_NOT =>
					if (to_integer(unsigned(ResBin(31 downto 0))) = 0) then
						DataRegInEXALU(FLAG_Z) <= '1';
					else
						DataRegInEXALU(FLAG_Z) <= '0';
					end if;
					DataRegInEXALU(FLAG_S) <= ResBin(31);
					DataRegInEXALU(FLAG_O) <= '0';
					DataRegInEXALU(FLAG_C) <= '0';
					DataRegInEXALU(FLAG_A) <= '0';
					for i in 31 downto 0 loop
						if (ResBin(i) = '1') then
							cant1s := cant1s + 1;
						end if;
					end loop;
					if (cant1s MOD 2 = 0) then
						DataRegInEXALU(FLAG_P) <= '1';
					else
						DataRegInEXALU(FLAG_P) <= '0';
					end if;
					EnableRegEXALUWr <= '1';
					WAIT FOR 1 ns;
					EnableRegEXALUWr <= '0';
					WAIT FOR 1 ns; 
				WHEN EX_DSL to EX_DSR =>
					if (to_integer(unsigned(ResBin(31 downto 0))) = 0) then
						DataRegInEXALU(FLAG_Z) <= '1';
					else
						DataRegInEXALU(FLAG_Z) <= '0';
					end if;
					DataRegInEXALU(FLAG_S) <= ResBin(31);
					DataRegInEXALU(FLAG_O) <= '0';
					DataRegInEXALU(FLAG_C) <= '0';
					DataRegInEXALU(FLAG_A) <= '0';
					for i in 31 downto 0 loop
						if (ResBin(i) = '1') then
							cant1s := cant1s + 1;
						end if;
					end loop;
					if (cant1s MOD 2 = 0) then
						DataRegInEXALU(FLAG_P) <= '1';
					else
						DataRegInEXALU(FLAG_P) <= '0';
					end if;
					EnableRegEXALUWr <= '1';
					WAIT FOR 1 ns;
					EnableRegEXALUWr <= '0';
					WAIT FOR 1 ns;
				WHEN EX_BEQ =>
					if (to_integer(unsigned(ResBin(31 downto 0))) = 0) then
						DataRegInEXALU(FLAG_Z) <= '1';
					else
						DataRegInEXALU(FLAG_Z) <= '0';
					end if;
					DataRegInEXALU(FLAG_S) <= '0';
					DataRegInEXALU(FLAG_O) <= '0';
					if (to_integer(Uop1) < to_integer(Uop2)) then
						DataRegInEXALU(FLAG_C) <= '1';
					else
						DataRegInEXALU(FLAG_C) <= '0';
					end if;
					if (to_integer(Uop1(3 downto 0)) < to_integer(Uop2(3 downto 0))) then
						DataRegInEXALU(FLAG_A) <= '1';
					else
						DataRegInEXALU(FLAG_A) <= '0';
					end if;
					for i in 31 downto 0 loop
						if (ResBin(i) = '1') then
							cant1s := cant1s + 1;
						end if;
					end loop;
					if (cant1s MOD 2 = 0) then
						DataRegInEXALU(FLAG_P) <= '1';
					else
						DataRegInEXALU(FLAG_P) <= '0';
					end if;
					EnableRegEXALUWr <= '1';
					WAIT FOR 1 ns;
					EnableRegEXALUWr <= '0';
					WAIT FOR 1 ns;
				WHEN EX_BNE =>
					if (to_integer(unsigned(ResBin(31 downto 0))) = 0) then
						DataRegInEXALU(FLAG_Z) <= '1';
					else
						DataRegInEXALU(FLAG_Z) <= '0';
					end if;
					DataRegInEXALU(FLAG_S) <= '0';
					DataRegInEXALU(FLAG_O) <= '0';
					if (to_integer(Uop1) < to_integer(Uop2)) then
						DataRegInEXALU(FLAG_C) <= '1';
					else
						DataRegInEXALU(FLAG_C) <= '0';
					end if;
					if (to_integer(Uop1(3 downto 0)) < to_integer(Uop2(3 downto 0))) then
						DataRegInEXALU(FLAG_A) <= '1';
					else
						DataRegInEXALU(FLAG_A) <= '0';
					end if;
					for i in 31 downto 0 loop
						if (ResBin(i) = '1') then
							cant1s := cant1s + 1;
						end if;
					end loop;
					if (cant1s MOD 2 = 0) then
						DataRegInEXALU(FLAG_P) <= '1';
					else
						DataRegInEXALU(FLAG_P) <= '0';
					end if;
					EnableRegEXALUWr <= '1';
					WAIT FOR 1 ns;
					EnableRegEXALUWr <= '0';
					WAIT FOR 1 ns;
				WHEN EX_BEQZ =>
					if (to_integer(unsigned(ResBin(31 downto 0))) = 0) then
						DataRegInEXALU(FLAG_Z) <= '1';
					else
						DataRegInEXALU(FLAG_Z) <= '0';
					end if;
					DataRegInEXALU(FLAG_S) <= '0';
					DataRegInEXALU(FLAG_O) <= '0';
					DataRegInEXALU(FLAG_C) <= '0';
					DataRegInEXALU(FLAG_A) <= '0';
					for i in 31 downto 0 loop
						if (ResBin(i) = '1') then
							cant1s := cant1s + 1;
						end if;
					end loop;
					if (cant1s MOD 2 = 0) then
						DataRegInEXALU(FLAG_P) <= '1';
					else
						DataRegInEXALU(FLAG_P) <= '0';
					end if;
					EnableRegEXALUWr <= '1';
					WAIT FOR 1 ns;
					EnableRegEXALUWr <= '0';
					WAIT FOR 1 ns;
				WHEN EX_BNEZ =>
					if (to_integer(unsigned(ResBin(31 downto 0))) = 0) then
						DataRegInEXALU(FLAG_Z) <= '1';
					else
						DataRegInEXALU(FLAG_Z) <= '0';
					end if;
					DataRegInEXALU(FLAG_S) <= '0';
					DataRegInEXALU(FLAG_O) <= '0';
					DataRegInEXALU(FLAG_C) <= '0';
					DataRegInEXALU(FLAG_A) <= '0';
					for i in 31 downto 0 loop
						if (ResBin(i) = '1') then
							cant1s := cant1s + 1;
						end if;
					end loop;
					if (cant1s MOD 2 = 0) then
						DataRegInEXALU(FLAG_P) <= '1';
					else
						DataRegInEXALU(FLAG_P) <= '0';
					end if;
					EnableRegEXALUWr <= '1';
					WAIT FOR 1 ns;
					EnableRegEXALUWr <= '0';
					WAIT FOR 1 ns;
				WHEN EX_BFPT =>
					if (ResBin(FLAG_F) = '0') then
						DataRegInEXALU(FLAG_Z) <= '1';
					else
						DataRegInEXALU(FLAG_Z) <= '0';
					end if;
					DataRegInEXALU(FLAG_S) <= '0';
					DataRegInEXALU(FLAG_O) <= '0';
					DataRegInEXALU(FLAG_C) <= '0';
					DataRegInEXALU(FLAG_A) <= '0';
					for i in 7 downto 0 loop
						if (ResBin(i) = '1') then
							cant1s := cant1s + 1;
						end if;
					end loop;
					if (cant1s MOD 2 = 0) then
						DataRegInEXALU(FLAG_P) <= '1';
					else
						DataRegInEXALU(FLAG_P) <= '0';
					end if;
					EnableRegEXALUWr <= '1';
					WAIT FOR 1 ns;
					EnableRegEXALUWr <= '0';
					WAIT FOR 1 ns;
				WHEN EX_BFPF =>
					if (ResBin(FLAG_F) = '0') then
						DataRegInEXALU(FLAG_Z) <= '1';
					else
						DataRegInEXALU(FLAG_Z) <= '0';
					end if;
					DataRegInEXALU(FLAG_S) <= '0';
					DataRegInEXALU(FLAG_O) <= '0';
					DataRegInEXALU(FLAG_C) <= '0';
					DataRegInEXALU(FLAG_A) <= '0';
					for i in 7 downto 0 loop
						if (ResBin(i) = '1') then
							cant1s := cant1s + 1;
						end if;
					end loop;
					if (cant1s MOD 2 = 0) then
						DataRegInEXALU(FLAG_P) <= '1';
					else
						DataRegInEXALU(FLAG_P) <= '0';
					end if;
					EnableRegEXALUWr <= '1';
					WAIT FOR 1 ns;
					EnableRegEXALUWr <= '0';
					WAIT FOR 1 ns;
				WHEN OTHERS =>
					report "Error: la operación a ejecutar en la ALU no es válida"
					severity FAILURE;
			END CASE;
		elsif (Sign = '1') then
			CASE Op IS
				WHEN EX_NULL =>
					NULL;
				WHEN EX_ADD =>
					if (to_integer(signed(ResBin(31 downto 0))) = 0) then
						DataRegInEXALU(FLAG_Z) <= '1';
					else
						DataRegInEXALU(FLAG_Z) <= '0';
					end if;
					DataRegInEXALU(FLAG_S) <= ResBin(31);
					if ((Sop1(31) = Sop2(31)) and (Sres(31) /= Sop1(31))) then
						DataRegInEXALU(FLAG_O) <= '1';
					else
						DataRegInEXALU(FLAG_O) <= '0';
					end if;
					--DataRegInEXALU(FLAG_C) <= ResBin(32);
					DataRegInEXALU(FLAG_C) <= '0';
					if ((Sop1(4) = '0') OR (Sop2(4) = '0')) then
						if ((Sop1(4) OR Sop2(4)) /= ResBin(4)) then
							DataRegInEXALU(FLAG_A) <= '1';
						else
							DataRegInEXALU(FLAG_A) <= '0';
						end if;
					else
						if (ResBin(4) /= '0') then
							DataRegInEXALU(FLAG_A) <= '1';
						else
							DataRegInEXALU(FLAG_A) <= '0';
						end if;
					end if;
					for i in 31 downto 0 loop
						if (ResBin(i) = '1') then
							cant1s := cant1s + 1;
						end if;
					end loop;
					if (cant1s MOD 2 = 0) then
						DataRegInEXALU(FLAG_P) <= '1';
					else
						DataRegInEXALU(FLAG_P) <= '0';
					end if;
					EnableRegEXALUWr <= '1';
					WAIT FOR 1 ns;
					EnableRegEXALUWr <= '0';
					WAIT FOR 1 ns;
				WHEN EX_SUB =>
					if (to_integer(signed(ResBin(31 downto 0))) = 0) then
						DataRegInEXALU(FLAG_Z) <= '1';
					else
						DataRegInEXALU(FLAG_Z) <= '0';
					end if;
					DataRegInEXALU(FLAG_S) <= ResBin(31);
					if ((Sop1(31) /= Sop2(31)) and (Sres(31) /= Sop1(31))) then
						DataRegInEXALU(FLAG_O) <= '1';
					else
						DataRegInEXALU(FLAG_O) <= '0';
					end if;
					if (to_integer(Sop1) < to_integer(Sop2)) then
						DataRegInEXALU(FLAG_C) <= '1';
					else
						DataRegInEXALU(FLAG_C) <= '0';
					end if;
					if (to_integer(Sop1(3 downto 0)) < to_integer(Sop2(3 downto 0))) then
						DataRegInEXALU(FLAG_A) <= '1';
					else
						DataRegInEXALU(FLAG_A) <= '0';
					end if;
					for i in 31 downto 0 loop
						if (ResBin(i) = '1') then
							cant1s := cant1s + 1;
						end if;
					end loop;
					if (cant1s MOD 2 = 0) then
						DataRegInEXALU(FLAG_P) <= '1';
					else
						DataRegInEXALU(FLAG_P) <= '0';
					end if;
					EnableRegEXALUWr <= '1';
					WAIT FOR 1 ns;
					EnableRegEXALUWr <= '0';
					WAIT FOR 1 ns;
				WHEN EX_MUL =>
					if (to_integer(signed(ResBin(31 downto 0))) = 0) then
						DataRegInEXALU(FLAG_Z) <= '1';
					else
						DataRegInEXALU(FLAG_Z) <= '0';
					end if;
					DataRegInEXALU(FLAG_S) <= ResBin(31);
					if ((Sop1(31) = Sop2(31)) and (Sres(31) = '1')) then
						DataRegInEXALU(FLAG_O) <= '1';
					elsif ((Sop1(31) /= Sop2(31)) and (Sres(31) = '0')) then  
						DataRegInEXALU(FLAG_O) <= '1';
					else
						DataRegInEXALU(FLAG_O) <= '0';
					end if;
					DataRegInEXALU(FLAG_C) <= 'Z';
					DataRegInEXALU(FLAG_A) <= 'Z';
					for i in 31 downto 0 loop
						if (ResBin(i) = '1') then
							cant1s := cant1s + 1;
						end if;
					end loop;
					if (cant1s MOD 2 = 0) then
						DataRegInEXALU(FLAG_P) <= '1';
					else
						DataRegInEXALU(FLAG_P) <= '0';
					end if;
					EnableRegEXALUWr <= '1';
					WAIT FOR 1 ns;
					EnableRegEXALUWr <= '0';
					WAIT FOR 1 ns;
				WHEN EX_DIV =>
					if (to_integer(signed(ResBin(31 downto 0))) = 0) then
						DataRegInEXALU(FLAG_Z) <= '1';
					else
						DataRegInEXALU(FLAG_Z) <= '0';
					end if;
					DataRegInEXALU(FLAG_S) <= ResBin(31);
					if ((Sop1(31) = Sop2(31)) and (Sres(31) = '1')) then
						DataRegInEXALU(FLAG_O) <= '1';
					elsif ((Sop1(31) /= Sop2(31)) and (Sres(31) = '0')) then  
						DataRegInEXALU(FLAG_O) <= '1';
					else
						DataRegInEXALU(FLAG_O) <= '0';
					end if;
					DataRegInEXALU(FLAG_C) <= 'Z';
					DataRegInEXALU(FLAG_A) <= 'Z';
					for i in 31 downto 0 loop
						if (ResBin(i) = '1') then
							cant1s := cant1s + 1;
						end if;
					end loop;
					if (cant1s MOD 2 = 0) then
						DataRegInEXALU(FLAG_P) <= '1';
					else
						DataRegInEXALU(FLAG_P) <= '0';
					end if;
					EnableRegEXALUWr <= '1';
					WAIT FOR 1 ns;
					EnableRegEXALUWr <= '0';
					WAIT FOR 1 ns;
				WHEN EX_SLT =>
					if (to_integer(signed(ResBin(31 downto 0))) = 0) then
						DataRegInEXALU(FLAG_Z) <= '1';
					else
						DataRegInEXALU(FLAG_Z) <= '0';
					end if;
					DataRegInEXALU(FLAG_S) <= ResBin(31);
					if ((Sop1(31) /= Sop2(31)) and (Sres(31) /= Sop1(31))) then
						DataRegInEXALU(FLAG_O) <= '1';
					else
						DataRegInEXALU(FLAG_O) <= '0';
					end if;
					if (to_integer(Sop1) < to_integer(Sop2)) then
						DataRegInEXALU(FLAG_C) <= '1';
					else
						DataRegInEXALU(FLAG_C) <= '0';
					end if;
					if (to_integer(Sop1(3 downto 0)) < to_integer(Sop2(3 downto 0))) then
						DataRegInEXALU(FLAG_A) <= '1';
					else
						DataRegInEXALU(FLAG_A) <= '0';
					end if;
					for i in 31 downto 0 loop
						if (ResBin(i) = '1') then
							cant1s := cant1s + 1;
						end if;
					end loop;
					if (cant1s MOD 2 = 0) then
						DataRegInEXALU(FLAG_P) <= '1';
					else
						DataRegInEXALU(FLAG_P) <= '0';
					end if;
					EnableRegEXALUWr <= '1';
					WAIT FOR 1 ns;
					EnableRegEXALUWr <= '0';
					WAIT FOR 1 ns; 
				WHEN EX_NEG =>
					if (to_integer(signed(ResBin(31 downto 0))) = 0) then
						DataRegInEXALU(FLAG_Z) <= '1';
					else
						DataRegInEXALU(FLAG_Z) <= '0';
					end if;
					DataRegInEXALU(FLAG_S) <= ResBin(31);
					if ((Sop1(31) = Sop2(31)) and (Sres(31) /= Sop1(31))) then
						DataRegInEXALU(FLAG_O) <= '1';
					else
						DataRegInEXALU(FLAG_O) <= '0';
					end if;
					--DataRegInEXALU(FLAG_C) <= ResBin(32);
					DataRegInEXALU(FLAG_C) <= '0';
					if ((Sop1(4) = '0') OR (Sop2(4) = '0')) then
						if ((Sop1(4) OR Sop2(4)) /= ResBin(4)) then
							DataRegInEXALU(FLAG_A) <= '1';
						else
							DataRegInEXALU(FLAG_A) <= '0';
						end if;
					else
						if (ResBin(4) /= '0') then
							DataRegInEXALU(FLAG_A) <= '1';
						else
							DataRegInEXALU(FLAG_A) <= '0';
						end if;
					end if;
					for i in 31 downto 0 loop
						if (ResBin(i) = '1') then
							cant1s := cant1s + 1;
						end if;
					end loop;
					if (cant1s MOD 2 = 0) then
						DataRegInEXALU(FLAG_P) <= '1';
					else
						DataRegInEXALU(FLAG_P) <= '0';
					end if;
					EnableRegEXALUWr <= '1';
					WAIT FOR 1 ns;
					EnableRegEXALUWr <= '0';
					WAIT FOR 1 ns;
				WHEN EX_AND to EX_NOT =>
					if (to_integer(unsigned(ResBin(31 downto 0))) = 0) then
						DataRegInEXALU(FLAG_Z) <= '1';
					else
						DataRegInEXALU(FLAG_Z) <= '0';
					end if;
					DataRegInEXALU(FLAG_S) <= ResBin(31);
					DataRegInEXALU(FLAG_O) <= '0';
					DataRegInEXALU(FLAG_C) <= '0';
					DataRegInEXALU(FLAG_A) <= '0';
					for i in 31 downto 0 loop
						if (ResBin(i) = '1') then
							cant1s := cant1s + 1;
						end if;
					end loop;
					if (cant1s MOD 2 = 0) then
						DataRegInEXALU(FLAG_P) <= '1';
					else
						DataRegInEXALU(FLAG_P) <= '0';
					end if;
					EnableRegEXALUWr <= '1';
					WAIT FOR 1 ns;
					EnableRegEXALUWr <= '0';
					WAIT FOR 1 ns; 
				WHEN EX_DSL to EX_DSR =>
					if (to_integer(unsigned(ResBin(31 downto 0))) = 0) then
						DataRegInEXALU(FLAG_Z) <= '1';
					else
						DataRegInEXALU(FLAG_Z) <= '0';
					end if;
					DataRegInEXALU(FLAG_S) <= ResBin(31);
					DataRegInEXALU(FLAG_O) <= '0';
					DataRegInEXALU(FLAG_C) <= '0';
					DataRegInEXALU(FLAG_A) <= '0';
					for i in 31 downto 0 loop
						if (ResBin(i) = '1') then
							cant1s := cant1s + 1;
						end if;
					end loop;
					if (cant1s MOD 2 = 0) then
						DataRegInEXALU(FLAG_P) <= '1';
					else
						DataRegInEXALU(FLAG_P) <= '0';
					end if;
					EnableRegEXALUWr <= '1';
					WAIT FOR 1 ns;
					EnableRegEXALUWr <= '0';
					WAIT FOR 1 ns;
				WHEN EX_BEQ =>
					if (to_integer(signed(ResBin(31 downto 0))) = 0) then
						DataRegInEXALU(FLAG_Z) <= '1';
					else
						DataRegInEXALU(FLAG_Z) <= '0';
					end if;
					DataRegInEXALU(FLAG_S) <= ResBin(31);
					if ((Sop1(31) /= Sop2(31)) and (Sres(31) /= Sop1(31))) then
						DataRegInEXALU(FLAG_O) <= '1';
					else
						DataRegInEXALU(FLAG_O) <= '0';
					end if;
					if (to_integer(Sop1) < to_integer(Sop2)) then
						DataRegInEXALU(FLAG_C) <= '1';
					else
						DataRegInEXALU(FLAG_C) <= '0';
					end if;
					if (to_integer(Sop1(3 downto 0)) < to_integer(Sop2(3 downto 0))) then
						DataRegInEXALU(FLAG_A) <= '1';
					else
						DataRegInEXALU(FLAG_A) <= '0';
					end if;
					for i in 31 downto 0 loop
						if (ResBin(i) = '1') then
							cant1s := cant1s + 1;
						end if;
					end loop;
					if (cant1s MOD 2 = 0) then
						DataRegInEXALU(FLAG_P) <= '1';
					else
						DataRegInEXALU(FLAG_P) <= '0';
					end if;
					EnableRegEXALUWr <= '1';
					WAIT FOR 1 ns;
					EnableRegEXALUWr <= '0';
					WAIT FOR 1 ns;
				WHEN EX_BNE =>
					if (to_integer(signed(ResBin(31 downto 0))) = 0) then
						DataRegInEXALU(FLAG_Z) <= '1';
					else
						DataRegInEXALU(FLAG_Z) <= '0';
					end if;
					DataRegInEXALU(FLAG_S) <= ResBin(31);
					if ((Sop1(31) /= Sop2(31)) and (Sres(31) /= Sop1(31))) then
						DataRegInEXALU(FLAG_O) <= '1';
					else
						DataRegInEXALU(FLAG_O) <= '0';
					end if;
					if (to_integer(Sop1) < to_integer(Sop2)) then
						DataRegInEXALU(FLAG_C) <= '1';
					else
						DataRegInEXALU(FLAG_C) <= '0';
					end if;
					if (to_integer(Sop1(3 downto 0)) < to_integer(Sop2(3 downto 0))) then
						DataRegInEXALU(FLAG_A) <= '1';
					else
						DataRegInEXALU(FLAG_A) <= '0';
					end if;
					for i in 31 downto 0 loop
						if (ResBin(i) = '1') then
							cant1s := cant1s + 1;
						end if;
					end loop;
					if (cant1s MOD 2 = 0) then
						DataRegInEXALU(FLAG_P) <= '1';
					else
						DataRegInEXALU(FLAG_P) <= '0';
					end if;
					EnableRegEXALUWr <= '1';
					WAIT FOR 1 ns;
					EnableRegEXALUWr <= '0';
					WAIT FOR 1 ns;
				WHEN EX_BEQZ =>
					if (to_integer(signed(ResBin(31 downto 0))) = 0) then
						DataRegInEXALU(FLAG_Z) <= '1';
					else
						DataRegInEXALU(FLAG_Z) <= '0';
					end if;
					DataRegInEXALU(FLAG_S) <= ResBin(31);
					DataRegInEXALU(FLAG_O) <= '0';
					DataRegInEXALU(FLAG_C) <= '0';
					DataRegInEXALU(FLAG_A) <= '0';
					for i in 31 downto 0 loop
						if (ResBin(i) = '1') then
							cant1s := cant1s + 1;
						end if;
					end loop;
					if (cant1s MOD 2 = 0) then
						DataRegInEXALU(FLAG_P) <= '1';
					else
						DataRegInEXALU(FLAG_P) <= '0';
					end if;
					EnableRegEXALUWr <= '1';
					WAIT FOR 1 ns;
					EnableRegEXALUWr <= '0';
					WAIT FOR 1 ns;
				WHEN EX_BNEZ =>
					if (to_integer(signed(ResBin(31 downto 0))) = 0) then
						DataRegInEXALU(FLAG_Z) <= '1';
					else
						DataRegInEXALU(FLAG_Z) <= '0';
					end if;
					DataRegInEXALU(FLAG_S) <= ResBin(31);
					DataRegInEXALU(FLAG_O) <= '0';
					DataRegInEXALU(FLAG_C) <= '0';
					DataRegInEXALU(FLAG_A) <= '0';
					for i in 31 downto 0 loop
						if (ResBin(i) = '1') then
							cant1s := cant1s + 1;
						end if;
					end loop;
					if (cant1s MOD 2 = 0) then
						DataRegInEXALU(FLAG_P) <= '1';
					else
						DataRegInEXALU(FLAG_P) <= '0';
					end if;
					EnableRegEXALUWr <= '1';
					WAIT FOR 1 ns;
					EnableRegEXALUWr <= '0';
					WAIT FOR 1 ns;
				WHEN EX_BFPT =>
					if (ResBin(FLAG_F) = '0') then
						DataRegInEXALU(FLAG_Z) <= '1';
					else
						DataRegInEXALU(FLAG_Z) <= '0';
					end if;
					DataRegInEXALU(FLAG_S) <= '0';
					DataRegInEXALU(FLAG_O) <= '0';
					DataRegInEXALU(FLAG_C) <= '0';
					DataRegInEXALU(FLAG_A) <= '0';
					for i in 7 downto 0 loop
						if (ResBin(i) = '1') then
							cant1s := cant1s + 1;
						end if;
					end loop;
					if (cant1s MOD 2 = 0) then
						DataRegInEXALU(FLAG_P) <= '1';
					else
						DataRegInEXALU(FLAG_P) <= '0';
					end if;
					EnableRegEXALUWr <= '1';
					WAIT FOR 1 ns;
					EnableRegEXALUWr <= '0';
					WAIT FOR 1 ns;
				WHEN EX_BFPF =>
					if (ResBin(FLAG_F) = '0') then
						DataRegInEXALU(FLAG_Z) <= '1';
					else
						DataRegInEXALU(FLAG_Z) <= '0';
					end if;
					DataRegInEXALU(FLAG_S) <= '0';
					DataRegInEXALU(FLAG_O) <= '0';
					DataRegInEXALU(FLAG_C) <= '0';
					DataRegInEXALU(FLAG_A) <= '0';
					for i in 7 downto 0 loop
						if (ResBin(i) = '1') then
							cant1s := cant1s + 1;
						end if;
					end loop;
					if (cant1s MOD 2 = 0) then
						DataRegInEXALU(FLAG_P) <= '1';
					else
						DataRegInEXALU(FLAG_P) <= '0';
					end if;
					EnableRegEXALUWr <= '1';
					WAIT FOR 1 ns;
					EnableRegEXALUWr <= '0';
					WAIT FOR 1 ns;
				WHEN OTHERS =>
					report "Error: la operación a ejecutar en la ALU no es válida"
					severity FAILURE;
			END CASE;
		else
			report "Error: el signo de la operación ejecutada en la ALU no es válido"
			severity FAILURE;
		end if;
	END setFlagsRegister;
	
	PROCEDURE getAndUseFlagsRegister IS
		
	BEGIN
		EnableRegEXALURd <= '1';
		WAIT FOR 1 ns;
		EnableRegEXALURd <= '0';
		WAIT FOR 1 ns;
		CASE Op IS
			WHEN EX_SLT =>
				ResBin := "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" & DataRegOutEXALU(FLAG_S);
			WHEN EX_BEQ =>
				if (DataRegOutEXALU(FLAG_Z) = '1') then 
					DataRegInEXALU <= "ZZZZZZZZZZZZZZZZ" & jumpAddress;
					BranchEXALUtoSM.branch_taken <= '1';
					BranchEXALUtoSM.enable <= '1';
					EnableRegEXALUIP <= '1';
					WAIT FOR 1 ns;
					BranchEXALUtoSM.enable <= '0';
					EnableRegEXALUIP <= '0';
					WAIT FOR 1 ns;
				else
					BranchEXALUtoSM.branch_taken <= '0';
					BranchEXALUtoSM.enable <= '1';
					WAIT FOR 1 ns;
					BranchEXALUtoSM.enable <= '0';
					WAIT FOR 1 ns;
				end if;
			WHEN EX_BNE =>
				if (DataRegOutEXALU(FLAG_Z) = '0') then 
					DataRegInEXALU <= "ZZZZZZZZZZZZZZZZ" & jumpAddress;
					BranchEXALUtoSM.branch_taken <= '1';
					BranchEXALUtoSM.enable <= '1';
					EnableRegEXALUIP <= '1';
					WAIT FOR 1 ns;
					BranchEXALUtoSM.enable <= '0';
					EnableRegEXALUIP <= '0';
					WAIT FOR 1 ns;
				else
					BranchEXALUtoSM.branch_taken <= '0';
					BranchEXALUtoSM.enable <= '1';
					WAIT FOR 1 ns;
					BranchEXALUtoSM.enable <= '0';
					WAIT FOR 1 ns;
				end if;
			WHEN EX_BEQZ =>
				if (DataRegOutEXALU(FLAG_Z) = '1') then 
					DataRegInEXALU <= "ZZZZZZZZZZZZZZZZ" & jumpAddress;
					BranchEXALUtoSM.branch_taken <= '1';
					BranchEXALUtoSM.enable <= '1';
					EnableRegEXALUIP <= '1';
					WAIT FOR 1 ns;
					BranchEXALUtoSM.enable <= '0';
					EnableRegEXALUIP <= '0';
					WAIT FOR 1 ns;
				else
					BranchEXALUtoSM.branch_taken <= '0';
					BranchEXALUtoSM.enable <= '1';
					WAIT FOR 1 ns;
					BranchEXALUtoSM.enable <= '0';
					WAIT FOR 1 ns;
				end if;
			WHEN EX_BNEZ =>
				if (DataRegOutEXALU(FLAG_Z) = '0') then 
					DataRegInEXALU <= "ZZZZZZZZZZZZZZZZ" & jumpAddress;
					BranchEXALUtoSM.branch_taken <= '1';
					BranchEXALUtoSM.enable <= '1';
					EnableRegEXALUIP <= '1';
					WAIT FOR 1 ns;
					BranchEXALUtoSM.enable <= '0';
					EnableRegEXALUIP <= '0';
					WAIT FOR 1 ns;
				else
					BranchEXALUtoSM.branch_taken <= '0';
					BranchEXALUtoSM.enable <= '1';
					WAIT FOR 1 ns;
					BranchEXALUtoSM.enable <= '0';
					WAIT FOR 1 ns;
				end if;
			WHEN EX_BFPT =>
				if (DataRegOutEXALU(FLAG_Z) = '0') then 
					DataRegInEXALU <= "ZZZZZZZZZZZZZZZZ" & jumpAddress;
					BranchEXALUtoSM.branch_taken <= '1';
					BranchEXALUtoSM.enable <= '1';
					EnableRegEXALUIP <= '1';
					WAIT FOR 1 ns;
					BranchEXALUtoSM.enable <= '0';
					EnableRegEXALUIP <= '0';
					WAIT FOR 1 ns;
				else
					BranchEXALUtoSM.branch_taken <= '0';
					BranchEXALUtoSM.enable <= '1';
					WAIT FOR 1 ns;
					BranchEXALUtoSM.enable <= '0';
					WAIT FOR 1 ns;
				end if;
			WHEN EX_BFPF =>
				if (DataRegOutEXALU(FLAG_Z) = '1') then 
					DataRegInEXALU <= "ZZZZZZZZZZZZZZZZ" & jumpAddress;
					BranchEXALUtoSM.branch_taken <= '1';
					BranchEXALUtoSM.enable <= '1';
					EnableRegEXALUIP <= '1';
					WAIT FOR 1 ns;
					BranchEXALUtoSM.enable <= '0';
					EnableRegEXALUIP <= '0';
					WAIT FOR 1 ns;
				else
					BranchEXALUtoSM.branch_taken <= '0';
					BranchEXALUtoSM.enable <= '1';
					WAIT FOR 1 ns;
					BranchEXALUtoSM.enable <= '0';
					WAIT FOR 1 ns;
				end if;
			WHEN OTHERS =>
				report "Error: la operación para utilizar el registro de banderas de la ALU no es válida"
				severity FAILURE;
		END CASE;	
	END getAndUseFlagsRegister;	

	
	BEGIN 
		if (First) then
			First := false;
			BranchEXALUtoSM.enable <= '0';
			EnableRegEXALURd <= '0'; 
			EnableRegEXALUWr <= '0';
			EnableRegEXALUIP <= '0';	
			DoneEXALU <= '0';
			WAIT FOR 1 ns;
		end if;
		WAIT UNTIL falling_edge(EnableEXALU);
		DoneEXALU <= '0';
		Op := to_integer(unsigned(IDtoEXALU.op));
		if (Op /= EX_NULL) then
			alu; 
			setFlagsRegister;
			if (needFlags) then
				getAndUseFlagsRegister;
			end if;	
			if (not isJumpOp) then
				DataEXALUtoWB <= ResBin(31 downto 0);
			end if;
		end if;
		DoneEXALU <= '1';	
	END PROCESS Main;
	
	
end EXECUTE_ALU_ARCHITECTURE;





