module div #(
    parameter WIDTH = 16
)(
    input    clk,
	input    rst,
	input    start,
    input    [WIDTH-1:0] dividend, 
    input    [WIDTH-1:0] divisor,
    output   wire finish,
    output   wire [WIDTH-1:0] quotient,
    output   wire [WIDTH-1:0] remainder
);

    localparam IDLE = 2'b00;        // About to start
    localparam BUSY = 2'b01;        // Calculating
    localparam DONE = 2'b10;        // Done

    reg [1:0]         state;
    reg [5:0]         cnt;
    reg [WIDTH-1:0]   B;
    reg [2*WIDTH-1:0] O;

    /* write code here */

    assign finish    = (state == DONE);
    assign quotient  = O[WIDTH-1:0];
    assign remainder = O[2*WIDTH-1:WIDTH];

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            cnt   <= 6'd0;
            B     <= {WIDTH{1'b0}};
            O     <= {2*WIDTH{1'b0}};
        end

        else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        O     = {{WIDTH{1'b0}}, dividend};
                        B     <= divisor;
                        cnt   <= 6'd0;
                        state <= BUSY;
                    end
                end

                BUSY: begin
                    O = O << 1;
                    if (O[2*WIDTH-1:WIDTH] >= B)
                        O = {remainder - B, quotient} + 1'b1;

                    cnt <= cnt + 6'd1;
                    if (cnt == WIDTH - 1)
                        state <= DONE;
                end

                DONE: begin
                    if (start) begin
                        O     = {{WIDTH{1'b0}}, dividend};
                        B     <= divisor;
                        cnt   <= 6'd0;
                        state <= BUSY;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
