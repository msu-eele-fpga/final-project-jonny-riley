library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;
use ieee.math_real.all;

entity timer is
    port(
      clk       : in std_logic;
      rst       : in std_logic;
      pb        : in std_logic;
      start     : in std_logic;
      time_out  : out unsigned(19 downto 0);
      LED       : out std_logic
    );
end entity;

architecture timer_arch of timer is 

    type state_type is (idle, delay, timer);
    signal state : state_type;

    
    
    signal pb_sync : std_logic;

    signal count : unsigned(19 downto 0) := "00000000000000000000";
    signal delay_counter : integer := 0;

    

    component async_conditioner is
        port (
            clk     :  in std_ulogic;
            rst     :  in std_ulogic;
            async   :  in std_ulogic;
            sync    : out std_ulogic
        );
    end component async_conditioner;


    begin

        time_out <= count;

        pb_conditioner  : component async_conditioner 
            port map (
                clk => clk,
                rst => rst, 
                async => pb,
                sync  => pb_sync
            );
        
        state_logic : process(clk,rst)
          begin
          if rst = '1' then
            state <= idle;
          elsif rising_edge(clk) then
            case state is
                when idle =>
                    if start = '1' then
                        state <= delay;
                    else
                        LED <= '0';
                        state <= idle;
                    end if;
                when delay =>
                    if delay_counter >= 100 then --100000000
                        state <= timer;
                        count <= "00000000000000000000";
                        LED <= '0';
                    else
                        LED <= '1';
                        state <= delay;
                        delay_counter <= delay_counter + 1;
                    end if;
                when timer => 
                    if pb_sync = '1' then
                        state <= idle;
                        delay_counter <= 0;
                    else 
                        count <= count + 1;
                        state <= timer;
                    end if;
                when others =>
                    state <= idle;
            end case;
          end if;
        end process;


end architecture timer_arch;