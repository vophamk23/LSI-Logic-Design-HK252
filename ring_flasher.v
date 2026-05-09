`timescale 1ns / 1ps
module ring_flasher(
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start_sig,
    output reg  [15:0] led_out
);

    // FSM states
    localparam IDLE = 2'd0; // Chờ start_sig
    localparam UP   = 2'd1; // Quét xuôi 8 bước
    localparam DOWN = 2'd2; // Quét ngược 4 bước

    reg [1:0] state;
    reg [3:0] ptr;       // Con trỏ LED hiện tại (mod16)
    reg [2:0] step_cnt;  // Bước trong phase: UP=0..7, DOWN=0..3
    reg [3:0] phase_cnt; // Phase đã hoàn thành (0..12)

    // Sau 6 phase (3 UP + 3 DOWN): chuyển sang chế độ toggle
    wire toggle_mode = (phase_cnt >= 4'd6);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= IDLE;
            ptr       <= 4'd0;
            step_cnt  <= 3'd0;
            phase_cnt <= 4'd0;
            led_out   <= 16'b0;
        end else begin
            case (state)

                IDLE: begin
                    led_out   <= 16'b0;
                    ptr       <= 4'd0;
                    step_cnt  <= 3'd0;
                    phase_cnt <= 4'd0;
                    if (start_sig) state <= UP;
                end

                // UP: bật LED (normal) hoặc toggle OFF (toggle mode)
                // ptr tăng, giữ nguyên khi xong để DOWN bắt đầu từ đây
                UP: begin
                    led_out[ptr] <= toggle_mode ? ~led_out[ptr] : 1'b1;
                    if (step_cnt == 3'd7) begin
                        step_cnt  <= 3'd0;
                        phase_cnt <= phase_cnt + 1'b1;
                        state     <= DOWN;
                    end else begin
                        ptr      <= ptr + 1'b1;
                        step_cnt <= step_cnt + 1'b1;
                    end
                end

                // DOWN: tắt LED (normal) hoặc toggle ON (toggle mode)
                // ptr giảm, giữ nguyên khi xong để UP tiếp bắt đầu từ đây
                DOWN: begin
                    led_out[ptr] <= toggle_mode ? ~led_out[ptr] : 1'b0;
                    if (step_cnt == 3'd3) begin
                        step_cnt  <= 3'd0;
                        phase_cnt <= phase_cnt + 1'b1;
                        if (toggle_mode &&
                            ((led_out & ~(16'd1 << ptr)) == 16'b0)) begin
                            // All LED tắt: restart hoặc về IDLE
                            led_out <= 16'b0;
                            if (start_sig) begin
                                state     <= UP;
                                ptr       <= 4'd0;
                                step_cnt  <= 3'd0;
                                phase_cnt <= 4'd0;
                            end else
                                state <= IDLE;
                        end else
                            state <= UP; // ptr giữ nguyên
                    end else begin
                        ptr      <= ptr - 1'b1;
                        step_cnt <= step_cnt + 1'b1;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule