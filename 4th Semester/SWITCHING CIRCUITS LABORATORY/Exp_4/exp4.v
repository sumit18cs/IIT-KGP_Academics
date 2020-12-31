//Group No:44
//Sumit Kumar Yadav: 18CS30042
//Avijit Mandal: 18CS30010

//Please uncoment test batches one by one while running the code . While checking for one 
//particular testbatch all the other test batches should be in commented form .





// MODULE FOR FULL ADDER
module add(input a, input b,input cin, output cout, output s,output p,output g);
    assign s=a^b^cin;
    assign cout=(a&b)+(cin&(a^b));
    assign p = a^b;
    assign g = a&b;
endmodule



//TEST BENCH FOR FULL ADDER
/*
module testFullAdder();
    initial begin
        count = 3'b000;
        $dumpfile("addFull.vcd");
        $dumpvars;
        $display("%d\ta\tb\tcin\tcout\tsum",$time);
        $monitor("%d\t%d\t%d\t%d  \t%d   \t%d",$time,count[2],count[1],count[0],cout,s);

    end 

    always
        #5 count = count + 1'b1;
    
    initial 
        #35 $finish;

    reg[3:0] count;
    wire cout , s;
    wire p,g;
    add Fulladder(count[2],count[1],count[0],cout,s,p,g);
    
endmodule
*/

//MODULE FOR CARRY LOOK AHEAD

module carryLookAhead(
    input c0,
    input p0,input g0,
    input p1,input g1,
    input p2,input g2,
    input p3,input g3,
    output [4:0]carry,
    output pg,output gg
);
    assign carry[0]=c0;
    assign carry[1]=g0|(p0&c0);
    assign carry[2]=g1|(p1&g0)|(p1&p0&c0);
    assign carry[3]=g2|(p2&g1)|(p2&p1&g0)|(p2&p1&p0&c0);
    assign carry[4]=g3|(p3&g2)|(p3&p2&g1)|(p3&p2&p1&g0)|(p3&p2&p1&p0&c0);
    assign pg=p0&p1&p2&p3;
    assign gg=g3|(p3&g2)|(p3&p2&g1)|(p3&p2&p1&g0);

endmodule

//TEST BENCH FOR 4 BIT CARRY LOOK AHEAD UNIT 

/*
module testCarryLookAheadUnit();

    reg[8:0] count;    //inputs
    wire[4:0] carry;    //outputs
    wire gg, pg;  //outputs

    //circuit to test
   carryLookAhead clau(
       .c0(count[8]),
       .p0(count[0]), .g0(count[4]),
       .p1(count[1]), .g1(count[5]),
       .p2(count[2]), .g2(count[6]),
       .p3(count[3]), .g3(count[7]),
        .carry(carry),
        .pg(pg), .gg(gg)
   );

    //initialize
    initial begin
        count = 9'b000000000;
    end

    
    initial begin

        $dumpfile("carryLookAheadUnit.vcd");
        $dumpvars;
        $display("%d\tc\tgi  \tpi  \tci   \tpg\tgg", $time);
        $monitor("%d\t%b\t%b%b%b%b\t%b%b%b%b\t%b%b%b%b%b\t%b\t%b", $time, 
        count[8],
        count[7], count[6],count[5], count[4],
        count[3], count[2],count[1], count[0],
        carry[4], carry[3], carry[2], carry[1], carry[0], gg, pg);
    end

     always
        #5 count = count + 1'b1; // incrementing the value after 5 unit of time in a loop upto 2555
    //termination time
    initial
        #2555 $finish;

endmodule
*/

module carryLookAhead4bit(input [3:0]a,input [3:0]b,input cin,output [3:0]sum,output pg,output gg,output c4);
    wire [3:0] p;   //storing the p's
    wire [3:0] g;   //storing the g's
    wire [4:0] carry; //generate the carry's
    wire temp;  
    assign temp = 0 ; //dump value to operate the addition function
    genvar i;
    //copying full adder circuit 4 times
    generate
        for(i=0;i<4;i=i+1)
        begin
            add fa(a[i],b[i],carry[i],temp,sum[i],p[i],g[i]);
        end
    endgenerate
    
    //connecting with the CARRY LOOK AHEAD UNIT

    carryLookAhead unit(
        cin,
        p[0],g[0],
        p[1],g[1],
        p[2],g[2],
        p[3],g[3],
        carry,
        pg,gg

    );
    assign c4=carry[4];

endmodule

//TEST BENCH FOR 4 BIT CARRY LOOK AHEAD ADDER
/*

module testCarryLookAhead4bit();
    reg [7:0] count;
    reg cin;
    wire [3:0] sum;
    wire pg,gg,c4;
    
    //initialize the values
    initial begin
      count = 8'b00000000;
      cin = 0;
    end
    always
        #5 count = count + 1'b1;

    carryLookAhead4bit ca(count[3:0],count[7:4],cin,sum,pg,gg,c4);
    initial begin
      $dumpfile("clau4bit.vcd");
      $dumpvars;
        $display("%d\tA   \tB   \tsum \tgg\tpg\tcout", $time);
        $monitor("%d\t%b%b%b%b\t%b%b%b%b\t%b%b%b%b\t%b\t%b\t%b", $time, 
        count[3], count[2],
        count[1], count[0],
        count[7], count[6],
        count[5], count[4],
        sum[3], sum[2], sum[1], sum[0], gg, pg, c4);
    end
    initial
        #1275 $finish;
endmodule

*/

//16 Bit Carry Look Ahead adder

module carryLookAhead16bit(input [15:0] a,input [15:0] b,input cin,output [15:0] s,output pg,output gg,output c16);
    wire [3:0] p;
    wire [3:0] g;
    wire [4:0] carry;
    wire temp;
    genvar i;

    // Estimating 4 bit CarryLookAhead Adder 4 times

    generate
        for(i=0;i<4;i=i+1)
        begin
            carryLookAhead4bit CLA4Bitblock(a[4*(i+1)-1:4*i],b[4*(i+1)-1:4*i],carry[i],s[4*(i+1)-1:4*i],p[i],g[i],temp);
        end
    endgenerate

    //Using CLAU unit

    carryLookAhead unit(cin,p[0],g[0],p[1],g[1],p[2],g[2],p[3],g[3],carry,pg,gg);
    assign c16=carry[4];
endmodule


//TEST BENCH CARRY LOOK AHEAD ADDER 16 BIT 

/*
module testCarryLookAhead16bit();

    reg [15:0]a;
    reg [15:0]b;
    reg cin;
    wire [15:0]sum;
    wire gg;
    wire pg;
    wire c16;
    
    carryLookAhead16bit cla16bit(a,b, cin,sum,pg,gg,c16);

    // inputs will updated and tested every after 10 unit of time 

    initial begin
        a=0; b=0; cin=0;
        #10 a=16'd0; b=16'd0; cin=1'd1;
        #10 a=16'd14; b=16'd1; cin=1'd1;
        #10 a=16'd5; b=16'd0; cin=1'd0;
        #10 a=16'd999; b=16'd0; cin=1'd1;
        #10 a=16'd65535; b=16'd0;cin=1'd1;

    end

    initial begin
        $dumpfile("clau16bit.vcd");
        $dumpvars;
        $monitor( "A=%d, B=%d, cin= %d, sum=%d, cout=%d", a,b,cin,sum,c16);

    end
    
    endmodule

*/

