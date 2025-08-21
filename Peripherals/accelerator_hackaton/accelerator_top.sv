module accelerator_top (
    input  logic        wb_clk_i,
    input  logic        wb_rst_i,
    input  logic        wb_stb_i,
    input  logic [2:0]  wb_cti_i,
    input  logic [1:0]  wb_bte_i,
    input  logic        wb_cyc_i,
    input  logic [3:0]  wb_sel_i,
    input  logic        wb_we_i,
    input  logic [7:0]  wb_adr_i,
    input  logic [31:0] wb_dat_i,
    output logic [31:0] wb_dat_o,
    output logic        wb_ack_o,
    output logic        wb_err_o,
    output logic        wb_rty_o,
    output logic        int_o
);

    logic [31:0] wb_data_reg_out;
    logic [31:0] wb_data_reg_in;
    logic [7:0]  wb_adr_int;
    logic        we_o;
    logic        re_o;

    logic [31:0] rega, regb;
    logic [31:0] key0, key1, key2, key3;
    logic [31:0] result_ve0, result_ve1;
    logic [31:0] result_vd0, result_vd1;

    logic        done1;
    logic        done2;

    accelerator_wb wb_interface (
        .clk              (wb_clk_i),
        .wb_rst_i         (wb_rst_i),
        .wb_stb_i         (wb_stb_i),
        .wb_cti_i         (wb_cti_i),
        .wb_bte_i         (wb_bte_i),
        .wb_cyc_i         (wb_cyc_i),
        .wb_sel_i         (wb_sel_i),
        .wb_we_i          (wb_we_i),
        .wb_adr_i         (wb_adr_i),
        .wb_dat_i         (wb_dat_i),
        .wb_dat_o         (wb_dat_o),
        .wb_ack_o         (wb_ack_o),
        .wb_err_o         (wb_err_o),
        .wb_rty_o         (wb_rty_o),
        .wb_adr_reg       (wb_adr_int),
        .wb_data_reg_in   (wb_data_reg_in),
        .wb_data_reg_out  (wb_data_reg_out),
        .we_o             (we_o),
        .re_o             (re_o)
    );

    // ========== REGISTERS ==========
    accelerator_regs regs (
        .clk         (wb_clk_i),
        .wb_rst_i    (wb_rst_i),
        .wb_addr_i   (wb_adr_int),
        .wb_dat_i    (wb_data_reg_out),
        .wb_dat_o    (wb_data_reg_in),
        .wb_we_i     (we_o),
        .wb_re_i     (re_o),
        .rega        (rega),
        .regb        (regb),
        .key0        (key0),
        .key1        (key1),
        .key2        (key2),
        .key3        (key3),
        .result_ve0   (result_ve0),
        .result_ve1   (result_ve1),
        .result_vd0   (result_vd0),
        .result_vd1   (result_vd1),
        
        .done_enc        (done_enc),
        .done_dec        (done_dec)

    );

    // ========== CORE ==========
    accelerator_core core (
        .clk         (wb_clk_i),
        .wb_rst_i    (wb_rst_i),
        .rega        (rega),
        .regb        (regb),
        .key0        (key0),
        .key1        (key1),
        .key2        (key2),
        .key3        (key3),
        .v0eout   (result_ve0),
        .v1eout   (result_ve1),
        .v0dout   (result_vd0),
        .v1dout   (result_vd1),
        .done_enc        (done_enc),
        .done_dec        (done_dec)
    );

    assign int_o = 1'b0;

endmodule