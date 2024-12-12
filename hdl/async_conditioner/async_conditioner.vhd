library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity async_conditioner is
    port (
        clk     :  in std_ulogic;
        rst     :  in std_ulogic;
        async   :  in std_ulogic;
        sync    : out std_ulogic
    );
end entity async_conditioner;

architecture async_conditioner_arch of async_conditioner is

    component one_pulse is
        port (
          clk    : in    std_logic;
          rst    : in    std_ulogic;
          input  : in    std_ulogic;
          pulse  : out    std_ulogic
        );
    end component one_pulse;
    
    component debouncer is
        generic (
        clk_period : time := 20 ns;
        debounce_time : time
        );
        port (
        clk : in std_ulogic;
        rst : in std_ulogic;
        input : in std_ulogic;
        debounced : out std_ulogic
        );
    end component debouncer;
    
    component synchronizer is
        port (
        clk     : in  std_ulogic;
        async   : in  std_ulogic;
        sync    : out std_ulogic
        );
    end component synchronizer;

    signal s_out : std_ulogic;
    signal d_out : std_ulogic;

    constant CLK_PERIOD    : time := 20 ns;
    constant DEBOUNCE_TIME : time := 100 ns;

    begin
    
    s1 : synchronizer 
        port map(
            clk =>  clk,
            async => async,
            sync => s_out);

    d1 : debouncer
        generic map (
            clk_period => CLK_PERIOD,
            debounce_time => DEBOUNCE_TIME)
        port map (
            clk => clk,
            rst => rst,
            input => s_out,
            debounced => d_out);

    o1 : one_pulse
        port map (
            clk => clk,
            rst => rst,
            input => d_out, 
            pulse => sync);

end architecture async_conditioner_arch;