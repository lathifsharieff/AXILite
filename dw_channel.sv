
module dw_channel(
    input clk,
    input reset,

    input start,
    input [3:0] bytes,
    output rem,
    output comp,
    input [15:0][31:0]   data,

    output reg [31:0]   wdata,
    output reg [3:0]    wstrb,
    output reg          wvalid,
    input           wready
);

    reg [7:0] total_bytes;
    reg begin_transfer;
    reg [3:0] index;
    reg handshake;
    
    assign comp = handshake;

    always@(posedge clk) begin
        if(reset) begin
            wdata <= 'b0;
            wstrb <= 'b0;
            wvalid <= 'b0;
            total_bytes <= 'b0;
            begin_transfer <= 'b0;
            index <= 'b0;
            handshake <= 'b0;
        end else if (handshake == 'b1) begin
            wvalid <= 'b0;
            if(total_bytes >= 4) begin
                total_bytes <= total_bytes - 4;    
            end else total_bytes <= 0;
        end else if (wvalid && wready) begin
            handshake <= 'b1;
        end else if (start && !begin_transfer) begin
            total_bytes <= bytes;
            begin_transfer <= 'b1;
        end else if (begin_transfer) begin
            wdata <= data[0];
            wvalid <= 'b1;
            if(total_bytes == 1) begin
                wstrb <= 4'b0001;
            end else if(total_bytes == 2) begin
                wstrb <= 4'b0011;
            end else if(total_bytes == 3) begin
                wstrb <= 4'b0111;    
            end else wstrb <= 4'b1111;
        end
    end
endmodule