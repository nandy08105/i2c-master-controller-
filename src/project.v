/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */


module tt_um_example (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

// ── Pin assignments ──────────────────────────────────────────
// ui_in[7:0]  : {1b unused, 1b rw, 6b addr} when cmd_valid
// ui_in[7:0]  : write data byte when in DATA state
// uo_out[7:0] : read data byte / status
// uio_out[0]  : SCL
// uio_out[1]  : SDA out
// uio_in[1]   : SDA in
// uio_oe[1:0] : drive enables (SCL always out, SDA tristate)

// ── Parameters ───────────────────────────────────────────────
parameter CLK_DIV = 50; // clk cycles per SCL half-period

// ── Internal signals ─────────────────────────────────────────
reg scl_r, sda_out_r, sda_oe_r;
reg [7:0] data_out_r;

assign uio_out[0]   = scl_r;
assign uio_out[1]   = sda_out_r;
assign uio_out[7:2] = 6'b0;
assign uio_oe[0]    = 1'b1;        // SCL always driven
assign uio_oe[1]    = sda_oe_r;    // SDA tristate for read
assign uio_oe[7:2]  = 6'b0;
assign uo_out       = data_out_r;

wire sda_in = uio_in[1];

// ── FSM ──────────────────────────────────────────────────────
localparam IDLE    = 4'd0,
           START   = 4'd1,
           ADDR    = 4'd2,
           ACK1    = 4'd3,
           DATA    = 4'd4,
           ACK2    = 4'd5,
           STOP    = 4'd6,
           DONE    = 4'd7;

reg [3:0]  state;
reg [7:0]  clk_cnt;
reg [3:0]  bit_cnt;
reg [7:0]  shift_reg;
reg        rw_bit;     // 0=write, 1=read
reg        scl_phase;  // 0=lo, 1=hi

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state      <= IDLE;
        scl_r      <= 1'b1;
        sda_out_r  <= 1'b1;
        sda_oe_r   <= 1'b1;
        data_out_r <= 8'h00;
        clk_cnt    <= 8'd0;
        bit_cnt    <= 4'd0;
        scl_phase  <= 1'b0;
    end else begin
        case (state)
            // ── IDLE: wait for command ───────────────────────
            IDLE: begin
                scl_r     <= 1'b1;
                sda_out_r <= 1'b1;
                sda_oe_r  <= 1'b1;
                if (ui_in[7]) begin          // bit[7] = cmd_valid
                    rw_bit    <= ui_in[6];   // bit[6] = R/W
                    shift_reg <= {ui_in[5:0], ui_in[6], 1'b0}; // addr+rw
                    clk_cnt   <= 8'd0;
                    state     <= START;
                end
            end

            // ── START condition ──────────────────────────────
            START: begin
                sda_oe_r  <= 1'b1;
                sda_out_r <= 1'b0;  // SDA falls while SCL high
                if (clk_cnt == CLK_DIV-1) begin
                    scl_r   <= 1'b0;
                    clk_cnt <= 8'd0;
                    bit_cnt <= 4'd7;
                    state   <= ADDR;
                end else clk_cnt <= clk_cnt + 1;
            end

            // ── Clock out 8-bit address+RW ───────────────────
            ADDR: begin
                sda_oe_r  <= 1'b1;
                if (clk_cnt == CLK_DIV/2-1) begin
                    scl_r <= 1'b1;
                end else if (clk_cnt == CLK_DIV-1) begin
                    scl_r     <= 1'b0;
                    sda_out_r <= shift_reg[bit_cnt];
                    if (bit_cnt == 0) begin
                        clk_cnt <= 8'd0;
                        state   <= ACK1;
                    end else begin
                        bit_cnt <= bit_cnt - 1;
                        clk_cnt <= 8'd0;
                    end
                end else clk_cnt <= clk_cnt + 1;
            end

            // ── Wait for slave ACK ────────────────────────────
            ACK1: begin
                sda_oe_r <= 1'b0;  // release SDA, slave drives
                if (clk_cnt == CLK_DIV/2-1) scl_r <= 1'b1;
                else if (clk_cnt == CLK_DIV-1) begin
                    scl_r   <= 1'b0;
                    clk_cnt <= 8'd0;
                    bit_cnt <= 4'd7;
                    shift_reg <= rw_bit ? 8'hFF : ui_in; // read=FF, write=data
                    state   <= DATA;
                end else clk_cnt <= clk_cnt + 1;
            end

            // ── Clock 8 data bits ─────────────────────────────
            DATA: begin
                sda_oe_r <= ~rw_bit;  // drive for write, float for read
                if (~rw_bit) sda_out_r <= shift_reg[bit_cnt];
                if (clk_cnt == CLK_DIV/2-1) begin
                    scl_r <= 1'b1;
                    if (rw_bit)  // sample on rising SCL
                        data_out_r[bit_cnt] <= sda_in;
                end else if (clk_cnt == CLK_DIV-1) begin
                    scl_r <= 1'b0;
                    clk_cnt <= 8'd0;
                    if (bit_cnt == 0) state <= ACK2;
                    else bit_cnt <= bit_cnt - 1;
                end else clk_cnt <= clk_cnt + 1;
            end

            // ── Master ACK/NAK then STOP ──────────────────────
            ACK2: begin
                sda_oe_r  <= 1'b1;
                sda_out_r <= 1'b1; // NAK (master done)
                if (clk_cnt == CLK_DIV/2-1) scl_r <= 1'b1;
                else if (clk_cnt == CLK_DIV-1) begin
                    scl_r   <= 1'b0;
                    clk_cnt <= 8'd0;
                    state   <= STOP;
                end else clk_cnt <= clk_cnt + 1;
            end

            // ── STOP condition ────────────────────────────────
            STOP: begin
                sda_oe_r  <= 1'b1;
                sda_out_r <= 1'b0;
                if (clk_cnt == CLK_DIV/2-1) scl_r <= 1'b1;
                else if (clk_cnt == CLK_DIV-1) begin
                    sda_out_r <= 1'b1; // SDA rises while SCL high = STOP
                    clk_cnt   <= 8'd0;
                    state     <= IDLE;
                end else clk_cnt <= clk_cnt + 1;
            end

            default: state <= IDLE;
        endcase
    end
end

wire _unused = &{ena, 1'b0};
endmodule
