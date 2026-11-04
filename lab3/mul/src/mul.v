module mul #(
    parameter WIDTH = 16
)(
    input                     clk,
    input                     rst,
    input       [WIDTH-1:0]   multiplicand,
    input       [WIDTH-1:0]   multiplier,
    input                     start,
    output reg  [2*WIDTH-1:0] product,
    output wire               finish
);

    localparam IDLE = 2'b00;        // About to start
    localparam BUSY = 2'b01;        // Calculating
    localparam DONE = 2'b10;        // Done

    reg [1:0]         state;
    reg [5:0]         cnt;
    reg [WIDTH-1:0]   B;

    /* write code here */

    assign finish = (state == DONE);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state   <= IDLE;
            cnt     <= 6'd0;
            B       <= {WIDTH{1'b0}};
            product <= {2*WIDTH{1'b0}};
        end

        else begin
            case (state)
                IDLE: begin
                    // UNOPTIMIZED VERSION
                    //
                    // if (start) begin
                    //     product <= {2*WIDTH{1'b0}};
                    //     A       <= {{WIDTH{1'b0}}, multiplicand};
                    //     B       <= multiplier;
                    //     cnt     <= 6'd0;
                    //     state   <= BUSY;
                    // end

                    // OPTIMIZED VERSION
                    //
                    if (start) begin
                        product <= {{WIDTH{1'b0}}, multiplicand};
                        B       <= multiplier;
                        cnt     <= 6'd0;
                        state   <= BUSY;
                    end
                end

                BUSY: begin
                    // UNOPTIMIZED VERSION
                    //
                    // if (B[0])
                    //     product <= product + A;
                    // A   <= A << 1;
                    // B   <= B >> 1;
                    // cnt <= cnt + 6'd1;
                    // if (cnt == WIDTH - 1)
                    //     state <= DONE;

                    // OPTIMIZED VERSION
                    //
                    product <= { ({1'b0, product[2*WIDTH-1:WIDTH]} + (product[0] ? {1'b0, B} : {(WIDTH+1){1'b0}})),
                                 product[WIDTH-1:0] } >> 1;

                    cnt <= cnt + 6'd1;
                    if (cnt == WIDTH - 1)
                        state <= DONE;
                end

                // The same as IDLE
                DONE: begin
                    if (start) begin
                        product <= {{WIDTH{1'b0}}, multiplicand};
                        B       <= multiplier;
                        cnt     <= 6'd0;
                        state   <= BUSY;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
