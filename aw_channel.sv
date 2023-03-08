module aw_channel(
    input clk,
    input reset,

    input start,
    input [31:0] addr,
    output comp,

    output reg [31:0]   awaddr,
    output [3:0]    awcache,
    output [2:0]    awprot,
    output reg         awvalid,
    input           awready
);

    reg handshake;

    assign awcache = awvalid ? 4'b0011 : 4'b0000;
    assign awprot = 3'b000;
    assign comp = handshake;

    always@(posedge clk) begin
        awvalid <= 'b0;
        if(reset) begin
            awaddr <= 'b0;
            handshake <= 'b0;
        end else if (handshake == 'b1) begin
            awvalid <= 'b0;
        end else if (awvalid && awready) begin
            handshake <= 'b1;
        end else if (start) begin
            awaddr <= addr;
            awvalid <= 'b1;
        end else begin
            awaddr <= 'b0;
            awvalid <= 'b0;
            handshake <= 'b0;
        end
    end
endmodule