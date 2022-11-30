
-- Entidad "ui":
-- Descripción: Éste es el diseño estructural de la interfaz de usuario (UI) de la CPU, 
-- encargada de ofrecer al usuario información sobre el estado actual del procesador
-- de una manera inteligible y atractiva para él, siempre teniendo en cuenta las 
-- limitaciones del lenguaje VHDL con respecto a su interfaz gráfica. Al igual que los
-- diseños estructurales puros anteriores, no posee ningún proceso, ya que su 
-- funcionalidad se limita únicamente a interconectar los componentes internos de la 
-- interfaz definida para este proyecto (máquina de estados y registros de punto flotante), 
-- cada uno de ellos con sus respectivos puertos de entrada. Cabe mencionar que tanto ésta
-- como sus componentes son las únicas entidades que poseen pura y exclusivamente puertos
-- de entrada: todos los datos necesarios para mantener actualizada la interfaz provienen 
-- de señales de la CPU, mientras que la información para inicializar la máquina de 
-- estados se origina en el ensamblador.


library TDA_1819;
use TDA_1819.tipos_cpu.all;

library ieee;
use ieee.NUMERIC_STD.all;
use ieee.std_logic_1164.all;
library std;
use std.TEXTIO.all;

	-- Add your library and packages declaration here ...

entity ui is
	
	generic (
		Pipelining: BOOLEAN); 
		
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
		EnableSM			: in std_logic;
		DataRegFP			: in std_logic_vector(31 downto 0);
		IdRegFP				: in std_logic_vector(7 downto 0);
		EnableRegFP			: in std_logic);	
			
end ui;

architecture UI_ARCHITECTURE of ui is
	
	-- Component declaration of the tested unit
	component states_machine
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
	end component;
	
	component registros_fp
		port (
			DataRegFP			: in std_logic_vector(31 downto 0);
			IdRegFP				: in std_logic_vector(7 downto 0);
			EnableRegFP			: in std_logic);	
	end component;

		
	FOR UUT1: states_machine USE ENTITY WORK.states_machine(states_machine_architecture);
	FOR UUT2: registros_fp USE ENTITY WORK.registros_fp(registros_fp_architecture);	
		
	
	-- Add your code here ...	
	

begin
	
	
	-- Unit Under Test port map
	
	UUT1: states_machine
		generic map (
			Pipelining			=> Pipelining)
		port map (
			CompToSM			=> CompToSM,
			BranchIDtoSM		=> BranchIDtoSM,
			BranchEXALUtoSM		=> BranchEXALUtoSM,
			Fp					=> Fp,
			LoadInstState		=> LoadInstState,
			LoadBranchInstState	=> LoadBranchInstState,
			DoneID				=> DoneID,
			StallHLT			=> StallHLT,
			StallSTR			=> StallSTR,
			StallRAW			=> StallRAW,
			StallWAWAux			=> StallWAWAux,
			StopSM				=> StopSM,
			EnableSM			=> EnableSM);
			
	UUT2: registros_fp
		port map (
			DataRegFP			=> DataRegFP,
			IdRegFP				=> IdRegFP,
			EnableRegFP			=> EnableRegFP);
	
	-- Add your stimulus here ...


end UI_ARCHITECTURE;



