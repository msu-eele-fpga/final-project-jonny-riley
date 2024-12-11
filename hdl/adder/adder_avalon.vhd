library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;
use ieee.math_real.all;

entity adder_avalon is
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
    push_button     : in std_ulogic;
    led             : out std_ulogic_vector(7 downto 0)
    );
end entity adder_avalon;


architecture adder_avalon_arch of adder_avalon is 

    component adder is
        port(
            clk             : in std_ulogic; -- system clock
            rst             : in std_ulogic; -- system reset (assume active high, change at top level if needed)
            push_button     : in std_ulogic; -- Pushbutton to change state (assume active high, change at top level if needed)
            amount          : in unsigned(7 downto 0); -- Amount the binary will add by on each button press
            led             : out std_ulogic_vector(7 downto 0) -- LEDs on the DE10-Nano board
        );
    end component adder;

        signal amount  : unsigned(7 downto 0);

    begin

        patterns : component adder
		port map (
			clk => clk,
			rst => rst,
			push_button => push_button,
            amount => amount,
			led => led
		);

        avalon_register_read : process(clk)
        begin
            if rising_edge(clk) and avs_read = '1' then
                case avs_address is
                when "00" => avs_readdata <= "000000000000000000000000" & amount;

                when others => avs_readdata <= (others =>'0'); -- return zeros for unused registers

                end case;
            end if;
        end process;

        avalon_register_write : process(clk, rst)
        begin
            if rst = '1' then
                amount <= "00000001";

                elsif rising_edge(clk) and avs_write = '1' then
                    case avs_address is
                    when "00" => amount <= unsigned(avs_writedata(0));

                    when others => null;
                    end case;
            end if;
        end process;

end architecture adder_avalon_arch;