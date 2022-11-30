
-- Entidad "states_machine":
-- Descripción: Aquí se define la máquina de estados para que el usuario pueda mantenerse
-- informado sobre la situación actual del procesador: qué etapa del pipeline se encuentra 
-- ejecutando cada instrucción, si en algún momento surgió algún tipo de atasco en el 
-- procesador por dependencias estructurales, de datos o de control, si alguna instrucción de 
-- transferencia de control provocó un salto o no, etc.	Cabe mencionar que, al tratarse de
-- una simple interfaz, el comportamiento de esta entidad no posee ningún tipo de repercusión 
-- sobre el funcionamiento de la CPU: solamente pretende describirlo de una manera tan sencilla
-- como resulte posible para que pueda ser comprendida por el usuario.
-- Procesos:
-- Init: Este proceso representa la inicialización de la máquina de estados: recibe del 
-- ensamblador información detallada sobre cada una de las instrucciones del programa para 
-- mostrársela al usuario conforme empiecen a ejecutarse.
-- Main: Una vez comenzada la ejecución del programa en la CPU, procede a cargar para cada 
-- instrucción que empieza a ejecutarse la información recibida del ensamblador y actualiza 
-- su estado (etapa de la segmentación) a través del tiempo.
-- Procedimientos y funciones:
-- SetDetail(): Carga la nueva instrucción a ser ejecutada con toda la información recibida
-- del ensamblador.
-- SetIdInstStateComp(): Si se produjo un salto en la ejecución del programa como consecuencia 
-- de una instrucción de transferencia de control, actualiza el índice necesario para obtener
-- la información recibida del ensamblador para la próxima instrucción a ejecutar.
-- SetState(): Actualiza los estados de las instrucciones en ejecución en caso de que la 
-- segmentación del procesador haya sido desactivada por el usuario. Por lo tanto, sólo 
-- existirá una única instrucción ejecutándose al mismo tiempo, simplificándose 
-- considerablemente el funcionamiento de la máquina de estados.
-- SetStates(): Actualiza el estado de las instrucciones en ejecución en caso de que la
-- segmentación del procesador haya sido activada por el usuario. Por lo tanto, podrán existir
-- múltiples instrucciones ejecutándose al mismo tiempo, aunque cada una siempre se encontrará
-- en una etapa distinta del pipeline, es decir, poseerá un estado diferente de las demás.


library TDA_1819;	
use TDA_1819.const_buses.all;
use TDA_1819.const_cpu.all;
use TDA_1819.tipos_cpu.all; 


LIBRARY IEEE;

USE std.textio.all;
use ieee.NUMERIC_STD.all;
USE IEEE.std_logic_1164.all; 




entity states_machine is 
	
	generic (
		Pipelining			: BOOLEAN);
	
	port (
		CompToSM			: in state_comp;
		BranchIDtoSM		: in state_branch;
		BranchEXALUtoSM		: in state_branch;
		Fp					: in std_logic;
		LoadInstState		: in std_logic;
		LoadBranchInstState	: in std_logic;
		DoneID				: in std_logic;
		StallHLT			: in std_logic;
		StallSTR			: in std_logic;
		StallRAW			: in std_logic;
		StallWAWAux			: in std_logic;
		StopSM				: in std_logic;
		EnableSM			: in std_logic);

end states_machine;




architecture STATES_MACHINE_ARCHITECTURE of states_machine is


	SIGNAL InstStatesComp:	state_records(1 to CANT_MAX_INST_COMP);	
	SIGNAL InstStatesExec:	state_records(1 to CANT_MAX_INST_EXEC);
	
	
begin
	
	
	Init: PROCESS
	
	VARIABLE First: BOOLEAN := true;
	VARIABLE i: INTEGER := 1;

	BEGIN
		if (First) then
			for j in InstStatesComp'range loop
				InstStatesComp(i).id <= -1;
			end loop;
			First := false;
		end if;
		WAIT UNTIL (rising_edge(LoadInstState) OR rising_edge(LoadBranchInstState));
		if (LoadInstState = '1') then 
			InstStatesComp(i).id <= i;
			InstStatesComp(i).state <= B;
			InstStatesComp(i).detail.num_linea <= CompToSM.num_linea;
			InstStatesComp(i).detail.name_inst <= CompToSM.name_inst;
			InstStatesComp(i).detail.num_inst <= i;
			InstStatesComp(i).detail.num_linea_branch_taken_ID <= -1;
			InstStatesComp(i).detail.num_linea_branch_taken_EX <= -1;
		elsif (LoadBranchInstState = '1') then	
			for j in InstStatesComp'range loop
				if (InstStatesComp(j).id = -1) then
					report "Error: la máquina de estados no pudo encontrar la instrucción destino del salto"
					severity FAILURE;
				end if; 
				if (InstStatesComp(j).detail.num_linea = CompToSM.num_linea) then
					InstStatesComp(j).detail.num_linea_branch_taken_ID <= CompToSM.num_linea_branch_taken_ID;
					InstStatesComp(j).detail.num_linea_branch_taken_EX <= CompToSM.num_linea_branch_taken_EX;
					exit;
				end if;	
			end loop;
		end if;
		i := i + 1;
	END PROCESS Init;			
		
	
	Main: PROCESS 
	
	
	PROCEDURE SetDetail (CONSTANT idInstStateExec: IN INTEGER; idInstStateComp: INOUT INTEGER) IS
	BEGIN
		InstStatesExec(idInstStateExec).detail <= InstStatesComp(idInstStateComp).detail;
		idInstStateComp := idInstStateComp + 1;
	END SetDetail;
	
	PROCEDURE SetIdInstStateComp (CONSTANT num_linea_branch_taken: IN INTEGER; idInstStateComp: INOUT INTEGER) IS
	VARIABLE i: INTEGER := 1;	
	BEGIN
		while (InstStatesComp(i).detail.num_linea /= num_linea_branch_taken) loop
			i := i + 1;
			if (InstStatesComp(i).id = -1) then
				report "Error: la máquina de estados no pudo encontrar la instrucción destino del salto"
				severity FAILURE;
			end if;
		end loop;
		idInstStateComp := i;
	END SetIdInstStateComp;
																
	PROCEDURE SetState (idInstStateExec, idInstStateComp: INOUT INTEGER) IS
	BEGIN 
		CASE InstStatesExec(idInstStateExec).state IS
			WHEN B =>
				InstStatesExec(idInstStateExec).state <= F;
				SetDetail(idInstStateExec, idInstStateComp);
			WHEN F =>
				InstStatesExec(idInstStateExec).state <= D;
				if (InstStatesExec(idInstStateExec).detail.num_linea_branch_taken_ID /= -1) then	
					WAIT UNTIL rising_edge(BranchIDtoSM.enable);
					if (BranchIDtoSM.branch_taken = '1') then 
						SetIdInstStateComp(InstStatesExec(idInstStateExec).detail.num_linea_branch_taken_ID, idInstStateComp);
					end if;
				end if;
			WHEN D =>
				if ((Fp = '0') or (Fp = 'Z')) then	
					InstStatesExec(idInstStateExec).state <= X;
					if (InstStatesExec(idInstStateExec).detail.num_linea_branch_taken_EX /= -1) then
						WAIT UNTIL rising_edge(BranchEXALUtoSM.enable);
						if (BranchEXALUtoSM.branch_taken = '1') then
							SetIdInstStateComp(InstStatesExec(idInstStateExec).detail.num_linea_branch_taken_EX, idInstStateComp);
						end if;
					end if;
				else
					InstStatesExec(idInstStateExec).state <= X_FP1;
				end if;
			WHEN X =>
				InstStatesExec(idInstStateExec).state <= M;
			WHEN X_FP1 =>
				InstStatesExec(idInstStateExec).state <= X_FP2;
			WHEN X_FP2 =>
				InstStatesExec(idInstStateExec).state <= X_FP3;
			WHEN X_FP3 =>
				InstStatesExec(idInstStateExec).state <= X_FP4;
			WHEN X_FP4 =>
				InstStatesExec(idInstStateExec).state <= M;
			WHEN M =>
				InstStatesExec(idInstStateExec).state <= W;
			WHEN W =>
				InstStatesExec(idInstStateExec).state <= E;
				if (StopSM = '0') then
					idInstStateExec := idInstStateExec + 1;
					InstStatesExec(idInstStateExec).state <= F;
					SetDetail(idInstStateExec, idInstStateComp);
				end if;
			WHEN OTHERS =>
				report "Error: el estado de la instrucción " & integer'image(idInstStateExec) & " es inválido"
				severity FAILURE;
		END CASE;
	END SetState;
	
	PROCEDURE SetStates (idInstStateExecEnd, idInstStateComp: INOUT INTEGER; firstSTR, firstWAW, wasHLT: INOUT BOOLEAN) IS
	BEGIN	
		for i in 1 to idInstStateExecEnd loop
			CASE InstStatesExec(i).state IS
				WHEN B => 
					if (StallSTR = '1') then
						if ((not firstSTR) and (not wasHLT)) then
							firstSTR := true;
						else
							firstSTR := false;
						end if;
					end if;
					if (((StallSTR = '0') and (StallRAW = '0') and (StallWAWAux = '0')) or ((StallSTR = '1') and (firstSTR) and (StallRAW = '0')) or (firstWAW)) then
						if (i > 1) then
							if ((InstStatesExec(i-1).state /= B) and ((StallSTR = '0') or (firstSTR))) then
								InstStatesExec(i).state <= F;
								SetDetail(i, idInstStateComp);
								if ((StopSM = '0') or ((StopSM = '1') and (InstStatesExec(i-1).state = F))) then
									idInstStateExecEnd := idInstStateExecEnd + 1;
								end if;
							end if;
						else
							InstStatesExec(i).state <= F;
							SetDetail(i, idInstStateComp);
							if ((StopSM = '0') or ((StopSM = '1') and (InstStatesExec(i-1).state = F))) then
								idInstStateExecEnd := idInstStateExecEnd + 1;
							end if;
						end if;
					end if;
					--if (StallSTR = '1') then
						--InstStatesExec(i).state <= F_STR;
					--elsif (StallRAW = '1') then
						--InstStatesExec(i).state <= F_RAW;
					--elsif (StallWAWAux = '1') then
						--InstStatesExec(i).state <= F_WAW;
					--end if;
				WHEN F_STR =>
					if (StallSTR = '0') then
						if (StallRAW = '1') then
							InstStatesExec(i).state <= F_RAW;
						elsif (StallWAWAux = '1') then
							InstStatesExec(i).state <= F_WAW;
						else
							InstStatesExec(i).state <= F;
						end if;
					end if;
				WHEN F_RAW =>
					if (StallRAW = '0') then
						if (StallSTR = '1') then
							InstStatesExec(i).state <= F_STR;
						elsif (StallWAWAux = '1') then
							InstStatesExec(i).state <= F_WAW;
						else
							InstStatesExec(i).state <= F;
							SetDetail(i, idInstStateComp);
						end if;
					end if;
				WHEN F_WAW =>
					if (StallWAWAux = '0') then
						if (StallSTR = '1') then
							InstStatesExec(i).state <= F_STR;
						elsif (StallRAW = '1') then
							InstStatesExec(i).state <= F_RAW;
						else
							InstStatesExec(i).state <= F;
						end if;
					end if;
				--WHEN F_BRX =>
					--InstStatesExec(i).state <= F;
					--SetDetail(i, idInstStateComp); 
					--exit;
				WHEN F_END =>
					InstStatesExec(i).state <= D_END;
				WHEN F =>
					--InstStatesExec(i).state <= D;
					if (StallSTR = '1') then
						InstStatesExec(i).state <= D_STR;
					elsif (StallRAW = '1') then
						InstStatesExec(i).state <= D_RAW;
					elsif ((StallWAWAux = '1') and (not firstWAW)) then
						InstStatesExec(i).state <= D_WAW;
					else
						if (InstStatesExec(i).detail.num_linea_branch_taken_ID /= -1) then 
							WAIT UNTIL rising_edge(BranchIDtoSM.enable);
							InstStatesExec(i).state <= D;
							if (BranchIDtoSM.branch_taken = '1') then
								InstStatesExec(i+1).state <= F_END;
								SetDetail(i+1, idInstStateComp);
								idInstStateExecEnd := idInstStateExecEnd + 1;
								SetIdInstStateComp(InstStatesExec(i).detail.num_linea_branch_taken_ID, idInstStateComp);
								exit;
							--else
								--InstStatesExec(i).state <= D;
							end if;
						else
							WAIT UNTIL rising_edge(DoneID);
							if (StallRAW = '1') then
								InstStatesExec(i).state <= D_RAW;
								--InstStatesExec(i+1).state <= F_RAW;	
								--if (i = idInstStateExecEnd) then
									--idInstStateExecEnd := idInstStateExecEnd + 1;
								--end if;
								exit;
							elsif (StallHLT = '1') then
								if ((StallWAWAux = '0') or (InstStatesExec(i-1).state = X) or (InstStatesExec(i-1).state = X_FP1)) then
									InstStatesExec(i).state <= D_HLT;
								else 
									InstStatesExec(i).state <= D;
									idInstStateExecEnd := idInstStateExecEnd + 1;
								end if;
								wasHLT := true;
								exit;
							else
								InstStatesExec(i).state <= D;
							end if;
						end if;
					end if;
				WHEN D_HLT =>
					WAIT UNTIL falling_edge(EnableSM);
					WAIT FOR 2 ns;
					if (i = idInstStateExecEnd - 1) then
						idInstStateExecEnd := idInstStateExecEnd + 1;
					end if;
					if (StallHLT = '0') then
						if ((StallSTR = '1') or (InstStatesExec(i-1).state = M_STR)) then
							InstStatesExec(i).state <= D_STR;
							idInstStateExecEnd := idInstStateExecEnd - 1;
							exit;
						else
							InstStatesExec(i).state <= D;
						end if;
					elsif (StallWAWAux = '1') then
						InstStatesExec(i).state <= D_WAW;
						idInstStateExecEnd := idInstStateExecEnd - 1;
						exit;
					else
						--if (i = idInstStateExecEnd - 1) then
							--idInstStateExecEnd := idInstStateExecEnd + 1;
						--end if;
						exit;
					end if;
				WHEN D_STR =>
					if (StallSTR = '0') then
						if (StallRAW = '1') then
							InstStatesExec(i).state <= D_RAW;
							exit;
						elsif (StallWAWAux = '1') then
							InstStatesExec(i).state <= D_WAW;
							exit;
						else
							InstStatesExec(i).state <= D;
							if (i = idInstStateExecEnd) then
								idInstStateExecEnd := idInstStateExecEnd + 1;
							end if;
						end if;
					elsif (StallWAWAux = '1') then
						InstStatesExec(i).state <= D_WAW;
						exit;
					else
						exit;
					end if;
					--exit;
				WHEN D_RAW =>  
					--InstStatesExec(i+2).state <= E;
					--for j in 2 to InstStatesExec'length-2 loop
						--if (InstStatesExec(i+j).state = B) then
							--InstStatesExec(i+j).state <= E;
							--exit;
						--end if;
					--end loop;
					--if (StallRAW = '1') then
						--InstStatesExec(i+2).state <= E;
					--else
						--InstStatesExec(i+2).state <= E; 
					if (StallRAW = '0') then 
						if (StallSTR = '1') then
							InstStatesExec(i).state <= D_STR;
							exit;
						elsif (StallWAWAux = '1') then
							InstStatesExec(i).state <= D_WAW; 
							exit;
						else
							InstStatesExec(i).state <= D;
							if (i = idInstStateExecEnd) then
								idInstStateExecEnd := idInstStateExecEnd + 1;
							end if;
						end if;
					end if;
					--exit;
				WHEN D_WAW =>
					if (StallWAWAux = '0') then
						if (StallSTR = '1') then
							InstStatesExec(i).state <= D_STR;
							exit;
						elsif (StallRAW = '1') then
							InstStatesExec(i).state <= D_RAW;
							exit;
						elsif (StallHLT = '1') then
							InstStatesExec(i).state <= D_HLT;
							exit;
						else
							InstStatesExec(i).state <= D;
							if (i = idInstStateExecEnd) then
								idInstStateExecEnd := idInstStateExecEnd + 1;
							end if;
						end if;	
					else
						exit;
					end if;
				WHEN D_BRX =>
					if (BranchEXALUtoSM.branch_taken = '1') then
						InstStatesExec(i).state <= D_END;
					elsif (StallSTR = '1') then
						InstStatesExec(i).state <= D_STR;
					elsif (StallWAWAux = '1') then
						InstStatesExec(i).state <= D_WAW;
					else
						InstStatesExec(i).state <= D;
					end if;
				WHEN D_END =>
					InstStatesExec(i).state <= X_END;
				WHEN D =>
					if (StallSTR = '1') then
						if ((Fp = '0') or (Fp = 'Z')) then
							InstStatesExec(i).state <= X_STR;
						else
							InstStatesExec(i).state <= X_FP1_STR;
						end if;
					elsif ((StallWAWAux = '1') and (not firstWAW)) then
						if ((Fp = '0') or (Fp = 'Z')) then
							InstStatesExec(i).state <= X_WAW;
						else
							InstStatesExec(i).state <= X_FP1_WAW;
						end if;
					else
						if ((Fp = '0') or (Fp = 'Z')) then
							InstStatesExec(i).state <= X;
							if (InstStatesExec(i).detail.num_linea_branch_taken_EX /= -1) then
								InstStatesExec(i+1).state <= D_BRX;
								--InstStatesExec(i+2).state <= F_BRX; 
								--InstStatesExec(i+2).state <= E;
								WAIT UNTIL rising_edge(BranchEXALUtoSM.enable); 
								if (BranchEXALUtoSM.branch_taken = '1') then
									--InstStatesExec(i+1).state <= D_END;
									SetIdInstStateComp(InstStatesExec(i).detail.num_linea_branch_taken_EX, idInstStateComp); 
								end if;
								--InstStatesExec(i+2).state <= F_BRX;
								exit;
							end if;
						else
							InstStatesExec(i).state <= X_FP1;
						end if;
					end if;
				WHEN X_STR => 
					if (StallSTR = '0') then
						if (StallWAWAux = '1') then
							InstStatesExec(i).state <= X_WAW; 
						else
							InstStatesExec(i).state <= X;
							if (InstStatesExec(i+1).state = B) then
								InstStatesExec(i+1).state <= F;
							end if;
							if (InstStatesExec(i).detail.num_linea_branch_taken_EX /= -1) then
								InstStatesExec(i+1).state <= D_BRX;
								--InstStatesExec(i+2).state <= F_BRX; 
								--InstStatesExec(i+2).state <= E;
								WAIT UNTIL rising_edge(BranchEXALUtoSM.enable); 
								if (BranchEXALUtoSM.branch_taken = '1') then
									--InstStatesExec(i+1).state <= D_END;
									SetIdInstStateComp(InstStatesExec(i).detail.num_linea_branch_taken_EX, idInstStateComp); 
								end if;
								--InstStatesExec(i+2).state <= F_BRX; 
								exit;
							end if;
						end if;
					elsif (StallWAWAux = '1') then
						InstStatesExec(i).state <= X_WAW;
					end if;
				WHEN X_WAW =>
					if (StallWAWAux = '0') then
						if (StallSTR = '1') then
							InstStatesExec(i).state <= X_STR;
						else
							InstStatesExec(i).state <= X;
							if (InstStatesExec(i).detail.num_linea_branch_taken_EX /= -1) then
								InstStatesExec(i+1).state <= D_BRX;
								--InstStatesExec(i+2).state <= F_BRX; 
								--InstStatesExec(i+2).state <= E;
								WAIT UNTIL rising_edge(BranchEXALUtoSM.enable); 
								if (BranchEXALUtoSM.branch_taken = '1') then
									--InstStatesExec(i+1).state <= D_END;
									SetIdInstStateComp(InstStatesExec(i).detail.num_linea_branch_taken_EX, idInstStateComp); 
								end if;
								--InstStatesExec(i+2).state <= F_BRX;
								exit;
							end if;
						end if;
					end if;
				WHEN X_FP1_STR =>
					if (StallSTR = '0') then
						if (StallWAWAux = '1') then
							InstStatesExec(i).state <= X_FP1_WAW;
						else
							InstStatesExec(i).state <= X_FP1;
						end if;
					elsif (StallWAWAux = '1') then
						InstStatesExec(i).state <= X_FP1_WAW;
					end if;
				WHEN X_FP1_WAW =>
					if (StallWAWAux = '0') then
						if (StallSTR = '1') then
							InstStatesExec(i).state <= X_FP1_STR;
						else
							InstStatesExec(i).state <= X_FP1;
						end if;
					end if;
				WHEN X_FP1 =>
					if (StallSTR = '1') then
						InstStatesExec(i).state <= X_FP2_STR;
					elsif ((StallWAWAux = '1') and (not firstWAW)) then
						InstStatesExec(i).state <= X_FP2_WAW;
					else
						InstStatesExec(i).state <= X_FP2;
					end if;
				WHEN X_FP2_STR =>
					if (StallSTR = '0') then
						if (StallWAWAux = '1') then
							InstStatesExec(i).state <= X_FP2_WAW;
						else
							InstStatesExec(i).state <= X_FP2;
						end if;
					elsif (StallWAWAux = '1') then
						InstStatesExec(i).state <= X_FP2_WAW;
					end if;
				WHEN X_FP2_WAW =>
					if (StallWAWAux = '0') then
						if (StallSTR = '1') then
							InstStatesExec(i).state <= X_FP2_STR;
						else
							InstStatesExec(i).state <= X_FP2;
						end if;
					end if;
				WHEN X_FP2 =>
					if (StallSTR = '1') then
						InstStatesExec(i).state <= X_FP3_STR;
					elsif (StallWAWAux = '1') then
						InstStatesExec(i).state <= X_FP3_WAW;
					else
						InstStatesExec(i).state <= X_FP3;
					end if;
				WHEN X_FP3_STR =>
					if (StallSTR = '0') then
						if (StallWAWAux = '1') then
							InstStatesExec(i).state <= X_FP3_WAW;
						else
							InstStatesExec(i).state <= X_FP3;
						end if;
					elsif (StallWAWAux = '1') then
						InstStatesExec(i).state <= X_FP3_WAW;
					end if;
				WHEN X_FP3_WAW =>
					if (StallWAWAux = '0') then
						if (StallSTR = '1') then
							InstStatesExec(i).state <= X_FP3_STR;
						else
							InstStatesExec(i).state <= X_FP3;
						end if;
					end if;
				WHEN X_FP3 =>
					--if (StallSTR = '1') then
						--InstStatesExec(i).state <= X_FP4_STR;
					--elsif (StallWAWAux = '1') then
					if (StallWAWAux = '1') then
						InstStatesExec(i).state <= X_FP4_WAW;
					else
						InstStatesExec(i).state <= X_FP4;
					end if;
				WHEN X_FP4_STR =>
					if (StallSTR = '0') then
						if (StallWAWAux = '1') then
							InstStatesExec(i).state <= X_FP4_WAW;
						else
							InstStatesExec(i).state <= X_FP4;
						end if;
					elsif (StallWAWAux = '1') then
						InstStatesExec(i).state <= X_FP4_WAW;
					end if;
				WHEN X_FP4_WAW =>
					if (StallWAWAux = '0') then
						if (StallSTR = '1') then
							InstStatesExec(i).state <= X_FP4_STR;
						else
							InstStatesExec(i).state <= X_FP4;
						end if;
					end if;
				WHEN X_FP4 =>
					--if (StallSTR = '1') then
						--InstStatesExec(i).state <= M_STR;
					--elsif (StallWAWAux = '1') then
					--if (StallWAWAux = '1') then
						--InstStatesExec(i).state <= M_WAW;
					--else
						InstStatesExec(i).state <= M;
						if (i > 2) then
							if (InstStatesExec(i-2).state = W) then 
								InstStatesExec(i-2).state <= E;
							end if;
						end if;
					--end if;
				WHEN X_END =>
					InstStatesExec(i).state <= M_END; 
					if (StallSTR = '1') then
						exit;
					end if;
				WHEN X =>
					if (StallSTR = '1') then
						InstStatesExec(i).state <= M_STR;
					elsif ((StallWAWAux = '1') and (not firstWAW)) then
						InstStatesExec(i).state <= M_WAW;
					else
						InstStatesExec(i).state <= M;
						if (i > 2) then
							if (InstStatesExec(i-2).state = W) then 
								InstStatesExec(i-2).state <= E;
							end if;
						end if;
					end if;
				WHEN M_STR =>
					if (StallSTR = '0') then  
						if (StallWAWAux = '1') then
							InstStatesExec(i).state <= M_WAW;
						else
							InstStatesExec(i).state <= M;
							if (i > 1) then
								if (InstStatesExec(i-1).state = W) then 
									InstStatesExec(i-1).state <= E;
								end if;
							end if;
						end if;
					elsif (StallWAWAux = '1') then
						InstStatesExec(i).state <= M_WAW;
					end if;
				WHEN M_WAW =>
					if (StallWAWAux = '0') then  
						if (StallSTR = '1') then
							InstStatesExec(i).state <= M_STR;
						else
							InstStatesExec(i).state <= M;
							if (i > 1) then
								if (InstStatesExec(i-1).state = W) then 
									InstStatesExec(i-1).state <= E;
								end if;
							end if;
						end if;
					end if;
				WHEN M_END =>
					InstStatesExec(i).state <= W_END;
					if (i > 1) then
						if (InstStatesExec(i-1).state = W) then 
							InstStatesExec(i-1).state <= E;
						end if;	
					end if;		  
				WHEN M =>
					--if (StallSTR = '1') then
					if (i > 1) then
						if ((InstStatesExec(i-1).state = X_FP3) OR (InstStatesExec(i-1).state = X_FP4)) then 
							WAIT FOR 1 ns;
							if (StallWAWAux = '1') then
								firstWAW := true;
								InstStatesExec(i).state <= W_WAW;
							else	
								InstStatesExec(i).state <= W;
								if (InstStatesExec(i-1).state = W) then 
									InstStatesExec(i-1).state <= E;
								end if;
							end if;
						elsif (InstStatesExec(i-1).state = W_WAW) then
							InstStatesExec(i).state <= W_WAW;
						else
							InstStatesExec(i).state <= W;
							if (InstStatesExec(i-1).state = W) then 
								InstStatesExec(i-1).state <= E;
							end if;
						end if;
					else
						InstStatesExec(i).state <= W;
					end if;
				WHEN W_STR =>
					if (StallSTR = '0') then  
						if (StallWAWAux = '1') then
							InstStatesExec(i).state <= W_WAW;
						else
							InstStatesExec(i).state <= W;
						end if;
					elsif (StallWAWAux = '1') then
						InstStatesExec(i).state <= W_WAW;
					end if;
				WHEN W_WAW =>
					--if (StallSTR = '1') then
					if (StallWAWAux = '0') then
						if (StallSTR = '1') then
							if (InstStatesExec(i-1).state = W) then
								InstStatesExec(i).state <= W;
							else
								InstStatesExec(i).state <= W_STR;
							end if;
						else
							InstStatesExec(i).state <= W;
						end if;
					else
						firstWAW := false;
					end if;
				WHEN W_END =>  
					--report "StateMachine" severity WARNING;
					InstStatesExec(i).state <= E;
				WHEN W =>
					InstStatesExec(i).state <= E;
				WHEN E =>
					NULL;
				WHEN OTHERS =>
					report "Error: el estado de la instrucción " & integer'image(i) & " es inválido"
					severity FAILURE;
			END CASE;
		end loop;
	END SetStates;
	
	VARIABLE First:					BOOLEAN := TRUE;			
	VARIABLE idInstStateExec:		INTEGER := 0;
	VARIABLE idInstStateExecEnd:	INTEGER := 0;
	VARIABLE idInstStateComp:		INTEGER := 0;
	VARIABLE firstSTR:				BOOLEAN := false;
	VARIABLE firstWAW:				BOOLEAN := false;
	VARIABLE wasHLT:				BOOLEAN := false;
	VARIABLE Last:					BOOLEAN := FALSE;
	
	BEGIN		 					
		IF (First) THEN
			for i in InstStatesExec'range loop
				InstStatesExec(i).id <= i;
				InstStatesExec(i).state <= B;
				InstStatesExec(i).detail.num_linea <= -1;
			end loop;
			--cantInstrucciones := 1;
			if (not Pipelining) then
				idInstStateExec := 1;
			else
				--idInstStateExecBegin := 1;
				idInstStateExecEnd := 1;
			end if;
			idInstStateComp := 1;
			First := FALSE;
		END IF;
		WAIT UNTIL rising_edge(EnableSM);
		IF (not Pipelining) THEN
			SetState(idInstStateExec, idInstStateComp);
		ELSE 
			if ((StopSM = '1') and (not Last)) then	 
				idInstStateExecEnd := idInstStateExecEnd - 2;
				Last := TRUE;
			end if;
			SetStates(idInstStateExecEnd, idInstStateComp, firstSTR, firstWAW, wasHLT);
			--if (StopSM = '0') then
				--idInstStateExecEnd := idInstStateExecEnd + 1;
			--end if;
			--if (idInstStateExecEnd > 5) then
				--idInstStateExecBegin := idInstStateExecBegin + 1;
			--end if;
		END IF;
	END PROCESS Main; 
	
	
end STATES_MACHINE_ARCHITECTURE;





