-----------------------------
-- timer_alavon.vhdr, EELE467 final
-- Riley Holmes, Jonny Hughes
-- 12/11/24
-- lets up read and write to registers that control timer.vhd
-----------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;
use ieee.math_real.all;

entity timer_avalon is
    port (
    clk             : in std_ulogic;
    rst             : in std_ulogic;
    -- avalon memory-mapped slave interface
    avs_read        : in std_logic;
    avs_write       : in std_logic;
    avs_address     : in std_logic_vector(1 downto 0);
    avs_readdata    : out std_logic_vector(31 downto 0);
    avs_writedata   : in std_logic_vector(31 downto 0);
    -- external I/O; export to top-level
    push_button     : in std_logic;
    LED             : out std_logic
    );
end entity timer_avalon;


architecture timer_avalon_arch of timer_avalon is 

    

         component timer
            port(
              clk         : in std_logic;
              rst         : in std_logic;
              push_button : in std_logic;
              start       : in std_logic;
              time_out    : out unsigned(19 downto 0);
              LED         : out std_logic
            );
        end component;

        signal start : std_logic := '0';
        signal time_out : unsigned(19 downto 0) := "00000000000000000000";


        begin

            dut : component timer
            port map(
                clk => clk,
                rst => rst,
                push_button => push_button,
                start => start,
                time_out => time_out,
                LED => LED
            );


       

        avalon_register_read : process(clk)
        begin
            if rising_edge(clk) and avs_read = '1' then
                case avs_address is
                when "00" => avs_readdata <= "0000000000000000000000000000000" & start;

                when "01" => avs_readdata <= "000000000000" & std_logic_vector(time_out);

                when others => avs_readdata <= (others =>'0'); -- return zeros for unused registers

                end case;
            end if;
        end process;

        avalon_register_write : process(clk, rst)
        begin
            if rst = '1' then
                

                elsif rising_edge(clk) and avs_write = '1' then
                    case avs_address is
                    when "00" => start <= avs_writedata(0);

                    when others => null;
                    end case;
            end if;
        end process;

end architecture timer_avalon_arch;