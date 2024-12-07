
module unsaved (
	clk_clk,
	reset_reset_n,
	led_patterns_push_button,
	led_patterns_switches,
	led_patterns_led);	

	input		clk_clk;
	input		reset_reset_n;
	input		led_patterns_push_button;
	input	[3:0]	led_patterns_switches;
	output	[7:0]	led_patterns_led;
endmodule
