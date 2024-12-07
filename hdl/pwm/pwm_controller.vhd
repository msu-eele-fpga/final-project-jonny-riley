library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;
use ieee.math_real.all;

entity pwm_controller is
    generic (
        CLK_PERIOD : time := 20 ns
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        -- PWM repetition period in milliseconds;
        -- datatype (W.F) is individually assigned
        period : in unsigned(31 - 1 downto 0);
        -- PWM duty cycle between [0 1]; out-of-range values are hard-limited
        -- datatype (W.F) is individually assigned
        duty_cycle : in std_logic_vector(18 - 1 downto 0);
        output : out std_logic
    );
end entity pwm_controller;

architecture pwm_controller_arch of pwm_controller is

    signal counter          : unsigned(31 - 1 downto 0) :=  (others => '0');

    --# of bits required to represent the clock frequency
    constant N_BITS_SYS_CLK_FREQ : natural := natural(ceil(log2(real(1 ms / CLK_PERIOD))));

    -- convert to unsigned
    constant SYS_CLK_FREQ : unsigned(N_BITS_SYS_CLK_FREQ - 1 downto 0) := to_unsigned((1 ms / CLK_PERIOD), N_BITS_SYS_CLK_FREQ);

    --# of bits required to represent the multiplication for the period
    constant N_BITS_CLK_CYCLES_FULL : natural := N_BITS_SYS_CLK_FREQ + 31;

    -- # of bit required to represent the integer part of SYS_CLK_FREQ * period 
    constant N_BITS_CLK_CYCLES : natural := N_BITS_SYS_CLK_FREQ + 6;

    --# of clock cycles in in one base period
    -- this has the same number of factional bits at the base_period
    signal period_clk_full_prec : unsigned(N_BITS_CLK_CYCLES_FULL - 1 downto 0);

    -- Number of clock cycles in one base period 
    -- represented as an integer
    signal period_clk : unsigned(N_BITS_CLK_CYCLES - 1 downto 0);



    -- for duty cycle multiplication
    constant DUTY_COUNT_BITS_FULL : natural := N_BITS_CLK_CYCLES_FULL + 18;

    -- for integer bits of duty multiplication
    constant DUTY_COUNT_BITS : natural := N_BITS_CLK_CYCLES_FULL + 1;

    -- full multiplication 
    signal duty_count_full_prec : unsigned(DUTY_COUNT_BITS_FULL - 1 downto 0);

    --integer amount of clock cycles in the duty cycle 
    signal duty_count : unsigned(22 downto 0);

    -- type cast of logic vector to unsiged
    signal duty_cycle_scaled : unsigned(17 downto 0);




    

    begin

        duty_cycle_scaled <= unsigned(duty_cycle);

        period_clk_full_prec <= SYS_CLK_FREQ * period;

        -- get rid of factional bits of SYS_CLK_FREQ * base_period so we have
        -- an integer number of clock cycles.
        period_clk <= period_clk_full_prec(N_BITS_CLK_CYCLES_FULL - 1 downto 25);

        -- Convert duty_cycle to unsigned and compute duty count with fixed-point scaling
        duty_count_full_prec <= period_clk_full_prec * duty_cycle_scaled;

        --Integers value of clock cycles in the duty cycle
        duty_count <= duty_count_full_prec(DUTY_COUNT_BITS_FULL - 1 downto 25+17);

        -- Extract the integer part of duty_count_full by shifting out fractional bits
        --duty_count <= duty_count_full(N_BITS_CLK_CYCLES_FULL + 18 - 1 downto 17);



        pwm_generatr : process(clk)
        begin
            if rising_edge(clk) then
                if rst = '1' then
                    counter <= (others => '0');
                    output <= '0';
                else

                    if counter < period_clk then
                        counter <= counter + 1;
                    elsif counter >= period_clk then
                        counter <= (others => '0');
                    else 
                        counter <= (others => '0');
                        
                    end if;
                    
                    if counter < duty_count then
                        output <= '1';
                    else
                        output <= '0';
                    end if;

                end if;
            end if;
        end process;
end architecture ; -- pwm_controller
