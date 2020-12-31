//VERILOG CODE:
//Sumit kumar yadav: 18CS30042
//Avijit mandal: 18CS30010

module flipflop(input clk,input d,output y);
    reg y;
    always @(posedge clk)
     y<=d;
endmodule

module UpdateState (input clk,input[3:0] d,output[3:0] y);
    genvar i;
    generate
         for(i=0;i<4;i=i+1) flipflop ff(clk,d[i],y[i]);
    endgenerate
endmodule

module Meal(input clk,input reset,input i,output[3:0] o);
    wire [3:0] state,nextState;
    wire [3:0] ground=4'b0000;
    assign nextState=reset?ground:(state*
    UpdateState update(clk,nextState,state);
    assign o=reset?ground:(state*2+i)%(4);
endmodule

module Moor(input clk,input reset,input i,output[3:0] o);
    wire [3:0] state,nextState;
    wire [3:0] ground=4'b0000;
    wire [3:0] One=4'b0001;
    assign nextState=reset?ground:(state+
    UpdateState update(clk,nextState,state);
    assign o=nextState;
endmodule

module main();
    wire [3:0] ml,mr;
    reg clk,reset,i;
    Meal a(clk,reset,i,ml);
    Moor b(clk,reset,i,mr);
    initial clk=0;
    initial #140 $finish;
    initial
    begin
        reset=1;
        #5;
        reset=0;
    end
    always #5 clk = ~clk;
    initial
    begin
        i=0;
        #5; i=1;
        #15; i=1;
        #25; i=0;
        #35; i=1;
        #45; i=0;
    end
    initial
    $monitor(,$time," reset=%b, inp=%b, mealey=%d, moore=%d",reset,i,ml,mr);
endmodule

