

//Test Bench machine

module machine1_tb();

	reg I,clk,reset;
	wire [2:0] mod;
	machine1 mc(I, clk, reset, mod);

	initial begin
		clk = 0;
		forever #5 clk = ~clk;
	end


	initial begin
		$monitor($time," residue = %b", mod);

		$dumpfile("machine1.vcd");
		$dumpvars(0, machine1_tb);
		I = 0; //initialization
		reset = 1;

		#50

		10

		reset = 0;
		#10 I = 0;
		#10 I = 1; //residues

		reset = 0;
		#10 I = 0;
		#10 I = 1; //resdue test 42, uncomment for testing
		#10 I = 0;
		#10 I = 1;
		#10 I = 0;
		#10 I = 1;
		#10
		$finish;
	end
endmodule
