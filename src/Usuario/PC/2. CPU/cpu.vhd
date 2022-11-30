
-- Entidad "cpu":
-- Descripción: Éste es el diseño estructural de la CPU, por lo cual no posee ningún
-- proceso, ya que su funcionalidad se limita únicamente a interconectar los componentes
-- internos del procesador definido para este proyecto (interfaz de usuario, etapas de
-- segmentación, banco de registros internos para la segmentación, unidades detectoras 
-- de atascos, administrador de la CPU, reloj y banco de registros del procesador), 
-- cada uno de ellos con sus respectivos puertos de entrada, salida y entrada/salida. 
-- También recibe del ensamblador de la PC la señal para comenzar a ejecutar el programa, 
-- se comunica con la memoria principal para leer o escribir sobre su sección de datos 
-- o leer sobre su sección de instrucciones y por último envía al banco de pruebas del 
-- usuario la señal de finalización de la ejecución del programa.


library TDA_1819;
use TDA_1819.tipos_cpu.all;

library ieee;
use ieee.NUMERIC_STD.all;
use ieee.std_logic_1164.all;
library std;
use std.TEXTIO.all;

	-- Add your library and packages declaration here ...

entity cpu is
	
	generic (
		Pipelining	: BOOLEAN); 
		
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
			
end cpu;

architecture CPU_ARCHITECTURE of cpu is
	
	-- Component declaration of the tested unit
	component ui
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
			EnableSM			: in std_logic;
			DataRegFP			: in std_logic_vector(31 downto 0);
			IdRegFP				: in std_logic_vector(7 downto 0);
			EnableRegFP			: in std_logic);
	end component;
	
	component etapas 
		generic (
			Pipelining			: BOOLEAN);
		port (
			StallHLT			: out	std_logic;
			StopInit			: out   std_logic;
			DoneID				: out   std_logic;
			IdInstIncWrPend		: out	std_logic_vector(7 downto 0);
			IdRegIncWrPend		: out   std_logic_vector(7 downto 0);
			IdRegDecWrPend		: out   std_logic_vector(7 downto 0);
			BranchIDtoSM		: out   state_branch;
			IDtoMA				: out   memaccess_record;	 
			DataRegInID			: out   std_logic_vector(31 downto 0);
			IdRegID				: out   std_logic_vector(7 downto 0);
			SizeRegID			: out   std_logic_vector(3 downto 0);
			DataRegInWB			: out   std_logic_vector(31 downto 0);
			IdRegWB				: out   std_logic_vector(7 downto 0);
			SizeRegWB			: out   std_logic_vector(3 downto 0);	
			DataRegInEXALU		: out   std_logic_vector(31 downto 0);
			DataRegInEXFPU		: out   std_logic_vector(31 downto 0);
			DataEXtoWB			: out   std_logic_vector(31 downto 0);
			DataMAtoWB			: out   std_logic_vector(31 downto 0);
			DataRegInIF			: out   std_logic_vector(31 downto 0);
			WbRegCheckWAW		: out 	writeback_record;
			EnableCheckWAW		: out 	std_logic;
			DoneSTRW 			: out 	std_logic;
			DataAddrBusCpu		: out   std_logic_vector(15 downto 0);
			DataDataBusOutCpu	: out   std_logic_vector(31 downto 0);
			DataSizeBusCpu		: out   std_logic_vector(3 downto 0);
			DataCtrlBusCpu		: out   std_logic_vector(1 downto 0);
			InstAddrBusCpu		: out   std_logic_vector(15 downto 0);
			InstDataBusOutCpu	: out   std_logic_vector(31 downto 0);
			InstSizeBusCpu		: out   std_logic_vector(3 downto 0);
			InstCtrlBusCpu		: out   std_logic_vector(1 downto 0);
			EnableRegIFIPRd		: out 	std_logic;
			EnableRegIFIRWr		: out 	std_logic;		
			EnableRegIFIPWr		: out 	std_logic;
			EnableRegID			: out   std_logic;
			EnableRegIDIP		: out   std_logic;
			EnableRegEXALURd	: out   std_logic; 
			EnableRegEXFPURd	: out   std_logic;
			EnableRegEXALUWr	: out   std_logic;
			EnableRegEXFPUWr	: out   std_logic;
			EnableRegEXALUIP	: out   std_logic;
			EnableDecFPWrPend	: out 	std_logic;	
			EnableCheckSTRM		: out 	std_logic;
			EnableRegWB			: out   std_logic;
			EnableIncWrPend		: out   std_logic;
			EnableIncFPWrPend	: out   std_logic;
			EnableDecWrPend		: out   std_logic;
			EnableCpuToDataMem	: out   std_logic;
			EnableCpuToInstMem	: out   std_logic;
			IDtoEX				: inout execute_record;
			IDtoWB				: inout writeback_record;
			BranchEXALUtoSM		: inout state_branch;
			EnableEXALU			: inout std_logic;
			EnableEXFPU			: inout std_logic;
			RecInMA				: in    memaccess_record;
			RecInWB				: in    writeback_record;
			DataRegOutIF		: in    std_logic_vector(31 downto 0);
			DataRegOutID		: in    std_logic_vector(31 downto 0);
			DataRegOutEXALU		: in    std_logic_vector(31 downto 0);
			DataRegOutEXFPU		: in    std_logic_vector(31 downto 0);
			DataDataBusInCpu	: in    std_logic_vector(31 downto 0);
			InstDataBusInCpu	: in    std_logic_vector(31 downto 0);
			StallSTR			: in  	std_logic;
			StallRAW			: in    std_logic;
			StallWAWAux			: in 	std_logic;
			WbRegDoneWAW		: in 	writeback_record;
			DoneWAW				: in	std_logic;
			StallWAW			: in 	std_logic;
			EnableInDataCpu		: in    std_logic;
			EnableInInstCpu		: in    std_logic;
			EnableIF			: in    std_logic;
			EnableID			: in    std_logic;
			EnableEX			: in    std_logic;
			EnableMA			: in    std_logic;
			EnableWB			: in    std_logic);
	end component;
	
	component pipeline_registros
		port (
			RecInMA				: out memaccess_record;
			RecInWB				: out writeback_record;
			PipeFP_4			: out std_logic;
			StallSTRW			: in  std_logic;
			StallSTR			: in  std_logic;
			StallWAWAux			: in  std_logic;
			Fp					: in  std_logic;
			IDtoMA				: in  memaccess_record;
			IDtoWB				: in  writeback_record;
			DataEXtoWB			: in  std_logic_vector(31 downto 0);
			DataMAtoWB			: in  std_logic_vector(31 downto 0); 
			EnablePDA_ID		: in  std_logic;
			EnablePDA_EX		: in  std_logic;
			EnablePDA_MA		: in  std_logic);
	end component; 
	
	component atascos
		generic (
			Pipelining			: BOOLEAN);
		port (
			StallSTR			: out 	std_logic;
			WbRegDoneWAW		: out 	writeback_record;
			StallSTRW			: inout std_logic;
			StallWAWAux			: inout std_logic;
			DoneWAW				: inout	std_logic;
			StallWAW			: inout std_logic;
			StallRAW			: inout std_logic;
			EnableEXALU			: in 	std_logic;
			EnableEXFPU			: in 	std_logic;
			PipeFP_4			: in  	std_logic;
			DoneSTRW			: in 	std_logic;
			EnableCheckSTRM		: in 	std_logic;
			IdRegID				: in    std_logic_vector(7 downto 0);
			IdInstIncWrPend		: in	std_logic_vector(7 downto 0);
			IdRegIncWrPend		: in    std_logic_vector(7 downto 0);
			WbRegCheckWAW		: in	writeback_record;
			IdRegDecWrPend		: in    std_logic_vector(7 downto 0);
			EnableRegID			: in    std_logic;
			EnableIncWrPend		: in    std_logic;
			EnableIncFPWrPend	: in    std_logic;
			EnableCheckWAW		: in 	std_logic;
			EnableDecWrPend		: in    std_logic;
			EnableDecFPWrPend	: in	std_logic);	
	end component;
	
	component cpu_admin
		generic (
			Pipelining			: BOOLEAN);
	    port (
			EnableSM			: out std_logic;
			EnableIF			: out std_logic;
			EnableID			: out std_logic;
			EnableEX			: out std_logic;
			EnableMA			: out std_logic;
			EnableWB			: out std_logic;
			EnablePDA_ID		: out std_logic;
			EnablePDA_EX		: out std_logic;
			EnablePDA_MA		: out std_logic;
			StopSM				: out std_logic;
			StopEnd				: out std_logic;
			DoneCpuUser			: out std_logic;
			StallHLT			: in  std_logic;
			StopInit			: in  std_logic;
			Fp					: in  std_logic;
			CLK					: in  std_logic);
	end component;
	
	component reloj
		port (
			CLK					: out std_logic;
			DoneCompCPU			: in  std_logic;
			StopEnd				: in  std_logic);
	end component;
	
	component registros
		port (
			DataRegOutIF		: out std_logic_vector(31 downto 0);
			DataRegOutID		: out std_logic_vector(31 downto 0);
			DataRegOutEXALU		: out std_logic_vector(31 downto 0);
			DataRegOutEXFPU		: out std_logic_vector(31 downto 0);
			DataRegFP			: out std_logic_vector(31 downto 0);
			IdRegFP				: out std_logic_vector(7 downto 0);
			EnableRegFP			: out std_logic;
			DataRegInIF			: in  std_logic_vector(31 downto 0);
			DataRegInID			: in  std_logic_vector(31 downto 0);
			DataRegInEXALU		: in  std_logic_vector(31 downto 0);
			DataRegInEXFPU		: in  std_logic_vector(31 downto 0);
			DataRegInWB			: in  std_logic_vector(31 downto 0);
			IdRegID				: in  std_logic_vector(7 downto 0);
			IdRegWB				: in  std_logic_vector(7 downto 0);
			SizeRegID			: in  std_logic_vector(3 downto 0);
			SizeRegWB			: in  std_logic_vector(3 downto 0);
			EnableRegIFIPRd		: in  std_logic;
			EnableRegIFIRWr 	: in  std_logic;
			EnableRegIFIPWr		: in  std_logic;
			EnableRegID			: in  std_logic;
			EnableRegIDIP		: in  std_logic;
			EnableRegEXALURd	: in  std_logic;
			EnableRegEXFPURd	: in  std_logic;
			EnableRegEXALUWr	: in  std_logic; 
			EnableRegEXFPUWr	: in  std_logic;
			EnableRegEXALUIP	: in  std_logic;
			EnableRegWB			: in  std_logic);
	end component;
	
	
	FOR UUT1: ui USE ENTITY WORK.ui(ui_architecture);
	FOR UUT2: etapas USE ENTITY WORK.etapas(etapas_architecture);
	FOR UUT3: pipeline_registros USE ENTITY WORK.pipeline_registros(pipeline_registros_architecture);
	FOR UUT4: atascos USE ENTITY WORK.atascos(atascos_architecture);
	FOR UUT5: cpu_admin USE ENTITY WORK.cpu_admin(cpu_admin_architecture);	
	FOR UUT6: reloj USE ENTITY WORK.reloj(reloj_architecture);
	FOR UUT7: registros USE ENTITY WORK.registros(registros_architecture);	
		
	
	-- Add your code here ...	
	SIGNAL DoneID:				std_logic;
	SIGNAL IdInstIncWrPend: 	std_logic_vector(7 downto 0);
	SIGNAL IdRegIncWrPend:		std_logic_vector(7 downto 0);
	SIGNAL IdRegDecWrPend:		std_logic_vector(7 downto 0);
	SIGNAL EnableIncWrPend:		std_logic;
	SIGNAL EnableIncFPWrPend: 	std_logic;
	SIGNAL EnableDecWrPend: 	std_logic;
	SIGNAL EnableDecFPWrPend: 	std_logic;
	SIGNAL WbRegCheckWAW: 		writeback_record;
	SIGNAL EnableCheckWAW: 		std_logic;
	SIGNAL StallHLT:			std_logic;
	SIGNAL StallSTR:			std_logic;
	SIGNAL StallRAW: 			std_logic;
	SIGNAL StallWAWAux: 		std_logic;
	SIGNAL WbRegDoneWAW: 		writeback_record;
	SIGNAL DoneWAW: 			std_logic;
	SIGNAL StallWAW: 			std_logic;
	SIGNAL BranchIDtoSM:		state_branch;
	SIGNAL BranchEXALUtoSM:		state_branch;
	SIGNAL StopSM:				std_logic;
	SIGNAL EnableSM:			std_logic;
	SIGNAL DataRegFP:			std_logic_vector(31 downto 0);
	SIGNAL IdRegFP: 			std_logic_vector(7 downto 0);
	SIGNAL EnableRegFP:			std_logic;
	SIGNAL EnableRegIFIPRd: 	std_logic;
	SIGNAL EnableRegIFIRWr:		std_logic; 	
	SIGNAL EnableRegIFIPWr:		std_logic;
	SIGNAL DataRegInIF:			std_logic_vector(31 downto 0);
	SIGNAL DataRegOutIF:		std_logic_vector(31 downto 0);
	SIGNAL EnableIF:			std_logic;
	SIGNAL StopInit: 			std_logic; 
	SIGNAL IDtoEX:				execute_record;
	SIGNAL IDtoMA:				memaccess_record;
	SIGNAL IDtoWB:				writeback_record;
	SIGNAL DataRegInID:			std_logic_vector(31 downto 0);
	SIGNAL IdRegID:				std_logic_vector(7 downto 0);
	SIGNAL SizeRegID:			std_logic_vector(3 downto 0);
	SIGNAL EnableRegID:			std_logic;
	SIGNAL EnableRegIDIP:		std_logic;
	SIGNAL DataRegOutID:		std_logic_vector(31 downto 0);
	SIGNAL EnableID:			std_logic;
	SIGNAL DataRegInEXALU:		std_logic_vector(31 downto 0);
	SIGNAL DataRegInEXFPU:		std_logic_vector(31 downto 0);
	SIGNAL EnableRegEXALURd:	std_logic; 
	SIGNAL EnableRegEXFPURd:	std_logic;
	SIGNAL EnableRegEXALUWr: 	std_logic; 
	SIGNAL EnableRegEXFPUWr: 	std_logic;
	SIGNAL EnableRegEXALUIP: 	std_logic;
	SIGNAL EnableCheckSTRM: 	std_logic;
	SIGNAL PipeFP_4:			std_logic;
	SIGNAL StallSTRW:			std_logic;
	SIGNAL DoneSTRW:			std_logic;
	SIGNAL DataEXtoWB: 			std_logic_vector(31 downto 0);
	SIGNAL DataRegOutEXALU: 	std_logic_vector(31 downto 0);
	SIGNAL DataRegOutEXFPU: 	std_logic_vector(31 downto 0);
	SIGNAL EnableEX: 			std_logic;
	SIGNAL EnableEXALU: 		std_logic;
	SIGNAL EnableEXFPU: 		std_logic;
	SIGNAL DataMAtoWB:			std_logic_vector(31 downto 0);
	SIGNAL RecInMA: 			memaccess_record;
	SIGNAL EnableMA: 			std_logic;
	SIGNAL DataRegInWB: 		std_logic_vector(31 downto 0);
	SIGNAL IdRegWB: 			std_logic_vector(7 downto 0);
	SIGNAL SizeRegWB:			std_logic_vector(3 downto 0);
	SIGNAL EnableRegWB:			std_logic;
	SIGNAL RecInWB:				writeback_record;
	SIGNAL EnableWB:			std_logic;
	SIGNAL EnablePDA_ID:		std_logic;
	SIGNAL EnablePDA_EX: 		std_logic;
	SIGNAL EnablePDA_MA: 		std_logic;
	SIGNAL StopEnd: 			std_logic;
	SIGNAL CLK: 				std_logic;
	

begin
	
	
	-- Unit Under Test port map
	
	UUT1: ui
		generic map (
			Pipelining			=> Pipelining)
		port map (
			CompToSM			=> CompToSM,
			BranchIDtoSM		=> BranchIDtoSM,
			BranchEXALUtoSM		=> BranchEXALUtoSM,
			Fp					=> IDtoEX.fp,
			LoadInstState		=> LoadInstState,
			LoadBranchInstState	=> LoadBranchInstState,
			DoneID				=> DoneID,
			StallHLT			=> StallHLT,
			StallSTR			=> StallSTR,
			StallRAW			=> StallRAW,
			StallWAWAux			=> StallWAWAux,
			StopSM				=> StopSM,
			EnableSM			=> EnableSM,
			DataRegFP			=> DataRegFP,
			IdRegFP				=> IdRegFP,
			EnableRegFP			=> EnableRegFP);
			
	UUT2: etapas
		generic map (
			Pipelining			=> Pipelining)
		port map (
			StallHLT			=> StallHLT,
			StopInit			=> StopInit,
			DoneID				=> DoneID,
			IdInstIncWrPend		=> IdInstIncWrPend,
			IdRegIncWrPend		=> IdRegIncWrPend,
			IdRegDecWrPend		=> IdRegDecWrPend,
			BranchIDtoSM		=> BranchIDtoSM,
			IDtoMA				=> IDtoMA,	 
			DataRegInID			=> DataRegInID,
			IdRegID				=> IdRegID,
			SizeRegID			=> SizeRegID,
			DataRegInWB			=> DataRegInWB,
			IdRegWB				=> IdRegWB,
			SizeRegWB			=> SizeRegWB,	
			DataRegInEXALU		=> DataRegInEXALU,
			DataRegInEXFPU		=> DataRegInEXFPU,
			DataEXtoWB			=> DataEXtoWB,
			DataMAtoWB			=> DataMAtoWB,
			DataRegInIF			=> DataRegInIF,
			WbRegCheckWAW		=> WbRegCheckWAW,
			EnableCheckWAW		=> EnableCheckWAW,
			DoneSTRW 			=> DoneSTRW,
			DataAddrBusCpu		=> DataAddrBusCpu,
			DataDataBusOutCpu	=> DataDataBusOutCpu,
			DataSizeBusCpu		=> DataSizeBusCpu,
			DataCtrlBusCpu		=> DataCtrlBusCpu,
			InstAddrBusCpu		=> InstAddrBusCpu,
			InstDataBusOutCpu	=> InstDataBusOutCpu,
			InstSizeBusCpu		=> InstSizeBusCpu,
			InstCtrlBusCpu		=> InstCtrlBusCpu,
			EnableRegIFIPRd		=> EnableRegIFIPRd,
			EnableRegIFIRWr		=> EnableRegIFIRWr,
			EnableRegIFIPWr		=> EnableRegIFIPWr,
			EnableRegID			=> EnableRegID,
			EnableRegIDIP		=> EnableRegIDIP,
			EnableRegEXALURd	=> EnableRegEXALURd,
			EnableRegEXFPURd	=> EnableRegEXFPURd,
			EnableRegEXALUWr	=> EnableRegEXALUWr,
			EnableRegEXFPUWr	=> EnableRegEXFPUWr,
			EnableRegEXALUIP	=> EnableRegEXALUIP,
			EnableDecFPWrPend	=> EnableDecFPWrPend,
			EnableCheckSTRM		=> EnableCheckSTRM,
			EnableRegWB			=> EnableRegWB,
			EnableIncWrPend		=> EnableIncWrPend,
			EnableIncFPWrPend	=> EnableIncFPWrPend,
			EnableDecWrPend		=> EnableDecWrPend,
			EnableCpuToDataMem	=> EnableCpuToDataMem,
			EnableCpuToInstMem	=> EnableCpuToInstMem,
			IDtoEX				=> IDtoEX,
			IDtoWB				=> IDtoWB,
			BranchEXALUtoSM		=> BranchEXALUtoSM,
			EnableEXALU			=> EnableEXALU,
			EnableEXFPU			=> EnableEXFPU,
			RecInMA				=> RecInMA,
			RecInWB				=> RecInWB,
			DataRegOutIF		=> DataRegOutIF,
			DataRegOutID		=> DataRegOutID,
			DataRegOutEXALU		=> DataRegOutEXALU,
			DataRegOutEXFPU		=> DataRegOutEXFPU,
			DataDataBusInCpu	=> DataDataBusInCpu,
			InstDataBusInCpu	=> InstDataBusInCpu,
			StallSTR			=> StallSTR,
			StallRAW			=> StallRAW,
			StallWAWAux			=> StallWAWAux,
			WbRegDoneWAW		=> WbRegDoneWAW,
			DoneWAW				=> DoneWAW,
			StallWAW			=> StallWAW,
			EnableInDataCpu		=> EnableInDataCpu,
			EnableInInstCpu		=> EnableInInstCpu,
			EnableIF			=> EnableIF,
			EnableID			=> EnableID,
			EnableEX			=> EnableEX,
			EnableMA			=> EnableMA,
			EnableWB			=> EnableWB);

	UUT3: pipeline_registros
		port map (
			RecInMA				=> RecInMA,
			RecInWB				=> RecInWB,
			PipeFP_4			=> PipeFP_4,
			StallSTRW			=> StallSTRW,
			StallSTR			=> StallSTR,
			StallWAWAux			=> StallWAWAux,
			Fp					=> IDtoEX.fp,
			IDtoMA				=> IDtoMA,
			IDtoWB				=> IDtoWB,
			DataEXtoWB			=> DataEXtoWB,
			DataMAtoWB			=> DataMAtoWB,
			EnablePDA_ID		=> EnablePDA_ID,
			EnablePDA_EX		=> EnablePDA_EX,
			EnablePDA_MA		=> EnablePDA_MA);
			
	UUT4: atascos
		generic map (
			Pipelining			=> Pipelining)
		port map ( 
			StallSTR			=> StallSTR,
			WbRegDoneWAW		=> WbRegDoneWAW,
			StallSTRW			=> StallSTRW,
			StallWAWAux			=> StallWAWAux,
			DoneWAW				=> DoneWAW,
			StallWAW			=> StallWAW,
			StallRAW			=> StallRAW,
			EnableEXALU			=> EnableEXALU,
			EnableEXFPU			=> EnableEXFPU,
			PipeFP_4			=> PipeFP_4,
			DoneSTRW			=> DoneSTRW,
			EnableCheckSTRM		=> EnableCheckSTRM,
			IdRegID				=> IdRegID,	
			IdInstIncWrPend		=> IdInstIncWrPend,
			IdRegIncWrPend		=> IdRegIncWrPend,
			WbRegCheckWAW		=> WbRegCheckWAW,
			IdRegDecWrPend		=> IdRegDecWrPend,
			EnableRegID			=> EnableRegID,
			EnableIncWrPend		=> EnableIncWrPend,
			EnableIncFPWrPend	=> EnableIncFPWrPend,
			EnableCheckWAW		=> EnableCheckWAW,
			EnableDecWrPend		=> EnableDecWrPend,
			EnableDecFPWrPend	=> EnableDecFPWrPend);
		
	UUT5: cpu_admin
		generic map (
			Pipelining			=> Pipelining)
		port map (
			EnableSM			=> EnableSM,
			EnableIF			=> EnableIF,
			EnableID			=> EnableID,
			EnableEX			=> EnableEX,
			EnableMA			=> EnableMA,
			EnableWB			=> EnableWB,
			EnablePDA_ID		=> EnablePDA_ID,
			EnablePDA_EX		=> EnablePDA_EX,
			EnablePDA_MA		=> EnablePDA_MA,
			StopSM				=> StopSM,
			StopEnd				=> StopEnd,
			DoneCpuUser			=> DoneCpuUser,
			StallHLT			=> StallHLT,
			StopInit			=> StopInit,
			Fp					=> IDtoEX.fp,
			CLK					=> CLK);
	
	UUT6: reloj
		port map (
			CLK					=> CLK,
			DoneCompCPU			=> DoneCompCPU,
			StopEnd				=> StopEnd);
	
	UUT7: registros
		port map (
			DataRegOutIF		=> DataRegOutIF,
			DataRegOutID		=> DataRegOutID,
			DataRegOutEXALU		=> DataRegOutEXALU,
			DataRegOutEXFPU		=> DataRegOutEXFPU,
			DataRegFP			=> DataRegFP,
			IdRegFP				=> IdRegFP,
			EnableRegFP			=> EnableRegFP,
			DataRegInIF			=> DataRegInIF,
			DataRegInID			=> DataRegInID,
			DataRegInEXALU		=> DataRegInEXALU,
			DataRegInEXFPU		=> DataRegInEXFPU,
			DataRegInWB			=> DataRegInWB,
			IdRegID				=> IdRegID,
			IdRegWB				=> IdRegWB,
			SizeRegID			=> SizeRegID,
			SizeRegWB			=> SizeRegWB,
			EnableRegIFIPRd		=> EnableRegIFIPRd,
			EnableRegIFIRWr		=> EnableRegIFIRWr,
			EnableRegIFIPWr		=> EnableRegIFIPWr,
			EnableRegID			=> EnableRegID,
			EnableRegIDIP		=> EnableRegIDIP,
			EnableRegEXALURd	=> EnableRegEXALURd,
			EnableRegEXFPURd	=> EnableRegEXFPURd,
			EnableRegEXALUWr	=> EnableRegEXALUWr,
			EnableRegEXFPUWr	=> EnableRegEXFPUWr,
			EnableRegEXALUIP	=> EnableRegEXALUIP,
			EnableRegWB			=> EnableRegWB);	
	
	-- Add your stimulus here ...


end CPU_ARCHITECTURE;



