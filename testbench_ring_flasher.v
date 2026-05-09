`timescale 1ns / 1ps
module testbench_ring_flasher;
    localparam CYCLE = 20;
    
    reg  clk;
    reg  rst_n;
    reg  start_sig;
    wire [15:0] led_out;
    
    ring_flasher dut (
        .clk      (clk),
        .rst_n    (rst_n),
        .start_sig(start_sig),
        .led_out  (led_out)
    );
    
    initial clk = 1'b0;
    always #(CYCLE/2) clk = ~clk;
    
    always @(led_out)
        $display("[%0t ns] led_out = %016b", $time, led_out);

//  // ====== RECORD WAVES ======
//    initial begin
//        $recordfile("waves");
//        $recordvars("depth=0", testbench);
//    end
    
    initial begin
        rst_n     = 1'b1;
        start_sig = 1'b0;
        
        // ====== RESET ======
        $display("========== RESET ==========");
        @(posedge clk); #1;
        rst_n = 1'b0;
        repeat(3) @(posedge clk); #1;
        rst_n = 1'b1;
        $display("[%0t ns] Reset released", $time);

           // ====== TEST 1: 2 vòng đầy đủ rồi về IDLE ======
        $display("========== TEST 1: 2 vong day du ==========");
        repeat(2) @(posedge clk); #1;
        start_sig = 1'b1;
        $display("[%0t ns] start_sig = 1", $time);
        @(posedge clk); #1;
        start_sig = 1'b0;
        $display("[%0t ns] start_sig = 0 (1-clock pulse)", $time);
        repeat(100) @(posedge clk); #1;  // ← giảm từ 292 xuống 287
        $display("========== TEST 1: All OFF, kiem tra IDLE ==========");
        repeat(2) @(posedge clk); #1;    // ← giữ 2

        // ====== TEST 2: 2 vòng đầy đủ ======
        $display("========== TEST 2: 2 vong day du ==========");
        repeat(1) @(posedge clk); #1;    // ← giảm từ 2 xuống 1
        start_sig = 1'b1;
        $display("[%0t ns] start_sig = 1", $time);
        repeat(288) @(posedge clk); #1;
        start_sig = 1'b0;
        $display("========== TEST 2: Tat start_sig, ve IDLE ==========");
        repeat(5) @(posedge clk); #1;

        // ====== TEST 3: Restart ======
        $display("========== TEST 3: Restart ==========");
        rst_n = 1'b0;
        repeat(2) @(posedge clk); #1;
        rst_n = 1'b1;
        repeat(2) @(posedge clk); #1;
        start_sig = 1'b1;
        $display("[%0t ns] Restart!", $time);
        repeat(300) @(posedge clk); #1;
        start_sig = 1'b0;
        repeat(5) @(posedge clk); #1;
        
        // ====== TEST 4: Reset giữa chừng ======
        $display("========== TEST 4: Reset giua chung ==========");
        rst_n = 1'b0;
        repeat(2) @(posedge clk); #1;
        rst_n = 1'b1;
        repeat(2) @(posedge clk); #1;
        start_sig = 1'b1;
        repeat(20) @(posedge clk); #1;
        $display("[%0t ns] Reset giua chung!", $time);
        rst_n = 1'b0;
        repeat(2) @(posedge clk); #1;
        rst_n = 1'b1;
        repeat(5) @(posedge clk); #1;
        start_sig = 1'b0;
        repeat(5) @(posedge clk); #1;
        
        $display("========== END SIMULATION ==========");
        $finish;
    end
    
endmodule