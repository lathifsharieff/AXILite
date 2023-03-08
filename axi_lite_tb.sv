`define CLK_WAIT @(posedge pclk);

module axi_lite_tb;
        //--------- APB Slave to configure CSR ---------
    reg           pclk;
    reg           preset;
    reg           psel;
    reg           penable;
    reg [31:0]    paddr;
    reg [31:0]    pwdata;
    reg           pwrite;
    wire [31:0]   prdata;
    wire          pready;

    wire interrupt;

    //--------- AXI-Lite Master Interface ---------
    wire          aclk;
    wire          areset;
    // write addresss channel
    wire [31:0]   awaddr;
    wire [3:0]    awcache;
    wire [2:0]    awprot;
    wire          awvalid;
    reg           awready;

    // write data channel
    wire [31:0]   wdata;
    wire [3:0]    wstrb;
    wire          wvalid;
    reg           wready;

    // write resp channel
    wire          bready;
    reg [1:0]     bresp;
    reg           bvalid;

    // address read channel
    wire [31:0]   araddr;
    wire [3:0]    arcache;
    wire [2:0]    arprot;
    wire          arvalid;
    reg           arready;

    // read responce channel
    reg [31:0]    rdata;
    reg           rvalid;
    wire          rready;
    reg [1:0]     rresp;

    bit [31:0] read_data;

    axi_lite DUT (
        .pclk(pclk),
        .preset(preset),
        .psel(psel),
        .penable(penable),
        .paddr(paddr),
        .pwdata(pwdata),
        .pwrite(pwrite),
        .prdata(prdata),
        .pready(pready),
        .aclk(aclk),
        .areset(areset),
        .awaddr(awaddr),
        .awcache(awcache),
        .awprot(awprot),
        .awvalid(awvalid),
        .awready(awready),
        .wdata(wdata),
        .wstrb(wstrb),
        .wvalid(wvalid),
        .wready(wready),
        .bready(bready),
        .bresp(bresp),
        .bvalid(bvalid),
        .araddr(araddr),
        .arcache(arcache),
        .arprot(arprot),
        .arvalid(arvalid),
        .arready(arready),
        .rdata(rdata),
        .rvalid(rvalid),
        .rready(rready),
        .rresp(rresp)
    );

    axi_ram RAM(
        .S_AXI_ACLK(aclk),
        .S_AXI_ARESETN(!areset),
        .S_AXI_AWADDR(awaddr),
        .S_AXI_AWPROT(awprot),
        .S_AXI_AWVALID(awvalid),
        .S_AXI_AWREADY(awready),
        .S_AXI_WDATA(wdata),
        .S_AXI_WSTRB(wstrb),
        .S_AXI_WVALID(wvalid),
        .S_AXI_WREADY(wready),
        .S_AXI_BRESP(bresp),
        .S_AXI_BVALID(bvalid),
        .S_AXI_BREADY(bready),
        .S_AXI_ARADDR(araddr),
        .S_AXI_ARPROT(arprot),
        .S_AXI_ARVALID(arvalid),
        .S_AXI_ARREADY(arready),
        .S_AXI_RDATA(rdata),
        .S_AXI_RRESP(rresp),
        .S_AXI_RVALID(rvalid),
        .S_AXI_RREADY(rready)
    );

    initial begin
        pclk = 'b0;
        forever begin
            #5 pclk = ~pclk;
        end
    end

    task reset();
        preset = 'b0;
        psel = 'b0;
        penable = 'b0;
        paddr = 'b0;
        pwdata = 'b0;
        pwrite = 'b0;
        `CLK_WAIT
        preset = 'b1;
        repeat(10)`CLK_WAIT
        preset = 'b0;
    endtask

    task write_apb(input bit [31:0] addr, input [31:0] data);
        psel = 'b1;
        pwrite = 'b1;
        paddr = addr;
        pwdata = data;
        `CLK_WAIT
        penable = 'b1;
        wait(pready == 'b1);
        `CLK_WAIT
        penable = 'b0;
        psel = 'b0;
        pwrite = 'b0;
    endtask
    
    task read_apb(input bit [31:0] addr, output bit [31:0] data);
        psel = 'b1;
        paddr = addr;
        `CLK_WAIT
        penable = 'b1;
        wait(pready == 'b1);
        data = prdata;
        `CLK_WAIT
        penable = 'b0;
        psel = 'b0;
    endtask

    task write_via_axi(input bit [31:0] addr, input [31:0] data);
        write_apb('b1,addr);
        write_apb('h10,data);
        write_apb('b0,'h0000_0089);
        read_apb('h0,read_data);
        do begin
            read_apb('h0,read_data);
        end while(read_data[9] != 'b1);
        write_apb('b0,'h0000_0200);
        repeat(5)`CLK_WAIT
    endtask

    task read_via_axi(input bit [31:0] addr, output [31:0] data);
        write_apb('b1,addr);
        write_apb('b0,'h0000_0009);
        read_apb('h0,read_data);
        do begin
            read_apb('h0,read_data);
        end while(read_data[9] != 'b1);
        write_apb('b0,'h0000_0200);
        read_apb('h20,read_data);
        repeat(5)`CLK_WAIT
    endtask

    initial begin
        reset();
        write_via_axi('h8000_1020, 'hdeadbeef);
        read_via_axi('h8000_1020, read_data);
    end
endmodule
