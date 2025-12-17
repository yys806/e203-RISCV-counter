module clk_mng(
    input clk_in,
    input rst,
    output clk_out_1hz,
    output clk_out_200hz
);

reg [17:0] clk_cnt;
reg [7:0] clk_cnt_200hz;
reg clk_reg_1hz;
reg clk_reg_200hz;

// Assumes 27 MHz input clock
localparam integer DIV_200HZ = 67500;

// Generate 200 Hz clock from the input clock
always @(posedge clk_in or posedge rst) begin
    if (rst) begin
        clk_reg_200hz <= 0;
        clk_cnt <= 0;
    end 
    else begin
        if (clk_cnt == DIV_200HZ - 1) begin
            clk_reg_200hz <= ~clk_reg_200hz;
            clk_cnt <= 0;
        end
        else begin
            clk_cnt <= clk_cnt + 1;
        end
    end
end

// Generate 1Hz clocks from the 200Hz clock
always @(posedge clk_reg_200hz or posedge rst) begin
    if (rst) begin
        clk_cnt_200hz <= 0;
        clk_reg_1hz <= 0;
    end 
    else begin
        if (clk_cnt_200hz == 100 - 1) begin
            clk_cnt_200hz <= 0;
            clk_reg_1hz <= ~clk_reg_1hz;
        end 
        else begin
            clk_cnt_200hz <= clk_cnt_200hz + 1;
        end
    end
end

assign clk_out_1hz = clk_reg_1hz;
assign clk_out_200hz = clk_reg_200hz;

endmodule
