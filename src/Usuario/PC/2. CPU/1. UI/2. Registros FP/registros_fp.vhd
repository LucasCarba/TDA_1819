
-- Entidad "registros_fp":
-- Descripción: Aquí se define la interfaz de usuario para el banco de registros en punto 
-- flotante del procesador. La particular importancia de esta entidad radica en que el 
-- simulador no cuenta con la capacidad de representar los valores de las señales en 
-- punto flotante en el sistema decimal, por lo cual sin dicha interfaz el usuario no 
-- podría visualizar en forma inteligible el contenido de cada uno de estos registros a 
-- través del tiempo.
-- Procesos:
-- Main: Cada vez que se actualiza alguno de los registros en punto flotante del procesador,
-- este proceso obtiene la representación de este nuevo valor en el sistema decimal y la
-- asigna a su correspondiente registro de la interfaz para que el usuario pueda visualizarla.


library TDA_1819; 
use TDA_1819.const_registros.all;

LIBRARY IEEE;
USE std.textio.all;
use ieee.NUMERIC_STD.all;
USE IEEE.std_logic_1164.all; 	

library ieee_proposed;
use ieee_proposed.float_pkg.all;




entity registros_fp is
	
	port (
		DataRegFP		: in std_logic_vector(31 downto 0);
		IdRegFP			: in std_logic_vector(7 downto 0);
		EnableRegFP		: in std_logic);

end registros_fp;




architecture REGISTROS_FP_ARCHITECTURE of registros_fp is

	
	SIGNAL UI_F0:		real := 0.00;
	SIGNAL UI_F1:		real := 0.00;
	SIGNAL UI_F2:		real := 0.00;
	SIGNAL UI_F3:		real := 0.00;
	SIGNAL UI_F4:		real := 0.00;
	SIGNAL UI_F5:		real := 0.00;
	SIGNAL UI_F6:		real := 0.00;
	SIGNAL UI_F7:		real := 0.00;
	SIGNAL UI_F8:		real := 0.00;
	SIGNAL UI_F9:		real := 0.00;
	SIGNAL UI_F10:		real := 0.00;
	SIGNAL UI_F11:		real := 0.00;
	SIGNAL UI_F12:		real := 0.00;
	SIGNAL UI_F13:		real := 0.00;
	SIGNAL UI_F14:		real := 0.00;
	SIGNAL UI_F15:		real := 0.00;

	
begin				
	
	
	Main: PROCESS
	
	BEGIN
		WAIT UNTIL rising_edge(EnableRegFP);
		CASE to_integer(unsigned(IdRegFP)) IS 
			WHEN ID_F0 =>
				UI_F0 <= to_real(to_float(DataRegFP(31 downto 0)));
			WHEN ID_F1 =>
				UI_F1 <= to_real(to_float(DataRegFP(31 downto 0)));
			WHEN ID_F2 =>
				UI_F2 <= to_real(to_float(DataRegFP(31 downto 0)));
			WHEN ID_F3 =>
				UI_F3 <= to_real(to_float(DataRegFP(31 downto 0)));
			WHEN ID_F4 =>
				UI_F4 <= to_real(to_float(DataRegFP(31 downto 0)));
			WHEN ID_F5 =>
				UI_F5 <= to_real(to_float(DataRegFP(31 downto 0)));
			WHEN ID_F6 =>
				UI_F6 <= to_real(to_float(DataRegFP(31 downto 0)));
			WHEN ID_F7 =>
				UI_F7 <= to_real(to_float(DataRegFP(31 downto 0)));
			WHEN ID_F8 =>
				UI_F8 <= to_real(to_float(DataRegFP(31 downto 0)));
			WHEN ID_F9 =>
				UI_F9 <= to_real(to_float(DataRegFP(31 downto 0)));
			WHEN ID_F10 =>
				UI_F10 <= to_real(to_float(DataRegFP(31 downto 0)));
			WHEN ID_F11 =>
				UI_F11 <= to_real(to_float(DataRegFP(31 downto 0)));
			WHEN ID_F12 =>
				UI_F12 <= to_real(to_float(DataRegFP(31 downto 0)));
			WHEN ID_F13 =>
				UI_F13 <= to_real(to_float(DataRegFP(31 downto 0)));
			WHEN ID_F14 =>
				UI_F14 <= to_real(to_float(DataRegFP(31 downto 0)));
			WHEN ID_F15 =>
				UI_F15 <= to_real(to_float(DataRegFP(31 downto 0)));
			WHEN OTHERS =>
				report "Acceso incorrecto a la interfaz de usuario para los registros de punto flotante"
				severity FAILURE;
		END CASE;
	END PROCESS Main;
		
	
end REGISTROS_FP_ARCHITECTURE;



