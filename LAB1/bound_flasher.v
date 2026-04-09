module bound_flasher (
  output reg [15:0] lamp,
  input  wire       clk,
  input  wire       rst_n,
  input  wire       flick
);
  parameter INIT = 4'd0;
  parameter S1   = 4'd1;
  parameter S2   = 4'd2;
  parameter S3   = 4'd3;
  parameter S3K  = 4'd4;
  parameter S4   = 4'd5;
  parameter S5   = 4'd6;
  parameter S5K  = 4'd7;
  parameter S6   = 4'd8;

  reg [3:0]  state, next_state;
  reg [15:0] next_lamp;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state <= INIT;
      lamp  <= 16'h0000;
    end else begin
      state <= next_state;
      lamp  <= next_lamp;
    end
  end

  always @(*) begin
    next_state = state;
    next_lamp  = lamp;
    case (state)

      // INIT: chờ flick
      INIT: begin
        next_lamp  = 16'h0000;
        if (flick)
          next_state = S1;
      end

      // Phase 1: ON L0→L5 (không check kickback)
      S1: begin
        if (lamp == 16'h0000)
          next_lamp = 16'h0001;
        else if (lamp == 16'h003F)
          next_state = S2;
        else
          next_lamp = lamp | (lamp << 1);
      end

      // Phase 2: OFF L5→L0
      S2: begin
        if (lamp == 16'h0001) begin
          next_lamp  = 16'h0000;
          next_state = S3;
        end else
          next_lamp = lamp >> 1;
      end

      // Phase 3: ON L0→L10 (kickback tại L5 và L10)
      S3: begin
        if (lamp == 16'h0000)
          next_lamp = 16'h0001;
        else if ((lamp == 16'h003F || lamp == 16'h07FF) && flick) begin
          next_lamp  = lamp;
          next_state = S3K;
        end else if (lamp == 16'h07FF)
          next_state = S4;
        else
          next_lamp = lamp | (lamp << 1);
      end

      // S3K: OFF về L0, quay lại S3
      S3K: begin
        if (lamp == 16'h0001) begin
          next_lamp  = 16'h0000;
          next_state = S3;
        end else
          next_lamp = lamp >> 1;
      end

      // Phase 4: OFF L10→L5
      S4: begin
        if (lamp == 16'h003F)
          next_state = S5;
        else
          next_lamp = lamp >> 1;
      end

      // Phase 5: ON L5→L15 (kickback tại L10)
      S5: begin
        if (lamp == 16'h07FF && flick) begin
          next_lamp  = lamp;
          next_state = S5K;
        end else if (lamp == 16'hFFFF)
          next_state = S6;
        else
          next_lamp = lamp | (lamp << 1);
      end

      // S5K: OFF về L5, quay lại S5
      S5K: begin
        if (lamp == 16'h003F) begin
          next_lamp  = lamp;
          next_state = S5;
        end else
          next_lamp = lamp >> 1;
      end

      // Phase 6: OFF L15→L0
      S6: begin
        if (lamp == 16'h0001) begin
          next_lamp  = 16'h0000;
          next_state = INIT;
        end else
          next_lamp = lamp >> 1;
      end

      default: begin
        next_state = INIT;
        next_lamp  = 16'h0000;
      end

    endcase
  end
endmodule