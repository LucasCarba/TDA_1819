
-- Entidad "reloj":	
-- Descripción: Aquí se define el generador para el reloj de la CPU. Su función es simple, 
-- ya que se encarga únicamente de crear y transmitir una señal periódica, cuyo período se 
-- encuentra establecido en el paquete "const_reloj", hacia el administrador del procesador
-- para que éste gestione a partir de ella la habilitación de los demás componentes
-- de la CPU. Este reloj se activa una vez finalizado el ensamblaje del programa
-- para comenzar su ejecución y se desactiva solamente cuando todos los otros 
-- procesos del procesador ya se encuentren detenidos por el administrador. 
-- Descripción: Aquí se define el administrador de la CPU, encargado de, en cada ciclo
-- de reloj, habilitar en primer lugar la ejecución simultánea de todas las etapas del 
-- pipeline (en caso de que la segmentación del procesador se encuentre activada por el 
-- usuario). Luego, antes de que finalice el ciclo de reloj habilitará al banco de 
-- registros internos intermedios de la segmentación para que reciba y almacene de las 
-- etapas "decode", "execute" y "memory access" toda la información que deseen 
-- transmitir especialmente a las siguientes etapas del pipeline que no sean 
-- consecutivas a ellas.
-- Procesos: 
-- Main: Mantiene la señal de reloj en un estado inactivo hasta recibir desde el
-- ensamblador la señal de finalización del ensamblaje del programa, momento a partir
-- del cual procederá a generar los ciclos de reloj, activando la señal durante la 
-- primera mitad de cada período y desactivándola durante la segunda mitad. Esta señal
-- será transmitida al administrador de la CPU, el cual utilizará tanto el flanco 
-- ascendente como el descendente de cada ciclo para gestionar la habilitación de todos
-- los demás componentes del procesador. Finalmente, una vez recibida la señal del
-- administrador de que el resto de los módulos de la CPU ya se encuentran detenidos,
-- este proceso se detendrá de manera permanente, por lo que la señal de reloj volverá
-- a su estado inicial inactivo	y ya no se generarán más ciclos de reloj.


library TDA_1819;	
use TDA_1819.const_reloj.all;


library ieee;
use ieee.NUMERIC_STD.all;
use ieee.std_logic_1164.all;
library std;
use std.TEXTIO.all;



entity reloj is

    port (
		CLK				: out std_logic;
		DoneCompCPU		: in  std_logic;
		StopEnd			: in  std_logic);

end reloj;




architecture reloj_architecture of reloj is		


	
begin	
	
	
	Main: PROCESS
	
	VARIABLE First: BOOLEAN := true;
	
	BEGIN
		if (First) then
			First := false;
			CLK <= '0';
		else
			CLK <= '1' AND DoneCompCPU;
		end if;
		WAIT FOR PERIODO / 2; 
		CLK <= '0';
		WAIT FOR PERIODO / 2;
		if (StopEnd = '1') then
			WAIT;
		end if; 
	END PROCESS Main;
	

end reloj_architecture;