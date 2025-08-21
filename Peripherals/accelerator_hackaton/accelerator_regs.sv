// Alex Grinshpun Dec 2023
// Register addresses
// Provided AS IS without any warranty of any kind nor EXPLICIT nor IMPLIED

`define ACCELERATOR_REG_A       8'h00
`define ACCELERATOR_REG_B       8'h04
`define ACCELERATOR_REG_KEY0    8'h08
`define ACCELERATOR_REG_KEY1    8'h0C
`define ACCELERATOR_REG_KEY2    8'h10
`define ACCELERATOR_REG_KEY3    8'h14
`define ACCELERATOR_REG_EOUT0    8'h18
`define ACCELERATOR_REG_EOUT1    8'h1c
`define ACCELERATOR_REG_DOUT0    8'h20
`define ACCELERATOR_REG_DOUT1    8'h24
`define ACCELERATOR_REG_STATUS  8'h28  // חדש: בודק אם ההצפנה הסתיימה

module accelerator_regs
#(parameter SIM = 0)
(
    input  logic         clk,
    input  logic         wb_rst_i,
    input  logic [7:0]   wb_addr_i,
    input  logic [31:0]  wb_dat_i,
    output logic [31:0]  wb_dat_o,
    input  logic         wb_we_i,
    input  logic         wb_re_i,

    // User-defined interface
    output logic [31:0] rega,
    output logic [31:0] regb,
    output logic [31:0] key0,
    output logic [31:0] key1,
    output logic [31:0] key2,
    output logic [31:0] key3,
    input  logic [31:0] result_ve0,
    input  logic [31:0] result_ve1,
    input  logic [31:0] result_vd0,
    input  logic [31:0] result_vd1,
    input  logic        done_enc,   // ← סיגנל חדש שמגיע מה-CORE
    input  logic        done_dec   // ← סיגנל חדש שמגיע מה-CORE
);

    always_comb begin
        case (wb_addr_i)
            `ACCELERATOR_REG_A      : wb_dat_o = rega;
            `ACCELERATOR_REG_B      : wb_dat_o = regb;
            `ACCELERATOR_REG_KEY0   : wb_dat_o = key0;
            `ACCELERATOR_REG_KEY1   : wb_dat_o = key1;
            `ACCELERATOR_REG_KEY2   : wb_dat_o = key2;
            `ACCELERATOR_REG_KEY3   : wb_dat_o = key3;
            `ACCELERATOR_REG_EOUT0   : wb_dat_o = result_ve0;
            `ACCELERATOR_REG_EOUT1   : wb_dat_o = result_ve1;
            
            `ACCELERATOR_REG_DOUT0   : wb_dat_o = result_vd0;
            `ACCELERATOR_REG_DOUT1   : wb_dat_o = result_vd1;
            
            `ACCELERATOR_REG_STATUS : wb_dat_o = {30'b0, done_enc, done_dec};  // ← STATUS = ביט 0 בלבד
            default                 : wb_dat_o = 32'b0;
        endcase
    end

    // Write logic
    always_ff @(posedge clk or posedge wb_rst_i) begin
        if (wb_rst_i) begin
            rega <= 32'b0;
            regb <= 32'b0;
            key0 <= 32'b0;
            key1 <= 32'b0;
            key2 <= 32'b0;
            key3 <= 32'b0;
        end else if (wb_we_i) begin
            case (wb_addr_i)
                `ACCELERATOR_REG_A     : rega <= wb_dat_i;
                `ACCELERATOR_REG_B     : regb <= wb_dat_i;
                `ACCELERATOR_REG_KEY0  : key0 <= wb_dat_i;
                `ACCELERATOR_REG_KEY1  : key1 <= wb_dat_i;
                `ACCELERATOR_REG_KEY2  : key2 <= wb_dat_i;
                `ACCELERATOR_REG_KEY3  : key3 <= wb_dat_i;
            endcase
        end
    end

endmodule