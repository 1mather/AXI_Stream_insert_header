`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/16 12:32:33
// Design Name: 
// Module Name: axi_stream_insert_header
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module axi_stream_insert_header#(
		parameter 					DATA_WD=32,
		parameter 					DATA_BYTE_WD=DATA_WD/8,
		parameter 					BYTE_CNT_WD=$clog2(DATA_BYTE_WD)
    )(
		input clk,
		input rst_n,
		
		//axi input orginal data
		input 						valid_in,
		input [DATA_WD-1:0] 		data_in,
		input [DATA_BYTE_WD-1:0] 	keep_in,
		input 						las_in,
		output 						ready_in,       //control r6
		//axi  output with header inseted
		output						valid_out,    	//control r1
		output [DATA_WD-1:0] 		data_out,		//control r2
		output [DATA_BYTE_WD-1:0] 	keep_out,		//control r3	
		output						last_out,		//control r4
		input						ready_out,		
		//header input to be inserted to axi stream
		input 						valid_insert,
		input [DATA_WD-1:0]			data_insert,
		input [DATA_BYTE_WD-1:0]	keep_insert,
		input [BYTE_CNT_WD:0]		byte_insert_cnt,
		output						ready_insert	//control r5
	);
	/*********************register*****************************/
	

	/*------------ data_out 2 data_in----------*/										
	reg						r_ready_in;	
	/*------------ data_out 2 insert_in--------*/
	reg						r_ready_insert;
	
	/*------------ data_out output------------*/	
	reg [DATA_WD-1:0] 		r_data_out;
	reg [DATA_BYTE_WD-1:0] 	r_keep_out;
	reg						r_last_out;		
    reg 					  r_valid_out;


	

	//reg                     r_byte_insert_cnt;   //strore the value of insert_cnt

	
										


	// Delay the axis_tvalid and axis_tlast signal by one clock cycle                              
	// to match the latency of DATA                          
    reg  						las_in_delay_1;
	reg [DATA_WD-1:0]			data_in_delay_1;   
	reg [DATA_BYTE_WD-1:0]  	keep_in_delay_1;  	
	reg  						las_in_delay;
	reg [DATA_WD-1:0]			data_in_delay;   //data_in from the former circle
	reg [DATA_BYTE_WD-1:0]  	keep_in_delay;  //which will be used in compensatory burst

	reg      				count;          //a flag of the first transfer of data'1'
	reg                   compens;     // a flag of the compensatory transfer
/*  reg [DATA_WD-1:0]		data_in_temp;
	reg [DATA_WD-1:0]		data_out_temp;
	reg [BYTE_CNT_WD-1:0]   r_byte_insert_cnt_delay; */
	
	
	/****************************connection******************************/
	
	assign valid_out 	=	r_valid_out;
	assign data_out  	=	r_data_out;
	assign keep_out  	=	r_keep_out;
	assign last_out 	=	r_last_out;
	assign ready_insert	=	r_ready_insert;

	assign ready_in 	=	r_ready_in;
	/*********************combinational path*****************************/	



	
	/*********************sequntial data path*****************************/	
				
						/*-----data inserted------*/
	
		always@(posedge clk)begin
		
		if (!rst_n||count)// unabel after first burst////////////////////////////////////
		  begin
			r_ready_insert<='d0;
		  end
		else if(valid_insert)
		  begin
			r_ready_insert<='d1;
		  end
		else
		begin
			r_ready_insert<='d0;
	   end
	   end


	/*-----data in------*/
		always @ (posedge clk)
	begin
		
		if(!rst_n||las_in)// stable during whole period of a transfer///////////////////////////////
		  begin
			r_ready_in='d0;
		  end
		else if(valid_in)
		  begin
			r_ready_in='d1;
		  end
		else
			r_ready_in='d0;
	end	
	/*----- data out------*/
/*  	always @(posedge clk)                                                                  
	begin                                                                                          
	  if (!rst_n||~count) // count==0 mean the finish of transfer                                                                         
	    begin                                                                                      
	       r_valid_out<= 1'b0;                                                                                                                   
	    end                                                                                        
	  else if(valid_in&valid_insert)                                                                                        
	    begin                                                                                      
          r_valid_out <= 1'b1;                                           
	    end 
	  else
		begin
		  r_valid_out <= 1'b0;     
		end
		
	end  */	


                                /***r_valid_out  ***/
always @(posedge clk)
begin
    if(!rst_n)
        begin
            r_valid_out<=0;
        end
     else if (valid_in&valid_insert)
         begin
            r_valid_out<=1;
         end
      else
            r_valid_out<=0;
end

	
	
	
	
	
					/***r_data_out    r_keep_out    r_last_out   ***/
	always @(posedge clk)                                                                  
	begin                                                                                          
	  if (!rst_n)                                                                         
	    begin                                                                                      
            r_data_out <=0;
			count<=0;
			r_keep_out<=0;
			r_last_out<=0;
			compens<=0;
	    end   
		
	  else if(r_valid_out&ready_out&~las_in&~count&~compens)		//the first  burst of a transfer
		//else if(valid_out&ready_out)
		begin
		          r_last_out<=0;
				//r_byte_insert_cnt<=byte_insert_cnt;
				case (byte_insert_cnt)
				 // 
				1: r_data_out <= {data_in[23:0], data_insert[31:24]};
				2: r_data_out <= {data_in[15:0], data_insert[31:16]};
				3: r_data_out <= {data_in[7:0], data_insert[31:8]};
				4: r_data_out <= data_insert;
//				1: r_data_out <= {data_insert[31:24], data_in[23:0]};
//				2: r_data_out <= {data_insert[31:16], data_in[15:0]}; // 
//				3: r_data_out <= {data_insert[31:8], data_in[7:0]};   // 
//				4: r_data_out <= data_insert;                         // 
				//default: data_out = data_insert; 				   
			endcase	
			count=~count;								//the finish of first burst of a transfer
	
	    end
		
	   else if (r_valid_out&ready_out&~las_in&~compens)			//middle period of a transfer
	     begin
			
			case (byte_insert_cnt)
				1: r_data_out <= {data_in[23:0], data_in_delay[31:24]};
				2: r_data_out <= {data_in[15:0], data_in_delay[31:16]};
				3: r_data_out <= {data_in[7:0], data_in_delay[31:8]};
				4: r_data_out <= data_in_delay;
//				1: r_data_out <= {data_in_delay[31:24], data_in[23:0]}; // 
//				2: r_data_out <= {data_in_delay[31:16], data_in[15:0]}; // 
//				3: r_data_out <= {data_in_delay[31:8], data_in[7:0]};   // 
//				4: r_data_out <= data_in_delay;                         //
				//default: data_out = data_in; 				            // 
			endcase	
		 end

	   else if (r_valid_out&ready_out&las_in&~compens)            // the last burst of a transfer
	     begin
			case (byte_insert_cnt)
				1: case (keep_in)
						4'b1111:begin
						//r_data_out 		<= {data_in_delay[31:24], data_in[23:0]}; 
						r_data_out 		<= {data_in[23:0], data_in_delay[31:24]};//  not yet finish 
						//r_las_in_delay  <= las_in;
						compens<=1;						

						end
						4'b1110:begin
						
						r_data_out 		<= {data_in[23:0], data_in_delay[31:24]};//   finish
						count			<=0;
						r_keep_out		<=4'b1111;
						r_last_out		<=1'b1;
						end
						4'b1100:begin
						r_data_out 		<= {{8{1'b0}}, data_in[15:0],data_in_delay[31:24]};//finish 
						count			<=0;
						r_keep_out		<=4'b1110;
						r_last_out		<=1'b1;
						end
						4'b1000:begin
						r_data_out 		<= {{16{1'b0}}, data_in[7:0],data_in_delay[31:24]};  // finish
						count			<=0;
						r_keep_out		<=4'b1100;
						r_last_out		<=1'b1;
						end
					endcase
				
				2: case (keep_in)
						4'b1111:begin
						r_data_out 		<= {data_in[15:0], data_in_delay[31:16]}; // not yet finish
						//r_las_in_delay  <= las_in;
						compens<=1;	
						end
						4'b1110:begin
						r_data_out 		<= {data_in[15:0], data_in_delay[31:16]}; // not yet finish
						//r_las_in_delay  <= las_in;
						compens<=1;	
						end
						4'b1100:begin
						r_data_out 		<= {data_in[15:0], data_in_delay[31:16]}; // finsh
						count			<=0;
						r_keep_out		<=4'b1111;
						r_last_out		<=1'b1;
						end
						4'b1000:begin
						r_data_out 		<= {{8{1'b0}}, data_in[7:0],data_in_delay[31:16]}; // finish
						count			<=0;
						r_keep_out		<=4'b1110;
						r_last_out		<=1'b1;
						end
					endcase
				
				3: case (keep_in)
						4'b1111:begin
						r_data_out 		<= { data_in[7:0], data_in_delay[31:8]}; // not yet finish
						//r_las_in_delay  <= las_in;
						compens<=1;	
						end
						4'b1110:begin
						r_data_out 		<= {data_in[7:0], data_in_delay[31:8]}; // not yet finish
						//r_las_in_delay  <= las_in;
						compens<=1;	
						end
						4'b1100:begin
						r_data_out 		<= {data_in[7:0], data_in_delay[31:8]}; // not yet finish
						//r_las_in_delay  <= las_in;
						compens<=1;	
						end
						4'b1000:begin
						r_data_out 		<= {data_in[7:0], data_in_delay[31:8]}; // finish
						count			<=0;
						r_keep_out		<=4'b1110;
						r_last_out		<=1'b1;
						end
					endcase
				
				
				4:  begin
						r_data_out 		<= data_in_delay; // not yet finish
						//r_las_in_delay  <= las_in;
						compens<=1;	
						end
						
					
			endcase	
		 end	


		 
	   else if (r_valid_out&ready_out&las_in_delay&compens)  //compensary burst,so we need to delay the (data_in,keep_in) which are unabel after 'las_in'
		begin	 
				count<=0;
				compens<=0;
				case (byte_insert_cnt)
					1: case (keep_in_delay)
							4'b1111:begin
							r_data_out 		<= {{24{1'b0}},data_in[31:24]}; // 
							r_keep_out		<=4'b1000;
							r_last_out		<=1'b1;
							end
						endcase
					
					2: case (keep_in_delay)
							4'b1111:begin
							r_data_out 		<= {{16{1'b0}},data_in[31:16]}; 
							r_keep_out		<=4'b1100;
							r_last_out		<=1'b1;
							end
							4'b1110:begin
							r_data_out 		<= { {24{1'b0}},data_in[23:16]};
							r_keep_out		<=4'b1000;
							r_last_out		<=1'b1;
							end
						endcase
					
					3: case (keep_in_delay)
							4'b1111:begin
							r_data_out 		<= {{8{1'b0}}, data_in[31:8]};
							r_keep_out		<=4'b1110;
							r_last_out		<=1'b1;
							end
							4'b1110:begin
							r_data_out 		<= { {16{1'b0}}, data_in[23:8]};
							r_keep_out		<=4'b1100;
							r_last_out		<=1'b1;
							end
							4'b1100:begin
							r_data_out 		<= {{24{1'b0}}, data_in[15:8]}; 
							r_keep_out		<=4'b1000;
							r_last_out		<=1'b1;
							end
							
						endcase
					
					
					4: case (keep_in_delay)
							4'b1111:begin
							r_data_out 		<= data_in; //
							r_keep_out		<=4'b1111;
							r_last_out		<=1'b1;
							end
							4'b1110:begin
							r_data_out 		<= {{8{1'b0}},data_in[23:0]}; // 
							r_keep_out		<=4'b1110;
							r_last_out		<=1'b1;
							end
							4'b1100:begin
							r_data_out 		<= {{16{1'b0}},data_in[15:0]}; // 
							r_keep_out		<=4'b1100;
							r_last_out		<=1'b1;
							end
							4'b1000:begin
							r_data_out 		<= {{24{1'b0}},data_in[7:0]}; // 
							r_keep_out		<=4'b1000;
							r_keep_out		<=4'b1000;
							r_last_out		<=1'b1;
							
							end
						endcase
				endcase	
		end	
	end
	
	
	
	
	
	
	/*----- delay the signal and data_in------*/
	// Delay the axis_tvalid and axis_tlast signal by one clock cycle                              
	// to match the latency of DATA 
	always @(posedge clk)                                                                  
	begin                                                                                          
	  if (!rst_n)                                                                         
	    begin
	     data_in_delay_1 <=0;                                                                                      
		  data_in_delay <=0;
	    end                                                                                        
	  else                                                                                         
	    begin                                                                                      
		  data_in_delay_1	<=data_in;
		   data_in_delay    <=data_in;	  
	    end                                                                                        
	end  

	always @(posedge clk)                                                                  
	begin                                                                                          
	  if (!rst_n)                                                                         
	    begin                                                                                      
	      keep_in_delay_1 <= 0;                                                               
          keep_in_delay <= 0;                                                      
	    end                                                                                        
	  else                                                                                         
	    begin                                                                                      
	      keep_in_delay_1 <= keep_in;                                                        
           keep_in_delay <= keep_in;                                                  
	    end                                                                                        
	end 

	always @(posedge clk)                                                                  
	begin                                                                                          
	  if (!rst_n)                                                                         
	    begin                                                                                      
	      las_in_delay_1 <= 1'b0;                                                               
          las_in_delay <= 1'b0;                                                     
	    end                                                                                        
	  else                                                                                         
	    begin                                                                                      
	      las_in_delay_1 <= las_in;                                                        
          las_in_delay <=  las_in;                                               
	    end                                                                                        
	end 

endmodule
