
-- Entidad "atascos":
-- Descripción: Éste es el diseño estructural del detector para cualquier tipo de
-- dependencias estructurales o de datos que puedan provocar atascos en el cauce del 
-- procesador. No posee ningún proceso, ya que su funcionalidad se limita
-- únicamente a interconectar sus componentes internos (detectores de dependencias
-- estructurales y de datos), cada uno de ellos con sus respectivos puertos de entrada,
-- salida y entrada/salida. También recibe del administrador para la etapa de ejecución 
-- de la segmentación del procesador la señal para realizar la comprobación de 
-- dependencias estructurales respecto a la memoria de datos; de la etapa "writeback"
-- la señal para verificar posibles dependencias de datos WAW (Escritura Después de 
-- Escritura); de la etapa "decode" la señal para comprobar dependencias de datos RAW 
-- (Lectura Después de Escritura); y, por último, del banco de registros internos 
-- intermedios la señal necesaria para analizar dependencias estructurales respecto a
-- la actualización del banco de registros de propósito general de la CPU.


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




entity atascos is
	
	generic (
		Pipelining	: BOOLEAN);
	
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
		DoneSTRW			: in  	std_logic;
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

end atascos;




architecture ATASCOS_ARCHITECTURE of atascos is


	-- Component declaration of the tested unit
	component str_detector
		generic (
			Pipelining			: BOOLEAN);
		port ( 
			StallSTR			: out 	std_logic;
			StallSTRW			: inout std_logic;
			EnableEXALU			: in  	std_logic;
			EnableEXFPU			: in  	std_logic;
			StallWAWAux			: in  	std_logic;
			PipeFP_4			: in  	std_logic;
			DoneSTRW			: in  	std_logic;
			EnableCheckSTRM		: in  	std_logic);
	end component;
	
	component raw_waw_detector 
		generic (
			Pipelining			: BOOLEAN);
		port ( 
			WbRegDoneWAW		: out 	writeback_record;
			StallWAWAux			: out 	std_logic;
			DoneWAW				: inout	std_logic;
			StallWAW			: inout std_logic;
			StallRAW			: inout std_logic;
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
	
	
	FOR UUT1: str_detector USE ENTITY WORK.str_detector(str_detector_architecture);
	FOR UUT2: raw_waw_detector USE ENTITY WORK.raw_waw_detector(raw_waw_detector_architecture);
		
	
	-- Add your code here ...		
	
	
begin
	
	
	-- Unit Under Test port map
		
	UUT1: str_detector
		generic map (
			Pipelining			=> Pipelining)
		port map (
			StallSTR			=> StallSTR,
			StallSTRW			=> StallSTRW,
			EnableEXALU			=> EnableEXALU,
			EnableEXFPU			=> EnableEXFPU,
			StallWAWAux			=> StallWAWAux,
			PipeFP_4			=> PipeFP_4,
			DoneSTRW			=> DoneSTRW,
			EnableCheckSTRM		=> EnableCheckSTRM);
	
	UUT2: raw_waw_detector
		generic map (
			Pipelining			=> Pipelining)
		port map (
			WbRegDoneWAW		=> WbRegDoneWAW,
			StallWAWAux			=> StallWAWAux,
			DoneWAW				=> DoneWAW,
			StallWAW			=> StallWAW,
			StallRAW			=> StallRAW,
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
		
	-- Add your stimulus here ...
	
	
end ATASCOS_ARCHITECTURE;





