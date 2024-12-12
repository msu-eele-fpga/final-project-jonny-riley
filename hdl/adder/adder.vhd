library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;
use ieee.math_real.all;

entity adder is
    port(
        clk             : in std_ulogic;                     -- system clock
        rst             : in std_ulogic;                     -- system reset (assume active high, change at top level if needed)
        push_button     : in std_ulogic;                     -- Pushbutton adds to the LED on every push
        amount          : in unsigned(7 downto 0);           -- Amount the binary will add by on each button press
        led             : out std_ulogic_vector(6 downto 0)  -- LEDs on the DE10-Nano board (only using 0 through 6)
    );
end entity adder;

architecture adder_arch of adder is
    -- Async Conditioner is used to debouce and syncronize the push button press
    component async_conditioner is
        port (
            clk     : in std_ulogic;
            rst     : in std_ulogic;
            async   : in std_ulogic;
            sync    : out std_ulogic);
    end component async_conditioner;

    signal sync_button  : std_ulogic;
    
    -- Count is 6 downto 0 to match the led output we expecct
    signal count : unsigned(6 downto 0) := "0000000";

    begin

        button_conditioner : async_conditioner 
        port map(
            clk =>  clk,
            rst => rst,
            async => push_button,
            sync => sync_button);

        -- On button push add amount to count
        state_logic : process(clk, rst, sync_button)
            begin
                if rst = '1' then
                    count <= "0000000";
                elsif rising_edge(clk) then
                    if sync_button = '1' then
                        count <= count + amount(6 downto 0);
                    end if;

                end if;
        end process state_logic;

        -- Always updating leds to count
        output_logic : process(clk)
            begin
                if rst = '1' then
                    led <= "0000000";
                elsif rising_edge(clk) then
                    led <= std_ulogic_vector(count);
                end if;

        end process output_logic;

    end architecture;


 