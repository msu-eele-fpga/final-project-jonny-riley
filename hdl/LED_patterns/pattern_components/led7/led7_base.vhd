library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;
use ieee.math_real.all;

entity led7_base is
    port(
            clk                  : in std_ulogic;    -- this will trigger every second coming from clock gen
            rst                  : in std_ulogic;
            enable               : in boolean;       -- Tells the component its on
            led7                 : buffer std_ulogic); -- Output led 
    
end entity led7_base;


--Flashes at base rate
architecture led7_base_arch of led7_base is
    

    
    signal led_state : std_ulogic := '0';


    begin 


        -- generate the base clock speed of 1 second
        toggle : process(clk, rst)
    begin
        if rst = '1' then
            led_state <= '0';  -- Reset the LED to off
        elsif rising_edge(clk) then
            if enable = true then
                -- Toggle the led state
                led_state <= not led_state;
            else
                led_state <= '0';  -- Turn off LED when not enabled
            end if;
        end if;
    end process toggle;

    -- Drive the output
    led7 <= led_state;

end architecture led7_base_arch;
