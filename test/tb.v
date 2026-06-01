// test/tb.v  — simple iverilog testbench
`timescale 1ns/1ps

module tb;

    reg clk = 0;
    reg rst_n = 0;
    reg [7:0] ui_in = 0;

    wire [7:0] uo_out;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;

    reg [7:0] uio_in = 0;

    // DUT
    tt_um_example dut (
        .ui_in(ui_in),
        .uo_out(uo_out),
        .uio_in(uio_in),
        .uio_out(uio_out),
        .uio_oe(uio_oe),
        .ena(1'b1),
        .clk(clk),
        .rst_n(rst_n)
    );

    // 100 MHz clock
    always #5 clk = ~clk;

    initial begin
        $dumpfile("tb.vcd");
        $dumpvars(0, tb);

        // Reset
        rst_n = 0;
        #50;
        rst_n = 1;

        // --------------------------------------------------
        // WRITE TRANSACTION
        // cmd_valid=1
        // rw=0 (write)
        // address bits = 0x14
        // --------------------------------------------------
        #20;
        ui_in = 8'h94;   // 1001_0100

        #20;
        ui_in = 8'h55;   // write data byte

        // Clear input bus
        #20;
        ui_in = 8'h00;

        // Wait long enough for transaction
        #50000;

        $display("Simulation completed.");
        $finish;
    end

    // --------------------------------------------------
    // Simple slave ACK model
    // Whenever DUT releases SDA (uio_oe[1]==0),
    // drive SDA low to generate ACK.
    // --------------------------------------------------
    always @(*) begin
        uio_in = 8'h00;

        if (uio_oe[1] == 1'b0)
            uio_in[1] = 1'b0;   // ACK
        else
            uio_in[1] = 1'b1;   // idle high
    end

endmodule


