module ar_channel(
    input clk,
    input reset,

    input start,
    input [31:0] addr,
    output comp,

    output reg [31:0]   araddr,
    output [3:0]    arcache,
    output [2:0]    arprot,
    output reg         arvalid,
    input           arready
);

    reg handshake;

    assign arcache = arvalid ? 4'b0011 : 4'b0000;
    assign arprot = 3'b000;
    assign comp = handshake;

    always@(posedge clk) begin
        arvalid <= 'b0;
        if(reset) begin
            araddr <= 'b0;
            handshake <= 'b0;
        end else if (handshake == 'b1) begin
            arvalid <= 'b0;
        end else if (arvalid && arready) begin
            handshake <= 'b1;
        end else if (start) begin
            araddr <= addr;
            arvalid <= 'b1;
        end else begin
            araddr <= 'b0;
            arvalid <= 'b0;
            handshake <= 'b0;
        end
    end
endmodule