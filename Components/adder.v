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

