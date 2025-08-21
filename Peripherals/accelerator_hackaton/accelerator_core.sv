// Alex Grinshpun Dec 2023
//Provided AS IS without any warranty of any kind nor EXPLICIT nor IMPLIED
module accelerator_core_dec (
    input  logic         clk,
    input  logic         wb_rst_i,

    input  logic [31:0]  rega,
    input  logic [31:0]  regb,
    input  logic [31:0]  key0,
    input  logic [31:0]  key1,
    input  logic [31:0]  key2,
    input  logic [31:0]  key3,

    output logic [31:0]  result_v0,
    output logic [31:0]  result_v1,
    output logic         done
);

    logic [31:0] v0, v1, sum;
    logic [5:0]  round;

    localparam DELTA     = 32'h9E3779B9;
    localparam SUM_INIT  = 32'hC6EF3720;

    typedef enum logic [2:0] {
        IDLE,
        WAIT_FOR_DATA,
        FIRST_STEP_V1,
        FIRST_STEP_V0,
        CALC_PART1,
        CALC_PART2,
        DONE
    } state_t;

    state_t state, next_state;

    logic inputs_ready;
    assign inputs_ready = (rega != 32'b0) &&
                          (regb != 32'b0) &&
                          (key0 != 32'b0) &&
                          (key1 != 32'b0) &&
                          (key2 != 32'b0) &&
                          (key3 != 32'b0);

    logic [31:0] result_v0_reg, result_v1_reg;
    assign result_v0 = result_v0_reg;
    assign result_v1 = result_v1_reg;

    assign done = (state == DONE);

    // FSM transitions
    always_comb begin
        case (state)
            IDLE:          next_state = WAIT_FOR_DATA;
            WAIT_FOR_DATA: next_state = inputs_ready ? FIRST_STEP_V1 : WAIT_FOR_DATA;
            FIRST_STEP_V1:      next_state = FIRST_STEP_V0;
            FIRST_STEP_V0:      next_state = CALC_PART1;
            CALC_PART1:    next_state = CALC_PART2;
            CALC_PART2:    next_state = (round == 6'd31) ? DONE : CALC_PART1;
            DONE:          next_state = IDLE;
            default:       next_state = IDLE;
        endcase
    end

    // Register updates and logic
    always_ff @(posedge clk or posedge wb_rst_i) begin
        if (wb_rst_i) begin
            state           <= IDLE;
            v0              <= 32'b0;
            v1              <= 32'b0;
            sum             <= 32'b0;
            round           <= 6'd0;
            result_v0_reg   <= 32'b0;
            result_v1_reg   <= 32'b0;
        end else begin
            state <= next_state;

            case (next_state)
                WAIT_FOR_DATA: begin
                    if (inputs_ready) begin
                        v0    <= rega;
                        v1    <= regb;
                        sum   <= SUM_INIT;
                        round <= 5'd0;
                    end
                end
                FIRST_STEP_V1: begin
                    v1 <= v1 - (((v0 << 4) + key2) ^ (v0 + sum) ^ ((v0 >> 5) + key3));
                end

                FIRST_STEP_V0: begin
                    v0 <= v0 - (((v1 << 4) + key0) ^ (v1 + sum) ^ ((v1 >> 5) + key1));
                    sum <= sum - DELTA;
                end
                CALC_PART1: begin
                    v1 <= v1 - (((v0 << 4) + key2) ^ (v0 + sum) ^ ((v0 >> 5) + key3));
                end

                CALC_PART2: begin
                    v0 <= v0 - (((v1 << 4) + key0) ^ (v1 + sum) ^ ((v1 >> 5) + key1));
                    sum <= sum - DELTA;
                    round <= round + 1;
                end

                DONE: begin
                    result_v0_reg <= v0;
                    result_v1_reg <= v1;
                end
            endcase
        end
    end

endmodule

module accelerator_core_enc (
    input  logic         clk,
    input  logic         wb_rst_i,

    input  logic [31:0]  rega,
    input  logic [31:0]  regb,
    input  logic [31:0]  key0,
    input  logic [31:0]  key1,
    input  logic [31:0]  key2,
    input  logic [31:0]  key3,

    output logic [31:0]  result_v0,
    output logic [31:0]  result_v1,
    output logic         done  // ← חדש
);

    logic [31:0] v0, v1, sum;
    logic [5:0]  round;

    localparam DELTA = 32'h9E3779B9;

    typedef enum logic [2:0] {
        IDLE,
        WAIT_FOR_DATA,
        CALC_ROUND_PART1,
        CALC_ROUND_PART2,
        LAST_ONE_V0,
        LAST_ONE_V1,
        DONE
    } state_t;

    state_t state, next_state;

    logic inputs_ready;
    assign inputs_ready = (rega != 32'b0) &&
                          (regb != 32'b0) &&
                          (key0 != 32'b0) &&
                          (key1 != 32'b0) &&
                          (key2 != 32'b0) &&
                          (key3 != 32'b0);

    // קיבוע תוצאות אחרי DONE
    logic [31:0] result_v0_reg, result_v1_reg;
    assign result_v0 = result_v0_reg;
    assign result_v1 = result_v1_reg;

    assign done = (state == DONE);  // ← חדש

    always_comb begin
        case (state)
            IDLE:             next_state = WAIT_FOR_DATA;
            WAIT_FOR_DATA:    next_state = inputs_ready ? CALC_ROUND_PART1 : WAIT_FOR_DATA;
            CALC_ROUND_PART1: next_state = CALC_ROUND_PART2;
            CALC_ROUND_PART2: next_state = (round == 5'd31) ? LAST_ONE_V0 : CALC_ROUND_PART1;
            LAST_ONE_V0:      next_state = LAST_ONE_V1;
            LAST_ONE_V1:      next_state = DONE;
            DONE:             next_state = IDLE;
            default:          next_state = IDLE;
        endcase
    end

    always_ff @(posedge clk or posedge wb_rst_i) begin
        if (wb_rst_i) begin
            state <= IDLE;
            v0 <= 32'b0;
            v1 <= 32'b0;
            sum <= 32'b0;
            round <= 6'd0;
            result_v0_reg <= 32'b0;
            result_v1_reg <= 32'b0;
        end else begin
            state <= next_state;

            case (next_state)
                WAIT_FOR_DATA: begin
                    if (inputs_ready) begin
                        v0 <= rega;
                        v1 <= regb;
                        sum <= 32'b0;
                        round <= 6'd0;
                    end
                end

                CALC_ROUND_PART1: begin
                    sum <= sum + DELTA;
                    v0 <= v0 + (((v1 << 4) + key0) ^ (v1 + (sum + DELTA)) ^ ((v1 >> 5) + key1));
                end

                CALC_ROUND_PART2: begin
                    v1 <= v1 + (((v0 << 4) + key2) ^ (v0 + sum) ^ ((v0 >> 5) + key3));
                    round <= round + 1;
                end

                LAST_ONE_V0: begin
                    sum <= sum + DELTA;
                    v0 <= v0 + (((v1 << 4) + key0) ^ (v1 + (sum + DELTA)) ^ ((v1 >> 5) + key1));
                end

                LAST_ONE_V1: begin
                    v1 <= v1 + (((v0 << 4) + key2) ^ (v0 + sum) ^ ((v0 >> 5) + key3));
                end

                DONE: begin
                    result_v0_reg <= v0;
                    result_v1_reg <= v1;
                end
            endcase
        end
    end

endmodule

// Updated top-level accelerator_core module
module accelerator_core (
    input  logic         clk,
    input  logic         wb_rst_i,

    // Encryption/Decryption inputs
    input  logic [31:0]  rega,
    input  logic [31:0]  regb,
    input  logic [31:0]  key0,
    input  logic [31:0]  key1,
    input  logic [31:0]  key2,
    input  logic [31:0]  key3,

    // Outputs
    output logic [31:0]  v0eout,
    output logic [31:0]  v1eout,
    output logic [31:0]  v0dout,
    output logic [31:0]  v1dout,
    output logic         done_enc,
    output logic         done_dec
);

    // Instantiate the encryption core
    accelerator_core_enc acc_enc_inst (
        .clk(clk),
        .wb_rst_i(wb_rst_i),
        .rega(rega),
        .regb(regb),
        .key0(key0),
        .key1(key1),
        .key2(key2),
        .key3(key3),
        .result_v0(v0eout),
        .result_v1(v1eout),
        .done(done_enc)
    );

    // Instantiate the decryption core
    accelerator_core_dec acc_dec_inst (
        .clk(clk),
        .wb_rst_i(wb_rst_i),
        .rega(rega),
        .regb(regb),
        .key0(key0),
        .key1(key1),
        .key2(key2),
        .key3(key3),
        .result_v0(v0dout),
        .result_v1(v1dout),
        .done(done_dec)
    );

endmodule

