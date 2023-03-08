module controller(
    input clk,
    input reset,

    input r_w,
    input start,

    output reg w_start,
    output reg r_start,
    output reg tr_complete,
    output reg cntrl_rst,
    input w_resp,
    input r_resp,
    input w_comp,
    input r_comp
);

    wire write,read;

    assign write = (r_w && start) ? 1:0;
    assign read = (!r_w && start) ? 1:0;

    localparam START = 0,
                WRITE = 1,
                READ = 2,
                W_RESP = 3,
                R_RESP = 4,
                W_BEGIN = 5,
                R_BEGIN = 6,
                TR_END = 7;

    reg [3:0] state;

    always@(posedge clk) begin
        if(reset) begin
            state <= 'b0;
        end else begin
            case(state)
                START : begin state <= write ? WRITE : (read ? READ : START); end
                WRITE : begin state <= W_BEGIN; end
                READ : begin state <= R_BEGIN; end
                W_RESP : begin state <= w_resp ? TR_END : W_RESP; end
                R_RESP : begin state <= r_resp ? TR_END : R_RESP; end
                W_BEGIN : begin state <= w_comp ? W_RESP : W_BEGIN; end
                R_BEGIN : begin state <= r_comp ? R_RESP : R_BEGIN; end
                TR_END : begin state <= START; end 
            endcase
        end
    end

    always_comb begin
        w_start = 'b0;
        r_start = 'b0;
        tr_complete = 'b0;
        cntrl_rst = 'b0;
        case(state)
            START : begin cntrl_rst = 'b1; end
            WRITE : begin  end
            READ : begin  end
            W_RESP : begin  end
            R_RESP : begin  end
            W_BEGIN : begin w_start = 'b1; end
            R_BEGIN : begin r_start = 'b1; end
            TR_END : begin tr_complete = 'b1; end 
        endcase
    end

endmodule