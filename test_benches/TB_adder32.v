module testbench;

	reg [31:0] A;
	reg [31:0] B;
        reg Clock,reset,start,mode;
        wire [31:0] Product;
        

        always begin
		#10
		Clock=~Clock;
	end 

	adder UUT (.Product(Product),.A(A),.B(B),.mode(mode),.start(start),.Clock(Clock),.reset(reset));

	integer i,temp;
	real Afloat,Bfloat, fpProduct, expectedProduct;
	//registers to hold the parts of each input value
	reg sign1,sign2;
	reg [7:0] exp1,exp2;
	reg [8:0] boundsCheck;
	reg [22:0] frac1bit32,frac2bit32;
	reg [6:0] frac1bit16,frac2bit16;
	reg [10:0] expA;
	reg [10:0] expB;
	reg [10:0] expProd;
	
	initial begin
                Clock=1'b0;
		reset=1'b0;
		start=1'b0;
		mode=1'b0;
		#40
		reset=1'b1;
                for (i=0; i<100; i=i+1) begin
		
			sign1=$random%2;
			sign2=$random%2;
			exp1=($random%4)+127;
			exp2=($random%4)+127;
			temp=$pow(2,23);
			frac1bit32=$random%temp;
			frac2bit32=$random%temp;
			
	
			A = {sign1,exp1,frac1bit32};
			B = {sign2,exp2,frac2bit32};
			
			
			#20
			start=1'b1;
			#40
			start=1'b0;
			#400
		
			//wait (done==1);
			//bias of 64 IEEE 1023 - 127 = 896
			expA=A[30:23]+ 11'b01110000000;
			expB=B[30:23]+ 11'b01110000000;
			expProd=Product[30:23]+ 11'b01110000000;
			Afloat=$bitstoreal({A[31],expA,A[22:0],29'd0});
			Bfloat=$bitstoreal({B[31],expB,B[22:0],29'd0});
			expectedProduct=Afloat+Bfloat;
			fpProduct=$bitstoreal({Product[31],expProd,Product[22:0],29'd0});
			//wait (done==0);
			
			//compute the total of the exponents and make sure there is not overflow, underflow
			boundsCheck=exp1+exp2;
			$display("A: %h + B %h  =        %h",A,B,Product);
			$display("Expected: A   %f ",Afloat);
                        $display("Expected: B    %f ",Bfloat);
                        $display("Expected: Product   %f",expectedProduct);
                        $display("Our Result:   %f ",fpProduct); 
                        // -126 to 127 -> so the max total = 127 + 127 and bias 127 upper bounds 381
                        
			if (boundsCheck>381)begin
                           $display("Falls out of range");
                           $display("Range before bias 128 < e < 381");
		           $display("overflow");
                           $display("");
                        end
			else if(boundsCheck<128)begin
                           $display("Falls out of range");
                           $display("Range before bias 128 < e < 381");
			   $display("underflow");
			   $display("");
                        end
			else begin
				$display("Percent error: %f percent",((expectedProduct-fpProduct)/expectedProduct)*100);
				$display("");
			end
		end

               
           $finish;
		
	end

endmodule