
-- Entidad "ensamblador":
-- Descripción: Aquí se define el ensamblador incluido en la PC para traducir el programa
-- escrito por el usuario en el lenguaje Assembler a un código máquina que pueda ser
-- interpretado y ejecutado por el procesador. También se comprueban errores de sintaxis
-- en el código del programa y se almacena en la memoria principal el código máquina
-- para su posterior ejecución.
-- Procesos:
-- Main: En primer lugar, recibe la señal del usuario para comenzar la tarea de ensamblar 
-- el programa. Luego, procede con el ensamblaje hasta informar, en caso de corresponder, la  
-- correcta finalización del mismo tanto al usuario para que éste tome conocimiento
-- como al procesador para que empiece la ejecución propiamente dicha del programa.
-- Procedimientos y funciones:
-- checkDataBegin(): Comprueba que la primera línea de código escrito por el usuario
-- corresponda efectivamente a la definición del comienzo de la sección de datos 
-- del programa (directiva ".data").
-- isDataType(): Comprueba si cada una de las variables definidas en el programa posee
-- asociado un tipo de datos válido (ascii, entero de 8, 16 ó 32 bits, punto flotante, etc.).
-- saveDataIntDecValue(): Representa en código máquina cada uno de los valores enteros decimales
-- que el usuario haya asignado a las distintas variables del programa y almacena el resultado
-- en la memoria de datos de la PC.
-- saveDataIntHexValue(): Representa en código máquina cada uno de los valores hexadecimales 
-- que el usuario haya asignado a las distintas variables del programa y almacena el resultado en 
-- la memoria de datos de la PC.
-- saveDataIntBinValue(): Representa en código máquina cada uno de los valores binarios que el 
-- usuario haya asignado a las distintas variables del programa y almacena el resultado en la 
-- memoria de datos de la PC.
-- saveDataFloatValue(): Representa en código máquina cada uno de los valores decimales	en punto
-- flotante que el usuario haya asignado a las distintas variables del programa y almacena el 
-- resultado en la memoria de datos de la PC.
-- saveDataAsciiValue(): Representa en código máquina cada uno de los caracteres ASCII que el 
-- usuario haya asignado a las distintas variables del programa y almacena el resultado en la 
-- memoria de datos de la PC.
-- checkData(): Comprueba que ninguna de las líneas de la sección de datos del programa posea 
-- errores de sintaxis.
-- checkCodeBegin(): Comprueba que la primera línea de código escrito por el usuario luego de
-- la sección de datos corresponda efectivamente a la definición del comienzo de la sección de 
-- instrucciones del programa (directiva ".code" o ".text").
-- checkInstTd(): Comprueba si la línea de código que se encuentra actualmente siendo ensamblada
-- corresponde a una instrucción de transferencia de datos. En caso afirmativo, representa en
-- código máquina tanto su respectivo código de operación como sus operandos (registros,
-- direcciones de memoria de datos) y lo almacena en la memoria de instrucciones de la PC.
-- checkInstAr(): Comprueba si la línea de código que se encuentra actualmente siendo ensamblada
-- corresponde a una instrucción aritmética. En caso afirmativo, representa en
-- código máquina tanto su respectivo código de operación como sus operandos (registros,
-- valores inmediatos) y lo almacena en la memoria de instrucciones de la PC.
-- checkInstLD(): Comprueba si la línea de código que se encuentra actualmente siendo ensamblada
-- corresponde a una instrucción lógica o de desplazamiento de bits. En caso afirmativo, 
-- representa en código máquina tanto su respectivo código de operación como sus operandos 
-- (registros, valores inmediatos) y lo almacena en la memoria de instrucciones de la PC.
-- checkInstTc(): Comprueba si la línea de código que se encuentra actualmente siendo ensamblada
-- corresponde a una instrucción de transferencia de control. En caso afirmativo, representa 
-- en código máquina tanto su respectivo código de operación como sus operandos (registros, 
-- direcciones de salto) y lo almacena en la memoria de instrucciones de la PC.
-- checkInstCt(): Comprueba si la línea de código que se encuentra actualmente siendo ensamblada
-- corresponde a una instrucción de control del procesador. En caso afirmativo, representa 
-- en código máquina su respectivo código de operación y lo almacena en la memoria de 
-- instrucciones de la PC.
-- checkCode(): Comprueba que ninguna de las líneas de la sección de instrucciones del programa 
-- posea errores de sintaxis.
-- checkOffsets(): Comprueba que todas las direcciones de salto definidas en las instrucciones de
-- transferencia de datos correspondan efectivamente a etiquetas declaradas en la sección de
-- instrucciones del programa.
-- assembleProgram(): Supervisa la correcta apertura del archivo que contiene el código del
-- programa en el lenguaje Assembler, verificando que dicho fichero se encuentre efectivamente
-- en la dirección especificada por el usuario. Si la tarea fue exitosa, procede con el
-- ensamblaje propiamente dicho del código.


library TDA_1819;
use TDA_1819.func_ensamblador.all;
use TDA_1819.const_memoria.all;
use TDA_1819.const_buses.all;
use TDA_1819.const_ensamblador.all;
use TDA_1819.const_ascii.all;
use TDA_1819.tipos_ensamblador.all; 
use TDA_1819.tipos_cpu.all;
use TDA_1819.tipos_ascii.all;

library ieee;
use ieee.NUMERIC_STD.all;
use ieee.std_logic_1164.all;
library std;
use std.TEXTIO.all;	

library ieee_proposed;
use ieee_proposed.float_pkg.all;

	-- Add your library and packages declaration here ...

entity ensamblador is
	
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
			
end ensamblador;



architecture ENSAMBLADOR_ARCHITECTURE of ensamblador is
	
	-- Component declaration of the tested unit
	
	-- Add your code here ...

begin
	
	-- Add your stimulus here ...
	
	Main: PROCESS	  
	
	
	PROCEDURE checkDataBegin(CONSTANT cadena: IN STRING; CONSTANT length: IN INTEGER; 
							 CONSTANT nombre: IN STRING; CONSTANT num_linea: IN INTEGER) IS
	
	CONSTANT DATA: STRING := ".data";
	VARIABLE i: INTEGER := 1;
	
	BEGIN
		if (cadena(i) /= HT) then
			report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': la identación utilizada es incorrecta"
			severity FAILURE;
		end if;
		i := i + 1;
		while (cadena(i) = HT) loop
			i := i + 1;
		end loop; 
		for j in DATA'RANGE loop
			if (cadena(i) /= DATA(j)) then
				report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': no se encuentra la directiva '.data'"
				severity FAILURE;
			end if;
			i := i + 1;
		end loop;
		while (i <= length) loop 
			if (cadena(i) /= HT) then
				if (cadena(i) = ';') then
					exit;
				else
					report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': los comentarios no se encuentran correctamente declarados"
					severity FAILURE;
				end if;
			end if;
			i := i + 1;
		end loop;
	END checkDataBegin;
	
	
	FUNCTION isDataType(CONSTANT cadena, DATA_NAME: IN STRING; CONSTANT i: IN INTEGER) RETURN INTEGER IS
	
	VARIABLE match: BOOLEAN := true;
	VARIABLE indice: INTEGER := i;
						   
	BEGIN
		for j in DATA_NAME'RANGE loop
			if (DATA_NAME(j) = ' ') then
				exit;
			end if;
			if (cadena(indice) /= DATA_NAME(j)) then
				match := false;
				exit;
			end if;
			indice := indice + 1;
		end loop;
		if (match) then
			if (cadena(indice) /= HT) then
				return -1;
			end if;
			return indice;
		else
			return -1;
		end if;
	END isDataType;
	
	
	PROCEDURE saveDataIntDecValue(CONSTANT variable_rec: IN variable_record; CONSTANT is_minus: IN BOOLEAN;
							   CONSTANT size_aux: IN INTEGER) IS
	
	VARIABLE base10 : INTEGER := 1;
	VARIABLE uValueAux : UNSIGNED(31 downto 0);
	VARIABLE sValueAux : SIGNED(31 downto 0);
	
	BEGIN
		uValueAux := to_unsigned(0, uValueAux'length);
		sValueAux := to_signed(0, sValueAux'length);
		for i in variable_rec.strvaluelength downto 1 loop
			for j in DIGITS_DEC'RANGE loop
				if (variable_rec.strvalue(i) = DIGITS_DEC(j)) then
					if (variable_rec.datatype = IS_UINTEGER) then
						uValueAux := uValueAux + (j-1) * base10;
					elsif (variable_rec.datatype = IS_INTEGER) then
						sValueAux := sValueAux + (j-1) * base10;
					end if;
					exit;
				end if;
			end loop;
			base10 := base10 * 10;
		end loop;
		if (is_minus) then
			sValueAux := -sValueAux;
		end if;
		DataAddrBusComp <= std_logic_vector(to_unsigned(variable_rec.address + variable_rec.size, DataAddrBusComp'length));
		if (variable_rec.datatype = IS_UINTEGER) then
			DataDataBusOutComp <= std_logic_vector(uValueAux);
		elsif (variable_rec.datatype = IS_INTEGER) then
			DataDataBusOutComp <= std_logic_vector(sValueAux);
		end if;
		DataSizeBusComp <= std_logic_vector(to_unsigned(size_aux, DataSizeBusComp'length));
		DataCtrlBusComp <= WRITE_MEMORY;
		EnableCompToDataMem <= '1';
		WAIT FOR 1 ns;
		EnableCompToDataMem <= '0';
		WAIT FOR 1 ns;
	END saveDataIntDecValue;
	
	
	PROCEDURE saveDataIntHexValue(CONSTANT variable_rec: IN variable_record; CONSTANT size_aux: IN INTEGER) IS
	
	VARIABLE valueAux : STD_LOGIC_VECTOR(31 downto 0) := X"00000000";
	VARIABLE i_beg : INTEGER := 3;
	VARIABLE i_end : INTEGER := 0;
	
	BEGIN  
		for i in variable_rec.strvaluelength downto 1 loop
			for j in DIGITS_HEX'RANGE loop
				if (variable_rec.strvalue(i) = DIGITS_HEX(j)) then
					valueAux(i_beg downto i_end) := std_logic_vector(to_unsigned(j-1, 4));
					exit;
				end if;
			end loop;
			i_beg := i_beg + 4;
			i_end := i_end + 4;
		end loop;
		DataAddrBusComp <= std_logic_vector(to_unsigned(variable_rec.address + variable_rec.size, DataAddrBusComp'length));
		DataDataBusOutComp <= valueAux;
		DataSizeBusComp <= std_logic_vector(to_unsigned(size_aux, DataSizeBusComp'length));
		DataCtrlBusComp <= WRITE_MEMORY;
		EnableCompToDataMem <= '1';
		WAIT FOR 1 ns;
		EnableCompToDataMem <= '0';
		WAIT FOR 1 ns;
	END saveDataIntHexValue; 
	
	
	PROCEDURE saveDataIntBinValue(CONSTANT variable_rec: IN variable_record; CONSTANT size_aux: IN INTEGER) IS
	
	VARIABLE valueAux : STD_LOGIC_VECTOR(31 downto 0) := X"00000000";
	VARIABLE bitValueAux: STD_LOGIC_VECTOR(0 downto 0);
	VARIABLE index : INTEGER := 0;
	
	BEGIN
		for i in variable_rec.strvaluelength downto 1 loop
			for j in DIGITS_BIN'RANGE loop
				if (variable_rec.strvalue(i) = DIGITS_BIN(j)) then
					bitValueAux := std_logic_vector(to_unsigned(j-1, bitValueAux'length));
					valueAux(index) := bitValueAux(0);
					exit;
				end if;
			end loop;
			index := index + 1;
		end loop;
		DataAddrBusComp <= std_logic_vector(to_unsigned(variable_rec.address + variable_rec.size, DataAddrBusComp'length));
		DataDataBusOutComp <= valueAux;
		DataSizeBusComp <= std_logic_vector(to_unsigned(size_aux, DataSizeBusComp'length));
		DataCtrlBusComp <= WRITE_MEMORY;
		EnableCompToDataMem <= '1';
		WAIT FOR 1 ns;
		EnableCompToDataMem <= '0';
		WAIT FOR 1 ns;
	END saveDataIntBinValue;
	
	
	PROCEDURE saveDataFloatValue(CONSTANT variable_rec: IN variable_record; 
								 CONSTANT is_minus: IN BOOLEAN; CONSTANT f_aux: IN INTEGER) IS
	
	VARIABLE base10 : float32;
	VARIABLE intValue : float32;
	VARIABLE decValue : float32;
	VARIABLE value : float32;
	
	BEGIN
		intValue := to_float(0, intValue);
		decValue := to_float(0, intValue);
		base10 := to_float(1, intValue);	 
		for i in f_aux-1 downto 1 loop
			for j in DIGITS_DEC'RANGE loop
				if (variable_rec.strvalue(i) = DIGITS_DEC(j)) then
					intValue := intValue + (j-1) * base10;
					exit;
				end if;
			end loop;
			base10 := base10 * 10;
		end loop;
		base10 := to_float(0.1, intValue);
		for i in f_aux+1 to variable_rec.strvaluelength loop
			for j in DIGITS_DEC'RANGE loop
				if (variable_rec.strvalue(i) = DIGITS_DEC(j)) then
					decValue := decValue + (j-1) * base10;
					exit;
				end if;
			end loop;
			base10 := base10 / 10;
		end loop;
		value := intValue + decValue;
		if (is_minus) then
			value := -value;
		end if;
		DataAddrBusComp <= std_logic_vector(to_unsigned(variable_rec.address + variable_rec.size, DataAddrBusComp'length));
		DataDataBusOutComp <= to_Std_Logic_Vector(value);
		DataSizeBusComp <= std_logic_vector(to_unsigned(SIZE_FLOAT, DataSizeBusComp'length));
		DataCtrlBusComp <= WRITE_MEMORY;
		EnableCompToDataMem <= '1';
		WAIT FOR 1 ns;
		EnableCompToDataMem <= '0';
		WAIT FOR 1 ns;
	END saveDataFloatValue;
	
	
	PROCEDURE saveDataAsciiValue(CONSTANT cod_caracter: IN std_logic_vector(7 downto 0); 
								 CONSTANT address, offset: IN INTEGER) IS
	
	BEGIN
		DataAddrBusComp <= std_logic_vector(to_unsigned(address + offset, DataAddrBusComp'length));
		DataDataBusOutComp <= "ZZZZZZZZZZZZZZZZZZZZZZZZ" & cod_caracter;
		DataSizeBusComp <= std_logic_vector(to_unsigned(SIZE_ASCII, DataSizeBusComp'length));
		DataCtrlBusComp <= WRITE_MEMORY;
		EnableCompToDataMem <= '1';
		WAIT FOR 1 ns;
		EnableCompToDataMem <= '0';
		WAIT FOR 1 ns;
	END saveDataAsciiValue;
	
	
	PROCEDURE checkData(variables: INOUT variable_records; CONSTANT cant_variables: IN INTEGER;
						CONSTANT cadena: IN STRING; CONSTANT length: IN INTEGER; 
	                    CONSTANT nombre: IN STRING; CONSTANT num_linea: IN INTEGER) IS
	
	VARIABLE f_aux: INTEGER;
	VARIABLE i_aux: INTEGER;
	VARIABLE i: INTEGER := 1;
	VARIABLE is_minus: BOOLEAN;
	VARIABLE numsystem: INTEGER;
	VARIABLE size_aux: INTEGER;
	 
	BEGIN 
		if (not isLetter(cadena(i))) then
			report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el nombre de la variable no es válido"
			severity FAILURE;
		end if;
		variables(cant_variables).name(i) := cadena(i);
		variables(cant_variables).namelength := 1;
		i := i + 1;
		while (cadena(i) /= ':') loop
			if (not isValidChar(cadena(i))) then
				report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el nombre de la variable no es válido"
				severity FAILURE;
			end if;
			variables(cant_variables).name(i) := cadena(i);
			variables(cant_variables).namelength := variables(cant_variables).namelength + 1;
			i := i + 1;
		end loop;
		i := i + 1;
		while (cadena(i) = HT) loop
			i := i + 1;
		end loop;
		variables(cant_variables).size := 0;
		for j in DATA_NAMES'RANGE loop 
			i_aux := isDataType(cadena, DATA_NAMES(j), i);
			if (i_aux /= -1) then
				if (cant_variables = 1) then
					variables(cant_variables).address := DATA_BEGIN; 
				else
					variables(cant_variables).address := variables(cant_variables-1).address + variables(cant_variables-1).size;
				end if;
				variables(cant_variables).datatype := DATA_TYPES(j);
				if ((DATA_TYPES(j) = IS_INTEGER) or (DATA_TYPES(j) = IS_UINTEGER)) then
					size_aux := DATA_SIZES(j);
				end if;
				exit;
			end if;
		end loop;
		if (i_aux = -1) then
			report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el tipo de dato definido para la variable no es válido"
			severity FAILURE;
		end if;
		i := i_aux;
		while (cadena(i) = HT) loop
			i := i + 1;
		end loop; 
		if ((variables(cant_variables).datatype = IS_INTEGER) OR (variables(cant_variables).datatype = IS_UINTEGER)) then
			if (not isNumberOrMinus(cadena(i))) then
				report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el valor de la variable no es válido"
				severity FAILURE;
			end if;
			if (isMinus(cadena(i))) then 
				if (variables(cant_variables).datatype = IS_UINTEGER) then
					report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': una variable sin signo no puede ser negativa"
					severity FAILURE;
				end if;
				numsystem := IS_DEC;
				is_minus := true;
				i := i + 1;
			elsif (cadena(i) = '0') then
				if (cadena(i+1) = 'd') then
					numsystem := IS_DEC;
					i := i + 2;
				elsif (cadena(i+1) = 'x') then
					numsystem := IS_HEX;
					i := i + 2;
				elsif (cadena(i+1) = 'b') then
					numsystem := IS_BIN;
					i := i + 2;
				elsif (cadena(i+1) /= ' ') then
					report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el sistema de numeración en el cual se encuentra representada la variable no es válido"
					severity FAILURE;
				end if;	 
				is_minus := false;
			else
				numsystem := IS_DEC;
				is_minus := false;
			end if;	
			if (numsystem = IS_DEC) then
				if (not isNumber(cadena(i))) then
					report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el valor de la variable no es válido"
					severity FAILURE;
				end if;
				i_aux := 1;
				variables(cant_variables).strvalue(i_aux) := cadena(i);
				i_aux := i_aux + 1;
				i := i + 1;
				while (isNumber(cadena(i))) loop
					variables(cant_variables).strvalue(i_aux) := cadena(i);	
					i_aux := i_aux + 1;
					i := i + 1;
				end loop;
				variables(cant_variables).strvaluelength := i_aux - 1;
				saveDataIntDecValue(variables(cant_variables), is_minus, size_aux);	
				variables(cant_variables).size := size_aux;
			elsif (numsystem = IS_HEX) then
				if (not isHexadecimal(cadena(i))) then
					report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el valor de la variable no es válido"
					severity FAILURE;
				end if;
				i_aux := 1;
				variables(cant_variables).strvalue(i_aux) := cadena(i);
				i_aux := i_aux + 1;
				i := i + 1;
				while (isHexadecimal(cadena(i))) loop
					variables(cant_variables).strvalue(i_aux) := cadena(i);	
					i_aux := i_aux + 1;
					i := i + 1;
				end loop; 
				variables(cant_variables).strvaluelength := i_aux - 1;
				if (variables(cant_variables).strvaluelength > size_aux*2) then
					report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el valor de la variable no puede ser representado con la cantidad de bits seleccionada"
					severity FAILURE;
				end if;
				saveDataIntHexValue(variables(cant_variables), size_aux);	
				variables(cant_variables).size := size_aux;
			else
				if (not isBinary(cadena(i))) then
					report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el valor de la variable no es válido"
					severity FAILURE;
				end if;
				i_aux := 1;
				variables(cant_variables).strvalue(i_aux) := cadena(i);
				i_aux := i_aux + 1;
				i := i + 1;
				while (isBinary(cadena(i))) loop
					variables(cant_variables).strvalue(i_aux) := cadena(i);	
					i_aux := i_aux + 1;
					i := i + 1;
				end loop;
				variables(cant_variables).strvaluelength := i_aux - 1;
				if (variables(cant_variables).strvaluelength > size_aux*8) then
					report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el valor de la variable no puede ser representado con la cantidad de bits seleccionada"
					severity FAILURE;
				end if;
				saveDataIntBinValue(variables(cant_variables), size_aux);	
				variables(cant_variables).size := size_aux;
			end if;
			while (cadena(i) = ',') loop
				i := i + 1;
				if (cadena(i) /= ' ') then
					report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el vector se encuentra incorrectamente definido"
					severity FAILURE;
				end if;
				i := i + 1;
				if (not isNumberOrMinus(cadena(i))) then
					report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el valor de la variable no es válido"
					severity FAILURE;
				end if;
				if (isMinus(cadena(i))) then 
					if (variables(cant_variables).datatype = IS_UINTEGER) then
						report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': una variable sin signo no puede ser negativa"
						severity FAILURE;
					end if;
					numsystem := IS_DEC;
					is_minus := true;
					i := i + 1;
				elsif (cadena(i) = '0') then
					if (cadena(i+1) = 'd') then
						numsystem := IS_DEC;
						i := i + 2;
					elsif (cadena(i+1) = 'x') then
						numsystem := IS_HEX;
						i := i + 2;
					elsif (cadena(i+1) = 'b') then
						numsystem := IS_BIN;
						i := i + 2;
					elsif (cadena(i+1) /= ' ') then
						report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el sistema de numeración en el cual se encuentra representada la variable no es válido"
						severity FAILURE;
					end if;	 
					is_minus := false;
				else
					numsystem := IS_DEC;
					is_minus := false;
				end if;	
				if (numsystem = IS_DEC) then
					if (not isNumber(cadena(i))) then
						report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el valor de la variable no es válido"
						severity FAILURE;
					end if;
					i_aux := 1;
					variables(cant_variables).strvalue(i_aux) := cadena(i);
					i_aux := i_aux + 1;
					i := i + 1;
					while (isNumber(cadena(i))) loop
						variables(cant_variables).strvalue(i_aux) := cadena(i);	
						i_aux := i_aux + 1;
						i := i + 1;
					end loop;
					variables(cant_variables).strvaluelength := i_aux - 1;
					saveDataIntDecValue(variables(cant_variables), is_minus, size_aux);	
					variables(cant_variables).size := variables(cant_variables).size + size_aux;
				elsif (numsystem = IS_HEX) then
					if (not isHexadecimal(cadena(i))) then
						report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el valor de la variable no es válido"
						severity FAILURE;
					end if;
					i_aux := 1;
					variables(cant_variables).strvalue(i_aux) := cadena(i);
					i_aux := i_aux + 1;
					i := i + 1;
					while (isHexadecimal(cadena(i))) loop
						variables(cant_variables).strvalue(i_aux) := cadena(i);	
						i_aux := i_aux + 1;
						i := i + 1;
					end loop; 
					variables(cant_variables).strvaluelength := i_aux - 1; 
					if (variables(cant_variables).strvaluelength > size_aux*2) then
						report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el valor de la variable no puede ser representado con la cantidad de bits seleccionada"
						severity FAILURE;
					end if;
					saveDataIntHexValue(variables(cant_variables), size_aux);	
					variables(cant_variables).size := variables(cant_variables).size + size_aux;
				else
					if (not isBinary(cadena(i))) then
						report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el valor de la variable no es válido"
						severity FAILURE;
					end if;
					i_aux := 1;
					variables(cant_variables).strvalue(i_aux) := cadena(i);
					i_aux := i_aux + 1;
					i := i + 1;
					while (isBinary(cadena(i))) loop
						variables(cant_variables).strvalue(i_aux) := cadena(i);	
						i_aux := i_aux + 1;
						i := i + 1;
					end loop;
					variables(cant_variables).strvaluelength := i_aux - 1;
					if (variables(cant_variables).strvaluelength > size_aux*8) then
						report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el valor de la variable no puede ser representado con la cantidad de bits seleccionada"
						severity FAILURE;
					end if;
					saveDataIntBinValue(variables(cant_variables), size_aux);	
					variables(cant_variables).size := variables(cant_variables).size + size_aux;
				end if;
			end loop;
		elsif (variables(cant_variables).datatype = IS_FLOAT) then 
			if (not isNumberOrMinus(cadena(i))) then
				report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el valor de la variable no es válido"
				severity FAILURE;
			end if;
			if (isMinus(cadena(i))) then 
				if (variables(cant_variables).datatype = IS_UINTEGER) then
					report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': una variable sin signo no puede ser negativa"
					severity FAILURE;
				end if;
				is_minus := true;
				i := i + 1;
			else
				is_minus := false;
			end if;
			if (not isNumber(cadena(i))) then
				report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el valor de la variable no es válido"
				severity FAILURE;
			end if;
			i_aux := 1;
			variables(cant_variables).strvalue(i_aux) := cadena(i);
			i_aux := i_aux + 1;
			i := i + 1;
			while (isNumber(cadena(i))) loop
				variables(cant_variables).strvalue(i_aux) := cadena(i);	
				i_aux := i_aux + 1;
				i := i + 1;
			end loop;		
			if (cadena(i) /= '.') then
				report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el valor de la variable no es válido"
				severity FAILURE;
			end if;
			f_aux := i_aux;
			variables(cant_variables).strvalue(i_aux) := cadena(i);	
			i_aux := i_aux + 1;
			i := i + 1;
			while (isNumber(cadena(i))) loop
				variables(cant_variables).strvalue(i_aux) := cadena(i);	
				i_aux := i_aux + 1;
				i := i + 1;
			end loop;
			variables(cant_variables).strvaluelength := i_aux - 1;
			saveDataFloatValue(variables(cant_variables), is_minus, f_aux);	
			variables(cant_variables).size := SIZE_FLOAT;
			while (cadena(i) = ',') loop
				i := i + 1;
				if (cadena(i) /= ' ') then
					report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el vector se encuentra incorrectamente definido"
					severity FAILURE;
				end if;
				i := i + 1;
				if (not isNumberOrMinus(cadena(i))) then
					report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el valor de la variable no es válido"
					severity FAILURE;
				end if;
				if (isMinus(cadena(i))) then 
					if (variables(cant_variables).datatype = IS_UINTEGER) then
						report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': una variable sin signo no puede ser negativa"
						severity FAILURE;
					end if;
					is_minus := true;
					i := i + 1;
				else
					is_minus := false;
				end if;
				if (not isNumber(cadena(i))) then
					report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el valor de la variable no es válido"
					severity FAILURE;
				end if;
				i_aux := 1;
				variables(cant_variables).strvalue(i_aux) := cadena(i);
				i_aux := i_aux + 1;
				i := i + 1;
				while (isNumber(cadena(i))) loop
					variables(cant_variables).strvalue(i_aux) := cadena(i);	
					i_aux := i_aux + 1;
					i := i + 1;
				end loop;		
				if (cadena(i) /= '.') then
					report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el valor de la variable no es válido"
					severity FAILURE;
				end if;
				f_aux := i_aux;
				variables(cant_variables).strvalue(i_aux) := cadena(i);	
				i_aux := i_aux + 1;
				i := i + 1;
				while (isNumber(cadena(i))) loop
					variables(cant_variables).strvalue(i_aux) := cadena(i);	
					i_aux := i_aux + 1;
					i := i + 1;
				end loop;
				variables(cant_variables).strvaluelength := i_aux - 1;
				saveDataFloatValue(variables(cant_variables), is_minus, f_aux);	
				variables(cant_variables).size := variables(cant_variables).size + SIZE_FLOAT;
			end loop;
		else  
			if (cadena(i) /= '"') then
				report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el valor de la variable no es válido"
				severity FAILURE;
			end if;
			i := i + 1;
			i_aux := isAscii(cadena(i));
			if (i_aux = -1) then
				report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el valor de la variable no es válido"
				severity FAILURE;
			end if;
			saveDataAsciiValue(COD_CARACTERES(i_aux), variables(cant_variables).address, variables(cant_variables).size);
			variables(cant_variables).size := SIZE_ASCII;
			i := i + 1;
			while (cadena(i) /= '"') loop
				i_aux := isAscii(cadena(i));
				if (isAscii(cadena(i)) = -1) then
					report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el valor de la variable no es válido"
					severity FAILURE;
				end if;
				saveDataAsciiValue(COD_CARACTERES(i_aux), variables(cant_variables).address, variables(cant_variables).size);
				variables(cant_variables).size := variables(cant_variables).size + SIZE_ASCII;
				i := i + 1;
			end loop;
			if (variables(cant_variables).datatype = IS_STRINGZ) then
				saveDataAsciiValue(COD_CERO, variables(cant_variables).address, variables(cant_variables).size);
				variables(cant_variables).size := variables(cant_variables).size + SIZE_ASCII;
			end if;
			i := i + 1;	
			while (cadena(i) = ',') loop
				i := i + 1;
				if (cadena(i) /= ' ') then
					report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el vector se encuentra incorrectamente definido"
					severity FAILURE;
				end if;
				i := i + 1;
				if (cadena(i) /= '"') then
					report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el valor de la variable no es válido"
					severity FAILURE;
				end if;
				i := i + 1;
				i_aux := isAscii(cadena(i));
				if (i_aux = -1) then
					report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el valor de la variable no es válido"
					severity FAILURE;
				end if;
				saveDataAsciiValue(COD_CARACTERES(i_aux), variables(cant_variables).address, variables(cant_variables).size);
				variables(cant_variables).size := variables(cant_variables).size + SIZE_ASCII;
				i := i + 1;
				while (cadena(i) /= '"') loop
					i_aux := isAscii(cadena(i));
					if (isAscii(cadena(i)) = -1) then
						report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el valor de la variable no es válido"
						severity FAILURE;
					end if;
					saveDataAsciiValue(COD_CARACTERES(i_aux), variables(cant_variables).address, variables(cant_variables).size);
					variables(cant_variables).size := variables(cant_variables).size + SIZE_ASCII;
					i := i + 1;
				end loop;
				if (variables(cant_variables).datatype = IS_STRINGZ) then
					saveDataAsciiValue(COD_CERO, variables(cant_variables).address, variables(cant_variables).size);
					variables(cant_variables).size := variables(cant_variables).size + SIZE_ASCII;
				end if;
				i := i + 1;
			end loop;	
		end if;
		while (i <= length) loop 
			if (cadena(i) /= HT) then
				if (cadena(i) = ';') then
					exit;
				else
					report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': los comentarios no se encuentran correctamente declarados"
					severity FAILURE;
				end if;
			end if;
			i := i + 1;
		end loop;
	END checkData; 
	
	
	PROCEDURE checkCodeBegin(CONSTANT cadena: IN STRING; CONSTANT length: IN INTEGER; 
							 CONSTANT nombre: IN STRING; CONSTANT num_linea: IN INTEGER) IS
	
	CONSTANT CODE: STRING := ".code";
	CONSTANT TEXT: STRING := ".text";
	VARIABLE match: BOOLEAN := true;
	VARIABLE i: INTEGER := 1;
	VARIABLE i_aux: INTEGER;
	
	BEGIN
		if (cadena(i) /= HT) then
			report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': la identación utilizada es incorrecta"
			severity FAILURE;
		end if;
		i := i + 1;
		while (cadena(i) = HT) loop
			i := i + 1;
		end loop;
		i_aux := i;
		for j in CODE'RANGE loop
			if (cadena(i_aux) /= CODE(j)) then
				match := false;
				exit;
			end if;
			i_aux := i_aux + 1;
		end loop;
		if (not match) then
			match := true;
			i_aux := i;
			for j in TEXT'RANGE loop
				if (cadena(i_aux) /= TEXT(j)) then
					match := false;
					exit;
				end if;
				i_aux := i_aux + 1;
			end loop;
		end if;
		if (not match) then
			report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': no se encuentra la directiva '.code' o '.text'"
			severity FAILURE;
		end if;
		i := i_aux;
		while (i <= length) loop 
			if (cadena(i) /= HT) then
				if (cadena(i) = ';') then
					exit;
				else
					report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': los comentarios no se encuentran correctamente declarados"
					severity FAILURE;
				end if;
			end if;
			i := i + 1;
		end loop;
	END checkCodeBegin;
	
	
	PROCEDURE checkInstTd(CONSTANT variables: IN variable_records; CONSTANT cant_variables: IN INTEGER;
						  CONSTANT cadena, INSTTD_NAME: IN STRING; CONSTANT INSTTD_CODE: STD_LOGIC_VECTOR(7 downto 0);
						  CONSTANT INSTTD_SIZE: IN INTEGER; i: INOUT INTEGER; check: INOUT BOOLEAN;
						  CONSTANT nombre: IN STRING; CONSTANT num_linea: IN INTEGER; CONSTANT addr_linea: IN INTEGER) IS
	
	VARIABLE match: BOOLEAN := true;
	VARIABLE indice: INTEGER := i;
	VARIABLE i_aux: INTEGER;
	VARIABLE numReg1: INTEGER;
	VARIABLE numReg2: INTEGER;
	VARIABLE addrInm: INTEGER;
	VARIABLE addrReg: INTEGER;
						   
	BEGIN
		for j in INSTTD_NAME'RANGE loop
			if (INSTTD_NAME(j) = ' ') then
				exit;
			end if;
			if (cadena(indice) /= INSTTD_NAME(j)) then
				match := false;
				exit;
			end if;
			indice := indice + 1;
		end loop;
		if (match) then
			if (cadena(indice) /= ' ') then
				check := false;
				return;
			end if;
			while (cadena(indice) = ' ') loop
				indice := indice + 1;
			end loop;
			if (((INSTTD_SIZE = 6) and (INSTTD_NAME(2) /= 'f')) or (INSTTD_NAME = "mrf")) then
				if (cadena(indice) /= 'r') then
					report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el primer operando se encuentra incorrectamente declarado"
					severity FAILURE;
				end if;
				numReg1 := 0;
			else
				if (cadena(indice) /= 'f') then
					report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el primer operando se encuentra incorrectamente declarado"
					severity FAILURE;
				end if;
				numReg1 := CANT_REGISTROS;
			end if;
			indice := indice + 1;
			if (not isNumber(cadena(indice))) then
				report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el primer operando se encuentra incorrectamente declarado"
				severity FAILURE;
			end if;
			for j in DIGITS_DEC'range loop
				if (cadena(indice) = DIGITS_DEC(j)) then
					numReg1 := numReg1 + j-1;
					exit;
				end if;
			end loop;
			indice := indice + 1;
			if (cadena(indice) /= ',') then
				if (cadena(indice-1) /= '1') then
					report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el primer operando se encuentra incorrectamente declarado"
					severity FAILURE;
				end if;
				case cadena(indice) is
					when '0' to '5' =>
						for j in DIGITS_DEC'range loop
							if (cadena(indice) = DIGITS_DEC(j)) then
								if (cadena(indice-2) = 'r') then
									numReg1 := 10 + j-1;
								else
									numReg1 := CANT_REGISTROS + 10 + j-1; 
								end if;
								exit;
							end if;
						end loop;
						indice := indice + 1;
					when others =>
						report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el primer operando se encuentra incorrectamente declarado"
						severity FAILURE;
				end case;
			end if;
			if (cadena(indice) /= ',') then
				report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el primer operando se encuentra incorrectamente declarado"
				severity FAILURE;
			end if;
			indice := indice + 1;
			if (cadena(indice) /= ' ') then
				report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el segundo operando se encuentra incorrectamente declarado"
				severity FAILURE;	
			end if;
			indice := indice + 1; 
			if (INSTTD_SIZE = 6) then
				for j in 1 to cant_variables loop
					match := true;
					i_aux := indice;
					for k in 1 to variables(j).namelength loop
						if (cadena(i_aux) /= variables(j).name(k)) then
							match := false;
							exit;
						end if;
						i_aux := i_aux + 1;
					end loop;
					if (match) then
						addrInm := variables(j).address;
						indice := indice + variables(j).namelength;
						exit;
					end if;
				end loop; 
				--indice := indice + 1;
				if (not match) then
					report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el segundo operando no hace referencia al nombre de ninguna variable válida declarada"
					severity FAILURE;
				end if;
				if (cadena(indice) /= '(') then
					report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el segundo operando se encuentra incorrectamente declarado"
					severity FAILURE;
				end if;
				indice := indice + 1;
				if (cadena(indice) /= 'r') then
					report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el segundo operando se encuentra incorrectamente declarado"
					severity FAILURE;
				end if;
				indice := indice + 1;
				if (not isNumber(cadena(indice))) then
					report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el segundo operando se encuentra incorrectamente declarado"
					severity FAILURE;
				end if;
				for j in DIGITS_DEC'range loop
					if (cadena(indice) = DIGITS_DEC(j)) then
						addrReg := j-1;
						exit;
					end if;
				end loop;
				indice := indice + 1;
				if (cadena(indice) /= ')') then
					if (cadena(indice-1) /= '1') then
						report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el segundo operando se encuentra incorrectamente declarado"
						severity FAILURE;
					end if;
					case cadena(indice) is
						when '0' to '5' =>
							for j in DIGITS_DEC'range loop
								if (cadena(indice) = DIGITS_DEC(j)) then
									addrReg := 10 + j-1;
									exit;
								end if;
							end loop;
							indice := indice + 1;
						when others =>
							report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el segundo operando se encuentra incorrectamente declarado"
							severity FAILURE;
					end case;
				end if;
				if (cadena(indice) /= ')') then
					report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el segundo operando se encuentra incorrectamente declarado"
					severity FAILURE;
				end if;
				indice := indice + 1;
				InstAddrBusComp <= std_logic_vector(to_unsigned(addr_linea, InstAddrBusComp'length));
				InstDataBusOutComp <= std_logic_vector(to_unsigned(INSTTD_SIZE, InstDataBusOutComp'length));
				InstSizeBusComp <= std_logic_vector(to_unsigned(1, InstSizeBusComp'length));
				InstCtrlBusComp <= WRITE_MEMORY; 
				EnableCompToInstMem <= '1';
				WAIT FOR 1 ns;
				EnableCompToInstMem <= '0';	
				WAIT FOR 1 ns;
				InstAddrBusComp <= std_logic_vector(to_unsigned(addr_linea+1, InstAddrBusComp'length));
				InstDataBusOutComp <= "ZZZZZZZZZZZZZZZZZZZZZZZZ" & INSTTD_CODE;
				InstSizeBusComp <= std_logic_vector(to_unsigned(1, InstSizeBusComp'length));
				InstCtrlBusComp <= WRITE_MEMORY;
				EnableCompToInstMem <= '1';
				WAIT FOR 1 ns;
				EnableCompToInstMem <= '0';
				WAIT FOR 1 ns;
				InstAddrBusComp <= std_logic_vector(to_unsigned(addr_linea+2, InstAddrBusComp'length));
				InstDataBusOutComp <= std_logic_vector(to_unsigned(numReg1, InstDataBusOutComp'length));
				InstSizeBusComp <= std_logic_vector(to_unsigned(1, InstSizeBusComp'length));
				InstCtrlBusComp <= WRITE_MEMORY;
				EnableCompToInstMem <= '1';
				WAIT FOR 1 ns;
				EnableCompToInstMem <= '0';	
				WAIT FOR 1 ns;
				InstAddrBusComp <= std_logic_vector(to_unsigned(addr_linea+3, InstAddrBusComp'length));
				InstDataBusOutComp <= std_logic_vector(to_unsigned(addrInm, InstDataBusOutComp'length));
				InstSizeBusComp <= std_logic_vector(to_unsigned(2, InstSizeBusComp'length));
				InstCtrlBusComp <= WRITE_MEMORY;
				EnableCompToInstMem <= '1';
				WAIT FOR 1 ns;
				EnableCompToInstMem <= '0'; 
				WAIT FOR 1 ns;
				InstAddrBusComp <= std_logic_vector(to_unsigned(addr_linea+5, InstAddrBusComp'length));
				InstDataBusOutComp <= std_logic_vector(to_unsigned(addrReg, InstDataBusOutComp'length));
				InstSizeBusComp <= std_logic_vector(to_unsigned(1, InstSizeBusComp'length));
				InstCtrlBusComp <= WRITE_MEMORY;
				EnableCompToInstMem <= '1';
				WAIT FOR 1 ns;
				EnableCompToInstMem <= '0';
				WAIT FOR 1 ns; 
			else
				if (INSTTD_NAME /= "mfr") then
					if (cadena(indice) /= 'f') then
						report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el segundo operando se encuentra incorrectamente declarado"
						severity FAILURE;
					end if;
					numReg2 := CANT_REGISTROS;
				else
					if (cadena(indice) /= 'r') then
						report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el segundo operando se encuentra incorrectamente declarado"
						severity FAILURE;
					end if;
					numReg2 := 0;
				end if;
				indice := indice + 1;
				if (not isNumber(cadena(indice))) then
					report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el segundo operando se encuentra incorrectamente declarado"
					severity FAILURE;
				end if;
				for j in DIGITS_DEC'range loop
					if (cadena(indice) = DIGITS_DEC(j)) then
						numReg2 := numReg2 + j-1;
						exit;
					end if;
				end loop;
				indice := indice + 1;
				if (cadena(indice) /= ' ') then
					if (cadena(indice-1) /= '1') then
						report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el segundo operando se encuentra incorrectamente declarado"
						severity FAILURE;
					end if;
					case cadena(indice) is
						when '0' to '5' =>
							for j in DIGITS_DEC'range loop
								if (cadena(indice) = DIGITS_DEC(j)) then
									if (cadena(indice-2) = 'r') then
										numReg2 := 10 + j-1;
									else
										numReg2 := CANT_REGISTROS + 10 + j-1; 
									end if;
									exit;
								end if;
							end loop;
							indice := indice + 1;
						when others =>
							report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el segundo operando se encuentra incorrectamente declarado"
							severity FAILURE;
					end case; 
				end if;				
				InstAddrBusComp <= std_logic_vector(to_unsigned(addr_linea, InstAddrBusComp'length));
				InstDataBusOutComp <= std_logic_vector(to_unsigned(INSTTD_SIZE, InstDataBusOutComp'length));
				InstSizeBusComp <= std_logic_vector(to_unsigned(1, InstSizeBusComp'length));
				InstCtrlBusComp <= WRITE_MEMORY; 
				EnableCompToInstMem <= '1';
				WAIT FOR 1 ns;
				EnableCompToInstMem <= '0';	
				WAIT FOR 1 ns;
				InstAddrBusComp <= std_logic_vector(to_unsigned(addr_linea+1, InstAddrBusComp'length));
				InstDataBusOutComp <= "ZZZZZZZZZZZZZZZZZZZZZZZZ" & INSTTD_CODE;
				InstSizeBusComp <= std_logic_vector(to_unsigned(1, InstSizeBusComp'length));
				InstCtrlBusComp <= WRITE_MEMORY;
				EnableCompToInstMem <= '1';
				WAIT FOR 1 ns;
				EnableCompToInstMem <= '0';
				WAIT FOR 1 ns;
				InstAddrBusComp <= std_logic_vector(to_unsigned(addr_linea+2, InstAddrBusComp'length));
				InstDataBusOutComp <= std_logic_vector(to_unsigned(numReg1, InstDataBusOutComp'length));
				InstSizeBusComp <= std_logic_vector(to_unsigned(1, InstSizeBusComp'length));
				InstCtrlBusComp <= WRITE_MEMORY;
				EnableCompToInstMem <= '1';
				WAIT FOR 1 ns;
				EnableCompToInstMem <= '0';	
				WAIT FOR 1 ns;
				InstAddrBusComp <= std_logic_vector(to_unsigned(addr_linea+3, InstAddrBusComp'length));
				InstDataBusOutComp <= std_logic_vector(to_unsigned(numReg2, InstDataBusOutComp'length));
				InstSizeBusComp <= std_logic_vector(to_unsigned(1, InstSizeBusComp'length));
				InstCtrlBusComp <= WRITE_MEMORY;
				EnableCompToInstMem <= '1';
				WAIT FOR 1 ns;
				EnableCompToInstMem <= '0'; 
				WAIT FOR 1 ns;
			end if;
			i := indice;
			check := true;
		else
			check := false;
		end if;
	END checkInstTd;
	
	
	PROCEDURE checkInstAr(CONSTANT cadena, INSTAR_NAME: IN STRING; 
						  CONSTANT INSTAR_CODE: STD_LOGIC_VECTOR(7 downto 0); CONSTANT INSTAR_SIZE: IN INTEGER; 
						  i: INOUT INTEGER; check: INOUT BOOLEAN; CONSTANT nombre: IN STRING; 
						  CONSTANT num_linea: IN INTEGER; CONSTANT addr_linea: IN INTEGER) IS
	
	VARIABLE match: BOOLEAN := true;
	VARIABLE indice: INTEGER := i;
	VARIABLE i_aux: INTEGER;
	VARIABLE numReg1: INTEGER;
	VARIABLE numReg2: INTEGER;
	VARIABLE numReg3: INTEGER;
	VARIABLE uNumInm3 : UNSIGNED(31 downto 0);
	VARIABLE sNumInm3 : SIGNED(31 downto 0);
	VARIABLE valueAux : STD_LOGIC_VECTOR(31 downto 0) := X"00000000";
	VARIABLE i_beg : INTEGER := 3;
	VARIABLE i_end : INTEGER := 0;
	VARIABLE bitValueAux: STD_LOGIC_VECTOR(0 downto 0);
	VARIABLE index : INTEGER := 0;
	VARIABLE indInm3: INTEGER; 
	VARIABLE numsystem: INTEGER;
	VARIABLE is_minus: BOOLEAN;
	VARIABLE base10: INTEGER := 1;
						   
	BEGIN
		for j in INSTAR_NAME'RANGE loop 
			if (cadena(indice) /= INSTAR_NAME(j)) then
				match := false;
				exit;
			end if;
			if (INSTAR_NAME(j) = ' ') then
				exit;
			end if;
			indice := indice + 1;
		end loop;
		if (match) then
			if (cadena(indice) /= ' ') then
				check := false;
				return;
			end if;
			while (cadena(indice) = ' ') loop
				indice := indice + 1;
			end loop;
			if ((INSTAR_NAME(4) /= 'f') and (INSTAR_NAME(3) /= 'f')) then
				if (cadena(indice) /= 'r') then
					report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el primer operando se encuentra incorrectamente declarado"
					severity FAILURE;
				end if;
				numReg1 := 0;
			else
				if (cadena(indice) /= 'f') then
					report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el primer operando se encuentra incorrectamente declarado"
					severity FAILURE;
				end if;
				numReg1 := CANT_REGISTROS;
			end if;
			indice := indice + 1;
			if (not isNumber(cadena(indice))) then
				report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el primer operando se encuentra incorrectamente declarado"
				severity FAILURE;
			end if;
			for j in DIGITS_DEC'range loop
				if (cadena(indice) = DIGITS_DEC(j)) then
					numReg1 := numReg1 + j-1;
					exit;
				end if;
			end loop;
			indice := indice + 1;
			if (cadena(indice) /= ',') then
				if (cadena(indice-1) /= '1') then
					report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el primer operando se encuentra incorrectamente declarado"
					severity FAILURE;
				end if;
				case cadena(indice) is
					when '0' to '5' =>
						for j in DIGITS_DEC'range loop
							if (cadena(indice) = DIGITS_DEC(j)) then
								if (cadena(indice-2) = 'r') then
									numReg1 := 10 + j-1;
								else
									numReg1 := CANT_REGISTROS + 10 + j-1; 
								end if;
								exit;
							end if;
						end loop;
						indice := indice + 1;
					when others =>
						report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el primer operando se encuentra incorrectamente declarado"
						severity FAILURE;
				end case;
			end if;
			if (cadena(indice) /= ',') then
				report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el primer operando se encuentra incorrectamente declarado"
				severity FAILURE;
			end if;
			indice := indice + 1;
			if (cadena(indice) /= ' ') then
				report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el segundo operando se encuentra incorrectamente declarado"
				severity FAILURE;	
			end if;
			indice := indice + 1;  
			if ((INSTAR_NAME(4) /= 'f') and (INSTAR_NAME(3) /= 'f')) then
				if (cadena(indice) /= 'r') then
					report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el segundo operando se encuentra incorrectamente declarado"
					severity FAILURE;
				end if;
				numReg2 := 0;
			else
				if (cadena(indice) /= 'f') then	 
					report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el segundo operando se encuentra incorrectamente declarado"
					severity FAILURE;
				end if;
				numReg2 := CANT_REGISTROS;
			end if;
			indice := indice + 1;
			if (not isNumber(cadena(indice))) then
				report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el segundo operando se encuentra incorrectamente declarado"
				severity FAILURE;
			end if;
			for j in DIGITS_DEC'range loop
				if (cadena(indice) = DIGITS_DEC(j)) then
					numReg2 := numReg2 + j-1;
					exit;
				end if;
			end loop;
			indice := indice + 1; 
			if (INSTAR_SIZE /= 4) then
				if (cadena(indice) /= ',') then
					if (cadena(indice-1) /= '1') then
						report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el segundo operando se encuentra incorrectamente declarado"
						severity FAILURE;
					end if;
					case cadena(indice) is
						when '0' to '5' =>
							for j in DIGITS_DEC'range loop
								if (cadena(indice) = DIGITS_DEC(j)) then
									if (cadena(indice-2) = 'r') then
										numReg2 := 10 + j-1;
									else
										numReg2 := CANT_REGISTROS + 10 + j-1; 
									end if;
									exit;
								end if;
							end loop;
							indice := indice + 1;
						when others =>
							report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el segundo operando se encuentra incorrectamente declarado"
							severity FAILURE;
					end case;
				end if;
				if (cadena(indice) /= ',') then
					report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el segundo operando se encuentra incorrectamente declarado"
					severity FAILURE;
				end if;
				indice := indice + 1;
				if (cadena(indice) /= ' ') then
					report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el segundo operando se encuentra incorrectamente declarado"
					severity FAILURE;	
				end if;
				indice := indice + 1;
				if (INSTAR_SIZE = 5) then 
					if (INSTAR_NAME(4) /= 'f') then
						if (cadena(indice) /= 'r') then
							report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el tercer operando se encuentra incorrectamente declarado"
							severity FAILURE;
						end if;
						numReg3 := 0;
					else
						if (cadena(indice) /= 'f') then
							report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el tercer operando se encuentra incorrectamente declarado"
							severity FAILURE;
						end if;
						numReg3 := CANT_REGISTROS;
					end if;
					indice := indice + 1;
					if (not isNumber(cadena(indice))) then
						report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el tercer operando se encuentra incorrectamente declarado"
						severity FAILURE;
					end if;
					for j in DIGITS_DEC'range loop
						if (cadena(indice) = DIGITS_DEC(j)) then
							numReg3 := numReg3 + j-1;
							exit;
						end if;
					end loop;
					indice := indice + 1;
					if (cadena(indice) /= ' ') then
						if (cadena(indice-1) /= '1') then
							report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el tercer operando se encuentra incorrectamente declarado"
							severity FAILURE;
						end if;
						case cadena(indice) is
							when '0' to '5' =>
								for j in DIGITS_DEC'range loop
									if (cadena(indice) = DIGITS_DEC(j)) then
										if (cadena(indice-2) = 'r') then
											numReg3 := 10 + j-1;
										else
											numReg3 := CANT_REGISTROS + 10 + j-1; 
										end if;
										exit;
									end if;
								end loop;
								indice := indice + 1;
							when others =>
								report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el tercer operando se encuentra incorrectamente declarado"
								severity FAILURE;
						end case;
					end if;
					if (cadena(indice) /= ' ') then
						report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el tercer operando se encuentra incorrectamente declarado"
						severity FAILURE;
					end if;
					indice := indice + 1; 
				else  
					if (not isNumberOrMinus(cadena(indice))) then
						report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el tercer operando se encuentra incorrectamente declarado"
						severity FAILURE;
					end if;
					if (isMinus(cadena(indice))) then 
						numsystem := IS_DEC;
						is_minus := true;
						indice := indice + 1;
					elsif (cadena(indice) = '0') then
						if (cadena(indice+1) = 'd') then
							numsystem := IS_DEC;
							indice := indice + 2;
						elsif (cadena(indice+1) = 'x') then
							numsystem := IS_HEX;
							indice := indice + 2;
						elsif (cadena(indice+1) = 'b') then
							numsystem := IS_BIN;
							indice := indice + 2;
						elsif (cadena(indice+1) /= ' ') then
							report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el sistema de numeración del tercer operando no es válido"
							severity FAILURE;
						end if;	 
						is_minus := false;
					else
						numsystem := IS_DEC;
						is_minus := false;
					end if;	
					indInm3 := indice;
					if (numsystem = IS_DEC) then
						if (not isNumber(cadena(indInm3))) then
							report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el tercer operando se encuentra incorrectamente declarado"
							severity FAILURE;
						end if;
						indInm3 := indInm3 + 1;
						while (isNumber(cadena(indInm3))) loop
							indInm3 := indInm3 + 1;
						end loop;
						indInm3 := indInm3 - 1;	
						uNumInm3 := to_unsigned(0, uNumInm3'length);
						sNumInm3 := to_signed(0, sNumInm3'length);
						for j in indInm3 downto indice loop
							for k in DIGITS_DEC'range loop
								if (cadena(j) = DIGITS_DEC(k)) then
									if (INSTAR_NAME = "daddui") then
										uNumInm3 := uNumInm3 + (k-1) * base10;
									else
										sNumInm3 := sNumInm3 + (k-1) * base10;
									end if;	
									exit;
								end if;
							end loop;
							base10 := base10 * 10;
						end loop;
						if (is_minus) then
							sNumInm3 := -sNumInm3;
						end if;
						indice := indInm3 + 1;
					elsif (numsystem = IS_HEX) then
						if (not isHexadecimal(cadena(indInm3))) then
							report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el tercer operando se encuentra incorrectamente declarado"
							severity FAILURE;
						end if;
						indInm3 := indInm3 + 1;
						while (isHexadecimal(cadena(indInm3))) loop	
							indInm3 := indInm3 + 1;
						end loop;
						indInm3 := indInm3 - 1;
						if (indInm3-indice > 7) then 
							report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el valor del tercer operando no puede ser representado con la cantidad de bits seleccionada"
							severity FAILURE;
						end if;
						for j in indInm3 downto indice loop
							for k in DIGITS_HEX'RANGE loop
								if (cadena(j) = DIGITS_HEX(k)) then
									valueAux(i_beg downto i_end) := std_logic_vector(to_unsigned(k-1, 4));
									exit;
								end if;
							end loop;
							i_beg := i_beg + 4;
							i_end := i_end + 4;
						end loop;
						indice := indInm3 + 1;
					else
						if (not isBinary(cadena(indInm3))) then
							report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el tercer operando se encuentra incorrectamente declarado"
							severity FAILURE;
						end if;
						indInm3 := indInm3 + 1;
						while (isBinary(cadena(indInm3))) loop
							indInm3 := indInm3 + 1;
						end loop;
						indInm3 := indInm3 - 1;
						if (indInm3-indice > 31) then
							report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el valor del tercer operando no puede ser representado con la cantidad de bits seleccionada"
							severity FAILURE;
						end if;
						for j in indInm3 downto indice loop
							for k in DIGITS_BIN'RANGE loop
								if (cadena(j) = DIGITS_BIN(k)) then
									bitValueAux := std_logic_vector(to_unsigned(k-1, bitValueAux'length));
									valueAux(index) := bitValueAux(0);
									exit;
								end if;
							end loop;
							index := index + 1;
						end loop;
						indice := indInm3 + 1;
					end if;
				end if;
			else
				if (cadena(indice) /= ' ') then
					if (cadena(indice-1) /= '1') then
						report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el segundo operando se encuentra incorrectamente declarado"
						severity FAILURE;
					end if;
					case cadena(indice) is
						when '0' to '5' =>
							for j in DIGITS_DEC'range loop
								if (cadena(indice) = DIGITS_DEC(j)) then
									if (cadena(indice-2) = 'r') then
										numReg2 := 10 + j-1;
									else
										numReg2 := CANT_REGISTROS + 10 + j-1; 
									end if;
									exit;
								end if;
							end loop;
							indice := indice + 1;
						when others =>
							report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el segundo operando se encuentra incorrectamente declarado"
							severity FAILURE;
					end case;
				end if;
			end if;
			InstAddrBusComp <= std_logic_vector(to_unsigned(addr_linea, InstAddrBusComp'length));
			InstDataBusOutComp <= std_logic_vector(to_unsigned(INSTAR_SIZE, InstDataBusOutComp'length));
			InstSizeBusComp <= std_logic_vector(to_unsigned(1, InstSizeBusComp'length));
			InstCtrlBusComp <= WRITE_MEMORY;
			EnableCompToInstMem <= '1';
			WAIT FOR 1 ns;
			EnableCompToInstMem <= '0';	 
			WAIT FOR 1 ns;
			InstAddrBusComp <= std_logic_vector(to_unsigned(addr_linea+1, InstAddrBusComp'length));
			InstDataBusOutComp <= "ZZZZZZZZZZZZZZZZZZZZZZZZ" & INSTAR_CODE;
			InstSizeBusComp <= std_logic_vector(to_unsigned(1, InstSizeBusComp'length));
			InstCtrlBusComp <= WRITE_MEMORY;
			EnableCompToInstMem <= '1';
			WAIT FOR 1 ns;
			EnableCompToInstMem <= '0';	 
			WAIT FOR 1 ns;
			InstAddrBusComp <= std_logic_vector(to_unsigned(addr_linea+2, InstAddrBusComp'length));
			InstDataBusOutComp <= std_logic_vector(to_unsigned(numReg1, InstDataBusOutComp'length));
			InstSizeBusComp <= std_logic_vector(to_unsigned(1, InstSizeBusComp'length));
			InstCtrlBusComp <= WRITE_MEMORY;
			EnableCompToInstMem <= '1';
			WAIT FOR 1 ns;
			EnableCompToInstMem <= '0';	
			WAIT FOR 1 ns;
			InstAddrBusComp <= std_logic_vector(to_unsigned(addr_linea+3, InstAddrBusComp'length));
			InstDataBusOutComp <= std_logic_vector(to_unsigned(numReg2, InstDataBusOutComp'length));
			InstSizeBusComp <= std_logic_vector(to_unsigned(1, InstSizeBusComp'length));
			InstCtrlBusComp <= WRITE_MEMORY;
			EnableCompToInstMem <= '1';
			WAIT FOR 1 ns;
			EnableCompToInstMem <= '0';	 
			WAIT FOR 1 ns;	
			if (INSTAR_SIZE /= 4) then
				InstAddrBusComp <= std_logic_vector(to_unsigned(addr_linea+4, InstAddrBusComp'length));
				if (INSTAR_SIZE = 5) then
					InstDataBusOutComp <= std_logic_vector(to_unsigned(numReg3, InstDataBusOutComp'length));
					InstSizeBusComp <= std_logic_vector(to_unsigned(1, InstSizeBusComp'length));
				else
					if (numsystem = IS_DEC) then
						if (INSTAR_NAME = "daddui") then
							InstDataBusOutComp <= std_logic_vector(uNumInm3);
						else
							InstDataBusOutComp <= std_logic_vector(sNumInm3);
						end if;	 
					else
						InstDataBusOutComp <= valueAux;
					end if;
					InstSizeBusComp <= std_logic_vector(to_unsigned(4, InstSizeBusComp'length));
				end if;
				InstCtrlBusComp <= WRITE_MEMORY; 
				EnableCompToInstMem <= '1';
				WAIT FOR 1 ns;
				EnableCompToInstMem <= '0';	
				WAIT FOR 1 ns; 
			end if;
			i := indice;
			check := true;
		else
			check := false;
		end if;
	END checkInstAr;
	
	
	PROCEDURE checkInstLD(CONSTANT cadena, INSTLD_NAME: IN STRING; 
						  CONSTANT INSTLD_CODE: STD_LOGIC_VECTOR(7 downto 0); CONSTANT INSTLD_SIZE: IN INTEGER; 
						  i: INOUT INTEGER; check: INOUT BOOLEAN; CONSTANT nombre: IN STRING; 
						  CONSTANT num_linea: IN INTEGER; CONSTANT addr_linea: IN INTEGER) IS
	
	VARIABLE match: BOOLEAN := true;
	VARIABLE indice: INTEGER := i;
	VARIABLE i_aux: INTEGER;
	VARIABLE numReg1: INTEGER;
	VARIABLE numReg2: INTEGER;
	VARIABLE numReg3: INTEGER;
	VARIABLE uNumInm3 : UNSIGNED(31 downto 0);
	VARIABLE valueAux : STD_LOGIC_VECTOR(31 downto 0) := X"00000000";
	VARIABLE i_beg : INTEGER := 3;
	VARIABLE i_end : INTEGER := 0;
	VARIABLE bitValueAux: STD_LOGIC_VECTOR(0 downto 0);
	VARIABLE index : INTEGER := 0;
	VARIABLE indInm3: INTEGER; 
	VARIABLE numsystem: INTEGER;
	VARIABLE base10: INTEGER := 1;
						   
	BEGIN
		for j in INSTLD_NAME'RANGE loop 
			if (cadena(indice) /= INSTLD_NAME(j)) then
				match := false;
				exit;
			end if;
			if (INSTLD_NAME(j) = ' ') then
				exit;
			end if;
			indice := indice + 1;
		end loop;
		if (match) then
			if (cadena(indice) /= ' ') then
				check := false;
				return;
			end if;
			while (cadena(indice) = ' ') loop
				indice := indice + 1;
			end loop;
			if (cadena(indice) /= 'r') then
				report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el primer operando se encuentra incorrectamente declarado"
				severity FAILURE;
			end if;
			numReg1 := 0;
			indice := indice + 1;
			if (not isNumber(cadena(indice))) then
				report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el primer operando se encuentra incorrectamente declarado"
				severity FAILURE;
			end if;
			for j in DIGITS_DEC'range loop
				if (cadena(indice) = DIGITS_DEC(j)) then
					numReg1 := numReg1 + j-1;
					exit;
				end if;
			end loop;
			indice := indice + 1;
			if (cadena(indice) /= ',') then
				if (cadena(indice-1) /= '1') then
					report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el primer operando se encuentra incorrectamente declarado"
					severity FAILURE;
				end if;
				case cadena(indice) is
					when '0' to '5' =>
						for j in DIGITS_DEC'range loop
							if (cadena(indice) = DIGITS_DEC(j)) then
								numReg1 := 10 + j-1;
								exit;
							end if;
						end loop;
						indice := indice + 1;
					when others =>
						report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el primer operando se encuentra incorrectamente declarado"
						severity FAILURE;
				end case;
			end if;
			if (cadena(indice) /= ',') then
				report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el primer operando se encuentra incorrectamente declarado"
				severity FAILURE;
			end if;
			indice := indice + 1;
			if (cadena(indice) /= ' ') then
				report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el segundo operando se encuentra incorrectamente declarado"
				severity FAILURE;	
			end if;
			indice := indice + 1;  
			if (cadena(indice) /= 'r') then
				report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el segundo operando se encuentra incorrectamente declarado"
				severity FAILURE;
			end if;
			numReg2 := 0;
			indice := indice + 1;
			if (not isNumber(cadena(indice))) then
				report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el segundo operando se encuentra incorrectamente declarado"
				severity FAILURE;
			end if;
			for j in DIGITS_DEC'range loop
				if (cadena(indice) = DIGITS_DEC(j)) then
					numReg2 := numReg2 + j-1;
					exit;
				end if;
			end loop;
			indice := indice + 1; 
			if (INSTLD_SIZE /= 4) then
				if (cadena(indice) /= ',') then
					if (cadena(indice-1) /= '1') then
						report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el segundo operando se encuentra incorrectamente declarado"
						severity FAILURE;
					end if;
					case cadena(indice) is
						when '0' to '5' =>
							for j in DIGITS_DEC'range loop
								if (cadena(indice) = DIGITS_DEC(j)) then
									numReg2 := 10 + j-1;
									exit;
								end if;
							end loop;
							indice := indice + 1;
						when others =>
							report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el segundo operando se encuentra incorrectamente declarado"
							severity FAILURE;
					end case;
				end if;
				if (cadena(indice) /= ',') then
					report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el segundo operando se encuentra incorrectamente declarado"
					severity FAILURE;
				end if;
				indice := indice + 1;
				if (cadena(indice) /= ' ') then
					report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el segundo operando se encuentra incorrectamente declarado"
					severity FAILURE;	
				end if;
				indice := indice + 1;
				if (INSTLD_SIZE = 5) then 
					if (cadena(indice) /= 'r') then
						report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el tercer operando se encuentra incorrectamente declarado"
						severity FAILURE;
					end if;
					numReg3 := 0;
					indice := indice + 1;
					if (not isNumber(cadena(indice))) then
						report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el tercer operando se encuentra incorrectamente declarado"
						severity FAILURE;
					end if;
					for j in DIGITS_DEC'range loop
						if (cadena(indice) = DIGITS_DEC(j)) then
							numReg3 := numReg3 + j-1;
							exit;
						end if;
					end loop;
					indice := indice + 1;
					if (cadena(indice) /= ' ') then
						if (cadena(indice-1) /= '1') then
							report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el tercer operando se encuentra incorrectamente declarado"
							severity FAILURE;
						end if;
						case cadena(indice) is
							when '0' to '5' =>
								for j in DIGITS_DEC'range loop
									if (cadena(indice) = DIGITS_DEC(j)) then
										numReg3 := 10 + j-1;
										exit;
									end if;
								end loop;
								indice := indice + 1;
							when others =>
								report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el tercer operando se encuentra incorrectamente declarado"
								severity FAILURE;
						end case;
					end if;
					if (cadena(indice) /= ' ') then
						report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el tercer operando se encuentra incorrectamente declarado"
						severity FAILURE;
					end if;
					indice := indice + 1; 
				else  
					if (not isNumber(cadena(indice))) then
						report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el tercer operando se encuentra incorrectamente declarado"
						severity FAILURE;
					end if;
					if (cadena(indice) = '0') then
						if (cadena(indice+1) = 'd') then
							numsystem := IS_DEC;
							indice := indice + 2;
						elsif (cadena(indice+1) = 'x') then
							numsystem := IS_HEX;
							indice := indice + 2;
						elsif (cadena(indice+1) = 'b') then
							numsystem := IS_BIN;
							indice := indice + 2;
						elsif (cadena(indice+1) /= ' ') then
							report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el sistema de numeración del tercer operando no es válido"
							severity FAILURE;
						end if;	 
					else
						numsystem := IS_DEC;
					end if;	
					indInm3 := indice;
					if (numsystem = IS_DEC) then
						if (not isNumber(cadena(indInm3))) then
							report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el tercer operando se encuentra incorrectamente declarado"
							severity FAILURE;
						end if;
						indInm3 := indInm3 + 1;
						while (isNumber(cadena(indInm3))) loop
							indInm3 := indInm3 + 1;
						end loop;
						indInm3 := indInm3 - 1;	
						uNumInm3 := to_unsigned(0, uNumInm3'length);
						for j in indInm3 downto indice loop
							for k in DIGITS_DEC'range loop
								if (cadena(j) = DIGITS_DEC(k)) then
									uNumInm3 := uNumInm3 + (k-1) * base10;
									exit;
								end if;
							end loop;
							base10 := base10 * 10;
						end loop;
						indice := indInm3 + 1;
					elsif (numsystem = IS_HEX) then
						if (not isHexadecimal(cadena(indInm3))) then
							report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el tercer operando se encuentra incorrectamente declarado"
							severity FAILURE;
						end if;
						indInm3 := indInm3 + 1;
						while (isHexadecimal(cadena(indInm3))) loop	
							indInm3 := indInm3 + 1;
						end loop;
						indInm3 := indInm3 - 1;
						if (indInm3-indice > 7) then 
							report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el valor del tercer operando no puede ser representado con la cantidad de bits seleccionada"
							severity FAILURE;
						end if;
						for j in indInm3 downto indice loop
							for k in DIGITS_HEX'RANGE loop
								if (cadena(j) = DIGITS_HEX(k)) then
									valueAux(i_beg downto i_end) := std_logic_vector(to_unsigned(k-1, 4));
									exit;
								end if;
							end loop;
							i_beg := i_beg + 4;
							i_end := i_end + 4;
						end loop;
						indice := indInm3 + 1;
					else
						if (not isBinary(cadena(indInm3))) then
							report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el tercer operando se encuentra incorrectamente declarado"
							severity FAILURE;
						end if;
						indInm3 := indInm3 + 1;
						while (isBinary(cadena(indInm3))) loop
							indInm3 := indInm3 + 1;
						end loop;
						indInm3 := indInm3 - 1;
						if (indInm3-indice > 31) then
							report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el valor del tercer operando no puede ser representado con la cantidad de bits seleccionada"
							severity FAILURE;
						end if;
						for j in indInm3 downto indice loop
							for k in DIGITS_BIN'RANGE loop
								if (cadena(j) = DIGITS_BIN(k)) then
									bitValueAux := std_logic_vector(to_unsigned(k-1, bitValueAux'length));
									valueAux(index) := bitValueAux(0);
									exit;
								end if;
							end loop;
							index := index + 1;
						end loop;
						indice := indInm3 + 1;
					end if;
				end if;
			else
				if (cadena(indice) /= ' ') then
					if (cadena(indice-1) /= '1') then
						report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el segundo operando se encuentra incorrectamente declarado"
						severity FAILURE;
					end if;
					case cadena(indice) is
						when '0' to '5' =>
							for j in DIGITS_DEC'range loop
								if (cadena(indice) = DIGITS_DEC(j)) then
									numReg2 := 10 + j-1;
									exit;
								end if;
							end loop;
							indice := indice + 1;
						when others =>
							report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el segundo operando se encuentra incorrectamente declarado"
							severity FAILURE;
					end case;
				end if;
			end if;
			InstAddrBusComp <= std_logic_vector(to_unsigned(addr_linea, InstAddrBusComp'length));
			InstDataBusOutComp <= std_logic_vector(to_unsigned(INSTLD_SIZE, InstDataBusOutComp'length));
			InstSizeBusComp <= std_logic_vector(to_unsigned(1, InstSizeBusComp'length));
			InstCtrlBusComp <= WRITE_MEMORY;
			EnableCompToInstMem <= '1';
			WAIT FOR 1 ns;
			EnableCompToInstMem <= '0';	 
			WAIT FOR 1 ns;
			InstAddrBusComp <= std_logic_vector(to_unsigned(addr_linea+1, InstAddrBusComp'length));
			InstDataBusOutComp <= "ZZZZZZZZZZZZZZZZZZZZZZZZ" & INSTLD_CODE;
			InstSizeBusComp <= std_logic_vector(to_unsigned(1, InstSizeBusComp'length));
			InstCtrlBusComp <= WRITE_MEMORY;
			EnableCompToInstMem <= '1';
			WAIT FOR 1 ns;
			EnableCompToInstMem <= '0';	 
			WAIT FOR 1 ns;
			InstAddrBusComp <= std_logic_vector(to_unsigned(addr_linea+2, InstAddrBusComp'length));
			InstDataBusOutComp <= std_logic_vector(to_unsigned(numReg1, InstDataBusOutComp'length));
			InstSizeBusComp <= std_logic_vector(to_unsigned(1, InstSizeBusComp'length));
			InstCtrlBusComp <= WRITE_MEMORY;
			EnableCompToInstMem <= '1';
			WAIT FOR 1 ns;
			EnableCompToInstMem <= '0';	
			WAIT FOR 1 ns;
			InstAddrBusComp <= std_logic_vector(to_unsigned(addr_linea+3, InstAddrBusComp'length));
			InstDataBusOutComp <= std_logic_vector(to_unsigned(numReg2, InstDataBusOutComp'length));
			InstSizeBusComp <= std_logic_vector(to_unsigned(1, InstSizeBusComp'length));
			InstCtrlBusComp <= WRITE_MEMORY;
			EnableCompToInstMem <= '1';
			WAIT FOR 1 ns;
			EnableCompToInstMem <= '0';	 
			WAIT FOR 1 ns;	
			if (INSTLD_SIZE /= 4) then
				InstAddrBusComp <= std_logic_vector(to_unsigned(addr_linea+4, InstAddrBusComp'length));
				if (INSTLD_SIZE = 5) then
					InstDataBusOutComp <= std_logic_vector(to_unsigned(numReg3, InstDataBusOutComp'length));
					InstSizeBusComp <= std_logic_vector(to_unsigned(1, InstSizeBusComp'length));
				else
					if (numsystem = IS_DEC) then
						InstDataBusOutComp <= std_logic_vector(uNumInm3);	 
					else
						InstDataBusOutComp <= valueAux;
					end if;
					InstSizeBusComp <= std_logic_vector(to_unsigned(4, InstSizeBusComp'length));
				end if;
				InstCtrlBusComp <= WRITE_MEMORY; 
				EnableCompToInstMem <= '1';
				WAIT FOR 1 ns;
				EnableCompToInstMem <= '0';	
				WAIT FOR 1 ns; 
			end if;
			i := indice;
			check := true;
		else
			check := false;
		end if;
	END checkInstLD;
	
	
	PROCEDURE checkInstTc(offsets: INOUT offset_records; cant_offsets: INOUT INTEGER;
						  CONSTANT cadena, INSTTC_NAME: IN STRING; CONSTANT INSTTC_CODE: STD_LOGIC_VECTOR(7 downto 0);
						  CONSTANT INSTTC_SIZE: IN INTEGER; i: INOUT INTEGER; check: INOUT BOOLEAN;
						  CONSTANT nombre: IN STRING; CONSTANT num_linea: IN INTEGER; CONSTANT addr_linea: IN INTEGER) IS
	
	VARIABLE match: BOOLEAN := true;
	VARIABLE indice: INTEGER := i;
	VARIABLE i_aux: INTEGER;
	VARIABLE numReg1: INTEGER;
	VARIABLE numReg2: INTEGER;
						   
	BEGIN
		for j in INSTTC_NAME'RANGE loop
			if (INSTTC_NAME(j) = ' ') then
				exit;
			end if;
			if (cadena(indice) /= INSTTC_NAME(j)) then
				match := false;
				exit;
			end if;
			indice := indice + 1;
		end loop;
		if (match) then
			if (cadena(indice) /= ' ') then
				check := false;
				return;
			end if;
			indice := indice + 1;
			if (cadena(indice) = ' ') then
				check := false;
				return;
			end if;
			while (cadena(indice) = ' ') loop
				indice := indice + 1;
			end loop;
			if (INSTTC_SIZE /= 4) then
				if (cadena(indice) /= 'r') then
					report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el primer operando se encuentra incorrectamente declarado"
					severity FAILURE;
				end if;
				indice := indice + 1;
				if (not isNumber(cadena(indice))) then
					report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el primer operando se encuentra incorrectamente declarado"
					severity FAILURE;
				end if;
				for j in DIGITS_DEC'range loop
					if (cadena(indice) = DIGITS_DEC(j)) then
						numReg1 := j-1;
						exit;
					end if;
				end loop;
				indice := indice + 1;
				if (cadena(indice) /= ',') then
					if (cadena(indice-1) /= '1') then
						report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el primer operando se encuentra incorrectamente declarado"
						severity FAILURE;
					end if;
					case cadena(indice) is
						when '0' to '5' =>
							for j in DIGITS_DEC'range loop
								if (cadena(indice) = DIGITS_DEC(j)) then
									numReg1 := 10 + j-1;
									exit;
								end if;
							end loop;
							indice := indice + 1;
						when others =>
							report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el primer operando se encuentra incorrectamente declarado"
							severity FAILURE;
					end case;
				end if;
				if (cadena(indice) /= ',') then
					report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el primer operando se encuentra incorrectamente declarado"
					severity FAILURE;
				end if;
				indice := indice + 1;
				if (INSTTC_SIZE = 6) then
					if (cadena(indice) /= ' ') then
						report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el segundo operando se encuentra incorrectamente declarado"
						severity FAILURE;	
					end if;
					indice := indice + 1;
					if (cadena(indice) /= 'r') then
						report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el segundo operando se encuentra incorrectamente declarado"
						severity FAILURE;
					end if;
					indice := indice + 1;
					if (not isNumber(cadena(indice))) then
						report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el segundo operando se encuentra incorrectamente declarado"
						severity FAILURE;
					end if;
					for j in DIGITS_DEC'range loop
						if (cadena(indice) = DIGITS_DEC(j)) then
							numReg2 := j-1;
							exit;
						end if;
					end loop;
					indice := indice + 1;
					if (cadena(indice) /= ',') then
						if (cadena(indice-1) /= '1') then
							report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el segundo operando se encuentra incorrectamente declarado"
							severity FAILURE;
						end if;
						case cadena(indice) is
							when '0' to '5' =>
								for j in DIGITS_DEC'range loop
									if (cadena(indice) = DIGITS_DEC(j)) then
										numReg2 := 10 + j-1;
										exit;
									end if;
								end loop;
								indice := indice + 1;
							when others =>
								report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el segundo operando se encuentra incorrectamente declarado"
								severity FAILURE;
						end case;
					end if;
					if (cadena(indice) /= ',') then
						report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el segundo operando se encuentra incorrectamente declarado"
						severity FAILURE;
					end if;
					indice := indice + 1;
				end if;
			else 
				indice := indice - 1;
			end if;
			if (cadena(indice) /= ' ') then
				report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': la dirección de salto se encuentra incorrectamente declarada"
				severity FAILURE;	
			end if;
			indice := indice + 1;
			cant_offsets := cant_offsets + 1;
			if (not isLetter(cadena(indice))) then
				report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': la dirección de salto no es válida"
				severity FAILURE;
			end if;
			if (INSTTC_NAME = "jmp ") then
				offsets(cant_offsets).isJmp := true;
			else
				offsets(cant_offsets).isJmp := false;
			end if;
			offsets(cant_offsets).namelength := 1;
			offsets(cant_offsets).name(offsets(cant_offsets).namelength) := cadena(indice);
			indice := indice + 1;
			while (isValidChar(cadena(indice))) loop
				offsets(cant_offsets).namelength := offsets(cant_offsets).namelength + 1;
				offsets(cant_offsets).name(offsets(cant_offsets).namelength) := cadena(indice);
				indice := indice + 1;
			end loop;
			InstAddrBusComp <= std_logic_vector(to_unsigned(addr_linea, InstAddrBusComp'length));
			InstDataBusOutComp <= std_logic_vector(to_unsigned(INSTTC_SIZE, InstDataBusOutComp'length));
			InstSizeBusComp <= std_logic_vector(to_unsigned(1, InstSizeBusComp'length));
			InstCtrlBusComp <= WRITE_MEMORY;
			EnableCompToInstMem <= '1';
			WAIT FOR 1 ns;
			EnableCompToInstMem <= '0';	
			WAIT FOR 1 ns;
			InstAddrBusComp <= std_logic_vector(to_unsigned(addr_linea+1, InstAddrBusComp'length));
			InstDataBusOutComp <= "ZZZZZZZZZZZZZZZZZZZZZZZZ" & INSTTC_CODE;
			InstSizeBusComp <= std_logic_vector(to_unsigned(1, InstSizeBusComp'length));
			InstCtrlBusComp <= WRITE_MEMORY;
			EnableCompToInstMem <= '1';
			WAIT FOR 1 ns;
			EnableCompToInstMem <= '0';	
			WAIT FOR 1 ns;
			offsets(cant_offsets).num_linea := num_linea;
			if (INSTTC_SIZE = 4) then
				offsets(cant_offsets).address := addr_linea+2;
			elsif (INSTTC_SIZE = 5) then
				offsets(cant_offsets).address := addr_linea+3;
				InstAddrBusComp <= std_logic_vector(to_unsigned(addr_linea+2, InstAddrBusComp'length));
				InstDataBusOutComp <= std_logic_vector(to_unsigned(numReg1, InstDataBusOutComp'length));
				InstSizeBusComp <= std_logic_vector(to_unsigned(1, InstSizeBusComp'length));
				InstCtrlBusComp <= WRITE_MEMORY; 
				EnableCompToInstMem <= '1';
				WAIT FOR 1 ns;
				EnableCompToInstMem <= '0';
				WAIT FOR 1 ns;
			elsif (INSTTC_SIZE = 6) then
				offsets(cant_offsets).address := addr_linea+4;
				InstAddrBusComp <= std_logic_vector(to_unsigned(addr_linea+2, InstAddrBusComp'length));
				InstDataBusOutComp <= std_logic_vector(to_unsigned(numReg1, InstDataBusOutComp'length));
				InstSizeBusComp <= std_logic_vector(to_unsigned(1, InstSizeBusComp'length));
				InstCtrlBusComp <= WRITE_MEMORY;
				EnableCompToInstMem <= '1';
				WAIT FOR 1 ns;
				EnableCompToInstMem <= '0';
				WAIT FOR 1 ns;
				InstAddrBusComp <= std_logic_vector(to_unsigned(addr_linea+3, InstAddrBusComp'length));
				InstDataBusOutComp <= std_logic_vector(to_unsigned(numReg2, InstDataBusOutComp'length));
				InstSizeBusComp <= std_logic_vector(to_unsigned(1, InstSizeBusComp'length));
				InstCtrlBusComp <= WRITE_MEMORY;
				EnableCompToInstMem <= '1';
				WAIT FOR 1 ns;
				EnableCompToInstMem <= '0';
				WAIT FOR 1 ns;
			end if; 
			i := indice;
			check := true;
		else
			check := false;
		end if;
	END checkInstTc;
	
	
	PROCEDURE checkInstCt(CONSTANT cadena, INSTCT_NAME: IN STRING; CONSTANT INSTCT_CODE: STD_LOGIC_VECTOR(7 downto 0);
						  CONSTANT INSTCT_SIZE: IN INTEGER; i: INOUT INTEGER; check: INOUT BOOLEAN;	
						  is_halt: INOUT BOOLEAN; CONSTANT addr_linea: IN INTEGER) IS
	
	VARIABLE match: BOOLEAN := true;
	VARIABLE indice: INTEGER := i;
	VARIABLE i_aux: INTEGER;
	VARIABLE numReg1: INTEGER;
	VARIABLE numReg2: INTEGER;
						   
	BEGIN
		for j in INSTCT_NAME'RANGE loop
			if (INSTCT_NAME(j) = ' ') then
				exit;
			end if;
			if (cadena(indice) /= INSTCT_NAME(j)) then
				match := false;
				exit;
			end if;
			indice := indice + 1;
		end loop;
		if (match) then	
			if (INSTCT_NAME = "halt") then
				is_halt := true;
			end if;
			InstAddrBusComp <= std_logic_vector(to_unsigned(addr_linea, InstAddrBusComp'length));
			InstDataBusOutComp <= std_logic_vector(to_unsigned(INSTCT_SIZE, InstDataBusOutComp'length));
			InstSizeBusComp <= std_logic_vector(to_unsigned(1, InstSizeBusComp'length));
			InstCtrlBusComp <= WRITE_MEMORY;
			EnableCompToInstMem <= '1';
			WAIT FOR 1 ns;
			EnableCompToInstMem <= '0';	
			WAIT FOR 1 ns;
			InstAddrBusComp <= std_logic_vector(to_unsigned(addr_linea+1, InstAddrBusComp'length));
			InstDataBusOutComp <= "ZZZZZZZZZZZZZZZZZZZZZZZZ" & INSTCT_CODE;
			InstSizeBusComp <= std_logic_vector(to_unsigned(1, InstSizeBusComp'length));
			InstCtrlBusComp <= WRITE_MEMORY;
			EnableCompToInstMem <= '1';
			WAIT FOR 1 ns;
			EnableCompToInstMem <= '0';
			WAIT FOR 1 ns;
			i := indice;
			check := true;
		else
			check := false;
		end if;
	END checkInstCt;
	
	
	PROCEDURE checkCode(labels: INOUT label_records; cant_labels: INOUT INTEGER;
						offsets: INOUT offset_records; cant_offsets: INOUT INTEGER;
						CONSTANT variables: IN variable_records; CONSTANT cant_variables: IN INTEGER;
						CONSTANT cadena: IN STRING; CONSTANT length: IN INTEGER; 
	                    CONSTANT nombre: IN STRING; CONSTANT num_linea: IN INTEGER; 
						addr_linea: INOUT INTEGER; is_halt: INOUT BOOLEAN) IS
	 
	VARIABLE i: INTEGER := 1;
	VARIABLE check: BOOLEAN;
	
	BEGIN 
		CompToSM.num_linea <= num_linea;
		for k in CompToSM.name_inst'range loop
			CompToSM.name_inst(k) <= ' ';
		end loop;
		if (cadena(i) /= HT) then
			cant_labels := cant_labels + 1;
			if (not isLetter(cadena(i))) then
				report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el nombre de la etiqueta no es válido"
				severity FAILURE;
			end if;
			labels(cant_labels).name(i) := cadena(i);
			i := i + 1;
			while (cadena(i) /= ':') loop
				if (not isValidChar(cadena(i))) then
					report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': el nombre de la etiqueta no es válido"
					severity FAILURE;
				end if;
				labels(cant_labels).name(i) := cadena(i);
				i := i + 1;
			end loop;
			labels(cant_labels).namelength := i - 1; 
			labels(cant_labels).address := addr_linea;
			labels(cant_labels).num_linea := num_linea;
			i := i + 1;
		end if;
		while (cadena(i) = HT) loop
			i := i + 1;
		end loop;
		for j in INSTTD_NAMES'RANGE loop
			checkInstTd(variables, cant_variables, cadena, INSTTD_NAMES(j), INSTTD_CODES(j), INSTTD_SIZES(j), i, check, nombre, num_linea, addr_linea);
			if (check) then	
				addr_linea := addr_linea + INSTTD_SIZES(j);
				for k in INSTTD_NAMES(j)'RANGE loop
					CompToSM.name_inst(k) <= INSTTD_NAMES(j)(k);
				end loop;
				exit;
			end if;
		end loop;							  
		if (not check) then
			for j in INSTAR_NAMES'RANGE loop
				checkInstAr(cadena, INSTAR_NAMES(j), INSTAR_CODES(j), INSTAR_SIZES(j), i, check, nombre, num_linea, addr_linea);
				if (check) then	
					addr_linea := addr_linea + INSTAR_SIZES(j);
					for k in INSTAR_NAMES(j)'RANGE loop
						CompToSM.name_inst(k) <= INSTAR_NAMES(j)(k);
					end loop;
					exit;
				end if;
			end loop;
		end if;
		if (not check) then
			for j in INSTLD_NAMES'RANGE loop
				checkInstLD(cadena, INSTLD_NAMES(j), INSTLD_CODES(j), INSTLD_SIZES(j), i, check, nombre, num_linea, addr_linea);
				if (check) then
					addr_linea := addr_linea + INSTLD_SIZES(j);
					for k in INSTLD_NAMES(j)'RANGE loop
						CompToSM.name_inst(k) <= INSTLD_NAMES(j)(k);
					end loop;
					exit;
				end if;
			end loop;
		end if;
		if (not check) then
			for j in INSTTC_NAMES'RANGE loop
				checkInstTc(offsets, cant_offsets, cadena, INSTTC_NAMES(j), INSTTC_CODES(j), INSTTC_SIZES(j), i, check, nombre, num_linea, addr_linea);
				if (check) then	
					addr_linea := addr_linea + INSTTC_SIZES(j);
					for k in INSTTC_NAMES(j)'RANGE loop
					CompToSM.name_inst(k) <= INSTTC_NAMES(j)(k);
				end loop;
					exit;
				end if;
			end loop;
		end if;
		if (not check) then
			for j in INSTCT_NAMES'RANGE loop
				checkInstCt(cadena, INSTCT_NAMES(j), INSTCT_CODES(j), INSTCT_SIZES(j), i, check, is_halt, addr_linea);
				if (check) then	
					addr_linea := addr_linea + INSTCT_SIZES(j);
					for k in INSTCT_NAMES(j)'RANGE loop
						CompToSM.name_inst(k) <= INSTCT_NAMES(j)(k);
					end loop;
					exit;
				end if;
			end loop;
		end if;
		if (not check) then
			report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': la instrucción declarada no es válida"
			severity FAILURE;
		end if;
		while (cadena(i) = HT) loop
			i := i + 1;
		end loop;
		while (i <= length) loop 
			if (cadena(i) /= HT) then
				if (cadena(i) = ';') then
					exit;
				else
					report "Error en la línea " & integer'image(num_linea) & " del programa '" & trim(nombre) & "': los comentarios no se encuentran correctamente declarados"
					severity FAILURE;
				end if;
			end if;
			i := i + 1;
		end loop;
		LoadInstState <= '1';
		WAIT FOR 1 ns;
		LoadInstState <= '0';
		WAIT FOR 1 ns;
	END checkCode;
	
	
	PROCEDURE checkOffsets(CONSTANT labels: IN label_records; CONSTANT cant_labels: IN INTEGER;
						   CONSTANT offsets: IN offset_records; CONSTANT cant_offsets: IN INTEGER;
						   CONSTANT nombre: IN STRING) IS
	
	BEGIN
		for i in 1 to cant_offsets loop
			for j in 1 to cant_labels loop
				if (offsets(i).name(1 to offsets(i).namelength) = labels(j).name(1 to labels(j).namelength)) then
					CompToSM.num_linea <= offsets(i).num_linea;
					if (offsets(i).isJmp) then
						CompToSM.num_linea_branch_taken_ID <= labels(j).num_linea;
						CompToSM.num_linea_branch_taken_EX <= -1;
					else
						CompToSM.num_linea_branch_taken_ID <= -1;
						CompToSM.num_linea_branch_taken_EX <= labels(j).num_linea;
					end if;
					InstAddrBusComp <= std_logic_vector(to_unsigned(offsets(i).address, InstAddrBusComp'length));
					InstDataBusOutComp <= std_logic_vector(to_unsigned(labels(j).address, InstDataBusOutComp'length));
					InstSizeBusComp <= std_logic_vector(to_unsigned(2, InstSizeBusComp'length));
					InstCtrlBusComp <= WRITE_MEMORY;
					LoadBranchInstState <= '1';
					EnableCompToInstMem <= '1';
					WAIT FOR 1 ns;
					LoadBranchInstState <= '0';
					EnableCompToInstMem <= '0';
					WAIT FOR 1 ns;
					exit;
				elsif (j = cant_labels) then
					report "Error en la línea " & integer'image(offsets(i).num_linea) & " del programa '" & trim(nombre) & "': la dirección de salto no hace referencia a ninguna etiqueta válida"
					severity FAILURE;
				end if;
			end loop;
		end loop;
	END checkOffsets;
	
	
	PROCEDURE assembleProgram(CONSTANT nombre: IN STRING) IS
	
	CONSTANT cad_file_mode:		STRING := "READ_MODE";
	CONSTANT file_mode:			FILE_OPEN_KIND := read_mode;
	VARIABLE file_status:		FILE_OPEN_STATUS;
	FILE programa: 				TEXT open file_mode is nombre;
	VARIABLE linea: 			LINE;
	VARIABLE cadena: 			STRING(1 to 100);
	VARIABLE num_linea:			INTEGER := 1; 
	VARIABLE addr_linea:		INTEGER := INST_BEGIN;
	VARIABLE labels:			label_records(1 to CANT_LABELS);
	VARIABLE cant_labels:		INTEGER := 0;
	VARIABLE variables:			variable_records(1 to CANT_VARIABLES); 
	VARIABLE cant_variables:	INTEGER := 0;
	VARIABLE offsets:			offset_records(1 to CANT_OFFSETS);
	VARIABLE cant_offsets:		INTEGER := 0;
	VARIABLE cadena_length:		INTEGER;
	VARIABLE is_halt:			BOOLEAN := false;
	
	BEGIN 
		file_open(file_status, programa, nombre, file_mode);
		case file_status IS
			WHEN STATUS_ERROR =>
				report "Error en la apertura del archivo '" & trim(nombre) & "': dicho fichero ya se encuentra abierto" 
				severity FAILURE;
			WHEN NAME_ERROR =>
				report "Error en la apertura del archivo '" & trim(nombre) & "': no existe dicho fichero o no se encuentra el directorio en el cual el mismo debería estar ubicado"
				severity FAILURE;
			WHEN MODE_ERROR =>
				report "Error en la apertura del archivo '" & trim(nombre) & "': el modo elegido, '" & cad_file_mode & "', no es válido"
				severity FAILURE;
			WHEN OTHERS => 
				for i in cadena'range loop
					cadena(i) := ' ';
				end loop;
				readline(programa, linea);
				cadena_length := linea.all'LENGTH;
				read(linea, cadena(1 to cadena_length));
				checkDataBegin(cadena, linea.all'LENGTH, nombre, num_linea);
				deallocate(linea);
				for i in 1 to cadena_length loop
					cadena(i) := ' ';
				end loop;
				num_linea := num_linea + 1;
				readline(programa, linea);
				cadena_length := linea.all'LENGTH;
				read(linea, cadena(1 to cadena_length));
				cant_variables := cant_variables + 1;
				checkData(variables, cant_variables, cadena, linea.all'LENGTH, nombre, num_linea);
				deallocate(linea);
				for i in 1 to cadena_length loop
					cadena(i) := ' ';
				end loop;
				num_linea := num_linea + 1;
				readline(programa, linea);
				cadena_length := linea.all'LENGTH;
				while (linea.all(1) /= HT) loop	
					read(linea, cadena(1 to cadena_length));
					cant_variables := cant_variables + 1;
					checkData(variables, cant_variables, cadena, linea.all'LENGTH, nombre, num_linea);
					deallocate(linea);
					for i in 1 to cadena_length loop
						cadena(i) := ' ';
					end loop;
					num_linea := num_linea + 1;
					readline(programa, linea);
					cadena_length := linea.all'LENGTH;
				end loop;
				read(linea, cadena(1 to cadena_length));
				checkCodeBegin(cadena, linea.all'LENGTH, nombre, num_linea);
				deallocate(linea);
				for i in 1 to cadena_length loop
					cadena(i) := ' ';
				end loop;
				num_linea := num_linea + 1;
				readline(programa, linea);
				cadena_length := linea.all'LENGTH;
				while not endfile(programa) loop
					read(linea, cadena(1 to cadena_length));
					checkCode(labels, cant_labels, offsets, cant_offsets, variables, cant_variables, cadena, linea.all'LENGTH, nombre, num_linea, addr_linea, is_halt);
					deallocate(linea);
					for i in 1 to cadena_length loop
						cadena(i) := ' ';
					end loop;
					num_linea := num_linea + 1;
					readline(programa, linea);
					cadena_length := linea.all'LENGTH;
					if ((is_halt) and (not endfile(programa))) then
						report "Error en la línea " & integer'image(num_linea-1) & " del programa '" & trim(nombre) & "': la última instrucción debe detener la ejecución del procesador ('halt')"
						severity FAILURE;
					end if;
				end loop;
				if (not is_halt) then
					report "Error en la línea " & integer'image(num_linea-1) & " del programa '" & trim(nombre) & "': la última instrucción debe detener la ejecución del procesador ('halt')"
					severity FAILURE;
				end if;
				checkOffsets(labels, cant_labels, offsets, cant_offsets, nombre);
				file_close(programa);
		END CASE;
	END assembleProgram;
	
	
	BEGIN
		DoneCompUser <= '0';
	   	DoneCompCPU <= '0';
		LoadInstState <= '0';
		LoadBranchInstState <= '0';
		EnableCompToDataMem <= '0';
		EnableCompToInstMem <= '0';
		WAIT UNTIL rising_edge(ReadyUser);
		assembleProgram("Assembler/" & ProgName);
		DoneCompUser <= '1';
	   	DoneCompCPU <= '1';
		WAIT;
	END PROCESS Main;



end ENSAMBLADOR_ARCHITECTURE;



