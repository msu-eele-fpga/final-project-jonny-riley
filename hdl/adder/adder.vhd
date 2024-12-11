library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;
use ieee.math_real.all;

entity adder is
    port(
        clk             : in std_ulogic; -- system clock
        rst             : in std_ulogic; -- system reset (assume active high, change at top level if needed)
        push_button     : in std_ulogic; -- Pushbutton to change state (assume active high, change at top level if needed)
        amount          : in std_logic_vector(3 downto 0) -- Amount the binary will add by on each button press
        led             : out std_ulogic_vector(7 downto 0) -- LEDs on the DE10-Nano board
    );
end entity adder;

architecture adder_arch of adder is

    component async_conditioner is
        port (
            clk     : in std_ulogic;
            rst     : in std_ulogic;
            async   : in std_ulogic;
            sync    : out std_ulogic);
    end component async_conditioner;

    signal sync_button  : std_ulogic;

    signal count : std_logic_vector(7 downto 0);

    begin

        button_conditioner : async_conditioner 
        port map(
            clk =>  clk,
            rst => rst,
            async => push_button,
            sync => sync_button);

            state_logic : process(clk, rst, sync_button)
                begin
                    if rst = '1' then
                        count <= "00000000";
                    elsif rising_edge(clk) then
                        if sync_button = "1" then
                            count <= count + amount;
                        end if;

                    end if;
            end process state_logic;

            
            output_logic : process(clk)

                begin
                    if rst = '1' then
                        led <= "00000000";
                    elsif rising_edge(clk) then
                        led <= count;
                    end if;

            end process output_logic;


            


    end architecture;


 