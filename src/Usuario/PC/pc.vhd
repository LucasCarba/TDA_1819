
-- Entidad "pc":
-- Descripción: Éste es el diseño estructural de la PC, por lo cual no posee ningún
-- proceso, ya que su funcionalidad se limita únicamente a interconectar los componentes
-- internos de la computadora definida para este proyecto (ensamblador, CPU, administrador
-- de buses	y memoria principal), cada uno de ellos con sus respectivos puertos de entrada,
-- salida y entrada/salida. También se comunica con el banco de pruebas del usuario	para
-- mantener informado a este último sobre el estado actual de la simulación.
 

library TDA_1819;
use TDA_1819.tipos_ensamblador.all;
use TDA_1819.tipos_cpu.all;

library ieee;
use ieee.NUMERIC_STD.all;
use ieee.std_logic_1164.all;
library std;
use std.TEXTIO.all;

	-- Add your library and packages declaration here ...

entity pc is
	-- Generic declarations of the tested unit
	generic (
		ProgName		: STRING;
		Pipelining		: BOOLEAN;
		Cores 			: INTEGER); 
		
	port (
		DoneCompUser	: out STD_LOGIC;
		DoneCpuUser		: out STD_LOGIC;
		ReadyUser		: in  STD_LOGIC);	
			
end pc;

architecture PC_ARCHITECTURE of pc is
	
	-- Component declaration of the tested unit
	component ensamblador
		generic (
			ProgName				: STRING);
		port (
			CompToSM				: out state_comp;
			LoadInstState			: out std_logic;
			LoadBranchInstState		: out std_logic;
			EnableCompToDataMem		: out std_logic;
			DataAddrBusComp			: out std_logic_vector(15 downto 0);
			DataDataBusOutComp		: out std_logic_vector(31 downto 0);
			DataSizeBusComp			: out std_logic_vector(3 downto 0);
			DataCtrlBusComp			: out std_logic_vector(1 downto 0);
			EnableCompToInstMem		: out std_logic;
			InstAddrBusComp			: out std_logic_vector(15 downto 0);
			InstDataBusOutComp		: out std_logic_vector(31 downto 0);
			InstSizeBusComp			: out std_logic_vector(3 downto 0);
			InstCtrlBusComp			: out std_logic_vector(1 downto 0);
			DoneCompUser			: out std_logic;
			DoneCompCPU				: out std_logic;
			ReadyUser				: in  std_logic);
	end component;
	
	component cpu
		generic (
			Pipelining				: BOOLEAN);
		port (
			DoneCpuUser				: out std_logic;
			DataAddrBusCpu			: out std_logic_vector(15 downto 0);
			DataDataBusOutCpu		: out std_logic_vector(31 downto 0);
			DataSizeBusCpu			: out std_logic_vector(3 downto 0);
			DataCtrlBusCpu			: out std_logic_vector(1 downto 0);
			InstAddrBusCpu			: out std_logic_vector(15 downto 0);
			InstDataBusOutCpu		: out std_logic_vector(31 downto 0);
			InstSizeBusCpu			: out std_logic_vector(3 downto 0);
			InstCtrlBusCpu			: out std_logic_vector(1 downto 0); 
			EnableCpuToDataMem		: out std_logic;
			EnableCpuToInstMem		: out std_logic;
			CompToSM				: in  state_comp;
			LoadInstState			: in  std_logic;
			LoadBranchInstState		: in  std_logic;
			DoneCompCPU				: in  std_logic;
			DataDataBusInCpu		: in  std_logic_vector(31 downto 0);
			InstDataBusInCpu		: in  std_logic_vector(31 downto 0);
			EnableInDataCpu			: in  std_logic;
			EnableInInstCpu			: in  std_logic);
	end component;		
	
	component buses_admin
		port (
			DataDataBusInCpu		: out std_logic_vector(31 downto 0);
			InstDataBusInCpu		: out std_logic_vector(31 downto 0);
			EnableInDataCpu			: out std_logic;
			EnableInInstCpu			: out std_logic;
			DataAddrBusMem			: out std_logic_vector(15 downto 0);
			DataDataBusInMem		: out std_logic_vector(31 downto 0);
			DataSizeBusMem			: out std_logic_vector(3 downto 0);
			DataCtrlBusMem			: out std_logic_vector(1 downto 0);
			InstAddrBusMem			: out std_logic_vector(15 downto 0);
			InstDataBusInMem		: out std_logic_vector(31 downto 0);
			InstSizeBusMem			: out std_logic_vector(3 downto 0);
			InstCtrlBusMem			: out std_logic_vector(1 downto 0);
			EnableInDataMem			: out std_logic;
			EnableInInstMem			: out std_logic;
			DataAddrBusComp			: in  std_logic_vector(15 downto 0);
			DataDataBusOutComp		: in  std_logic_vector(31 downto 0);
			DataSizeBusComp			: in  std_logic_vector(3 downto 0);
			DataCtrlBusComp			: in  std_logic_vector(1 downto 0);
			InstAddrBusComp			: in  std_logic_vector(15 downto 0);
			InstDataBusOutComp		: in  std_logic_vector(31 downto 0);
			InstSizeBusComp			: in  std_logic_vector(3 downto 0);
			InstCtrlBusComp			: in  std_logic_vector(1 downto 0);
			DataDataBusOutMem		: in  std_logic_vector(31 downto 0);
			InstDataBusOutMem		: in  std_logic_vector(31 downto 0);
			DataAddrBusCpu			: in  std_logic_vector(15 downto 0);
			DataDataBusOutCpu		: in  std_logic_vector(31 downto 0);
			DataSizeBusCpu			: in  std_logic_vector(3 downto 0);
			DataCtrlBusCpu			: in  std_logic_vector(1 downto 0);
			InstAddrBusCpu			: in  std_logic_vector(15 downto 0);
			InstDataBusOutCpu		: in  std_logic_vector(31 downto 0);
			InstSizeBusCpu			: in  std_logic_vector(3 downto 0);
			InstCtrlBusCpu			: in  std_logic_vector(1 downto 0); 
			EnableCompToDataMem		: in  std_logic;
			EnableCompToInstMem		: in  std_logic;
			EnableCpuToDataMem		: in  std_logic;
			EnableCpuToInstMem		: in  std_logic;
			EnableDataMemToCpu		: in  std_logic;
			EnableInstMemToCpu		: in  std_logic);
	end component;
	
	component memoria
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
	end component;
	
	FOR UUT1: ensamblador USE ENTITY WORK.ensamblador(ensamblador_architecture);
	FOR UUT2: cpu USE ENTITY WORK.cpu(cpu_architecture);
	FOR UUT3: buses_admin USE ENTITY WORK.buses_admin(buses_admin_architecture);
	FOR UUT4: memoria USE ENTITY WORK.memoria(memoria_architecture);
	
	
	-- Add your code here ...
	SIGNAL CompToSM: 				state_comp;
	SIGNAL LoadInstState: 			std_logic;
	SIGNAL LoadBranchInstState: 	std_logic;
	SIGNAL DoneCompCPU:				std_logic;
	SIGNAL DataDataBusInCpu:		std_logic_vector(31 downto 0);
	SIGNAL InstDataBusInCpu: 		std_logic_vector(31 downto 0);
	SIGNAL EnableInDataCpu: 		std_logic;
	SIGNAL EnableInInstCpu: 		std_logic;
	SIGNAL DataAddrBusMem: 			std_logic_vector(15 downto 0);
	SIGNAL DataDataBusInMem: 		std_logic_vector(31 downto 0);
	SIGNAL DataSizeBusMem: 			std_logic_vector(3 downto 0);
	SIGNAL DataCtrlBusMem: 			std_logic_vector(1 downto 0);
	SIGNAL InstAddrBusMem: 			std_logic_vector(15 downto 0);
	SIGNAL InstDataBusInMem: 		std_logic_vector(31 downto 0);
	SIGNAL InstSizeBusMem: 			std_logic_vector(3 downto 0);
	SIGNAL InstCtrlBusMem: 			std_logic_vector(1 downto 0);
	SIGNAL EnableInDataMem: 		std_logic;
	SIGNAL EnableInInstMem: 		std_logic;
	SIGNAL DataAddrBusComp: 		std_logic_vector(15 downto 0);
	SIGNAL DataDataBusOutComp: 		std_logic_vector(31 downto 0);
	SIGNAL DataSizeBusComp:			std_logic_vector(3 downto 0);
	SIGNAL DataCtrlBusComp: 		std_logic_vector(1 downto 0);
	SIGNAL InstAddrBusComp: 		std_logic_vector(15 downto 0);
	SIGNAL InstDataBusOutComp: 		std_logic_vector(31 downto 0);
	SIGNAL InstSizeBusComp: 		std_logic_vector(3 downto 0);
	SIGNAL InstCtrlBusComp: 		std_logic_vector(1 downto 0);
	SIGNAL DataDataBusOutMem: 		std_logic_vector(31 downto 0);
	SIGNAL InstDataBusOutMem: 		std_logic_vector(31 downto 0);
	SIGNAL DataAddrBusCpu: 			std_logic_vector(15 downto 0);
	SIGNAL DataDataBusOutCpu: 		std_logic_vector(31 downto 0);
	SIGNAL DataSizeBusCpu:			std_logic_vector(3 downto 0);
	SIGNAL DataCtrlBusCpu: 			std_logic_vector(1 downto 0);
	SIGNAL InstAddrBusCpu: 			std_logic_vector(15 downto 0);
	SIGNAL InstDataBusOutCpu: 		std_logic_vector(31 downto 0);
	SIGNAL InstSizeBusCpu: 			std_logic_vector(3 downto 0);
	SIGNAL InstCtrlBusCpu: 			std_logic_vector(1 downto 0); 
	SIGNAL EnableCompToDataMem: 	std_logic;
	SIGNAL EnableCompToInstMem: 	std_logic;
	SIGNAL EnableCpuToDataMem: 		std_logic;
	SIGNAL EnableCpuToInstMem: 		std_logic;
	SIGNAL EnableDataMemToCpu: 		std_logic;
	SIGNAL EnableInstMemToCpu: 		std_logic;
	

begin
	
	
	-- Unit Under Test port map
	UUT1: ensamblador
		generic map (
			ProgName				=> ProgName)
		port map (
			CompToSM				=> CompToSM,
			LoadInstState			=> LoadInstState,
			LoadBranchInstState		=> LoadBranchInstState,
			EnableCompToDataMem		=> EnableCompToDataMem,
			DataAddrBusComp			=> DataAddrBusComp,
			DataDataBusOutComp		=> DataDataBusOutComp,
			DataSizeBusComp			=> DataSizeBusComp,
			DataCtrlBusComp			=> DataCtrlBusComp,
			EnableCompToInstMem		=> EnableCompToInstMem,
			InstAddrBusComp			=> InstAddrBusComp,
			InstDataBusOutComp		=> InstDataBusOutComp,
			InstSizeBusComp			=> InstSizeBusComp,
			InstCtrlBusComp			=> InstCtrlBusComp,
			DoneCompUser			=> DoneCompUser,
			DoneCompCPU				=> DoneCompCPU,
			ReadyUser				=> ReadyUser);
			
	UUT2: cpu 
		generic map (
			Pipelining				=> Pipelining)
		port map (
			DoneCpuUser				=> DoneCpuUser,
			DataAddrBusCpu			=> DataAddrBusCpu,
			DataDataBusOutCpu		=> DataDataBusOutCpu,
			DataSizeBusCpu			=> DataSizeBusCpu,
			DataCtrlBusCpu			=> DataCtrlBusCpu,
			InstAddrBusCpu			=> InstAddrBusCpu,
			InstDataBusOutCpu		=> InstDataBusOutCpu,
			InstSizeBusCpu			=> InstSizeBusCpu,
			InstCtrlBusCpu			=> InstCtrlBusCpu, 
			EnableCpuToDataMem		=> EnableCpuToDataMem,
			EnableCpuToInstMem		=> EnableCpuToInstMem,
			CompToSM				=> CompToSM,
			LoadInstState			=> LoadInstState,
			LoadBranchInstState		=> LoadBranchInstState,
			DoneCompCPU				=> DoneCompCPU,
			DataDataBusInCpu		=> DataDataBusInCpu,
			InstDataBusInCpu		=> InstDataBusInCpu,
			EnableInDataCpu			=> EnableInDataCpu,
			EnableInInstCpu			=> EnableInInstCpu);
			
	UUT3: buses_admin
		port map (
			DataDataBusInCpu		=> DataDataBusInCpu,
			InstDataBusInCpu		=> InstDataBusInCpu,
			EnableInDataCpu			=> EnableInDataCpu,
			EnableInInstCpu			=> EnableInInstCpu,
			DataAddrBusMem			=> DataAddrBusMem,
			DataDataBusInMem		=> DataDataBusInMem,
			DataSizeBusMem			=> DataSizeBusMem,
			DataCtrlBusMem			=> DataCtrlBusMem,
			InstAddrBusMem			=> InstAddrBusMem,
			InstDataBusInMem		=> InstDataBusInMem,
			InstSizeBusMem			=> InstSizeBusMem,
			InstCtrlBusMem			=> InstCtrlBusMem,
			EnableInDataMem			=> EnableInDataMem,
			EnableInInstMem			=> EnableInInstMem,
			DataAddrBusComp			=> DataAddrBusComp,
			DataDataBusOutComp		=> DataDataBusOutComp,
			DataSizeBusComp			=> DataSizeBusComp,
			DataCtrlBusComp			=> DataCtrlBusComp,
			InstAddrBusComp			=> InstAddrBusComp,
			InstDataBusOutComp		=> InstDataBusOutComp,
			InstSizeBusComp			=> InstSizeBusComp,
			InstCtrlBusComp			=> InstCtrlBusComp,
			DataDataBusOutMem		=> DataDataBusOutMem,
			InstDataBusOutMem		=> InstDataBusOutMem,
			DataAddrBusCpu			=> DataAddrBusCpu,
			DataDataBusOutCpu		=> DataDataBusOutCpu,
			DataSizeBusCpu			=> DataSizeBusCpu,
			DataCtrlBusCpu			=> DataCtrlBusCpu,
			InstAddrBusCpu			=> InstAddrBusCpu,
			InstDataBusOutCpu		=> InstDataBusOutCpu,
			InstSizeBusCpu			=> InstSizeBusCpu,
			InstCtrlBusCpu			=> InstCtrlBusCpu,
			EnableCompToDataMem		=> EnableCompToDataMem,
			EnableCompToInstMem		=> EnableCompToInstMem,
			EnableCpuToDataMem		=> EnableCpuToDataMem,
			EnableCpuToInstMem		=> EnableCpuToInstMem,
			EnableDataMemToCpu		=> EnableDataMemToCpu,
			EnableInstMemToCpu		=> EnableInstMemToCpu);
			
	UUT4: memoria 	
		port map (
			DataDataBusOutMem	=> DataDataBusOutMem,
			InstDataBusOutMem	=> InstDataBusOutMem,
			EnableDataMemToCpu	=> EnableDataMemToCpu,
			EnableInstMemToCpu	=> EnableInstMemToCpu,
			DataAddrBusMem		=> DataAddrBusMem,
			DataDataBusInMem	=> DataDataBusInMem,
			DataSizeBusMem		=> DataSizeBusMem,
			DataCtrlBusMem		=> DataCtrlBusMem,
			InstAddrBusMem		=> InstAddrBusMem,
			InstDataBusInMem	=> InstDataBusInMem,
			InstSizeBusMem		=> InstSizeBusMem,
			InstCtrlBusMem		=> InstCtrlBusMem,	
			EnableInDataMem		=> EnableInDataMem,
			EnableInInstMem		=> EnableInInstMem);
		
	
	-- Add your stimulus here ...


end PC_ARCHITECTURE;



