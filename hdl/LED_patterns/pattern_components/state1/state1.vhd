library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;
use ieee.math_real.all;

entity state1 is
    port(
            clk                  : in std_ulogic;    -- this will trigger every second coming from clock gen
            rst                  : in std_ulogic;
            leds                 : out std_ulogic_vector(6 downto 0)); -- Output led 
    
end entity state1;


--Flashes at base rate
architecture state1_arch of state1 is

    signal leds_last_state      : unsigned(6 downto 0);
    begin 


        -- generate the base clock speed of 1 second
        shift_right : process(clk, rst)
            begin
                if rst = '1' then
                    leds <= "0000011";
                    leds_last_state <= "0000011";
                elsif rising_edge(clk) then
                    leds_last_state <= leds_last_state rol 1;
                    leds <= std_ulogic_vector(leds_last_state);
                end if;
        end process shift_right;

end architecture state1_arch;
