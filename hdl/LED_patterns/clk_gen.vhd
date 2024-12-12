library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;
use ieee.math_real.all;

entity clk_gen is
    generic(
        NUM_OF_BITS             : natural
    );
    port(
            clk                  : in std_ulogic;
            rst                  : in std_ulogic;
            cnt                  : in unsigned(NUM_OF_BITS downto 0);
            base_clock           : out std_ulogic;
            half_base_clock      : out std_ulogic;
            quarter_base_clock   : out std_ulogic;
            eigth_base_clock     : out std_ulogic;
            twice_base_clock     : out std_ulogic);
end entity clk_gen;

architecture clk_gen_arch of clk_gen is

    signal counter1 : unsigned(NUM_OF_BITS downto 0) := (others => '0');
    signal counter2 : unsigned(NUM_OF_BITS downto 0) := (others => '0');
    signal counter3 : unsigned(NUM_OF_BITS downto 0) := (others => '0');
    signal counter4 : unsigned(NUM_OF_BITS downto 0) := (others => '0');
    signal counter5 : unsigned(NUM_OF_BITS downto 0) := (others => '0');

    signal cnt_times_two : unsigned(NUM_OF_BITS downto 0);


    begin 
	     cnt_times_two <= shift_left(cnt, 1);

        -- generate the base clock speed of 1 second
        base_rate : process(clk, rst)
            begin
                if rst = '1' then
                    base_clock <= '0';
                elsif rising_edge(clk) then
                    if counter1 >= cnt then
                        counter1 <= (others => '0');
                        base_clock <= '1';
                    elsif counter1 < cnt then
                        base_clock <= '0';
                        counter1 <= counter1 + 1;
                    else
                        base_clock <= '0';
                        counter1 <= (others => '0');
                    end if;
                end if;
            end process base_rate;

            half_base : process(clk, rst)
                begin
                    if rst = '1' then
                        half_base_clock <= '0';
                    elsif rising_edge(clk) then
                        if counter2 >= cnt/2 then
                            counter2 <= (others => '0');
                            half_base_clock <= '1';
                        elsif counter2 < cnt/2 then
                            half_base_clock <= '0';
                            counter2 <= counter2 + 1;
                        else
                            half_base_clock <= '0';
                            counter2 <= (others => '0');
                        end if;
                    end if;
            end process half_base;

            quarter_base : process(clk, rst)
                begin
                    if rst = '1' then
                        quarter_base_clock <= '0';
                    elsif rising_edge(clk) then
                        if counter5 >= cnt/4 then
                            counter5 <= (others => '0');
                            quarter_base_clock <= '1';
                        elsif counter5 < cnt/4 then
                            quarter_base_clock <= '0';
                            counter5 <= counter5 + 1;
                        else
                            quarter_base_clock <= '0';
                            counter5 <= (others => '0');
                        end if;
                    end if;
            end process quarter_base;

            eigth_base : process(clk, rst)
                begin
                    if rst = '1' then
                        eigth_base_clock <= '0';
                    elsif rising_edge(clk) then
                        if counter3 >= cnt/8 then
                            counter3 <=(others => '0');
                            eigth_base_clock <= '1';
                        elsif counter3 < cnt/8 then
                            eigth_base_clock <= '0';
                            counter3 <= counter3 + 1;
                        else
                            eigth_base_clock <= '0';
                            counter3 <= (others => '0');
                        end if;
                    end if;
            end process eigth_base;

            twice_base : process(clk, rst)
                begin
                    if rst = '1' then
                        twice_base_clock <= '0';
                    elsif rising_edge(clk) then
                        if counter4 >= cnt_times_two then
                            counter4 <= (others => '0');
                            twice_base_clock <= '1';
                        elsif counter4 < cnt_times_two then
                            twice_base_clock <= '0';
                            counter4 <= counter4 + 1;
                        else
                            twice_base_clock <= '0';
                            counter4 <= (others => '0');
                        end if;
                    end if;
            end process twice_base;

        
        
                    

        

end architecture clk_gen_arch;