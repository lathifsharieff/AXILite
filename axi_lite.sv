// This is the top module for AXI-Lite
//  The CSR's are as
// ---------------------------------------
// Offset 0x0, Control Reg
//  Bit 0 -> Start AXI Transaction
//  Bit 6:1 -> No. of bytes in transaction
//  Bit 7 -> 0 for read and 1 for write transaction
// ---------------------------------------
// Offset 0x1, Address Reg
//  address on which you want to perform read or write
//  transaction via AXI Master
// ---------------------------------------
// Offset 0x10 - 0x1f, Data Reg
//  data to read or write can be found in data registers
//

module axi_lite(
    //--------- APB Slave to configure CSR ---------
    input           pclk,
    input           preset,
    input           psel,
    input           penable,
    input [31:0]    paddr,
    input [31:0]    pwdata,
    input           pwrite,
    output [31:0]   prdata,
    output          pready,

    output interrupt,

    //--------- AXI-Lite Master Interface ---------
    output          aclk,
    output          areset,
    // write addresss channel
    output [31:0]   awaddr,
    output [3:0]    awcache,
    output [2:0]    awprot,
    output          awvalid,
    input           awready,

    // write data channel
    output [31:0]   wdata,
    output [3:0]    wstrb,
    output          wvalid,
    input           wready,

    // write resp channel
    output          bready,
    input [1:0]     bresp,
    input           bvalid,

    // address read channel
    output [31:0]   araddr,
    output [3:0]    arcache,
    output [2:0]    arprot,
    output          arvalid,
    input           arready,

    // read responce channel
    input [31:0]    rdata,
    input           rvalid,
    output          rready,
    input [1:0]     rresp
);

    wire [31:0]         address;
    wire                start;
    wire [5:0]          bytes;
    wire [15:0][31:0]   data;
    wire r_w, r_valid, rst;
    wire wbegin,rbegin;
    wire wrsp,rrsp;
    wire wcomp,rcomp;
    wire werr,rerr;
    wire tr_complete;
    wire [31:0] r_data;

    assign interrupt = (werr || rerr) ? 1:0;

axi_csr CSRs(
    .clk(pclk),
    .reset(preset),
    .sel(psel),
    .enable(penable),
    .addr(paddr),
    .wdata(pwdata),
    .write(pwrite),
    .rdata(prdata),
    .ready(pready),
    .address(address),
    .start(start),
    .bytes(bytes),
    .data(data),
    .r_w(r_w),
    .tr_start((rbegin || wbegin)),
    .r_data(r_data),
    .r_valid(r_valid),
    .tr_complete(tr_complete)
);

clk_rst_manager MNGR(
    .pclk(pclk),
    .preset(preset),
    .aclk(aclk),
    .areset(areset)
);

aw_channel AW_CHNL(
    .clk(aclk),
    .reset(areset || rst),
    .start(wbegin),
    .addr(address),
    .comp(wcomp),
    .awaddr(awaddr),
    .awcache(awcache),
    .awprot(awprot),
    .awvalid(awvalid),
    .awready(awready)
);

dw_channel DW_CHNL(
    .clk(aclk),
    .reset(areset || rst),
    .start(wbegin),
    .bytes(bytes),
    .rem(),
    .comp(),
    .data(data),
    .wdata(wdata),
    .wstrb(wstrb),
    .wvalid(wvalid),
    .wready(wready)
);

b_channel B_CHNL(
    .clk(aclk),
    .reset(areset || rst),
    .start(wbegin),
    .success(wrsp),
    .error(werr),
    .bready(bready),
    .bresp(bresp),
    .bvalid(bvalid)
);

ar_channel AR_CHNL(
    .clk(aclk),
    .reset(areset || rst),
    .start(rbegin),
    .addr(address),
    .comp(rcomp),
    .araddr(araddr),
    .arcache(arcache),
    .arprot(arprot),
    .arvalid(arvalid),
    .arready(arready)
);

r_channel R_CHNL(
    .clk(aclk),
    .reset(areset || rst),
    .data(r_data),
    .valid(r_valid),
    .error(rerr),
    .success(rrsp),
    .rdata(rdata),
    .rvalid(rvalid),
    .rready(rready),
    .rresp(rresp)
);

controller CNTRL(
    .clk(pclk),
    .reset(preset),
    .r_w(r_w),
    .start(start),
    .w_start(wbegin),
    .r_start(rbegin),
    .w_resp(wrsp),
    .r_resp(rrsp),
    .w_comp(wcomp),
    .r_comp(rcomp),
    .tr_complete(tr_complete),
    .cntrl_rst(rst)
);

endmodule