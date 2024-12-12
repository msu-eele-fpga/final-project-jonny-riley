library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;
use ieee.math_real.all;

entity led_patterns is
    generic(
        SYSTEM_CLOCK_PERIOD : time  := 20 ns);
    port(
        clk             : in std_ulogic; -- system clock
        rst             : in std_ulogic; -- system reset (assume active high, change at top level if needed)
        push_button     : in std_ulogic; -- Pushbutton to change state (assume active high, change at top level if needed)
        switches        : in std_ulogic_vector(3 downto 0); -- Switches that determine the next state to be selected
        hps_led_control : in std_logic; -- Software is in control when asserted (=1)
        base_period     : in unsigned(7 downto 0); -- base transition period in seconds , fixed -point data type (W=8, F=4).
        led_reg         : in std_ulogic_vector(7 downto 0); -- LED register
        led             : out std_ulogic_vector(7 downto 0) -- LEDs on the DE10-Nano board
    );
end entity led_patterns;

architecture led_patterns_arch of led_patterns is

    --# of bits required to represent the clock frequency
    constant N_BITS_SYS_CLK_FREQ : natural := natural(ceil(log2(real(1 sec / SYSTEM_CLOCK_PERIOD))));

    -- convert to unsigned
    constant SYS_CLK_FREQ : unsigned(N_BITS_SYS_CLK_FREQ - 1 downto 0) := to_unsigned((1 sec / SYSTEM_CLOCK_PERIOD), N_BITS_SYS_CLK_FREQ);

    --# of bits required to represent the multiplication
    constant N_BITS_CLK_CYCLES_FULL : natural := N_BITS_SYS_CLK_FREQ + 8;

    -- # of bit required to represent the integer part of SYS_CLK_FREQ * base_period 
    constant N_BITS_CLK_CYCLES : natural := N_BITS_SYS_CLK_FREQ + 4;

    --# of clock cycles in in one base period
    -- this has the same number of factional bits at the base_period
    signal period_base_clk_full_prec : unsigned(N_BITS_CLK_CYCLES_FULL - 1 downto 0);

    -- Number of clock cycles in one base period 
    -- represented as an integer
    signal period_base_clk : unsigned(N_BITS_CLK_CYCLES - 1 downto 0);

    --constant N_BITS_CLK_CYCLES : natural := 4;
    --signal period_base_clk : unsigned(3 downto 0) := "1010";

    component clk_gen is
        generic (
            NUM_OF_BITS         : natural := N_BITS_CLK_CYCLES - 1
        );
        port (
            clk                  : in std_ulogic;
            rst                  : in std_ulogic;
            cnt                  : in unsigned(N_BITS_CLK_CYCLES - 1 downto 0);
            base_clock           : out std_ulogic;
            half_base_clock      : out std_ulogic;
            quarter_base_clock   : out std_ulogic;
            eigth_base_clock     : out std_ulogic;
            twice_base_clock     : out std_ulogic);
    end component clk_gen;

    component timed_counter is
        generic (
            clk_period : time;
            count_time : time
        );
        port (
            clk : in std_ulogic;
            enable : in boolean;
            done : out boolean
        );
    end component timed_counter;

    component led7_base is
        port(
                clk                  : in std_ulogic;    -- this will trigger every second coming from clock gen
                rst                  : in std_ulogic;
                enable               : in boolean;       -- Tells the component its on
                led7                 : out std_ulogic); -- Output led 
    end component led7_base;

    component state0 is
        port(
                clk                  : in std_ulogic;    -- this will trigger every second coming from clock gen
                rst                  : in std_ulogic;
                leds                 : out std_ulogic_vector(6 downto 0)); -- Output led 
    end component state0;

    component state1 is
        port(
                clk                  : in std_ulogic;    -- this will trigger every second coming from clock gen
                rst                  : in std_ulogic;
                leds                 : out std_ulogic_vector(6 downto 0)); -- Output led 
    end component state1;

    component state2 is
        port(
                clk                  : in std_ulogic;    -- this will trigger every second coming from clock gen
                rst                  : in std_ulogic;
                leds                 : out std_ulogic_vector(6 downto 0)); -- Output led 
    end component state2;

    component state3 is
        port(
                clk                  : in std_ulogic;    -- this will trigger every second coming from clock gen
                rst                  : in std_ulogic;
                leds                 : out std_ulogic_vector(6 downto 0)); -- Output led 
    end component state3;

    component state4 is
        port(
                clk                  : in std_ulogic;    -- this will trigger every second coming from clock gen
                rst                  : in std_ulogic;
                leds                 : out std_ulogic_vector(6 downto 0)); -- Output led 
    end component state4;




    component async_conditioner is
        port (
            clk     : in std_ulogic;
            rst     : in std_ulogic;
            async   : in std_ulogic;
            sync    : out std_ulogic);
    end component async_conditioner;

    signal sync_button  : std_ulogic;

    type selection_state_type is (SW, S0_walking_one, S1_walking_two, S2_up_counter,
                                  S3_down_counter, S4);
    signal select_state : selection_state_type;

    signal led7_enable             : boolean := false;
    signal led7_output             : std_ulogic;


    signal base_clock           : std_ulogic;
    signal half_base_clock      : std_ulogic;
    signal quarter_base_clock   : std_ulogic;
    signal eigth_base_clock     : std_ulogic;
    signal twice_base_clock     : std_ulogic;
    signal enable_one_sec       : boolean;
    signal done_timer           : boolean;

    signal led_output_s0       : std_ulogic_vector(6 downto 0) := "0000001";
    signal led_output_s1       : std_ulogic_vector(6 downto 0) := "0000011";
    signal led_output_s2       : std_ulogic_vector(6 downto 0) := "0000001";
    signal led_output_s3       : std_ulogic_vector(6 downto 0) := "1111111";
    signal led_output_s4       : std_ulogic_vector(6 downto 0) := "0000111";

    begin

    
        period_base_clk_full_prec <= SYS_CLK_FREQ * base_period;

        -- get rid of factional bits of SYS_CLK_FREQ * base_period so we have
        -- an integer number of clock cycles.
        period_base_clk <= period_base_clk_full_prec(N_BITS_CLK_CYCLES_FULL - 1 downto 4);

        button_conditioner : async_conditioner 
        port map(
            clk =>  clk,
            rst => rst,
            async => push_button,
            sync => sync_button);

        dut_1s_counter : component timed_counter
            generic map (
                clk_period => SYSTEM_CLOCK_PERIOD,
                count_time =>  1 sec
            )
            port map (
                clk => clk,
                enable => enable_one_sec,
                done => done_timer
            );

        clock_generator : component clk_gen 
            generic map(
                NUM_OF_BITS => N_BITS_CLK_CYCLES - 1
            )
            port map(
                clk =>  clk,
                rst => rst,
                cnt => period_base_clk,
                base_clock => base_clock,
                half_base_clock => half_base_clock,
                quarter_base_clock => quarter_base_clock,
                eigth_base_clock => eigth_base_clock,
                twice_base_clock => twice_base_clock);
       
        led7_comp : led7_base
            port map(
            clk => base_clock,
            rst => rst,
            enable => led7_enable,
            led7 => led7_output
        );

        state0_comp : state0
            port map (
                clk => half_base_clock,
                rst => rst,
                leds => led_output_s0);

        state1_comp : state1
            port map (
                clk => quarter_base_clock,
                rst => rst,
                leds => led_output_s1);

        state2_comp : state2
            port map (
                clk => twice_base_clock,
                rst => rst,
                leds => led_output_s2);


        state3_comp : state3
            port map (
                clk => eigth_base_clock,
                rst => rst,
                leds => led_output_s3);
    
        state4_comp : state4
            port map (
                clk => twice_base_clock,
                rst => rst,
                leds => led_output_s4);
                    


            state_logic : process(clk, rst, sync_button)
                begin
                    if rst = '1' then
                        select_state <= SW;
                    elsif rising_edge(clk) and hps_led_control = '0' then

                        case select_state is
                            when SW =>
                                	-- When button is presssed
                                	-- LEDs show state number for 1 second
                                	-- Next State is determined on Switches
                                	
                                	if switches = "0000" then
                                        if done_timer = true then
                                            select_state <= S0_walking_one;
                                        else
                                            select_state <= SW;
                                        end if;
                                    elsif switches = "0001" then
                                        if done_timer = true then
                                            select_state <= S1_walking_two;
                                        else    
                                            select_state <= SW;
                                        end if;
                                    elsif switches = "0010" then
                                        if done_timer = true then
                                            select_state <= S2_up_counter;
                                        else
                                            select_state <= SW;
                                        end if;
                                	elsif switches = "0100" then 
                                        if done_timer = true then
                                            select_state <= S3_down_counter;
                                        else
                                            select_state <= SW;
                                        end if;
                                    elsif switches = "1000" then
                                        if done_timer = true then
                                            select_state <= S4;
                                        else
                                            select_state <= SW;
                                        end if;
                                    else
                                        select_state <= SW;
                                    end if;
                                    

                                    
                            when S0_walking_one =>
                                --one leftt LED shifting right at 1/2 * Base_rate seconds
                                if sync_button = '1' then
                                    select_state <= SW;
                                else
                                    select_state <= S0_walking_one;
                                end if;
                                
                            when S1_walking_two =>
                                -- two lit LEDs, side-by-side, shifting left at 1/4 * Base_rate seconds

                                if sync_button = '1' then
                                    select_state <= SW;
                                else
                                    select_state <= S1_walking_two;
                                end if;

                            when S2_up_counter =>
                                -- 7-bit up counter running at 2 * Base_rate seconds

                                if sync_button = '1' then
                                    select_state <= SW;
                                else
                                    select_state <= S2_up_counter;
                                end if;

                            when S3_down_counter =>
                                -- 7-bit down counter running at 1/8 * Base_rate seconds

                                if sync_button = '1' then
                                    select_state <= SW;
                                else
                                    select_state <= S3_down_counter;
                                end if;
                            when S4 =>
                                -- User defined patter 
                                if sync_button = '1' then
                                    select_state <= SW;
                                else
                                    select_state <= S4;
                                end if;
                            
                            when others =>

                            end case;

                    end if;


            end process state_logic;

            output_logic : process(clk)

                begin
                    if rst = '1' then
                        led <= "00000000";
                    elsif rising_edge(clk) and hps_led_control = '0' then
						
                        case select_state is
                            when SW =>
                                led7_enable <= true;
                                enable_one_sec <= true;
                                led(7 downto 0) <= (others => '0');
                                led(3 downto 0) <= switches(3 downto 0);
                            when S0_walking_one => 
                                led7_enable <= true;
                                enable_one_sec <= false;
                                led(6 downto 0) <= led_output_s0;
                                led(7) <= led7_output;

                            when S1_walking_two =>
                                led7_enable <= true;
                                enable_one_sec <= false;
                                led(6 downto 0) <= led_output_s1;
                                led(7) <= led7_output;
                                

                            when S2_up_counter =>
                                enable_one_sec <= false;
                                led7_enable <= true;
                                led(6 downto 0) <= led_output_s2;
                                led(7) <= led7_output;  


                            when S3_down_counter =>
                                led7_enable <= true;
                                enable_one_sec <= false;
                                led(6 downto 0) <= led_output_s3;
                                led(7) <= led7_output;
                                


                            when S4 =>
                                enable_one_sec <= false;
                                led7_enable <= true;
                                led(6 downto 0) <= led_output_s4;
                                led(7) <= led7_output;
                                


                            when others =>
                                
                                led(6 downto 0) <= "0000000";
                                led(7) <= '1';
                                

                        end case;

                    elsif rising_edge(clk) and hps_led_control = '1' then
                        led <= led_reg;

                    end if;

            end process output_logic;


            


    end architecture;


 