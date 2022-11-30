
-- Entidad "usuario":
-- Descripción: Aquí se define el banco de pruebas (testbench) con el objetivo de que 
-- el usuario pueda verificar el funcionamiento de la simulación de la PC. Para ello, 
-- debe escribir previamente un programa en el lenguaje Assembler para su ensamblaje 
-- y ejecución y definir las constantes generic declaradas en esta entidad para
-- especificar la arquitectura del procesador. El repertorio de instrucciones
-- soportado por esta CPU se encuentra determinado en el paquete "repert_cpu".
-- Parámetros:
-- ProgName: Contiene el nombre del programa a ser ensamblado y ejecutado por la PC.
-- El usuario debe acordarse de incluir la extensión ".asm" y de ubicar el archivo
-- en la carpeta "Assembler", dentro del espacio de trabajo (Workspace) del proyecto.
-- Pipelining: Determina si la CPU incluida en la PC simulada presentará (valor "true")
-- o no (valor "false") una segmentación en su cauce. Naturalmente debería esperarse una
-- notoria mejora en el rendimiento de un procesador segmentado respecto a uno secuencial.
-- Cores: Esta funcionalidad aún no se encuentra implementada, por lo que el valor asignado
-- a este parámetro resulta irrelevante. No obstante, cabe mencionar que aquí se estaría
-- definiendo la cantidad de núcleos que posee la arquitectura multi-core.
-- Procesos:
-- Main: Su función es habilitar el ensamblador de la PC para que comience a llevar a cabo
-- su tarea. Una vez completada, procede a recibir la señal de finalización del ensamblaje
-- para informar este evento al usuario. Un fenómeno similar ocurre con la ejecución 
-- propiamente dicha del programa: cuando la CPU termina su trabajo, envía una nueva señal 
-- a este proceso para que el mismo realice al usuario la notificación correspondiente.


library TDA_1819;
use TDA_1819.tipos_ensamblador.all;


library ieee;
use ieee.NUMERIC_STD.all;
use ieee.std_logic_1164.all;
library std;
use std.TEXTIO.all;

	-- Add your library and packages declaration here ...

entity usuario is
	-- Generic declarations of the tested unit
	generic (
		ProgName	: STRING := "mem_wb_str_waw1.asm";
		Pipelining	: BOOLEAN := true;
		Cores 		: INTEGER := 1);  	
			
end usuario;

architecture USUARIO_ARCHITECTURE of usuario is
	
	-- Component declaration of the tested unit
	component pc
		generic (
			ProgName		: STRING;
			Pipelining 		: BOOLEAN;
			Cores 			: INTEGER);
		port (
			DoneCompUser	: out std_logic;
			DoneCpuUser		: out std_logic;
			ReadyUser		: in  std_logic);
	end component;
	
	FOR UUT: pc USE ENTITY WORK.pc(pc_architecture);
	
	-- Add your code here ...
	
	SIGNAL DoneCompUser:	std_logic;
	SIGNAL DoneCpuUser:		std_logic;
	SIGNAL ReadyUser:		std_logic;
	

begin
	
	
	-- Unit Under Test port map
	UUT : pc
		generic map (
			ProgName 		=> ProgName,
			Pipelining 		=> Pipelining,
			Cores 			=> Cores
		)
		port map ( 
			DoneCompUser 	=> DoneCompUser,
			DoneCpuUser 	=> DoneCpuUser,
			ReadyUser 		=> ReadyUser
		);
	
	-- Add your stimulus here ...
	
	Main: PROCESS

	BEGIN 
		ReadyUser <= '0';
		WAIT FOR 1 ns;
		ReadyUser <= '1';
		WAIT UNTIL rising_edge(DoneCompUser);
		report "El programa 'Assembler/" & ProgName & "' ha sido ensamblado exitosamente"
		severity WARNING;
		WAIT UNTIL rising_edge(DoneCpuUser);
		report "El programa 'Assembler/" & ProgName & "' ha sido ejecutado exitosamente"
		severity WARNING;
		WAIT;
	END PROCESS Main;


end USUARIO_ARCHITECTURE;



