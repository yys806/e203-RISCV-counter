`timescale 1ns/1ns
`define USING_IVERILOG


module tb_top();
	reg  mclk;
	reg  rst_n;
	wire [3:0] cc;
	wire [7:0] seg_out;

`ifdef USING_IVERILOG
	initial begin
		$dumpfile("waveout.vcd");
		$dumpvars(0, tb_top);
	end
`endif


initial begin
	#2s;
	$finish;
end


initial begin
    mclk        <=0;
    rst_n      <=0;
    #10us rst_n <=1;
end


always begin 
    #18.52 mclk <= ~mclk;
end



led_seg_display uut (
	.clk_in             (mclk),  

	.rst_n              (rst_n),
	.cc                 (cc),
	.seg_out            (seg_out)
	
);

endmodule
