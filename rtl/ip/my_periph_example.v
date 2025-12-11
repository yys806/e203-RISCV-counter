//=====================================================================
//
// Designer   : Modified for 4-digit 7-seg display (ICB slave)
//
// Description:
//  ICB compatible peripheral that drives a 4-digit common-cathode
//  seven-segment display with dynamic scanning. CPU writes display
//  data via registers; refresh runs autonomously once configured.
//
//  Register map (offset from ICB base, 0x1001_4000 in current SoC):
//    0x00: CTRL
//          [0]    enable (1: display active)
//          [15:0] scan_div reload for refresh prescaler (0 -> use 1024)
//    0x04: DATA
//          [3:0]   digit0 (rightmost) BCD
//          [7:4]   digit1
//          [11:8]  digit2
//          [15:12] digit3 (leftmost)
//          [19:16] dp enables for digit3..0
//
// ====================================================================

module my_periph_example(
    input                   clk,
    input                   rst_n,

    input                   i_icb_cmd_valid,
    output                  i_icb_cmd_ready,
    input  [31:0]           i_icb_cmd_addr, 
    input                   i_icb_cmd_read, 
    input  [31:0]           i_icb_cmd_wdata,

    output                  i_icb_rsp_valid,
    input                   i_icb_rsp_ready,
    output [31:0]           i_icb_rsp_rdata,

    output                  io_interrupts_0_0,
    output                  io_pad_out,

    output [7:0]            seg,       // {dp,g,f,e,d,c,b,a} active high
    output [3:0]            dig        // digit select, active low
);

    // Registers
    reg [31:0] ctrl_reg;  // bit0 enable, [15:0] scan divider reload
    reg [31:0] data_reg;  // packed digit/dp fields
    reg [15:0] auto_data; // internal free-running counter for fallback

    // ICB response handling
    reg [31:0] rsp_rdata;
    reg        rsp_valid;

    wire       reset = ~rst_n;

    // Ready when no outstanding response or consumer is ready
    assign i_icb_cmd_ready = (~rsp_valid) | i_icb_rsp_ready;
    assign i_icb_rsp_valid = rsp_valid;
    assign i_icb_rsp_rdata = rsp_rdata;

    // No interrupt for now
    assign io_interrupts_0_0 = 1'b0;
    assign io_pad_out        = 1'b0;

    // -----------------------------------------------------------------
    // Bus access decode
    wire sel_ctrl_rd = i_icb_cmd_valid && i_icb_cmd_read  && (i_icb_cmd_addr[11:0] == 12'h000) && i_icb_cmd_ready;
    wire sel_ctrl_wr = i_icb_cmd_valid && (~i_icb_cmd_read) && (i_icb_cmd_addr[11:0] == 12'h000) && i_icb_cmd_ready;
    wire sel_data_rd = i_icb_cmd_valid && i_icb_cmd_read  && (i_icb_cmd_addr[11:0] == 12'h004) && i_icb_cmd_ready;
    wire sel_data_wr = i_icb_cmd_valid && (~i_icb_cmd_read) && (i_icb_cmd_addr[11:0] == 12'h004) && i_icb_cmd_ready;

    // -----------------------------------------------------------------
    // Display scanning
    reg [3:0]  dig_en;      // active high internal
    reg [7:0]  seg_bits;
    reg [1:0]  scan_idx;
    reg [15:0] div_cnt;

    wire [15:0] div_reload = (ctrl_reg[15:0] == 16'd0) ? 16'd512 : ctrl_reg[15:0];
    wire        disp_en    = ctrl_reg[0];
    wire        auto_en    = ctrl_reg[1];

    // Segment encoder for one digit (dp handled separately)
    function [6:0] encode7seg;
        input [3:0] val;
        begin
            case (val)
                4'h0: encode7seg = 7'b0111111;
                4'h1: encode7seg = 7'b0000110;
                4'h2: encode7seg = 7'b1011011;
                4'h3: encode7seg = 7'b1001111;
                4'h4: encode7seg = 7'b1100110;
                4'h5: encode7seg = 7'b1101101;
                4'h6: encode7seg = 7'b1111101;
                4'h7: encode7seg = 7'b0000111;
                4'h8: encode7seg = 7'b1111111;
                4'h9: encode7seg = 7'b1101111;
                4'hA: encode7seg = 7'b1110111;
                4'hB: encode7seg = 7'b1111100;
                4'hC: encode7seg = 7'b0111001;
                4'hD: encode7seg = 7'b1011110;
                4'hE: encode7seg = 7'b1111001;
                4'hF: encode7seg = 7'b1110001;
                default: encode7seg = 7'b0000000;
            endcase
        end
    endfunction

    // Extract current digit nibbles and dp bits
    wire [3:0] digit0 = data_reg[3:0];
    wire [3:0] digit1 = data_reg[7:4];
    wire [3:0] digit2 = data_reg[11:8];
    wire [3:0] digit3 = data_reg[15:12];
    wire [3:0] dp_bits = data_reg[19:16];

    // -----------------------------------------------------------------
    // Sequential logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ctrl_reg   <= 32'h0000_0203; // enable=1, auto_en=1, default divider=0x200 (faster refresh)
            data_reg   <= 32'h0000_0000;
            auto_data  <= 16'd0;
            rsp_rdata  <= 32'h0;
            rsp_valid  <= 1'b0;
            div_cnt    <= 16'd0;
            scan_idx   <= 2'd0;
            seg_bits   <= 8'h00;
            dig_en     <= 4'b0001;
        end else begin
            // Clear response when accepted
            if (rsp_valid && i_icb_rsp_ready) begin
                rsp_valid <= 1'b0;
            end

            // Handle bus write
            if (sel_ctrl_wr) begin
                ctrl_reg  <= i_icb_cmd_wdata;
                rsp_rdata <= ctrl_reg;
                rsp_valid <= 1'b1;
            end else if (sel_data_wr) begin
                data_reg  <= i_icb_cmd_wdata;
                auto_data <= i_icb_cmd_wdata[15:0];
                rsp_rdata <= data_reg;
                rsp_valid <= 1'b1;
            end else if (sel_ctrl_rd) begin
                rsp_rdata <= ctrl_reg;
                rsp_valid <= 1'b1;
            end else if (sel_data_rd) begin
                rsp_rdata <= data_reg;
                rsp_valid <= 1'b1;
            end

            // Scan timer
            if (div_cnt == 16'd0) begin
                div_cnt  <= div_reload;
                scan_idx <= scan_idx + 2'd1;
            end else begin
                div_cnt  <= div_cnt - 16'd1;
            end

            // Internal auto counter as a fallback when CPU not writing
            if (auto_en && sel_data_wr == 1'b0) begin
                auto_data <= auto_data + 16'd1;
                data_reg  <= data_reg; // hold unless we choose to mirror auto_data below
                // Mirror auto_data into display when no ICB write
                data_reg[15:0] <= auto_data + 16'd1;
            end

            // Active digit selection (internal active high)
            case (scan_idx)
                2'd0: begin
                    dig_en   <= 4'b0001;
                    seg_bits <= {dp_bits[0], encode7seg(digit0)};
                end
                2'd1: begin
                    dig_en   <= 4'b0010;
                    seg_bits <= {dp_bits[1], encode7seg(digit1)};
                end
                2'd2: begin
                    dig_en   <= 4'b0100;
                    seg_bits <= {dp_bits[2], encode7seg(digit2)};
                end
                default: begin
                    dig_en   <= 4'b1000;
                    seg_bits <= {dp_bits[3], encode7seg(digit3)};
                end
            endcase
        end
    end

    // Output mapping (segments active high, digit select active high for this LED board)
    assign seg = disp_en ? seg_bits : 8'h00;
    assign dig = disp_en ?  dig_en  : 4'b0000;

endmodule
