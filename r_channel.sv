module r_channel(
    input clk,
    input reset,

    output reg [31:0] data,
    output reg valid,
    output error,
    output success,

    input [31:0]    rdata,
    input           rvalid,
    output reg         rready,
    input [1:0]     rresp
);
    reg handshake;

    assign success = ((rresp == 'b0) && rready && rvalid) ? 1:0;
    assign error = ((rresp != 'b0) && rready && rvalid) ? 1:0;

    always@(posedge clk) begin
        if(reset) begin 
            rready <= 'b0;
            handshake <= 'b0;
            valid <= 'b0;
            data <= 'b0;
        end
        else if (handshake == 'b1) begin
            rready <= 'b0;
            valid <= 'b0;
        end else if (rvalid && rready) begin
            handshake <= 'b1;
            data <= rdata;
            valid <= 'b1;
        end else if (rvalid) begin
            rready <= 'b1;
        end
    end

endmodule
