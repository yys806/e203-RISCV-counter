//=====================================================================
//
// Description:
//  4-digit 7-seg driver with ICB register interface
//
//  Register map (offset from base):
//   0x00: CTRL[0] = count enable
//   0x04: DATA[15:0] = {digit3,digit2,digit1,digit0} (BCD)
//
// ====================================================================

module my_periph_example(
    input                   clk,
    input                   rst_n,

    input                   i_icb_cmd_valid,
    output                  i_icb_cmd_ready,
    input  [32-1:0]         i_icb_cmd_addr,
    input                   i_icb_cmd_read,
    input  [32-1:0]         i_icb_cmd_wdata,

    output                  i_icb_rsp_valid,
    input                   i_icb_rsp_ready,
    output [32-1:0]         i_icb_rsp_rdata,

    output                  io_interrupts_0_0,
    output [7:0]            seg_out,
    output [3:0]            cc
);

  localparam CTRL_ADDR = 12'h000;
  localparam DATA_ADDR = 12'h004;
  localparam integer CLK_HZ = 18_000_000;
  localparam integer DIV_200HZ = CLK_HZ / 200;

  reg [31:0] icb_data_out;
  reg        icb_rsp_valid;

  reg        count_en;
  reg [3:0]  digit0;
  reg [3:0]  digit1;
  reg [3:0]  digit2;
  reg [3:0]  digit3;

  reg [1:0]  digit_cnt;
  reg [3:0]  digit_out;
  reg [7:0]  seg_decode_out;
  reg [3:0]  cc_reg;

  reg [17:0] cnt_200hz;
  reg [7:0]  cnt_1hz;

  wire sel_ctrl = (i_icb_cmd_addr[11:0] == CTRL_ADDR);
  wire sel_data = (i_icb_cmd_addr[11:0] == DATA_ADDR);
  wire icb_rd_en = i_icb_cmd_valid && i_icb_cmd_read && (sel_ctrl || sel_data);
  wire icb_wr_en = i_icb_cmd_valid && (~i_icb_cmd_read) && (sel_ctrl || sel_data);
  wire icb_wr_ctrl = icb_wr_en && sel_ctrl;
  wire icb_wr_data = icb_wr_en && sel_data;

  wire tick_200hz = (cnt_200hz == (DIV_200HZ - 1));
  wire tick_1hz = tick_200hz && (cnt_1hz == 8'd199);

  wire [31:0] reg_ctrl = {31'b0, count_en};
  wire [31:0] reg_data = {16'b0, digit3, digit2, digit1, digit0};

  assign i_icb_cmd_ready = i_icb_cmd_valid;
  assign i_icb_rsp_valid = i_icb_rsp_ready && icb_rsp_valid;
  assign i_icb_rsp_rdata = icb_data_out;
  assign io_interrupts_0_0 = 1'b0;

  // Generate scan and count ticks.
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      cnt_200hz <= 17'b0;
      cnt_1hz <= 8'b0;
    end else if (tick_200hz) begin
      cnt_200hz <= 17'b0;
      if (cnt_1hz == 8'd199) begin
        cnt_1hz <= 8'b0;
      end else begin
        cnt_1hz <= cnt_1hz + 1'b1;
      end
    end else begin
      cnt_200hz <= cnt_200hz + 1'b1;
    end
  end

  // Control register.
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      count_en <= 1'b1;
    end else if (icb_wr_ctrl) begin
      count_en <= i_icb_cmd_wdata[0];
    end
  end

  // BCD digits update (write or auto count).
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      digit0 <= 4'b0;
      digit1 <= 4'b0;
      digit2 <= 4'b0;
      digit3 <= 4'b0;
    end else if (icb_wr_data) begin
      digit0 <= i_icb_cmd_wdata[3:0];
      digit1 <= i_icb_cmd_wdata[7:4];
      digit2 <= i_icb_cmd_wdata[11:8];
      digit3 <= i_icb_cmd_wdata[15:12];
    end else if (tick_1hz && count_en) begin
      if (digit0 == 4'd9) begin
        digit0 <= 4'd0;
        if (digit1 == 4'd9) begin
          digit1 <= 4'd0;
          if (digit2 == 4'd9) begin
            digit2 <= 4'd0;
            if (digit3 == 4'd9) begin
              digit3 <= 4'd0;
            end else begin
              digit3 <= digit3 + 1'b1;
            end
          end else begin
            digit2 <= digit2 + 1'b1;
          end
        end else begin
          digit1 <= digit1 + 1'b1;
        end
      end else begin
        digit0 <= digit0 + 1'b1;
      end
    end
  end

  // ICB response handling.
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      icb_rsp_valid <= 1'b0;
      icb_data_out <= 32'b0;
    end else begin
      if (icb_rd_en) begin
        icb_data_out <= sel_ctrl ? reg_ctrl : reg_data;
        icb_rsp_valid <= 1'b1;
      end else if (icb_wr_en) begin
        icb_rsp_valid <= 1'b1;
      end else begin
        icb_rsp_valid <= 1'b0;
      end
    end
  end

  // Digit scan counter (200 Hz).
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      digit_cnt <= 2'b0;
    end else if (tick_200hz) begin
      digit_cnt <= digit_cnt + 1'b1;
    end
  end

  // 4:1 mux for digit.
  always @(*) begin
    case (digit_cnt)
      2'b00: digit_out = digit0;
      2'b01: digit_out = digit1;
      2'b10: digit_out = digit2;
      2'b11: digit_out = digit3;
      default: digit_out = 4'b0000;
    endcase
  end

  // 7-segment decoder (active low).
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

  // Digit enable decoder.
  always @(*) begin
    case (digit_cnt)
      2'b00: cc_reg = 4'b1000; // rightmost digit
      2'b01: cc_reg = 4'b0100;
      2'b10: cc_reg = 4'b0010;
      2'b11: cc_reg = 4'b0001; // leftmost digit
      default: cc_reg = 4'b0000;
    endcase
  end

  assign seg_out = ~seg_decode_out;
  assign cc = cc_reg;

endmodule
