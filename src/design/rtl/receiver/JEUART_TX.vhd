----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/13/2023 12:41:02 PM
-- Design Name: 
-- Module Name: JEUART_TX - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity JEUART_TX is
    port (
        CLK_100MHZ         : in std_logic;
        RESET              : in std_logic;
        clk_en_16_x_baud   : in std_logic;
        data_in            : in std_logic_vector(7 downto 0);
        send_data          : in std_logic;
        UART_TX            : out std_logic;
        send_data_complete : out std_logic
    );
end JEUART_TX;

architecture Behavioral of JEUART_TX is

type   tstateTX is (idle, wstart, wstop, wd0, wd1, wd2, wd3, wd4, wd5, wd6, wd7, write_strobe);
signal sstateTX : tstateTX:=idle;
signal scount4 : std_logic_vector (3 downto 0) := (others => '0');

signal sdata_in : std_logic_vector (7 downto 0);

begin

-- State Machine: transitions
process(CLK_100MHZ, RESET)
begin
  if RESET = '1' then
    sstateTX <= idle;
  elsif CLK_100MHZ'event and CLK_100MHZ = '1' then
    if clk_en_16_x_baud = '1' then
	   case sstateTX is
          when idle      => if send_data = '1' then sstateTX <= wstart; end if;
		  when wstart    => if scount4 = X"F" then sstateTX <= wd0; end if;
		  when wd0       => if scount4 = X"F" then sstateTX <= wd1; end if;
		  when wd1       => if scount4 = X"F" then sstateTX <= wd2; end if;
		  when wd2       => if scount4 = X"F" then sstateTX <= wd3; end if;
		  when wd3       => if scount4 = X"F" then sstateTX <= wd4; end if;
		  when wd4       => if scount4 = X"F" then sstateTX <= wd5; end if;
		  when wd5       => if scount4 = X"F" then sstateTX <= wd6; end if;
		  when wd6       => if scount4 = X"F" then sstateTX <= wd7; end if;
		  when wd7       => if scount4 = X"F" then sstateTX <= wstop; end if;
		  when wstop     => sstateTX    <= write_strobe;
		  when write_strobe => sstateTX <= idle;
		end case;
	 end if;
  end if;
end process;

-- State Machine: output
process(sstateTX)
begin
  case sstateTX is
    when write_strobe =>  send_data_complete <= '1';
	when others       =>  send_data_complete <= '0';
  end case;
end process;

-- datapath

process(CLK_100MHZ)
begin
  if CLK_100MHZ'event and CLK_100MHZ = '1' then
    if clk_en_16_x_baud = '1' then
      case sstateTX is
           when wstart => UART_TX <= '0';
           when wd0    => UART_TX <= sdata_in(0);
           when wd1    => UART_TX <= sdata_in(1);
           when wd2    => UART_TX <= sdata_in(2);
           when wd3    => UART_TX <= sdata_in(3);
           when wd4    => UART_TX <= sdata_in(4);
           when wd5    => UART_TX <= sdata_in(5);
           when wd6    => UART_TX <= sdata_in(6);
           when wd7    => UART_TX <= sdata_in(7);
		   when others => UART_TX <= '1'; -- idle and wstop
	    end case;
	 end if;
  end if;
end process;

process(CLK_100MHZ)
begin
  if CLK_100MHZ'event and CLK_100MHZ = '1' then
    if clk_en_16_x_baud = '1' then
       case sstateTX is
		   when wstart|wd0|wd1|wd2|wd3|wd4|wd5|wd6|wd7|wstop => scount4 <= scount4 + '1';
		   when others => scount4 <= (others => '0');
		 end case;
	 end if;
  end if;
end process;

process(CLK_100MHZ)
begin
  if CLK_100MHZ'event and CLK_100MHZ = '1' then
    if clk_en_16_x_baud = '1' then
      case sstateTX is
		   when wstart => 
		         if scount4 = X"8" then -- Maybe change this??
		           sdata_in <= data_in; 
		         end if;
		   when others => null;
	    end case;
	 end if;
  end if;
end process;

end Behavioral;
