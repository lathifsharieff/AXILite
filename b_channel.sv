module b_channel(
    input clk,
    input reset,

    input start,
    output success,
    output error,

    output reg      bready,
    input [1:0]     bresp,
    input           bvalid
);

    assign success = ((bresp == 'b0) && bready && bvalid) ? 1:0;
    assign error = ((bresp != 'b0) && bready && bvalid) ? 1:0;

    always@(posedge clk) begin
       if(reset) bready <= 'b0;
       else if (start && !bvalid) bready <= 'b1;
       else if (bvalid) bready <= 'b0;
       else bready <= 'b0;
    end

endmodule