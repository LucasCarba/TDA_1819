
-- Paquete "const_ascii":
-- Descripción: Aquí se definen, por un lado, todos los caracteres que pueden ser
-- interpretados por el ensamblador y, por lo tanto, resultan válidos para que el usuario 
-- los utilice a fin de determinar valores para las cadenas ASCII que asigne a las 
-- variables de su programa (si es que las hubiera). Por otra parte, también se incluye 
-- la representación en código máquina (sistema binario) para cada uno de dichos 
-- caracteres a fin de que el ensamblador pueda recurrir a ella para determinar el valor 
-- correspondiente al caracter actual que debe almacenar en la memoria de datos de la PC.


library TDA_1819;
use TDA_1819.tipos_ensamblador.all;
use TDA_1819.repert_cpu.all;
use TDA_1819.tipos_ascii.all;

LIBRARY IEEE;

USE std.textio.all;
USE IEEE.std_logic_1164.all; 


PACKAGE const_ascii is
	
	
	CONSTANT CANT_CARACTERES:	INTEGER := 109;
	
	CONSTANT COD_ESPACIO:		std_logic_vector(7 downto 0) := X"20";
	CONSTANT COD_CER_EXCLAM:	std_logic_vector(7 downto 0) := X"21";
	CONSTANT COD_COM_DOBLE:		std_logic_vector(7 downto 0) := X"22";
	CONSTANT COD_NUMERAL:		std_logic_vector(7 downto 0) := X"23";
	CONSTANT COD_PESO:			std_logic_vector(7 downto 0) := X"24";
	CONSTANT COD_PORCENTAJE:	std_logic_vector(7 downto 0) := X"25";
	CONSTANT COD_AND:			std_logic_vector(7 downto 0) := X"26";
	CONSTANT COD_COM_SIMPLE:	std_logic_vector(7 downto 0) := X"27";
	CONSTANT COD_ABR_PARENT:	std_logic_vector(7 downto 0) := X"28";
	CONSTANT COD_CER_PARENT:	std_logic_vector(7 downto 0) := X"29";
	CONSTANT COD_ASTERISCO:		std_logic_vector(7 downto 0) := X"2A";
	CONSTANT COD_MAS:			std_logic_vector(7 downto 0) := X"2B";
	CONSTANT COD_COMA:			std_logic_vector(7 downto 0) := X"2C";
	CONSTANT COD_MENOS:			std_logic_vector(7 downto 0) := X"2D";
	CONSTANT COD_PUNTO:			std_logic_vector(7 downto 0) := X"2E";
	CONSTANT COD_BARRA:			std_logic_vector(7 downto 0) := X"2F";
	CONSTANT COD_CERO:			std_logic_vector(7 downto 0) := X"30";
	CONSTANT COD_UNO:			std_logic_vector(7 downto 0) := X"31";
	CONSTANT COD_DOS:			std_logic_vector(7 downto 0) := X"32";
	CONSTANT COD_TRES:			std_logic_vector(7 downto 0) := X"33";
	CONSTANT COD_CUATRO:		std_logic_vector(7 downto 0) := X"34";
	CONSTANT COD_CINCO:			std_logic_vector(7 downto 0) := X"35";
	CONSTANT COD_SEIS:			std_logic_vector(7 downto 0) := X"36";
	CONSTANT COD_SIETE:			std_logic_vector(7 downto 0) := X"37";
	CONSTANT COD_OCHO:			std_logic_vector(7 downto 0) := X"38";
	CONSTANT COD_NUEVE:			std_logic_vector(7 downto 0) := X"39";
	CONSTANT COD_DOS_PUNTOS:	std_logic_vector(7 downto 0) := X"3A";
	CONSTANT COD_PUNTO_COMA:	std_logic_vector(7 downto 0) := X"3B";
	CONSTANT COD_MENOR:			std_logic_vector(7 downto 0) := X"3C";
	CONSTANT COD_IGUAL:			std_logic_vector(7 downto 0) := X"3D";
	CONSTANT COD_MAYOR:			std_logic_vector(7 downto 0) := X"3E";
	CONSTANT COD_CER_PREGU:		std_logic_vector(7 downto 0) := X"3F";
	CONSTANT COD_ARROBA:		std_logic_vector(7 downto 0) := X"40";
	CONSTANT COD_A_MAYUS:		std_logic_vector(7 downto 0) := X"41";
	CONSTANT COD_B_MAYUS:		std_logic_vector(7 downto 0) := X"42";
	CONSTANT COD_C_MAYUS:		std_logic_vector(7 downto 0) := X"43";
	CONSTANT COD_D_MAYUS:		std_logic_vector(7 downto 0) := X"44";
	CONSTANT COD_E_MAYUS:		std_logic_vector(7 downto 0) := X"45";
	CONSTANT COD_F_MAYUS:		std_logic_vector(7 downto 0) := X"46";
	CONSTANT COD_G_MAYUS:		std_logic_vector(7 downto 0) := X"47";
	CONSTANT COD_H_MAYUS:		std_logic_vector(7 downto 0) := X"48";
	CONSTANT COD_I_MAYUS:		std_logic_vector(7 downto 0) := X"49";
	CONSTANT COD_J_MAYUS:		std_logic_vector(7 downto 0) := X"4A";
	CONSTANT COD_K_MAYUS:		std_logic_vector(7 downto 0) := X"4B";
	CONSTANT COD_L_MAYUS:		std_logic_vector(7 downto 0) := X"4C";
	CONSTANT COD_M_MAYUS:		std_logic_vector(7 downto 0) := X"4D";
	CONSTANT COD_N_MAYUS:		std_logic_vector(7 downto 0) := X"4E";
	CONSTANT COD_O_MAYUS:		std_logic_vector(7 downto 0) := X"4F";
	CONSTANT COD_P_MAYUS:		std_logic_vector(7 downto 0) := X"50";
	CONSTANT COD_Q_MAYUS:		std_logic_vector(7 downto 0) := X"51";
	CONSTANT COD_R_MAYUS:		std_logic_vector(7 downto 0) := X"52";
	CONSTANT COD_S_MAYUS:		std_logic_vector(7 downto 0) := X"53";
	CONSTANT COD_T_MAYUS:		std_logic_vector(7 downto 0) := X"54";
	CONSTANT COD_U_MAYUS:		std_logic_vector(7 downto 0) := X"55";
	CONSTANT COD_V_MAYUS:		std_logic_vector(7 downto 0) := X"56";
	CONSTANT COD_W_MAYUS:		std_logic_vector(7 downto 0) := X"57";
	CONSTANT COD_X_MAYUS:		std_logic_vector(7 downto 0) := X"58";
	CONSTANT COD_Y_MAYUS:		std_logic_vector(7 downto 0) := X"59";
	CONSTANT COD_Z_MAYUS:		std_logic_vector(7 downto 0) := X"5A";
	CONSTANT COD_ABR_CORCH:		std_logic_vector(7 downto 0) := X"5B";
	CONSTANT COD_BARRA_INV:		std_logic_vector(7 downto 0) := X"5C";
	CONSTANT COD_CER_CORCH:		std_logic_vector(7 downto 0) := X"5D";
	CONSTANT COD_SOMBRERO:		std_logic_vector(7 downto 0) := X"5E";
	CONSTANT COD_GUION_BAJO:	std_logic_vector(7 downto 0) := X"5F";
	CONSTANT COD_ACENTO_INV:	std_logic_vector(7 downto 0) := X"60";
	CONSTANT COD_A_MINUS:		std_logic_vector(7 downto 0) := X"61";
	CONSTANT COD_B_MINUS:		std_logic_vector(7 downto 0) := X"62";
	CONSTANT COD_C_MINUS:		std_logic_vector(7 downto 0) := X"63";
	CONSTANT COD_D_MINUS:		std_logic_vector(7 downto 0) := X"64";
	CONSTANT COD_E_MINUS:		std_logic_vector(7 downto 0) := X"65";
	CONSTANT COD_F_MINUS:		std_logic_vector(7 downto 0) := X"66";
	CONSTANT COD_G_MINUS:		std_logic_vector(7 downto 0) := X"67";
	CONSTANT COD_H_MINUS:		std_logic_vector(7 downto 0) := X"68";
	CONSTANT COD_I_MINUS:		std_logic_vector(7 downto 0) := X"69";
	CONSTANT COD_J_MINUS:		std_logic_vector(7 downto 0) := X"6A";
	CONSTANT COD_K_MINUS:		std_logic_vector(7 downto 0) := X"6B";
	CONSTANT COD_L_MINUS:		std_logic_vector(7 downto 0) := X"6C";
	CONSTANT COD_M_MINUS:		std_logic_vector(7 downto 0) := X"6D";
	CONSTANT COD_N_MINUS:		std_logic_vector(7 downto 0) := X"6E";
	CONSTANT COD_O_MINUS:		std_logic_vector(7 downto 0) := X"6F";
	CONSTANT COD_P_MINUS:		std_logic_vector(7 downto 0) := X"70";
	CONSTANT COD_Q_MINUS:		std_logic_vector(7 downto 0) := X"71";
	CONSTANT COD_R_MINUS:		std_logic_vector(7 downto 0) := X"72";
	CONSTANT COD_S_MINUS:		std_logic_vector(7 downto 0) := X"73";
	CONSTANT COD_T_MINUS:		std_logic_vector(7 downto 0) := X"74";
	CONSTANT COD_U_MINUS:		std_logic_vector(7 downto 0) := X"75";
	CONSTANT COD_V_MINUS:		std_logic_vector(7 downto 0) := X"76";
	CONSTANT COD_W_MINUS:		std_logic_vector(7 downto 0) := X"77";
	CONSTANT COD_X_MINUS:		std_logic_vector(7 downto 0) := X"78";
	CONSTANT COD_Y_MINUS:		std_logic_vector(7 downto 0) := X"79";
	CONSTANT COD_Z_MINUS:		std_logic_vector(7 downto 0) := X"7A";
	CONSTANT COD_ABR_LLAVE:		std_logic_vector(7 downto 0) := X"7B";
	CONSTANT COD_OR:			std_logic_vector(7 downto 0) := X"7C";
	CONSTANT COD_CER_LLAVE:		std_logic_vector(7 downto 0) := X"7D";
	CONSTANT COD_APROX:			std_logic_vector(7 downto 0) := X"7E";
	
	CONSTANT COD_E_MINUS_AC:	std_logic_vector(7 downto 0) := X"82";
	CONSTANT COD_A_MINUS_AC:	std_logic_vector(7 downto 0) := X"A0";
	CONSTANT COD_I_MINUS_AC:	std_logic_vector(7 downto 0) := X"A1";
	CONSTANT COD_O_MINUS_AC:	std_logic_vector(7 downto 0) := X"A2";
	CONSTANT COD_U_MINUS_AC:	std_logic_vector(7 downto 0) := X"A3";
	
	CONSTANT COD_Ñ_MINUS:		std_logic_vector(7 downto 0) := X"A4";
	CONSTANT COD_Ñ_MAYUS:		std_logic_vector(7 downto 0) := X"A5";
	
	CONSTANT COD_ABR_PREGU:		std_logic_vector(7 downto 0) := X"A8";
	CONSTANT COD_ABR_EXCLAM:	std_logic_vector(7 downto 0) := X"AD";
	
	CONSTANT COD_E_MAYUS_AC:	std_logic_vector(7 downto 0) := X"90";
	CONSTANT COD_A_MAYUS_AC:	std_logic_vector(7 downto 0) := X"B5";
	CONSTANT COD_I_MAYUS_AC:	std_logic_vector(7 downto 0) := X"D6";
	CONSTANT COD_O_MAYUS_AC:	std_logic_vector(7 downto 0) := X"E0";
	CONSTANT COD_U_MAYUS_AC:	std_logic_vector(7 downto 0) := X"E9";
	
	
	CONSTANT CAR_ESPACIO:		character := ' ';
	CONSTANT CAR_CER_EXCLAM:	character := '!';
	CONSTANT CAR_COM_DOBLE:		character := '"';
	CONSTANT CAR_NUMERAL:		character := '#';
	CONSTANT CAR_PESO:			character := '$';
	CONSTANT CAR_PORCENTAJE:	character := '%';
	CONSTANT CAR_AND:			character := '&';
	CONSTANT CAR_COM_SIMPLE:	character := ''';
	CONSTANT CAR_ABR_PARENT:	character := '(';
	CONSTANT CAR_CER_PARENT:	character := ')';
	CONSTANT CAR_ASTERISCO:		character := '*';
	CONSTANT CAR_MAS:			character := '+';
	CONSTANT CAR_COMA:			character := ',';
	CONSTANT CAR_MENOS:			character := '-';
	CONSTANT CAR_PUNTO:			character := '.';
	CONSTANT CAR_BARRA:			character := '/';
	CONSTANT CAR_CERO:			character := '0';
	CONSTANT CAR_UNO:			character := '1';
	CONSTANT CAR_DOS:			character := '2';
	CONSTANT CAR_TRES:			character := '3';
	CONSTANT CAR_CUATRO:		character := '4';
	CONSTANT CAR_CINCO:			character := '5';
	CONSTANT CAR_SEIS:			character := '6';
	CONSTANT CAR_SIETE:			character := '7';
	CONSTANT CAR_OCHO:			character := '8';
	CONSTANT CAR_NUEVE:			character := '9';
	CONSTANT CAR_DOS_PUNTOS:	character := ':';
	CONSTANT CAR_PUNTO_COMA:	character := ';';
	CONSTANT CAR_MENOR:			character := '<';
	CONSTANT CAR_IGUAL:			character := '=';
	CONSTANT CAR_MAYOR:			character := '>';
	CONSTANT CAR_CER_PREGU:		character := '?';
	CONSTANT CAR_ARROBA:		character := '@';
	CONSTANT CAR_A_MAYUS:		character := 'A';
	CONSTANT CAR_B_MAYUS:		character := 'B';
	CONSTANT CAR_C_MAYUS:		character := 'C';
	CONSTANT CAR_D_MAYUS:		character := 'D';
	CONSTANT CAR_E_MAYUS:		character := 'E';
	CONSTANT CAR_F_MAYUS:		character := 'F';
	CONSTANT CAR_G_MAYUS:		character := 'G';
	CONSTANT CAR_H_MAYUS:		character := 'H';
	CONSTANT CAR_I_MAYUS:		character := 'I';
	CONSTANT CAR_J_MAYUS:		character := 'J';
	CONSTANT CAR_K_MAYUS:		character := 'K';
	CONSTANT CAR_L_MAYUS:		character := 'L';
	CONSTANT CAR_M_MAYUS:		character := 'M';
	CONSTANT CAR_N_MAYUS:		character := 'N';
	CONSTANT CAR_O_MAYUS:		character := 'O';
	CONSTANT CAR_P_MAYUS:		character := 'P';
	CONSTANT CAR_Q_MAYUS:		character := 'Q';
	CONSTANT CAR_R_MAYUS:		character := 'R';
	CONSTANT CAR_S_MAYUS:		character := 'S';
	CONSTANT CAR_T_MAYUS:		character := 'T';
	CONSTANT CAR_U_MAYUS:		character := 'U';
	CONSTANT CAR_V_MAYUS:		character := 'V';
	CONSTANT CAR_W_MAYUS:		character := 'W';
	CONSTANT CAR_X_MAYUS:		character := 'X';
	CONSTANT CAR_Y_MAYUS:		character := 'Y';
	CONSTANT CAR_Z_MAYUS:		character := 'Z';
	CONSTANT CAR_ABR_CORCH:		character := '[';
	CONSTANT CAR_BARRA_INV:		character := '\';
	CONSTANT CAR_CER_CORCH:		character := ']';
	CONSTANT CAR_SOMBRERO:		character := '^';
	CONSTANT CAR_GUION_BAJO:	character := '_';
	CONSTANT CAR_ACENTO_INV:	character := '`';
	CONSTANT CAR_A_MINUS:		character := 'a';
	CONSTANT CAR_B_MINUS:		character := 'b';
	CONSTANT CAR_C_MINUS:		character := 'c';
	CONSTANT CAR_D_MINUS:		character := 'd';
	CONSTANT CAR_E_MINUS:		character := 'e';
	CONSTANT CAR_F_MINUS:		character := 'f';
	CONSTANT CAR_G_MINUS:		character := 'g';
	CONSTANT CAR_H_MINUS:		character := 'h';
	CONSTANT CAR_I_MINUS:		character := 'i';
	CONSTANT CAR_J_MINUS:		character := 'j';
	CONSTANT CAR_K_MINUS:		character := 'k';
	CONSTANT CAR_L_MINUS:		character := 'l';
	CONSTANT CAR_M_MINUS:		character := 'm';
	CONSTANT CAR_N_MINUS:		character := 'n';
	CONSTANT CAR_O_MINUS:		character := 'o';
	CONSTANT CAR_P_MINUS:		character := 'p';
	CONSTANT CAR_Q_MINUS:		character := 'q';
	CONSTANT CAR_R_MINUS:		character := 'r';
	CONSTANT CAR_S_MINUS:		character := 's';
	CONSTANT CAR_T_MINUS:		character := 't';
	CONSTANT CAR_U_MINUS:		character := 'u';
	CONSTANT CAR_V_MINUS:		character := 'v';
	CONSTANT CAR_W_MINUS:		character := 'w';
	CONSTANT CAR_X_MINUS:		character := 'x';
	CONSTANT CAR_Y_MINUS:		character := 'y';
	CONSTANT CAR_Z_MINUS:		character := 'z';
	CONSTANT CAR_ABR_LLAVE:		character := '{';
	CONSTANT CAR_OR:			character := '|';
	CONSTANT CAR_CER_LLAVE:		character := '}';
	CONSTANT CAR_APROX:			character := '~';
	
	CONSTANT CAR_E_MINUS_AC:	character := 'é';
	CONSTANT CAR_A_MINUS_AC:	character := 'á';
	CONSTANT CAR_I_MINUS_AC:	character := 'í';
	CONSTANT CAR_O_MINUS_AC:	character := 'ó';
	CONSTANT CAR_U_MINUS_AC:	character := 'ú';
	
	CONSTANT CAR_Ñ_MINUS:		character := 'ñ';
	CONSTANT CAR_Ñ_MAYUS:		character := 'Ñ';
	
	CONSTANT CAR_ABR_PREGU:		character := '¿';
	CONSTANT CAR_ABR_EXCLAM:	character := '¡';
	
	CONSTANT CAR_E_MAYUS_AC:	character := 'É';
	CONSTANT CAR_A_MAYUS_AC:	character := 'Á';
	CONSTANT CAR_I_MAYUS_AC:	character := 'Í';
	CONSTANT CAR_O_MAYUS_AC:	character := 'Ó';
	CONSTANT CAR_U_MAYUS_AC:	character := 'Ú'; 
	
	CONSTANT COD_CARACTERES: cod_caracteres_array(1 to CANT_CARACTERES) := (
																			COD_ESPACIO,
																			COD_CER_EXCLAM,
																			COD_COM_DOBLE,
																			COD_NUMERAL,
																			COD_PESO,
																			COD_PORCENTAJE,
																			COD_AND,
																			COD_COM_SIMPLE,
																			COD_ABR_PARENT,
																			COD_CER_PARENT,
																			COD_ASTERISCO,
																			COD_MAS,
																			COD_COMA,
																			COD_MENOS,
																			COD_PUNTO,
																			COD_BARRA,
																			COD_CERO,
																			COD_UNO,
																			COD_DOS,
																			COD_TRES,
																			COD_CUATRO,
																			COD_CINCO,
																			COD_SEIS,
																			COD_SIETE,
																			COD_OCHO,
																			COD_NUEVE,
																			COD_DOS_PUNTOS,
																			COD_PUNTO_COMA,
																			COD_MENOR,
																			COD_IGUAL,
																			COD_MAYOR,
																			COD_CER_PREGU,
																			COD_ARROBA,
																			COD_A_MAYUS,
																			COD_B_MAYUS,
																			COD_C_MAYUS,
																			COD_D_MAYUS,
																			COD_E_MAYUS,
																			COD_F_MAYUS,
																			COD_G_MAYUS,
																			COD_H_MAYUS,
																			COD_I_MAYUS,
																			COD_J_MAYUS,
																			COD_K_MAYUS,
																			COD_L_MAYUS,
																			COD_M_MAYUS,
																			COD_N_MAYUS,
																			COD_O_MAYUS,
																			COD_P_MAYUS,
																			COD_Q_MAYUS,
																			COD_R_MAYUS,
																			COD_S_MAYUS,
																			COD_T_MAYUS,
																		 	COD_U_MAYUS,
																			COD_V_MAYUS,
																			COD_W_MAYUS,
																			COD_X_MAYUS,
																			COD_Y_MAYUS,
																			COD_Z_MAYUS,
																			COD_ABR_CORCH,
																			COD_BARRA_INV,
																			COD_CER_CORCH,
																			COD_SOMBRERO,
																			COD_GUION_BAJO,
																			COD_ACENTO_INV,
																			COD_A_MINUS,
																			COD_B_MINUS,
																			COD_C_MINUS,
																			COD_D_MINUS,
																			COD_E_MINUS,
																			COD_F_MINUS,
																			COD_G_MINUS,
																			COD_H_MINUS,
																			COD_I_MINUS,
																			COD_J_MINUS,
																			COD_K_MINUS,
																			COD_L_MINUS,
																			COD_M_MINUS,
																			COD_N_MINUS,
																			COD_O_MINUS,
																			COD_P_MINUS,
																			COD_Q_MINUS,
																			COD_R_MINUS,
																			COD_S_MINUS,
																			COD_T_MINUS,
																			COD_U_MINUS,
																			COD_V_MINUS,
																			COD_W_MINUS,
																			COD_X_MINUS,
																			COD_Y_MINUS,
																		 	COD_Z_MINUS,
																			COD_ABR_LLAVE,
																			COD_OR,
																			COD_CER_LLAVE,
																			COD_APROX,
																			
																			COD_E_MINUS_AC,
																			COD_A_MINUS_AC,
																			COD_I_MINUS_AC,
																			COD_O_MINUS_AC,
																			COD_U_MINUS_AC,
																			
																			COD_Ñ_MINUS,
																			COD_Ñ_MAYUS,
																			
																			COD_ABR_PREGU,
																			COD_ABR_EXCLAM,
																			
																			COD_E_MAYUS_AC,
																			COD_A_MAYUS_AC,
																			COD_I_MAYUS_AC,
																			COD_O_MAYUS_AC,
																			COD_U_MAYUS_AC
																			);
	
	CONSTANT CARACTERES: caracteres_array(1 to CANT_CARACTERES) := 	CAR_ESPACIO &
																	CAR_CER_EXCLAM &
																	CAR_COM_DOBLE &
																	CAR_NUMERAL &
																	CAR_PESO &
																	CAR_PORCENTAJE &
																	CAR_AND &
																	CAR_COM_SIMPLE &
																	CAR_ABR_PARENT &
																	CAR_CER_PARENT &
																	CAR_ASTERISCO &
																	CAR_MAS &
																	CAR_COMA &
																	CAR_MENOS &
																	CAR_PUNTO &
																	CAR_BARRA &
																	CAR_CERO &
																	CAR_UNO &
																	CAR_DOS &
																	CAR_TRES &
																	CAR_CUATRO &
																	CAR_CINCO &
																	CAR_SEIS &
																	CAR_SIETE &
																	CAR_OCHO &
																	CAR_NUEVE &
																	CAR_DOS_PUNTOS &
																	CAR_PUNTO_COMA &
																	CAR_MENOR &
																	CAR_IGUAL &
																	CAR_MAYOR &
																	CAR_CER_PREGU &
																	CAR_ARROBA &
																	CAR_A_MAYUS &
																	CAR_B_MAYUS &
																	CAR_C_MAYUS &
																	CAR_D_MAYUS &
																	CAR_E_MAYUS &
																	CAR_F_MAYUS &
																	CAR_G_MAYUS &
																	CAR_H_MAYUS &
																	CAR_I_MAYUS &
																	CAR_J_MAYUS &
																	CAR_K_MAYUS &
																	CAR_L_MAYUS &
																	CAR_M_MAYUS &
																	CAR_N_MAYUS &
																	CAR_O_MAYUS &
																	CAR_P_MAYUS &
																	CAR_Q_MAYUS &
																	CAR_R_MAYUS &
																	CAR_S_MAYUS &
																	CAR_T_MAYUS &
																 	CAR_U_MAYUS &
																	CAR_V_MAYUS &
																	CAR_W_MAYUS &
																	CAR_X_MAYUS &
																	CAR_Y_MAYUS &
																	CAR_Z_MAYUS &
																	CAR_ABR_CORCH &
																	CAR_BARRA_INV &
																	CAR_CER_CORCH &
																	CAR_SOMBRERO &
																	CAR_GUION_BAJO &
																	CAR_ACENTO_INV &
																	CAR_A_MINUS &
																	CAR_B_MINUS &
																	CAR_C_MINUS &
																	CAR_D_MINUS &
																	CAR_E_MINUS &
																	CAR_F_MINUS &
																	CAR_G_MINUS &
																	CAR_H_MINUS &
																	CAR_I_MINUS &
																	CAR_J_MINUS &
																	CAR_K_MINUS &
																	CAR_L_MINUS &
																	CAR_M_MINUS &
																	CAR_N_MINUS &
																	CAR_O_MINUS &
																	CAR_P_MINUS &
																	CAR_Q_MINUS &
																	CAR_R_MINUS &
																	CAR_S_MINUS &
																	CAR_T_MINUS &
																	CAR_U_MINUS &
																	CAR_V_MINUS &
																	CAR_W_MINUS &
																	CAR_X_MINUS &
																	CAR_Y_MINUS &
																 	CAR_Z_MINUS &
																	CAR_ABR_LLAVE &
																	CAR_OR &
																	CAR_CER_LLAVE &
																	CAR_APROX &
																	
																	CAR_E_MINUS_AC &
																	CAR_A_MINUS_AC &
																	CAR_I_MINUS_AC &
																	CAR_O_MINUS_AC &
																	CAR_U_MINUS_AC &
																	
																	CAR_Ñ_MINUS &
																	CAR_Ñ_MAYUS &
																	
																	CAR_ABR_PREGU &
																	CAR_ABR_EXCLAM &
																	
																	CAR_E_MAYUS_AC &
																	CAR_A_MAYUS_AC &
																	CAR_I_MAYUS_AC &
																	CAR_O_MAYUS_AC &
																	CAR_U_MAYUS_AC
																	;
	
	
END const_ascii;




PACKAGE BODY const_ascii is 
	

END const_ascii;


