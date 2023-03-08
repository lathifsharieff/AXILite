module clk_rst_manager(
    input pclk,
    input preset,
    output aclk,
    output areset
);
    assign aclk = pclk;
    assign areset = preset;
endmodule