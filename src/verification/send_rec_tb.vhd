library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use IEEE.std_logic_TextIO.all;
use STD.TextIO.all;


entity send_rec_tb is
end send_rec_tb;

architecture tb of send_rec_tb is

    signal  clk            :  std_logic:='0';
    signal  sys_rst        :  std_logic:='1';
    signal  i_UART_RX      :  std_logic:='1';
    signal  uart_tx        :  std_logic;
    signal  corrupt_en     :  std_logic;
    signal  arq_en         :  std_logic;
    signal  rec_crc_val    :  std_logic_vector(7 downto 0);
    signal  send_crc_val   :  std_logic_vector(7 downto 0);
    signal  retrans_en     :  std_logic:= '1';
    signal  retrans_wait   :  std_logic;
    
    signal  ack            :  std_logic;
    signal  datapath       :  std_logic;

    -- Clock period definitions
    constant  clk_period   :  time     :=  5 ns; -- Does not represent current rate (100 MHz)
    constant  clk_per_sym  :  integer  :=  868; -- was 868 with 10 ns clock
    constant  symbol_len   :  time     :=  clk_period*clk_per_sym;  --   100  MHz  /  115200  =  868.1  clock/symbol

    constant  max_row_cnt   : integer := 64;
    constant  max_col_cnt   : integer := 64;
    shared variable row_cnt : integer := 0;
    shared variable col_cnt : integer := 0;
    
    component top is
        port (
            i_clk, i_rst, i_uart_rx, i_arq_en, i_corrupt_en, i_retrans_en, i_otn_tx_ack, i_otn_tx_data : in std_logic;
            i_corrupt_seed : in std_logic_vector(7 downto 0);
            o_uart_tx, o_retrans_wait, o_otn_rx_ack, o_otn_rx_data : out std_logic
        );
    end component;

begin

    top_inst : top
    port map (
        i_clk          => clk,
        i_rst          => sys_rst,
        i_uart_rx      => i_uart_rx,
        i_arq_en       => arq_en,
        i_corrupt_en   => corrupt_en,
        i_corrupt_seed => x"FB",
        i_retrans_en   => retrans_en,
        o_retrans_wait => retrans_wait,
        o_uart_tx      => uart_tx,
        -- wires (connects receiver and sender)
        i_otn_tx_ack   => ack,
        o_otn_rx_ack   => ack,
        i_otn_tx_data  => datapath,
        o_otn_rx_data  => datapath
    );


    -- Clock process definitions
    process is begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;
    
    process is begin
        retrans_en <= '1';
        wait for clk_period*2;
        retrans_en <= '0';
        wait for clk_period*2;
    end process;
    
    -- read data process
    process is
    
        procedure get_char(
            chr : out integer
        ) is
            variable vect : std_logic_vector(7 downto 0);
        begin
            if uart_tx /= '0' then        -- in case UART is started
                wait until uart_tx = '0'; -- start
            end if;
            wait for symbol_len/2; -- center
            wait for symbol_len; -- start bit
            for i in 0 to vect'high loop
                vect(i) := uart_tx;
                wait for symbol_len;
            end loop;
            chr := to_integer(unsigned(vect));
            wait for symbol_len/2;
        end get_char;
        
        
        constant payload_out_file1 : string := "payloadOUT1.txt";
        constant payload_out_file2 : string := "payloadOUT2.txt";
        file stim                  : TEXT;
        variable current_char      : integer;
        variable lineout           : line;
        variable dimline           : line;
    begin
        file_open(stim, payload_out_file1, write_mode);
        -- Finally, get all of the image data
        for row in 1 to 64 loop
            for col in 1 to 64 loop
                get_char(current_char);
                hwrite(lineout, std_ulogic_vector(to_unsigned(current_char, 8)));   
                write(lineout, ' ');      
            end loop;
            writeline(stim, lineout);
        end loop;  
        file_close(stim);
        
        file_open(stim, payload_out_file2, write_mode);
        -- Finally, get all of the image data
        for row in 1 to 64 loop
            for col in 1 to 64 loop
                get_char(current_char);
                hwrite(lineout, std_ulogic_vector(to_unsigned(current_char, 8)));   
                write(lineout, ' ');      
            end loop;
            writeline(stim, lineout);
        end loop;  
        file_close(stim);
    end process;

    -- Stimulus process
    process

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
        
        -- file IO
        constant payload_file   : string := "payload.txt";
        file     stim           : text;
        variable L_IN           : line;
        variable EOL_N          : boolean := TRUE;    
        variable byte_out       : std_ulogic_vector(7 downto 0);
    begin
        sys_rst         <= '1';
        arq_en          <= '1';
        corrupt_en      <= '1';
        
        file_open(stim, payload_file, read_mode);
        
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
        -- "refresh" file
        --file_open(stim, payload_file, read_mode);
        --wait for 5 us;
        file_close(stim);
        --corrupt_en <= '0';
        wait until retrans_wait = '1';
        wait until retrans_wait = '1';
        corrupt_en <= '0';
        wait for 500 ms;
        
--        while not endfile(stim) loop
--            readline(stim, L_IN);          -- get line
--            hread(L_IN, byte_out, EOL_N); -- get first byte
--            while (EOL_N = true) loop
--                send_char(unsigned(byte_out));
--                hread(L_IN, byte_out, EOL_N);
--                wait for 0 ns;
--            end loop;
--            EOL_N := true;
--        end loop;    
        
        wait for 2000 ms;  
        
        assert false
            report "End of simulation"
            severity failure;
        wait;

    end process;

end tb;