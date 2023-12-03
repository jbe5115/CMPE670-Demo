library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use IEEE.std_logic_TextIO.all;
use STD.TextIO.all;



entity sender_tb is
end sender_tb;

architecture tb of sender_tb is

    signal  clk            :  std_logic:='0';
    signal  sys_rst        :  std_logic:='1';
    signal  i_UART_RX      :  std_logic:='1';
    signal  o_otn_rx_data  :  std_logic;
    signal  i_otn_tx_ack   :  std_logic;
    signal  corrupt_en     :  std_logic;
    signal  arq_en         :  std_logic;

    -- Clock period definitions
    constant  clk_period   :  time     :=  10 ns;
    constant  clk_per_sym  :  integer  :=  868;
    constant  symbol_len   :  time     :=  clk_period*clk_per_sym;  --   100  MHz  /  115200  =  868.1  clock/symbol

    -- debug
    signal dbg_L_END    : boolean := true;
    signal dbg_data_out : std_ulogic_vector(7 downto 0);
    signal dbg_data_in  : std_logic_vector(7 downto 0);

begin

    sender_inst : entity sender
    port map(
        -- PC/FPPGA INTERFACE
        i_clk           => clk,
        i_rst           => sys_rst,
        i_uart_rx       => i_UART_RX,
        i_arq_en        => arq_en,
        i_corrupt_en    => corrupt_en,
        -- TRANSMIT INTERFACE
        o_otn_rx_data   => o_otn_rx_data,
        i_otn_tx_ack    => i_otn_tx_ack
    );

    -- Clock process definitions
    process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus process
    process
        -- TODO: Make more procedures for testing different sender cases
        

        -- read 1031 byte row TODO : make own process
        procedure read_row          (valid : out std_logic) is begin

        end read_row;

         -- checkers TODO : make into functions
        procedure check_overhead     (valid : out std_logic) is begin

        end check_overhead;

        procedure check_crc         (valid : out std_logic) is begin

        end check_crc;

        procedure check_payload     (valid : out std_logic) is begin

        end check_payload;
        
        -- stim 


        procedure send_char(
            chr : in unsigned(7 downto 0)
        ) is begin
            i_UART_RX <= '0';
            wait for symbol_len;
            for i in 0 to chr'high loop
                i_UART_RX <= chr(i);
                wait for symbol_len;
            end loop;
            i_UART_RX <= '1';
            wait for symbol_len;
        end send_char;

        procedure rx_char(
            chr : out integer
        ) is
            variable vect : std_logic_vector(7 downto 0);
        begin
            if o_otn_rx_data /= '0' then        -- in case UART is started
                wait until o_otn_rx_data = '0'; -- start
            end if;
            wait for symbol_len/2; -- center
            wait for symbol_len; -- start bit
            for i in 0 to vect'high loop
                vect(i) := o_otn_rx_data;
                wait for symbol_len;
            end loop;
            chr := to_integer(unsigned(vect));
            wait for symbol_len/2;
        end rx_char;
        
        -- file IO
        constant payload_file   :  string := "payload.txt";
        file     stim           : text open READ_MODE is payload_file;
        variable L_IN           : line;
        variable EOL_N          : boolean := TRUE;    
        variable byte_out       : std_ulogic_vector(7 downto 0);
    begin
        sys_rst         <= '1';
        arq_en          <= '0';
        corrupt_en      <= '0';
        i_otn_tx_ack    <= '1';
        
        wait for 200 ns;
        sys_rst <= '0';
        wait for 1 us; 
        while not endfile(stim) loop
            readline(stim, L_IN);          -- get line
            hread(L_IN, byte_out, EOL_N); -- get first byte
            while (EOL_N = true) loop
                send_char(unsigned(byte_out));
                hread(L_IN, byte_out, EOL_N);
                wait for 0 ns;
            end loop;
            EOL_N := true;
        end loop;
        
       wait for 10ms;

        assert false
            report "End of simulation"
            severity failure;

    end process;

end tb;