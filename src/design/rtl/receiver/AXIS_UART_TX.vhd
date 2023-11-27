library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity AXIS_UART_TX is
    port (
        CLK_100MHZ         : in std_logic;
        RESET              : in std_logic;
        clk_en_16_x_baud   : in std_logic;
        enable             : in std_logic;
        data_in            : in std_logic_vector(7 downto 0);
        UART_TX            : out std_logic;
        -- AXI STREAM
        valid              : in std_logic;
        ready              : out std_logic
    );
end AXIS_UART_TX;

architecture oh_behave of AXIS_UART_TX is

    component JEUART_TX is
        port (
            CLK_100MHZ         : in std_logic;
            RESET              : in std_logic;
            clk_en_16_x_baud   : in std_logic;
            data_in            : in std_logic_vector(7 downto 0);
            send_data          : in std_logic;
            UART_TX            : out std_logic;
            send_data_complete : out std_logic
        );
    end component;
    
    signal send_data : std_logic := '0';
    
    signal tx_data_complete      : std_logic;
    signal tx_data_complete_d1   : std_logic;
    signal tx_data_complete_edge : std_logic;
    
    type   AXIstateTX is (idle, process_data);
    signal c_stateTX, r_stateTX : AXIstateTX;
    
begin

    -- combinational state update process
    process (r_stateTX, tx_data_complete_edge, valid, RESET) is begin
        if RESET = '1' then
            c_stateTX <= idle;
        else
            case (r_stateTX) is
                when idle         => if (valid = '1') then c_stateTX <= process_data; else c_stateTX <= r_stateTX; end if;
                when process_data => if (tx_data_complete_edge = '1') then c_stateTX <= idle; else c_stateTX <= r_stateTX; end if;
                when others       => c_stateTX <= idle;
            end case;
        end if;
    end process;
    
    -- edge detector
    tx_data_complete_edge <= (not tx_data_complete_d1) and tx_data_complete;
    
    process (r_stateTX) is begin
            if (r_stateTX = idle) then
                send_data <= '0';
                ready <= '1';
            elsif (r_stateTX = process_data) then
                send_data <= '1';
                ready <= '0';
            else
                send_data <= '0';
                ready <= '0';
            end if;
    end process;
    
    -- reg update process
    process (CLK_100MHZ) is begin
        if rising_edge(CLK_100MHZ) then
            r_stateTX   <= c_stateTX;
            tx_data_complete_d1 <= tx_data_complete;
        end if;
    end process;

    TX_inst : JEUART_TX port map
    ( CLK_100MHZ         => CLK_100MHZ,
      RESET              => RESET,
      clk_en_16_x_baud   => clk_en_16_x_baud,
      send_data_complete => tx_data_complete,
      send_data          => send_data,
      data_in            => data_in,
      UART_TX            => UART_TX);

end oh_behave;