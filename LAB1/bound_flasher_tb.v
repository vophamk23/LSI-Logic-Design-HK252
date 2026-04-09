`timescale 1ns/1ps
`define CYCLE 100
`include "bound_flasher.v"

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

  initial begin
    $dumpfile("waves.vcd");
    $dumpvars(0, testbench);
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
    flick = 1;       // trigger 1 cycle để vào S1
    #(`CYCLE*1);
    flick = 0;       // giữ flick=0 toàn bộ
    #(`CYCLE*100);   // đủ cho 1 chu kỳ đầy đủ

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
    // Timing:
    //   S1(6) + S2(6) + S3 đến L10(11) = 23 cycles
    //--------------------------------------------------
    $display("========================================");
    $display("TEST CASE 3: flick=1 tai L10 trong S3 (L0->L10)");
    $display("========================================");
    rst_n = 0; flick = 0;
    #(`CYCLE*3);
    rst_n = 1;
    #(`CYCLE*2);
    flick = 1;       // trigger vào S1
    #(`CYCLE*1);
    flick = 0;
    // chờ qua S1(6) + S2(6) + S3 đến L10(11) = 23 cycles
    #(`CYCLE*23);
    flick = 1;       // assert tại L10 trong S3 → kickback về L0
    #(`CYCLE*2);
    flick = 0;
    #(`CYCLE*200);   // đủ để hoàn thành chu kỳ

    //--------------------------------------------------
    // TEST CASE 4: flick=1 tại kickback L10
    //              khi đang đếm S5: L5→L15
    // Timing:
    //   S1(6)+S2(6)+S3(11)+S4(6) = 29 cycles để vào S5
    //   S5 đến L10 = 6 cycles → tổng 35 cycles
    //--------------------------------------------------
    $display("========================================");
    $display("TEST CASE 4: flick=1 tai L10 trong S5 (L5->L15)");
    $display("========================================");
    rst_n = 0; flick = 0;
    #(`CYCLE*3);
    rst_n = 1;
    #(`CYCLE*2);
    flick = 1;       // trigger vào S1
    #(`CYCLE*1);
    flick = 0;
    // chờ qua S1(6)+S2(6)+S3(11)+S4(6)+S5 đến L10(6) = 35 cycles
    #(`CYCLE*35);
    flick = 1;       // assert tại L10 trong S5 → kickback về L5
    #(`CYCLE*2);
    flick = 0;
    #(`CYCLE*200);   // đủ để hoàn thành chu kỳ
    
    
        //--------------------------------------------------
    // TEST CASE 5: flick=1 tại CẢ L5 VÀ L10 trong S3
    // Kịch bản:
    //   - Đang bật L0→L10 (S3)
    //   - Gặp flick=1 tại L5 → kickback về L0 → bật lại
    //   - Lần này flick=0 tại L5 → tiếp tục lên L10
    //   - Gặp flick=1 tại L10 → kickback về L0 → bật lại
    //   - flick=0 tại L10 → sang S4 bình thường
    // Timing:
    //   S1(6)+S2(6) = 12 cycles để vào S3
    //   S3 đến L5   = 6 cycles  → tổng 18 cycles
    //   S3K tắt L5→L0 = 6 cycles
    //   S3 bật lại L0→L5 = 6 cycles → tổng 30 cycles
    //   S3 tiếp tục L5→L10 = 5 cycles → tổng 35 cycles
    //--------------------------------------------------
    $display("========================================");
    $display("TEST CASE 5: flick=1 tai ca L5 va L10 trong S3");
    $display("========================================");
    rst_n = 0; flick = 0;
    #(`CYCLE*3);
    rst_n = 1;
    #(`CYCLE*2);
    flick = 1;        // trigger vào S1
    #(`CYCLE*1);
    flick = 0;

    // chờ S1(6) + S2(6) + S3 đến L5(6) = 18 cycles
    #(`CYCLE*18);
    flick = 1;        // assert tại L5 → kickback lần 1
    #(`CYCLE*2);
    flick = 0;

    // S3K tắt L5→L0 (6 cycles) → S3 bật lại
    // S3 bật L0→L5 (6 cycles) → flick=0 tại L5, tiếp tục
    // S3 bật L5→L10 (5 cycles)
    // tổng chờ: 6 + 6 + 5 = 17 cycles
    #(`CYCLE*17);
    flick = 1;        // assert tại L10 → kickback lần 2
    #(`CYCLE*2);
    flick = 0;

    // S3K tắt L10→L0 → S3 bật lại L0→L10 → flick=0 → sang S4
    #(`CYCLE*250);    // đủ để hoàn thành chu kỳ
    
    
    //--------------------------------------------------
    // TEST CASE 6: flick=1 tại CẢ 3 kickback points
    // Kịch bản:
    //   - S3: gặp flick=1 tại L5  → kickback về L0
    //   - S3: gặp flick=1 tại L10 → kickback về L0
    //   - S5: gặp flick=1 tại L10 → kickback về L5
    // Timing:
    //   S1(6)+S2(6) = 12 cycles để vào S3
    //   S3 đến L5   = 6 cycles  → tổng 18 cycles
    //   --- kickback 1: S3K(6) + S3 đến L10(11) = 17 cycles
    //   → tổng 35 cycles tới L10 trong S3
    //   --- kickback 2: S3K(6) + S3(11) + S4(6) + S5 đến L10(6) 
    //   = 29 cycles
    //   → tổng 64 cycles tới L10 trong S5
    //--------------------------------------------------
    $display("========================================");
    $display("TEST CASE 6: flick=1 tai ca 3 kickback points");
    $display("========================================");
    rst_n = 0; flick = 0;
    #(`CYCLE*3);
    rst_n = 1;
    #(`CYCLE*2);
    flick = 1;        // trigger vào S1
    #(`CYCLE*1);
    flick = 0;

    // ── Kickback 1: L5 trong S3 ──────────────────────
    // chờ S1(6) + S2(6) + S3 đến L5(6) = 18 cycles
    #(`CYCLE*18);
    flick = 1;        // assert tại L5 → kickback về L0
    #(`CYCLE*2);
    flick = 0;

    // ── Kickback 2: L10 trong S3 ─────────────────────
    // S3K tắt L5→L0 (6) + S3 bật L0→L10 (11) = 17 cycles
    #(`CYCLE*17);
    flick = 1;        // assert tại L10 → kickback về L0
    #(`CYCLE*2);
    flick = 0;

    // ── Kickback 3: L10 trong S5 ─────────────────────
    // S3K tắt L10→L0 (10) + S3 bật L0→L10 (11)
    // + S4 tắt L10→L5 (6) + S5 bật L5→L10 (6) = 33 cycles
    #(`CYCLE*33);
    flick = 1;        // assert tại L10 trong S5 → kickback về L5
    #(`CYCLE*2);
    flick = 0;

    // S5K tắt L10→L5 → S5 tiếp tục bật L5→L15 → S6 → INIT
    #(`CYCLE*300);    // đủ để hoàn thành chu kỳ
    

    $display("========================================");
    $display("SIMULATION DONE");
    $display("========================================");
    $finish;
  end

endmodule