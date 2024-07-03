module full_adder(a, b, cin, sum, cout);
	input a;
	input b;
	input cin;
	output sum;
	output cout;
	
	
	assign sum = a ^ b ^ cin;
	assign cout = (a & cin)|(a & b)|(b & cin);
	
endmodule

module RippleCarryAdder #(parameter n) (
	input [n-1:0] a, b,
	output [n-1:0] sum,
	output carry
);

	wire [n-1:0] cout;

genvar i;
generate
	for (i = 0; i < n; i = i + 1) begin : ripple_adder
		
		full_adder f(.a(a[i]), .b(b[i]), .cin(i == 0 ? 1'b0 : cout[i-1]), .sum(sum[i]), .cout(cout[i]));
	end
assign carry = cout[n-1];
endgenerate

endmodule

