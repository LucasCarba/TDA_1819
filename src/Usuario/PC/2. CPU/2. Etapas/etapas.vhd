
-- Entidad "etapas":
-- Descripción: Éste es el diseño estructural para las etapas de la segmentación de la CPU, 
-- por lo cual no posee ningún proceso, ya que su funcionalidad se limita únicamente a 
-- interconectar los componentes internos del procesador definido para este proyecto, los
-- cuales en este caso corresponderían a cada una de las cinco etapas del pipeline: búsqueda
-- (fetch), decodificación (decode), ejecución (execute), acceso a memoria (memory access) y
-- almacenamiento en registro (writeback), cada uno de ellos con sus respectivos puertos de 
-- entrada, salida y entrada/salida. Cada etapa recibe del administrador de la CPU una señal
-- de habilitación para su respectiva ejecución y cabe destacarse que tanto la etapa "fetch"
-- como la "memory access" acceden frecuentemente a la memoria de instrucciones y datos 
-- respectivamente mientras se ejecutan, mientras que un fenómeno similar ocurre en la etapa
-- "writeback" con respecto al banco de registros del procesador.


library TDA_1819;
use TDA_1819.tipos_cpu.all;

library ieee;
use ieee.NUMERIC_STD.all;
use ieee.std_logic_1164.all;
library std;
use std.TEXTIO.all;

	-- Add your library and packages declaration here ...

entity etapas is	  
	
	generic (
		Pipelining	: BOOLEAN);
		
	port (
		StallHLT				: out	std_logic;
		StopInit				: out   std_logic;
		DoneID					: out   std_logic; 
		IdInstIncWrPend			: out	std_logic_vector(7 downto 0);
		IdRegIncWrPend			: out   std_logic_vector(7 downto 0);
		IdRegDecWrPend			: out   std_logic_vector(7 downto 0);
		BranchIDtoSM			: out   state_branch;
		IDtoMA					: out   memaccess_record;	 
		DataRegInID				: out   std_logic_vector(31 downto 0);
		IdRegID					: out   std_logic_vector(7 downto 0);
		SizeRegID				: out   std_logic_vector(3 downto 0);
		DataRegInWB				: out   std_logic_vector(31 downto 0);
		IdRegWB					: out   std_logic_vector(7 downto 0);
		SizeRegWB				: out   std_logic_vector(3 downto 0);	
		DataRegInEXALU			: out 	std_logic_vector(31 downto 0);
		DataRegInEXFPU			: out 	std_logic_vector(31 downto 0);
		DataEXtoWB				: out   std_logic_vector(31 downto 0);
		DataMAtoWB				: out   std_logic_vector(31 downto 0);
		DataRegInIF				: out   std_logic_vector(31 downto 0);
		WbRegCheckWAW			: out 	writeback_record;
		EnableCheckWAW			: out 	std_logic;
		DoneSTRW				: out	std_logic;
		DataAddrBusCpu			: out   std_logic_vector(15 downto 0);
		DataDataBusOutCpu		: out   std_logic_vector(31 downto 0);
		DataSizeBusCpu			: out   std_logic_vector(3 downto 0);
		DataCtrlBusCpu			: out   std_logic_vector(1 downto 0);
		InstAddrBusCpu			: out   std_logic_vector(15 downto 0);
		InstDataBusOutCpu		: out   std_logic_vector(31 downto 0);
		InstSizeBusCpu			: out   std_logic_vector(3 downto 0);
		InstCtrlBusCpu			: out   std_logic_vector(1 downto 0);
		EnableRegIFIPRd			: out 	std_logic;
		EnableRegIFIRWr			: out 	std_logic;		
		EnableRegIFIPWr			: out 	std_logic;
		EnableRegID				: out   std_logic;
		EnableRegIDIP			: out   std_logic;
		EnableRegEXALURd		: out 	std_logic;
		EnableRegEXFPURd		: out 	std_logic;
		EnableRegEXALUWr		: out 	std_logic;
		EnableRegEXFPUWr		: out 	std_logic;
		EnableRegEXALUIP		: out 	std_logic;
		EnableDecFPWrPend		: out 	std_logic;
		EnableCheckSTRM			: out 	std_logic;
		EnableRegWB				: out   std_logic;
		EnableIncWrPend			: out   std_logic;
		EnableIncFPWrPend		: out   std_logic;
		EnableDecWrPend			: out   std_logic;
		EnableCpuToDataMem		: out   std_logic;
		EnableCpuToInstMem		: out   std_logic;
		IDtoEX					: inout execute_record;
		IDtoWB					: inout writeback_record;
		BranchEXALUtoSM			: inout state_branch;
		EnableEXALU				: inout std_logic;
		EnableEXFPU				: inout std_logic;
		RecInMA					: in    memaccess_record;
		RecInWB					: in    writeback_record;
		DataRegOutIF			: in    std_logic_vector(31 downto 0);
		DataRegOutID			: in    std_logic_vector(31 downto 0);
		DataRegOutEXALU			: in    std_logic_vector(31 downto 0);
		DataRegOutEXFPU			: in    std_logic_vector(31 downto 0);
		DataDataBusInCpu		: in    std_logic_vector(31 downto 0);
		InstDataBusInCpu		: in    std_logic_vector(31 downto 0);
		StallSTR				: in  	std_logic;
		StallRAW				: in    std_logic;
		StallWAWAux				: in 	std_logic;
		WbRegDoneWAW			: in 	writeback_record;
		DoneWAW					: in	std_logic;
		StallWAW				: in 	std_logic;
		EnableInDataCpu			: in    std_logic;
		EnableInInstCpu			: in    std_logic;
		EnableIF				: in    std_logic;
		EnableID				: in    std_logic;
		EnableEX				: in    std_logic;
		EnableMA				: in    std_logic;
		EnableWB				: in    std_logic);	
			
end etapas;


architecture ETAPAS_ARCHITECTURE of etapas is
	
	-- Component declaration of the tested unit
	component fetch
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
	end component;
	
	component decode
		generic (
			Pipelining			: BOOLEAN);
		port (
			StallHLT			: out	std_logic;
			StopInit			: out   std_logic;
			DoneID				: out   std_logic;
			IdInstIncWrPend		: out	std_logic_vector(7 downto 0);
			IdRegIncWrPend		: out   std_logic_vector(7 downto 0);
			BranchIDtoSM		: out   state_branch;
			IDtoMA				: out   memaccess_record;
			DataRegInID			: out   std_logic_vector(31 downto 0);
			IdRegID				: out   std_logic_vector(7 downto 0);
			SizeRegID			: out   std_logic_vector(3 downto 0);
			EnableRegID			: out   std_logic;
			EnableRegIDIP		: out   std_logic;
			EnableIncWrPend		: out   std_logic;
			EnableIncFPWrPend	: out   std_logic;
			IDtoEX				: inout execute_record;
			IDtoWB				: inout writeback_record;
			StallBrEX			: inout std_logic;
			StallSTR			: in	std_logic;
			StallRAW			: in    std_logic;
			StallWAWAux			: in	std_logic;
			BranchEXALUtoSM		: in    state_branch;
			EXFPUPending		: in	std_logic;
			IFtoID				: in    decode_record;
			DataRegOutID		: in    std_logic_vector(31 downto 0);
			EnableID			: in    std_logic);
	end component;
	
	component execute
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
	end component;
	
	component memory_access
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
	end component;
	
	component writeback
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
	end component;
	
	
	FOR UUT1: fetch USE ENTITY WORK.fetch(fetch_architecture);
	FOR UUT2: decode USE ENTITY WORK.decode(decode_architecture);
	FOR UUT3: execute USE ENTITY WORK.execute(execute_architecture);
	FOR UUT4: memory_access USE ENTITY WORK.memory_access(memory_access_architecture);
	FOR UUT5: writeback USE ENTITY WORK.writeback(writeback_architecture);	
		
	
	-- Add your code here ...	
	SIGNAL IFtoID:				decode_record;
	SIGNAL EXFPUPending: 		std_logic;
	SIGNAL StallBrEX:			std_logic;
	

begin
	
	
	-- Unit Under Test port map
		
	UUT1: fetch
		port map (
			IFtoID				=> IFtoID,
			InstAddrBusCpu		=> InstAddrBusCpu,
			InstDataBusOutCpu	=> InstDataBusOutCpu,
			InstSizeBusCpu		=> InstSizeBusCpu,
			InstCtrlBusCpu		=> InstCtrlBusCpu,
			EnableRegIFIPRd		=> EnableRegIFIPRd,
			EnableRegIFIRWr		=> EnableRegIFIRWr,
			EnableRegIFIPWr		=> EnableRegIFIPWr,
			EnableCpuToInstMem	=> EnableCpuToInstMem,
			DataRegInIF			=> DataRegInIF,
			DataRegOutIF		=> DataRegOutIF,
			InstDataBusInCpu	=> InstDataBusInCpu,
			StallSTR			=> StallSTR,
			StallRAW			=> StallRAW,
			StallWAWAux			=> StallWAWAux,
			StallBrEX			=> StallBrEX,
			EnableInInstCpu		=> EnableInInstCpu,
			EnableIF			=> EnableIF);

	UUT2: decode
		generic map (
			Pipelining			=> Pipelining)
		port map (
			StallHLT			=> StallHLT,
			StopInit			=> StopInit,
			DoneID				=> DoneID,
			IdInstIncWrPend		=> IdInstIncWrPend,
			IdRegIncWrPend		=> IdRegIncWrPend,
			BranchIDtoSM		=> BranchIDtoSM,
			IDtoMA				=> IDtoMA,
			DataRegInID			=> DataRegInID,
			IdRegID				=> IdRegID,
			SizeRegID			=> SizeRegID,
			EnableRegID			=> EnableRegID,
			EnableRegIDIP		=> EnableRegIDIP,
			EnableIncWrPend		=> EnableIncWrPend,
			EnableIncFPWrPend	=> EnableIncFPWrPend,
			IDtoEX				=> IDtoEX,
			IDtoWB				=> IDtoWB,
			StallBrEX			=> StallBrEX,
			StallSTR			=> StallSTR,
			StallRAW			=> StallRAW,
			StallWAWAux			=> StallWAWAux,
			BranchEXALUtoSM		=> BranchEXALUtoSM, 
			EXFPUPending		=> EXFPUPending,
			IFtoID				=> IFtoID,
			DataRegOutID		=> DataRegOutID,
			EnableID			=> EnableID);
	
	UUT3: execute
		port map (
			BranchEXALUtoSM		=> BranchEXALUtoSM,
			DataRegInEXALU		=> DataRegInEXALU,
			DataRegInEXFPU		=> DataRegInEXFPU,
			EnableRegEXALURd	=> EnableRegEXALURd,
			EnableRegEXFPURd	=> EnableRegEXFPURd,
			EnableRegEXALUWr	=> EnableRegEXALUWr,
			EnableRegEXFPUWr	=> EnableRegEXFPUWr,
			EnableRegEXALUIP	=> EnableRegEXALUIP,
			EnableDecFPWrPend	=> EnableDecFPWrPend,
			DataEXtoWB			=> DataEXtoWB,
			EnableCheckSTRM		=> EnableCheckSTRM,
			EXFPUPending		=> EXFPUPending,
			EnableEXALU			=> EnableEXALU,
			EnableEXFPU			=> EnableEXFPU,
			StallSTR			=> StallSTR,
			StallWAWAux			=> StallWAWAux,
			IDtoEX				=> IDtoEX,
			DataRegOutEXALU		=> DataRegOutEXALU,
			DataRegOutEXFPU		=> DataRegOutEXFPU,
			EnableEX			=> EnableEX);
	
	UUT4: memory_access
		port map (
			DataAddrBusCpu		=> DataAddrBusCpu,
			DataDataBusOutCpu	=> DataDataBusOutCpu,
			DataSizeBusCpu		=> DataSizeBusCpu,
			DataCtrlBusCpu		=> DataCtrlBusCpu,
			EnableCpuToDataMem	=> EnableCpuToDataMem,
			DataMAtoWB			=> DataMAtoWB,
			RecInMA				=> RecInMA,
			DataDataBusInCpu	=> DataDataBusInCpu,
			EnableInDataCpu		=> EnableInDataCpu,
			EnableMA			=> EnableMA);
	
	UUT5: writeback
		port map (
			DataRegInWB			=> DataRegInWB,
			IdRegWB				=> IdRegWB,
			SizeRegWB			=> SizeRegWB,
			EnableRegWB			=> EnableRegWB,
			WbRegCheckWAW		=> WbRegCheckWAW,
			IdRegDecWrPend		=> IdRegDecWrPend,
			DoneSTRW			=> DoneSTRW,
			EnableCheckWAW		=> EnableCheckWAW,
			EnableDecWrPend		=> EnableDecWrPend,
			WbRegDoneWAW		=> WbRegDoneWAW,
			DoneWAW				=> DoneWAW,
			StallWAW			=> StallWAW,
			StallSTR			=> StallSTR,
			RecInWB				=> RecInWB,
			EnableWB			=> EnableWB);
	
	-- Add your stimulus here ...


end ETAPAS_ARCHITECTURE;



