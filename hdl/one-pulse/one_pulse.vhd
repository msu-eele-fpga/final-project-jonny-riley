library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;  -- Add this for numeric conversions

  

entity one_pulse is 
    port(
        clk     : in  std_ulogic;
        rst     : in  std_ulogic;
        input   : in  std_ulogic;
        pulse   : out std_logic
    );
end entity;

architecture one_pulse_arch of one_pulse is

    type state_type is (idle, high, low, waiting);
    signal state : state_type;
    
    
    begin
        state_logic : process(clk,rst)
            begin
                if rst = '1' then
                    state <= idle;
                elsif rising_edge(clk) then
                    case state is
                        when idle => 
                            if input = '1' then 
                                state <= high;
                            else 
                                state <= idle;
                            end if;
                        when high =>
                            state <= low;
                        when low =>
                            if input = '0' then
                                state <= idle;
                            else
                                state <= low;
                            end if;
                        when others =>
                            state <= idle;
                    end case;

                end if;
        end process;
        
        output_logic : process(clk)
        begin
            if rising_edge(clk) then
                case state is
                    when idle =>
                        pulse <= '0';
                    when high =>
                        pulse <= '1';
                    when low =>
                        pulse <= '0';
                    when others =>
                        pulse <= '0';
                end case;
            end if;
        end process output_logic;
    


end architecture one_pulse_arch;