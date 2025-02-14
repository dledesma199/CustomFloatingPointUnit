
//=======================================================
//  This code is generated by Terasic System Builder
//=======================================================

module Lab6Demo(

	//////////// CLOCK //////////
	input 		          		ADC_CLK_10,
	input 		          		MAX10_CLK1_50,
	input 		          		MAX10_CLK2_50,

	//////////// SEG7 //////////
	output		     [7:0]		HEX0,
	output		     [7:0]		HEX1,
	output		     [7:0]		HEX2,
	output		     [7:0]		HEX3,
	output		     [7:0]		HEX4,
	output		     [7:0]		HEX5,

	//////////// KEY //////////
	input 		     [1:0]		KEY,

	//////////// LED //////////
	output		     [9:0]		LEDR,

	//////////// SW //////////
	input 		     [9:0]		SW
);
wire [3:0] hexextra1,hexextra2;
reg [31:0] displayOut;
wire [63:0] sampleData;
wire [31:0] FPmultresult,FPadderresult,result;
reg cont = 1'b1;
reg [8:0] counter = 9'd0;
reg [1:0] state,nextstate;
 


RAM32x64 ram0(64'd0,SW[4:0],MAX10_CLK1_50,sampleData);


multiplier FPmult0(sampleData[63:32],sampleData[31:0],MAX10_CLK1_50,SW[9],1'b1,SW[8],FPmultresult);
adder      FPadd(FPadderresult,sampleData[63:32],sampleData[31:0],SW[8],1'b1,MAX10_CLK1_50,~SW[9]);


ifcall ifcall0(displayOut[15:12],displayOut[7:4],SW[5],hexextra1);
ifcall ifcall1(displayOut[11:8],displayOut[3:0],SW[5],hexextra2);

boardDisplay   bd(FPmultresult,FPadderresult,SW[8],SW[6],result);

display display5(displayOut[31:28],HEX5);
display display4(displayOut[27:24],HEX4);
display display3(displayOut[23:20],HEX3);
display display2(displayOut[19:16],HEX2);
display display1(hexextra1,HEX1);
display display0(hexextra2,HEX0);


	parameter COUNT = 1'b1, 
	          WAIT = 1'b0;
	always @(posedge MAX10_CLK1_50) begin
      if(state == WAIT)
       counter = 9'b000000000;
      else
       counter = counter + 9'b000000001;
   end

	
	always @(posedge MAX10_CLK1_50 or posedge SW[9]) begin
    if (SW[9] == 1'b1) begin
      state <= WAIT;
      end
      else 
      state <= nextstate;  	
    end

always @(*) begin
   case(state) 
	  WAIT: 
			if(cont == 1'b1)begin
				displayOut = result;
				nextstate = COUNT;
			end
	  else begin
	  nextstate = WAIT;
	  end
	  
	  COUNT: 
			if(counter < 9'd500)begin          
				nextstate = COUNT;
				end
	  else begin
	  nextstate = WAIT;
	  end
	endcase
end



endmodule


module display(
	input [3:0] a,
	output [7:0] hex
);

assign hex[0] = (~a[3]&a[2]&~a[1]&~a[0])|(a[3]&~a[2]&a[1]&a[0])|(~a[3]&~a[2]&~a[1]&a[0])|(a[3]&a[2]&~a[1]&a[0]);
assign hex[1] = (~a[3]&a[2]&~a[1]&a[0])|(a[3]&a[1]&a[0])|(a[3]&a[2]&~a[0])|(a[2]&a[1]&~a[0]);
assign hex[2] = (~a[3]&~a[2]&a[1]&~a[0])|(a[3]&a[2]&~a[0])|(a[3]&a[2]&a[1]);
assign hex[3] = (~a[3]&a[2]&~a[1]&~a[0])|(a[3]&~a[2]&a[1]&~a[0])|(~a[2]&~a[1]&a[0])|(a[2]&a[1]&a[0]);
assign hex[4] = (~a[3]&a[2]&~a[1])|(~a[2]&~a[1]&a[0])|(~a[3]&a[0]);
assign hex[5] = (a[3]&a[2]&~a[1]&a[0])|(~a[3]&~a[2]&a[1])|(~a[3]&~a[2]&a[0])|(~a[3]&a[1]&a[0]);
assign hex[6] = (a[3]&a[2]&~a[1]&~a[0])|(~a[3]&a[2]&a[1]&a[0])|(~a[3]&~a[2]&~a[1]);
assign hex[7] = 1; 

endmodule 


// Quartus Prime Verilog Template
// Single port RAM with single read/write address 
module RAM32x64(
input [63:0] data,
input [4:0] addr,   
input clk, 
output reg [63:0] q
);

	reg [63:0] mem [31:0];
	
	integer i;
	initial begin
	$readmemb ("testNums.txt", mem);
	end
	always @ (posedge clk)
	begin
		q <= mem[addr];
	end
 
	
endmodule






module multiplier #(parameter n = 32)(
    input [n-1:0] A, B,
	 input Clock,
	 input reset,
	 input start,
	 input mode,
	 output [n-1:0] Product
);

	wire sign1,sign2;
	wire [n-2:n-9] exp1,exp2;
	wire [n-10:0] frac1,frac2,tempFrac;
	wire [7:0] tempExp1,tempExp2;
	wire [6:0] fracHigh1, fracHigh2;
	wire [24:0] tempFrac1, tempFrac2;
	wire carry1;
	wire carry2;
	wire carry3;
	wire mMSB, tempSign;
	wire [49:0] tempOut;
	wire [8:0] fracHighMult1, fracHighMult2;
	wire [17:0] tempOut2;
	wire [22:0] tempmodeOut1; 
	wire [6:0]  tempmodeOut2;

	
	assign sign1 = A[31];
	assign sign2 = B[31];
	assign exp1  = A[30:23];
	assign exp2  = B[30:23];
	assign frac1 = A[22:0];
	assign frac2 = B[22:0];
	assign fracHigh1 = A[22:16];  
	assign fracHigh2 = B[22:16];
	
	assign tempSign = sign1 ^ sign2;
	
	RippleCarryAdder #(.n(8)) add1(exp1,exp2,tempExp1,carry1);
	
	RippleCarryAdder #(.n(8)) add2(tempExp1,8'b10000001,tempExp2,carry2);
	
	assign tempFrac1 = {2'b01,frac1};
	assign tempFrac2 = {2'b01,frac2};
	assign fracHighMult1 = {2'b01, fracHigh1};
	assign fracHighMult2 = {2'b01, fracHigh2};
	assign tempOut = tempFrac1 * tempFrac2;
   assign tempOut2 = fracHighMult1 * fracHighMult2;

	wire [7:0] tempExp;
	
	assign mMSB = ~mode ? tempOut[47] : tempOut2[15];
	
	RippleCarryAdder #(.n(8)) add3(tempExp2,{7'b0000000,mMSB},tempExp,carry3);
	
	assign tempmodeOut1 = tempOut[47] ? tempOut[46:24] : tempOut[45:23];
	assign tempmodeOut2 = tempOut2[15] ? tempOut2[14:8] : tempOut2[13:7];
	
	assign tempFrac = mode ? {tempmodeOut2, 16'b0000000000000000} : tempmodeOut1;
	
	assign Product ={tempSign,tempExp,{(~mode ? tempmodeOut1[22:16] : tempmodeOut2[6:0]),(~mode ? tempmodeOut1[15:0] : 16'b0000000000000000)}};
	
	
	
endmodule	
	

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


module ifcall(
input A,
input B,
input switch,
output reg answer
);

always @(*) begin


if (switch) begin
    answer <= 4'b1111;
	end
	else begin
	 answer <= B;
	end
end

endmodule 

module adder#(parameter n = 32)(
	output reg [31:0] Product,
	input [31:0] A,
	input [31:0] B,
	input mode,
	input start,
	input Clock,
	input reset
	);
	
	reg [n-1:0] frac1,frac2;
	reg sign1,sign2,signOut;
	reg [7:0] exp1,exp2;
	reg one1,one2;
	reg [n-2:n-9] expOut;
	reg [n-9:0] sum;
	reg [n-1:0] sumTotal;
	reg [3:0] temp3;
	
	reg [2:0] state, nextState; 
	
	
	
	
	
	parameter 	HOLD = 3'b001,
	            ALLIGN = 3'b010,
					ADD = 3'b011,
					NORMALIZE = 3'b100,
					FINISH = 3'b101;
					
	
	
	always@(posedge Clock or negedge reset) begin
		if(!reset) state = HOLD;
		else state <= nextState;
	end
	
	
	
	
	always @(posedge Clock) begin
		case (state)
			HOLD:begin
				
				if (start == 1)begin
				  frac1 <= A;
				  frac2 <= B;
				  one1 <= 1'b1;
				  one2 <= 1'b1;
				  Product <= 32'd0;
				  sign1 <= A[n-1];
				  sign2 <= B[n-1];
				  expOut <= 8'd0;
				  signOut <= 1'b0;
				  nextState = ALLIGN;
				  
				end
				else nextState = HOLD;
			end
			
			ALLIGN: begin
			     	if(frac1[30:0] == 0) begin
						signOut <= sign2;
						expOut <= frac2[n-2:n-9];
						sum[n-10:0] <= frac2[n-10:0];
						nextState = FINISH;	
					end
					
					else if(frac2[30:0] == 0) begin
						signOut <= sign1;
						expOut <= frac1[n-2:n-9];
						sum[n-10:0] <= frac1[n-10:0];
						nextState = FINISH;	
					end
					else begin
						if (frac1[n-2:n-9] < frac2[n-2:n-9])begin
						{one1,frac1[n-10:0]} <= {1'b0,one1, frac1[n-10:1]};
						frac1[n-2:n-9] = frac1[n-2:n-9] + 1;
						nextState = ALLIGN;
						end
						else if (frac2[n-2:n-9] < frac1[n-2:n-9])begin
							{one2,frac2[n-10:0]} <= {1'b0,one2, frac2[n-10:1]};
							frac2[n-2:n-9] = frac2[n-2:n-9] + 1;
							nextState = ALLIGN;
						end
						else begin
						expOut <= frac1[n-2:n-9];
						nextState = ADD;
						end
					end
			end
			
			ADD: begin
			
				 case({sign1,sign2})
				 
				 2'b00:
				 begin
						signOut <= 1'b0;
						sum <= {one1,frac1[n-10:0]} + {one2,frac2[n-10:0]};
						nextState = NORMALIZE;
				 end
				 
				 2'b01:
				 begin
				       if(B[n-2:n-9] < A[n-2:n-9])begin
						 signOut <= sign1;
						 sum <= {one1,frac1[n-10:0]} - {one2,frac2[n-10:0]};
						 nextState = NORMALIZE;
						 end
						 else if(A[n-2:n-9] < B[n-2:n-9])begin
						 signOut <= sign2;
						 sum <= {one2,frac2[n-10:0]} - {one1,frac1[n-10:0]};
						 nextState = NORMALIZE;
						 end
						 else if (A[n-2:n-9] == B[n-2:n-9])begin
							if (B[n-10:0] < A[n-10:0])begin
								signOut = sign1;
								sum <= {one1,frac1[n-10:0]} - {one2,frac2[n-10:0]};
								nextState = NORMALIZE;
							end	
							else if (A[n-10:0] < B[n-10:0])begin
								signOut = sign2;
								sum <= {one2,frac2[n-10:0]} - {one1,frac1[n-10:0]};
								nextState = NORMALIZE;
							end	
							else if (A[n-10:0] == B[n-10:0])begin
							signOut = 1'b0;
							sum = 24'd0;
							expOut = 8'd0;
							nextState = FINISH;
							end
						 end
						 
				 end
				 2'b10:
				 begin
				       if(B[n-2:n-9] < A[n-2:n-9])begin
						 signOut <= sign1;
						 sum <= {one1,frac1[n-10:0]} - {one2,frac2[n-10:0]};
						 nextState = NORMALIZE;
						 end
						 else if(A[n-2:n-9] < B[n-2:n-9])begin
						 signOut <= sign2;
						 sum <= {one2,frac2[n-10:0]} - {one1,frac1[n-10:0]};
						 nextState = NORMALIZE;
						 end
						 else if (A[n-2:n-9] == B[n-2:n-9])begin
							if (B[n-10:0] < A[n-10:0])begin
								signOut = sign1;
								sum <= {one1,frac1[n-10:0]} - {one2,frac2[n-10:0]};
								nextState = NORMALIZE;
							end	
							else if (A[n-10:0] < B[n-10:0])begin
								signOut = sign2;
								sum <= {one2,frac2[n-10:0]} - {one1,frac1[n-10:0]};
								nextState = NORMALIZE;
							end	
							else if (A[n-10:0] == B[n-10:0])begin
							signOut = 1'b0;
							sum = 24'd0;
							expOut = 8'd0;
							nextState = FINISH;
							end
						 end
		
				 end
				 2'b11:
				 begin
				     signOut <= 1'b1;
						sum <= {one1,frac1[n-10:0]} + {one2,frac2[n-10:0]};
						nextState = NORMALIZE;
				 end
				 
				endcase
			end

			NORMALIZE: begin 
			    case({sign1,sign2})
				 2'b00:
				 begin
						if(sum[n-9] == 1'b0)begin
							sum <= sum >> 1;
							expOut <= expOut + 1;
							nextState <= FINISH;
						end
						else begin
						   nextState <= FINISH;
					   end
				 end
				 
				 2'b01:
				  begin
						if(sum[n-9] == 1'b0)begin
							sum <= sum << 1;
							expOut <= expOut - 1;
							nextState <= NORMALIZE;
						end
						else begin
						   nextState <= FINISH;
					   end
				 end
				 
				 2'b10:
				 begin
				 		if(sum[n-9] == 1'b0)begin
							sum <= sum << 1;
							expOut <= expOut - 1;
							nextState <= NORMALIZE;
						end
						else begin
						   nextState <= FINISH;
					   end
				 end
				 
				 2'b11:
             begin
						if(sum[n-9] == 1'b0)begin
							sum <= sum >> 1;
							expOut <= expOut + 1;
							nextState <= FINISH;
						end
						else begin
						   nextState <= FINISH;
					   end
				  end
				endcase
			end
			FINISH: begin
			
			   
				if (mode == 1) begin
						Product[n-10:0] <= {sum[22:16],16'b0000000000000000};
						Product[n-1] <= signOut;
					   Product[n-2:n-9] <= expOut;
					   nextState = HOLD;
				end
				else begin
					Product[n-10:0] <= sum[n-10:0];
					Product[n-1] <= signOut;
					Product[n-2:n-9] <= expOut;
					nextState = HOLD;
				end
			end
		
		endcase
		
	end
	

endmodule

module boardDisplay(
input [31:0] A,
input [31:0] B,
input mode,
input operation,
output reg [31:0] toDisplay

);

always@(*)begin
    if(operation)begin
	    if(mode) begin
			toDisplay[31:28] <= A[31:28];
			toDisplay[27:24] <= A[27:24];
			toDisplay[23:20] <= A[23:20];
			toDisplay[19:16] <= A[19:16];
			toDisplay[15:12] <= 4'b1111;
			toDisplay[11:8]  <= 4'b1111;
			toDisplay[7:4]   <= 4'b1111;
			toDisplay[3:0]   <= 4'b1111;
	    end
		 else begin
			toDisplay[31:28] <= A[31:28];
			toDisplay[27:24] <= A[27:24];
			toDisplay[23:20] <= A[23:20];
			toDisplay[19:16] <= A[19:16];
			toDisplay[15:12] <= A[15:12];
			toDisplay[11:8]  <= A[11:8];
			toDisplay[7:4]   <= A[7:4];
			toDisplay[3:0]   <= A[3:0];
		end
	 end
	 else begin
		if(mode) begin
		toDisplay[31:28] <= B[31:28];
		toDisplay[27:24] <= B[27:24];
		toDisplay[23:20] <= B[23:20];
		toDisplay[19:16] <= B[19:16];
		toDisplay[15:12] <= 4'b1111;
		toDisplay[11:8]  <= 4'b1111;
		toDisplay[7:4]   <= 4'b1111;
		toDisplay[3:0]   <= 4'b1111;
		end
	 else begin
		toDisplay[31:28] <= B[31:28];
		toDisplay[27:24] <= B[27:24];
		toDisplay[23:20] <= B[23:20];
		toDisplay[19:16] <= B[19:16];
		toDisplay[15:12] <= B[15:12];
		toDisplay[11:8]  <= B[11:8];
		toDisplay[7:4]   <= B[7:4];
		toDisplay[3:0]   <= B[3:0];
	 end
	 end
	end
endmodule	