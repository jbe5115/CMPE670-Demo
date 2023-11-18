-- May have to change this to verilog at some point XD
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity AXIS_UART_RX is
    port (
        CLK_100MHZ         : in std_logic;
        RESET              : in std_logic;
        clk_en_16_x_baud   : in std_logic;
        data_out           : out std_logic_vector(7 downto 0);
        UART_RX            : in std_logic;
        -- AXI STREAM
        valid              : out std_logic;
        ready              : in std_logic;
        almost_full        : in std_logic
    );
end AXIS_UART_RX;

architecture Behavioral of AXIS_UART_RX is

    component JEUART_RX is
        port ( CLK_100MHZ         : in std_logic;
               RESET              : in std_logic;
               clk_en_16_x_baud   : in std_logic;
               read_data_complete : out std_logic;
               data_out           : out std_logic_vector(7 downto 0);
               UART_RX            : in std_logic);
    end component;
    
    signal rx_data_complete      : std_logic;
    signal rx_data_complete_d1   : std_logic;
    signal rx_data_complete_edge : std_logic;
    
    type   AXIstateRX is (idle, start, dob, done);
    signal stateRX : AXIstateRX;

begin

    -- combinational state update process
    process (CLK_100MHZ, RESET) is begin
        if RESET = '1' then
            stateRX <= idle;
        elsif rising_edge(CLK_100MHZ) then
            case (stateRX) is
                when idle    => if (rx_data_complete_edge = '1') then stateRX <= start; end if;
                when start   => if (almost_full = '0')           then stateRX <= dob; end if;
                when dob     => if (ready = '1')                 then stateRX <= done; end if;
                when others  => stateRX <= idle; -- done
            end case;
        end if;
    end process;
    
    -- edge detector
    rx_data_complete_edge <= (not rx_data_complete_d1) and rx_data_complete;
    
    process (stateRX) is begin
        if (stateRX = dob) then
            valid <= '1';
        else
            valid <= '0';
        end if;
    end process;
    
    
    -- reg update process
    process (CLK_100MHZ) is begin
        if rising_edge(CLK_100MHZ) then
            rx_data_complete_d1 <= rx_data_complete;
        end if;
    end process;
    
    RX_inst : JEUART_RX port map
    ( CLK_100MHZ         => CLK_100MHZ,
      RESET              => RESET,
      clk_en_16_x_baud   => clk_en_16_x_baud,
      read_data_complete => rx_data_complete,
      data_out           => data_out,
      UART_RX            => UART_RX);


end Behavioral;
