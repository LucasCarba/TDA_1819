
-- Entidad "execute_fpu":
-- Descripción: Aquí se define la funcionalidad correspondiente a la unidad de punto flotante
-- (FPU) dentro de la etapa de ejecución del pipeline, por lo que en esta FPU se ejecutarán 
-- únicamente las operaciones aritmético-lógicas que involucren operandos en punto flotante: 
-- sumas, restas, multiplicaciones y divisiones, conversiones y comparaciones. Una vez finalizada 
-- la operación en cuestión, accederá al Registro de Banderas del procesador asociado a esta FPU 
-- (FPFLAGS) con el objetivo de actualizarlo con el estado de la última operación ejecutada. 
-- A continuación, si llegara a ser necesario, se dirige nuevamente a este registro para obtener 
-- de él toda la información requerida para actualizar otra de sus banderas, llamada "punto 
-- flotante" (flag F), en función del resultado de la última comparación realizada. Finalmente, 
-- envía al administrador de la etapa de ejecución del pipeline el resultado final de la 
-- operación aritmético-lógica llevada a cabo en esta FPU para que éste disponga de él como 
-- juzgue conveniente y necesario. Recordar que, independientemente de la naturaleza de la 
-- operación en cuestión, una ejecución completa en esta unidad requerirá en total cuatro ciclos 
-- de reloj.
-- Procesos:
-- Main: En primer lugar, recibe la señal del administrador de la etapa de ejecución del
-- pipeline para comenzar la ejecución de la operación aritmético-lógica requerida por la
-- instrucción actual. También obtendrá toda la información necesaria para determinar el tipo
-- de operación a realizar y, en consecuencia, los procedimientos a invocar para llevar a cabo 
-- la operación y actualizar el registro FPFLAGS para luego, si se estuviera llevando a cabo una
-- comparación, leerlo para actualizar el flag FP con el valor que corresponda. Finalmente, 
-- este proceso enviará al administrador el resultado de la operación para que éste a su vez 
-- lo haga llegar a las siguientes etapas del pipeline según sea necesario.
-- Procedimientos y funciones:
-- fpu(): Este procedimiento lleva a cabo la tarea fundamental de esta FPU: ejecutar la
-- operación aritmético-lógica requerida por la instrucción actual (suma, resta, multiplicación o
-- división), tanto para posteriormente escribir su resultado en el banco de registros en la etapa 
-- "writeback" como así también para, en caso de ser necesario, utilizarlo internamente para una 
-- comparación.
-- setFlagsRegisterFP(): Actualiza algunas de las banderas del registro FLAGS con los atributos
-- del estado correspondiente a la última operación aritmético-lógica ejecutada: cero (flag Z), 
-- negativo (flag S), overflow (flag O), acarreo (flag C), acarreo auxiliar (flag A) y paridad 
-- (flag P). Dichas banderas pueden ser muy importantes para tomar una eventual decisión
-- respecto a una comparación (por ejemplo, el flag Z permitiría determinar si los operandos de la 
-- última operación ejecutada eran iguales; el flag S, si el primero era menor al segundo; etc.).
-- getAndUseFlagsRegisterFP(): Lee las banderas del registro FLAGS para obtener los atributos del
-- estado correspondiente a la última operación aritmético-lógica, ya actualizados en el
-- procedimiento anterior. A partir de los datos leídos, se determinará aquí cuál es el nuevo 
-- valor que deberá ser asignado al flag FP, para luego acceder nuevamente a este registro y 
-- actualizar efectivamente dicho flag con este valor.


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




entity execute_fpu is
	
	port ( 
		DataRegInEXFPU		: out std_logic_vector(31 downto 0);
		EnableRegEXFPURd	: out std_logic;
		EnableRegEXFPUWr	: out std_logic;
		DoneEXFPU			: out std_logic;
		DataEXFPUtoWB		: out std_logic_vector(31 downto 0);
		IDtoEXFPU			: in  execute_record;
		DataRegOutEXFPU		: in  std_logic_vector(31 downto 0);
		EnableEXFPU			: in  std_logic);

end execute_fpu;




architecture EXECUTE_FPU_ARCHITECTURE of execute_fpu is


	
begin
	
	
	Main: PROCESS
	
	VARIABLE First: BOOLEAN := true; 
	VARIABLE Op: INTEGER;			 
	VARIABLE Sign: STD_LOGIC;
	VARIABLE Fop1: float32;
	VARIABLE Fop2: float32;
	VARIABLE Fres: float32;
	VARIABLE ResBin: STD_LOGIC_VECTOR(31 downto 0);
	VARIABLE needFlags: BOOLEAN;
	VARIABLE jumpAddress: STD_LOGIC_VECTOR(15 downto 0);
	
	PROCEDURE fpu IS  
	
	BEGIN  
		jumpAddress := IDtoEXFPU.address;
		needFlags := false;
		Sign := IDtoEXFPU.sign;
		if (Sign = '1') then	
			Fop1 := to_float(IDtoEXFPU.op1, Fop1);
			Fop2 := to_float(IDtoEXFPU.op2, Fop2);
			CASE Op IS
				WHEN EX_NULL =>
					NULL;
				WHEN EX_TF =>
					Fres := Fop1;
				WHEN EX_TI =>
					Fres := Fop1;
				WHEN EX_ADD =>
					Fres := Fop1 + Fop2;
				WHEN EX_SUB =>
					Fres := Fop1 - Fop2;
				WHEN EX_MUL =>
					Fres := Fop1 * Fop2;
				WHEN EX_DIV =>
					Fres := Fop1 / Fop2;
				WHEN EX_LTF =>
					Fres := Fop1 - Fop2;
					needFlags := true;
				WHEN EX_LEF =>
					Fres := Fop1 - Fop2;
					needFlags := true;
				WHEN EX_EQF =>
					Fres := Fop1 - Fop2;
					needFlags := true;
				WHEN OTHERS =>
					report "Error: la operación a ejecutar en la ALU para punto flotante no es válida"
					severity FAILURE;
			END CASE;
		else
			report "Error: el signo de la operación a ejecutar en la ALU para punto flotante no es válido"
			severity FAILURE;
		end if;
		if (Sign = '1') then
			if (Op /= EX_TI) then 
				ResBin := to_Std_Logic_Vector(Fres);
			else 
				ResBin := std_logic_vector(to_signed(Fres, ResBin'length)); 
			end if;
		else
			report "Error: el signo de la operación ejecutada en la ALU para punto flotante no es válido"
			severity FAILURE;
		end if;		
	END fpu;
	
	PROCEDURE setFlagsRegisterFP IS	 
	
	VARIABLE cant1s: INTEGER := 0;
	
	BEGIN
		DataRegInEXFPU <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
		if (Sign = '1') then
			CASE Op IS
				WHEN EX_NULL =>
					NULL;
				WHEN EX_TF =>
					if (to_real(to_float(ResBin(31 downto 0))) = 0.0) then
						DataRegInEXFPU(FLAG_Z) <= '1';
					else
						DataRegInEXFPU(FLAG_Z) <= '0';
					end if;
					DataRegInEXFPU(FLAG_S) <= ResBin(31);
					DataRegInEXFPU(FLAG_O) <= '0';
					DataRegInEXFPU(FLAG_C) <= '0';
					DataRegInEXFPU(FLAG_A) <= '0';
					for i in 31 downto 0 loop
						if (ResBin(i) = '1') then
							cant1s := cant1s + 1;
						end if;
					end loop;
					if (cant1s MOD 2 = 0) then
						DataRegInEXFPU(FLAG_P) <= '1';
					else
						DataRegInEXFPU(FLAG_P) <= '0';
					end if;	
					DataRegInEXFPU(FLAG_F) <= '0';
					EnableRegEXFPUWr <= '1';
					WAIT FOR 1 ns;
					EnableRegEXFPUWr <= '0';
					WAIT FOR 1 ns;	
				WHEN EX_TI =>
					if (to_integer(signed(ResBin(31 downto 0))) = 0) then
						DataRegInEXFPU(FLAG_Z) <= '1';
					else
						DataRegInEXFPU(FLAG_Z) <= '0';
					end if;
					DataRegInEXFPU(FLAG_S) <= ResBin(31);
					DataRegInEXFPU(FLAG_O) <= '0';
					DataRegInEXFPU(FLAG_C) <= '0';
					DataRegInEXFPU(FLAG_A) <= '0';
					for i in 31 downto 0 loop
						if (ResBin(i) = '1') then
							cant1s := cant1s + 1;
						end if;
					end loop;
					if (cant1s MOD 2 = 0) then
						DataRegInEXFPU(FLAG_P) <= '1';
					else
						DataRegInEXFPU(FLAG_P) <= '0';
					end if;		
					DataRegInEXFPU(FLAG_F) <= '0';
					EnableRegEXFPUWr <= '1';
					WAIT FOR 1 ns;
					EnableRegEXFPUWr <= '0';
					WAIT FOR 1 ns;
				WHEN EX_ADD =>
					if (to_real(to_float(ResBin(31 downto 0))) = 0.0) then
						DataRegInEXFPU(FLAG_Z) <= '1';
					else
						DataRegInEXFPU(FLAG_Z) <= '0';
					end if;
					DataRegInEXFPU(FLAG_S) <= ResBin(31);
					if ((Fop1(8) = Fop2(8)) and (Fres(8) /= Fop1(8))) then
						DataRegInEXFPU(FLAG_O) <= '1';
					else
						DataRegInEXFPU(FLAG_O) <= '0';
					end if;
					--DataRegInEX(FLAG_C) <= ResBin(32);
					DataRegInEXFPU(FLAG_C) <= '0';
					if ((Fop1(-19) = '0') OR (Fop2(-19) = '0')) then
						if ((Fop1(-19) OR Fop2(-19)) /= ResBin(4)) then
							DataRegInEXFPU(FLAG_A) <= '1';
						else
							DataRegInEXFPU(FLAG_A) <= '0';
						end if;
					else
						if (ResBin(4) /= '0') then
							DataRegInEXFPU(FLAG_A) <= '1';
						else
							DataRegInEXFPU(FLAG_A) <= '0';
						end if;
					end if;
					for i in 31 downto 0 loop
						if (ResBin(i) = '1') then
							cant1s := cant1s + 1;
						end if;
					end loop;
					if (cant1s MOD 2 = 0) then
						DataRegInEXFPU(FLAG_P) <= '1';
					else
						DataRegInEXFPU(FLAG_P) <= '0';
					end if;		
					DataRegInEXFPU(FLAG_F) <= '0';
					EnableRegEXFPUWr <= '1';
					WAIT FOR 1 ns;
					EnableRegEXFPUWr <= '0';
					WAIT FOR 1 ns;
				WHEN EX_SUB =>
					if (to_real(to_float(ResBin(31 downto 0))) = 0.0) then
						DataRegInEXFPU(FLAG_Z) <= '1';
					else
						DataRegInEXFPU(FLAG_Z) <= '0';
					end if;
					DataRegInEXFPU(FLAG_S) <= ResBin(31);
					if ((Fop1(8) /= Fop2(8)) and (Fres(8) /= Fop1(8))) then
						DataRegInEXFPU(FLAG_O) <= '1';
					else
						DataRegInEXFPU(FLAG_O) <= '0';
					end if;
					if (Fop1 < Fop2) then
						DataRegInEXFPU(FLAG_C) <= '1';
					else
						DataRegInEXFPU(FLAG_C) <= '0';
					end if;
					--if (Fop1(-20 downto -23) < Fop2(-20 downto -23)) then
						--DataRegInEXFPU(FLAG_A) <= '1';
					--else
						DataRegInEXFPU(FLAG_A) <= '0';
					--end if;
					for i in 31 downto 0 loop
						if (ResBin(i) = '1') then
							cant1s := cant1s + 1;
						end if;
					end loop;
					if (cant1s MOD 2 = 0) then
						DataRegInEXFPU(FLAG_P) <= '1';
					else
						DataRegInEXFPU(FLAG_P) <= '0';
					end if;			
					DataRegInEXFPU(FLAG_F) <= '0';
					EnableRegEXFPUWr <= '1';
					WAIT FOR 1 ns;
					EnableRegEXFPUWr <= '0';
					WAIT FOR 1 ns;
				WHEN EX_MUL =>
					if (to_real(to_float(ResBin(31 downto 0))) = 0.0) then
						DataRegInEXFPU(FLAG_Z) <= '1';
					else
						DataRegInEXFPU(FLAG_Z) <= '0';
					end if;
					DataRegInEXFPU(FLAG_S) <= ResBin(31);
					if ((Fop1(8) = Fop2(8)) and (Fres(8) = '1')) then
						DataRegInEXFPU(FLAG_O) <= '1';
					elsif ((Fop1(8) /= Fop2(8)) and (Fres(8) = '0')) then  
						DataRegInEXFPU(FLAG_O) <= '1';
					else
						DataRegInEXFPU(FLAG_O) <= '0';
					end if;
					DataRegInEXFPU(FLAG_C) <= 'Z';
					DataRegInEXFPU(FLAG_A) <= 'Z';
					for i in 31 downto 0 loop
						if (ResBin(i) = '1') then
							cant1s := cant1s + 1;
						end if;
					end loop;
					if (cant1s MOD 2 = 0) then
						DataRegInEXFPU(FLAG_P) <= '1';
					else
						DataRegInEXFPU(FLAG_P) <= '0';
					end if;		   
					DataRegInEXFPU(FLAG_F) <= '0';
					EnableRegEXFPUWr <= '1';
					WAIT FOR 1 ns;
					EnableRegEXFPUWr <= '0';
					WAIT FOR 1 ns;
				WHEN EX_DIV =>
					if (to_real(to_float(ResBin(31 downto 0))) = 0.0) then
						DataRegInEXFPU(FLAG_Z) <= '1';
					else
						DataRegInEXFPU(FLAG_Z) <= '0';
					end if;
					DataRegInEXFPU(FLAG_S) <= ResBin(31);
					if ((Fop1(8) = Fop2(8)) and (Fres(8) = '1')) then
						DataRegInEXFPU(FLAG_O) <= '1';
					elsif ((Fop1(8) /= Fop2(8)) and (Fres(8) = '0')) then  
						DataRegInEXFPU(FLAG_O) <= '1';
					else
						DataRegInEXFPU(FLAG_O) <= '0';
					end if;
					DataRegInEXFPU(FLAG_C) <= 'Z';
					DataRegInEXFPU(FLAG_A) <= 'Z';
					for i in 31 downto 0 loop
						if (ResBin(i) = '1') then
							cant1s := cant1s + 1;
						end if;
					end loop;
					if (cant1s MOD 2 = 0) then
						DataRegInEXFPU(FLAG_P) <= '1';
					else
						DataRegInEXFPU(FLAG_P) <= '0';
					end if;		   
					DataRegInEXFPU(FLAG_F) <= '0';
					EnableRegEXFPUWr <= '1';
					WAIT FOR 1 ns;
					EnableRegEXFPUWr <= '0';
					WAIT FOR 1 ns;
				WHEN EX_LTF =>
					if (to_real(to_float(ResBin(31 downto 0))) = 0.0) then
						DataRegInEXFPU(FLAG_Z) <= '1';
					else
						DataRegInEXFPU(FLAG_Z) <= '0';
					end if;
					DataRegInEXFPU(FLAG_S) <= ResBin(31);
					if ((Fop1(8) /= Fop2(8)) and (Fres(8) /= Fop1(8))) then
						DataRegInEXFPU(FLAG_O) <= '1';
					else
						DataRegInEXFPU(FLAG_O) <= '0';
					end if;
					if (Fop1 < Fop2) then
						DataRegInEXFPU(FLAG_C) <= '1';
					else
						DataRegInEXFPU(FLAG_C) <= '0';
					end if;
					--if (Fop1(-20 downto -23) < Fop2(-20 downto -23)) then
						--DataRegInEXFPU(FLAG_A) <= '1';
					--else
						DataRegInEXFPU(FLAG_A) <= '0';
					--end if;
					for i in 31 downto 0 loop
						if (ResBin(i) = '1') then
							cant1s := cant1s + 1;
						end if;
					end loop;
					if (cant1s MOD 2 = 0) then
						DataRegInEXFPU(FLAG_P) <= '1';
					else
						DataRegInEXFPU(FLAG_P) <= '0';
					end if;			
					DataRegInEXFPU(FLAG_F) <= '0';
					EnableRegEXFPUWr <= '1';
					WAIT FOR 1 ns;
					EnableRegEXFPUWr <= '0';
					WAIT FOR 1 ns;
				WHEN EX_LEF =>
					if (to_real(to_float(ResBin(31 downto 0))) = 0.0) then
						DataRegInEXFPU(FLAG_Z) <= '1';
					else
						DataRegInEXFPU(FLAG_Z) <= '0';
					end if;
					DataRegInEXFPU(FLAG_S) <= ResBin(31);
					if ((Fop1(8) /= Fop2(8)) and (Fres(8) /= Fop1(8))) then
						DataRegInEXFPU(FLAG_O) <= '1';
					else
						DataRegInEXFPU(FLAG_O) <= '0';
					end if;
					if (Fop1 < Fop2) then
						DataRegInEXFPU(FLAG_C) <= '1';
					else
						DataRegInEXFPU(FLAG_C) <= '0';
					end if;
					--if (Fop1(-20 downto -23) < Fop2(-20 downto -23)) then
						--DataRegInEXFPU(FLAG_A) <= '1';
					--else
						DataRegInEXFPU(FLAG_A) <= '0';
					--end if;
					for i in 31 downto 0 loop
						if (ResBin(i) = '1') then
							cant1s := cant1s + 1;
						end if;
					end loop;
					if (cant1s MOD 2 = 0) then
						DataRegInEXFPU(FLAG_P) <= '1';
					else
						DataRegInEXFPU(FLAG_P) <= '0';
					end if;			
					DataRegInEXFPU(FLAG_F) <= '0';
					EnableRegEXFPUWr <= '1';
					WAIT FOR 1 ns;
					EnableRegEXFPUWr <= '0';
					WAIT FOR 1 ns;
				WHEN EX_EQF =>
					if (to_real(to_float(ResBin(31 downto 0))) = 0.0) then
						DataRegInEXFPU(FLAG_Z) <= '1';
					else
						DataRegInEXFPU(FLAG_Z) <= '0';
					end if;
					DataRegInEXFPU(FLAG_S) <= ResBin(31);
					if ((Fop1(8) /= Fop2(8)) and (Fres(8) /= Fop1(8))) then
						DataRegInEXFPU(FLAG_O) <= '1';
					else
						DataRegInEXFPU(FLAG_O) <= '0';
					end if;
					if (Fop1 < Fop2) then
						DataRegInEXFPU(FLAG_C) <= '1';
					else
						DataRegInEXFPU(FLAG_C) <= '0';
					end if;
					--if (Fop1(-20 downto -23) < Fop2(-20 downto -23)) then
						--DataRegInEXFPU(FLAG_A) <= '1';
					--else
						DataRegInEXFPU(FLAG_A) <= '0';
					--end if;
					for i in 31 downto 0 loop
						if (ResBin(i) = '1') then
							cant1s := cant1s + 1;
						end if;
					end loop;
					if (cant1s MOD 2 = 0) then
						DataRegInEXFPU(FLAG_P) <= '1';
					else
						DataRegInEXFPU(FLAG_P) <= '0';
					end if;			
					DataRegInEXFPU(FLAG_F) <= '0';
					EnableRegEXFPUWr <= '1';
					WAIT FOR 1 ns;
					EnableRegEXFPUWr <= '0';
					WAIT FOR 1 ns;
				WHEN OTHERS =>
					report "Error: la operación a ejecutar en la ALU para punto flotante no es válida"
					severity FAILURE;
			END CASE;
		else
			report "Error: el signo de la operación ejecutada en la ALU para punto flotante no es válido"
			severity FAILURE;
		end if;
	END setFlagsRegisterFP;
	
	PROCEDURE getAndUseFlagsRegisterFP IS
		
	BEGIN
		EnableRegEXFPURd <= '1';
		WAIT FOR 1 ns;
		EnableRegEXFPURd <= '0';
		WAIT FOR 1 ns;
		CASE Op IS
			WHEN EX_LTF =>
				DataRegInEXFPU(FLAG_F) <= DataRegOutEXFPU(FLAG_S);
				EnableRegEXFPUWr <= '1';
				WAIT FOR 1 ns;
				EnableRegEXFPUWr <= '0';
				WAIT FOR 1 ns;
			WHEN EX_LEF =>
				DataRegInEXFPU(FLAG_F) <= DataRegOutEXFPU(FLAG_S) OR DataRegOutEXFPU(FLAG_Z);
				EnableRegEXFPUWr <= '1';
				WAIT FOR 1 ns;
				EnableRegEXFPUWr <= '0';
				WAIT FOR 1 ns; 
			WHEN EX_EQF =>
				DataRegInEXFPU(FLAG_F) <= DataRegOutEXFPU(FLAG_Z);
				EnableRegEXFPUWr <= '1';
				WAIT FOR 1 ns;
				EnableRegEXFPUWr <= '0';
				WAIT FOR 1 ns;
			WHEN OTHERS =>
				report "Error: la operación para utilizar el registro de banderas de la ALU no es válida"
				severity FAILURE;
		END CASE;	
	END getAndUseFlagsRegisterFP;
	
	
	BEGIN	
		if (First) then
			First := false; 
			EnableRegEXFPURd <= '0';
			EnableRegEXFPUWr <= '0';
			DoneEXFPU <= '0';
			WAIT FOR 1 ns;	
		end if;
		WAIT UNTIL falling_edge(EnableEXFPU); 
		DoneEXFPU <= '0';
		Op := to_integer(unsigned(IDtoEXFPU.op));
		fpu;
		setFlagsRegisterFP;	   
		if (needFlags) then
			getAndUseFlagsRegisterFP;
		end if;	
		DataEXFPUtoWB <= ResBin(31 downto 0); 
		DoneEXFPU <= '1';
	END PROCESS Main;
	
	
	
end EXECUTE_FPU_ARCHITECTURE;





