module led_seg_display(
    input clk_in,
    input rst_n,
    output [3:0] cc,
    output [7:0] seg_out    
);

wire clk_out_1hz;
wire clk_out_200hz;

reg [3:0] digit0;
reg [3:0] digit1;
reg [3:0] digit2;
reg [3:0] digit3;
reg [1:0] digit_cnt;
reg [3:0] digit_out;
reg [7:0] seg_decode_out;
reg [3:0] cc_reg;

// BCD counter from 1 Hz clock
always @(posedge clk_out_1hz or negedge rst_n) begin
    if (!rst_n) begin
        digit0 <= 0;
        digit1 <= 0;
        digit2 <= 0;
        digit3 <= 0;
    end 
    else begin
        if (digit0 == 4'd9) begin
            digit0 <= 0;
            if (digit1 == 4'd9) begin
                digit1 <= 0;
                if (digit2 == 4'd9) begin
                    digit2 <= 0;
                    if (digit3 == 4'd9) begin
                        digit3 <= 0;
                    end else begin
                        digit3 <= digit3 + 1;
                    end
                end else begin
                    digit2 <= digit2 + 1;
                end
            end else begin
                digit1 <= digit1 + 1;
            end
        end else begin
            digit0 <= digit0 + 1;
        end
    end
end

//digit counter from 200hz
always @(posedge clk_out_200hz or negedge rst_n) begin
    if (!rst_n) begin
        digit_cnt <= 0;
    end 
    else begin
        if (digit_cnt == 2'b11) begin
            digit_cnt <= 0;
        end else begin
            digit_cnt <= digit_cnt + 1;
        end
    end
end

//4:1 mux for digit
always @(*) begin
    case (digit_cnt)
        2'b00: digit_out = digit0;
        2'b01: digit_out = digit1;
        2'b10: digit_out = digit2;
        2'b11: digit_out = digit3;
        default: digit_out = 4'b0000;
    endcase
end

//7-segment decoder
always @(*) begin
    case (digit_out)
        4'b0000: seg_decode_out = 8'b11000000; // 0
        4'b0001: seg_decode_out = 8'b11111001; // 1
        4'b0010: seg_decode_out = 8'b10100100; // 2
        4'b0011: seg_decode_out = 8'b10110000; // 3
        4'b0100: seg_decode_out = 8'b10011001; // 4
        4'b0101: seg_decode_out = 8'b10010010; // 5
        4'b0110: seg_decode_out = 8'b10000010; // 6
        4'b0111: seg_decode_out = 8'b11111000; // 7
        4'b1000: seg_decode_out = 8'b10000000; // 8
        4'b1001: seg_decode_out = 8'b10010000; // 9
        4'b1010: seg_decode_out = 8'b10001000; // A
        4'b1011: seg_decode_out = 8'b10000011; // B
        4'b1100: seg_decode_out = 8'b11000110; // C
        4'b1101: seg_decode_out = 8'b10100001; // D
        4'b1110: seg_decode_out = 8'b10000110; // E
        4'b1111: seg_decode_out = 8'b10001110; // F
        default: seg_decode_out = 8'b11111111; // off
    endcase
end

//cc decoder
always @(*) begin
    case (digit_cnt)
        2'b00: cc_reg = 4'b1000; // enable rightmost digit
        2'b01: cc_reg = 4'b0100; // enable next digit
        2'b10: cc_reg = 4'b0010; // enable next digit
        2'b11: cc_reg = 4'b0001; // enable leftmost digit
        default: cc_reg = 4'b0000; // disable all digits
    endcase
end

assign seg_out = ~seg_decode_out;
assign cc = cc_reg;

clk_mng inst_clk_mng(
    .clk_in(clk_in),
    .rst(~rst_n),
    .clk_out_1hz(clk_out_1hz),
    .clk_out_200hz(clk_out_200hz)
);


endmodule
