// test/tb.v  — simple iverilog testbench
`timescale 1ns/1ps
module tb;
  reg clk=0, rst_n=0;
  reg [7:0] ui_in=0;
  wire [7:0] uo_out, uio_out, uio_oe;
  reg [7:0] uio_in=0;

  tt_um_example dut (
    .ui_in(ui_in), .uo_out(uo_out),
    .uio_in(uio_in), .uio_out(uio_out),
    .uio_oe(uio_oe), .ena(1'b1),
    .clk(clk), .rst_n(rst_n)
  );

  always #5 clk = ~clk;          // 100 MHz

  initial begin
    $dumpfile("tb.vcd"); $dumpvars(0, tb);
    #20 rst_n = 1;
    #10 ui_in = 8'hD4;            // cmd_valid=1, rw=0, addr=0x52 → write 0x14
    #10 ui_in = 8'h14;
    #100000;
    $finish;
  end
endmodule


