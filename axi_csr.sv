module axi_csr(
    input           clk,
    input           reset,
    input           sel,
    input           enable,
    input [5:0]     addr,
    input [31:0]    wdata,
    input           write,
    output reg [31:0]   rdata,
    output reg      ready,

    output [31:0]   address,
    output          start,
    output [5:0]    bytes,
    output [15:0][31:0] data,
    output r_w,

    input tr_start,
    input tr_complete,
    input [31:0] r_data,
    input r_valid
);
    reg [31:0] address_reg;
    reg [15:0][31:0] data_reg;
    reg [31:0] control_reg;
    reg [31:0] read_data_reg;

    wire write_transaction;
    wire read_transaction;

    assign start = control_reg[0];
    assign bytes = control_reg[6:1];
    assign address = address_reg;
    assign r_w = control_reg[7];
    assign write_transaction = (sel && enable && write) ? 1:0;
    assign read_transaction = (sel && enable && !write) ? 1:0;
    assign data = data_reg;

    always @(posedge clk) begin
        ready <= 1'b0;
        if(reset) begin
            address_reg <= 'b0;
            control_reg <= 'b0;
            data_reg <= {'b0,'b0,'b0,'b0,'b0,'b0,'b0,'b0,'b0,'b0,'b0,'b0,'b0,'b0,'b0,'b0};
        end else if(write_transaction && addr == 'b0) begin
            control_reg[0] <= wdata[0];
            control_reg[7] <= wdata[7];
            if(wdata[6:1] > 4)
                control_reg[6:1] <= 'h4;
            else
                control_reg[6:1] <= wdata[6:1];
            ready <= 1'b1;
        end else if(write_transaction && addr == 'b1) begin
            address_reg <= wdata;
            ready <= 1'b1;
        end else if(write_transaction && addr[5:4] == 'b1) begin
            data_reg[addr[3:0]] <= wdata;
            ready <= 1'b1;
        end else if(read_transaction && addr == 'b0) begin
            rdata <= control_reg;
            ready <= 1'b1;
            control_reg[9] <= 0;
        end else if(read_transaction && addr == 'b1) begin
            rdata <= address_reg;
            ready <= 1'b1;
        end else if(read_transaction && addr[5:4] == 'b1) begin
            rdata <= data_reg[addr[3:0]];
            ready <= 1'b1;
        end else if(read_transaction && addr[5:4] == 'h2) begin
            rdata <= read_data_reg;
            ready <= 1'b1;
        end
        
        if (tr_start) begin
            control_reg[0] <= 'b0;
        end 

        if(tr_complete) begin
            control_reg[9:8] <= 'b10;
        end else if(start) begin
            control_reg[9:8] <= 'b01;
        end

        if(r_valid) begin
            read_data_reg <= r_data;
        end
    end
endmodule
