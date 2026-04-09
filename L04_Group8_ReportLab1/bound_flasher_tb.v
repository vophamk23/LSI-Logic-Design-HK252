`timescale 1ns/1ps
`define CYCLE 100

module testbench;
  reg         clk;
  reg         rst_n;
  reg         flick;
  wire [15:0] lamp;

  bound_flasher bound_flasher_01 (
    .lamp  (lamp),
    .clk   (clk),
    .rst_n (rst_n),
    .flick (flick)
  );

  initial clk = 0;
  always #(`CYCLE/2) clk = ~clk;

  // Xcelium waveform dump
  initial begin
    $recordfile("waves");
    $recordvars("depth=0", testbench);
  end

  initial begin
    $monitor("time=%0d state=%0d flick=%b lamp=%h",
              $time, testbench.bound_flasher_01.state,
              flick, lamp);
  end

  initial begin

    //--------------------------------------------------
    // TEST CASE 1: flick=0 toàn bộ quá trình
    // Flow chuẩn không kickback:
    // INIT→S1(6)→S2(6)→S3(11)→S4(6)→S5(11)→S6(16)→INIT
    // Tổng ~56 cycles
    //--------------------------------------------------
    $display("========================================");
    $display("TEST CASE 1: flick=0 toan bo qua trinh");
    $display("========================================");
    rst_n = 0; flick = 0;
    #(`CYCLE*3);
    rst_n = 1;
    #(`CYCLE*2);
    flick = 1;
    #(`CYCLE*1);
    flick = 0;
    #(`CYCLE*100);

    //--------------------------------------------------
    // TEST CASE 2: kickback only at lamp[5] in S3
    // Flow: INIT -> S1(6) -> S2(6) -> S3 up to lamp[5]
    //       -> S3K (OFF back to lamp[0]) -> S3 restart
    //       -> S4 -> S5 -> S6 -> INIT
    //--------------------------------------------------
    $display("========================================");
    $display("TEST CASE 2: kickback at lamp[5] in S3");
    $display("========================================");
    rst_n = 0; flick = 0;
    #(`CYCLE*3);          // Hold reset 3 cycles
    rst_n = 1;
    #(`CYCLE*2);          // Wait 2 cycles after reset
    flick = 1;
    #(`CYCLE*1);          // Pulse flick to start sequence
    flick = 0;

    // Wait until lamp[5] kickback point in S3:
    // S1 = 6 cycles
    // S2 = 6 cycles
    // S3 from lamp[0] to lamp[5] = 6 cycles
    // Total = 18 cycles
    #(`CYCLE*18);
    flick = 1;            // Assert flick at lamp[5] -> trigger kickback -> S3K
    #(`CYCLE*3);          // Hold flick long enough to be sampled
    flick = 0;

    // Let the rest of sequence complete normally (no more kickback)
    #(`CYCLE*150);

    //--------------------------------------------------
    // TEST CASE 3: flick=1 tại kickback L10
    //              khi đang đếm S3: L0→L10
    //--------------------------------------------------
    $display("========================================");
    $display("TEST CASE 3: flick=1 tai L10 trong S3 (L0->L10)");
    $display("========================================");
    rst_n = 0; flick = 0;
    #(`CYCLE*3);
    rst_n = 1;
    #(`CYCLE*2);
    flick = 1;
    #(`CYCLE*1);
    flick = 0;
    // S1(6) + S2(6) + S3 đến L10(11) = 23 cycles
    #(`CYCLE*23);
    flick = 1;       // kickback tại L10 trong S3
    #(`CYCLE*2);
    flick = 0;
    #(`CYCLE*200);

    //--------------------------------------------------
    // TEST CASE 4: flick=1 tại kickback L10
    //              khi đang đếm S5: L5→L15
    //--------------------------------------------------
    $display("========================================");
    $display("TEST CASE 4: flick=1 tai L10 trong S5 (L5->L15)");
    $display("========================================");
    rst_n = 0; flick = 0;
    #(`CYCLE*3);
    rst_n = 1;
    #(`CYCLE*2);
    flick = 1;
    #(`CYCLE*1);
    flick = 0;
    // S1(6)+S2(6)+S3(11)+S4(6)+S5 đến L10(6) = 35 cycles
    #(`CYCLE*35);
    flick = 1;       // kickback tại L10 trong S5
    #(`CYCLE*2);
    flick = 0;
    #(`CYCLE*200);

    //--------------------------------------------------
    // TEST CASE 5: flick=1 tại CẢ L5 VÀ L10 trong S3
    //--------------------------------------------------
    $display("========================================");
    $display("TEST CASE 5: flick=1 tai ca L5 va L10 trong S3");
    $display("========================================");
    rst_n = 0; flick = 0;
    #(`CYCLE*3);
    rst_n = 1;
    #(`CYCLE*2);
    flick = 1;
    #(`CYCLE*1);
    flick = 0;
    // S1(6) + S2(6) + S3 đến L5(6) = 18 cycles
    #(`CYCLE*18);
    flick = 1;       // kickback lần 1 tại L5
    #(`CYCLE*2);
    flick = 0;
    // S3K(6) + S3 bật L0→L5(6) + L5→L10(5) = 17 cycles
    #(`CYCLE*17);
    flick = 1;       // kickback lần 2 tại L10
    #(`CYCLE*2);
    flick = 0;
    #(`CYCLE*250);

    //--------------------------------------------------
    // TEST CASE 6: flick=1 tại CẢ 3 kickback points
    // L5 trong S3, L10 trong S3, L10 trong S5
    //--------------------------------------------------
    $display("========================================");
    $display("TEST CASE 6: flick=1 tai ca 3 kickback points");
    $display("========================================");
    rst_n = 0; flick = 0;
    #(`CYCLE*3);
    rst_n = 1;
    #(`CYCLE*2);
    flick = 1;
    #(`CYCLE*1);
    flick = 0;
    // S1(6) + S2(6) + S3 đến L5(6) = 18 cycles
    #(`CYCLE*18);
    flick = 1;       // kickback 1: L5 trong S3
    #(`CYCLE*2);
    flick = 0;
    // S3K(6) + S3 bật L0→L10(11) = 17 cycles
    #(`CYCLE*17);
    flick = 1;       // kickback 2: L10 trong S3
    #(`CYCLE*2);
    flick = 0;
    // S3K(10) + S3(11) + S4(6) + S5 đến L10(6) = 33 cycles
    #(`CYCLE*33);
    flick = 1;       // kickback 3: L10 trong S5
    #(`CYCLE*2);
    flick = 0;
    #(`CYCLE*300);

    $display("========================================");
    $display("SIMULATION DONE");
    $display("========================================");
    $finish;
  end

endmodule