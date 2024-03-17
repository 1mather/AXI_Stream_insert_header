`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/17 15:37:57
// Design Name: 
// Module Name: axi_stream_tb_v0
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
module axi_stream_tb_v0;

    // Parameters of the Unit Under Test (UUT)
    parameter 			DATA_WD = 32;
    parameter 			DATA_BYTE_WD = DATA_WD/8;
    parameter 			BYTE_CNT_WD = $clog2(DATA_BYTE_WD);

    // Ports of the UUT
    reg 						clk;
    reg 						rst_n;
    reg 						valid_in;
    reg [DATA_WD-1:0] 			data_in;
    reg [DATA_BYTE_WD-1:0] 		keep_in;
    reg 						las_in;
    wire 						ready_in;
	
    wire 						valid_out;
    wire [DATA_WD-1:0] 			data_out;
    wire [DATA_BYTE_WD-1:0] 	keep_out;
    wire 						last_out;
    reg 						ready_out;
	
    reg 						valid_insert;
    reg [DATA_WD-1:0] 			data_insert;
    reg [DATA_BYTE_WD-1:0] 		keep_insert;
    reg [BYTE_CNT_WD:0] 		byte_insert_cnt;
    wire 						ready_insert;
    reg  [0:1]               random_value;
    // Instantiate the Unit Under Test (UUT)
    axi_stream_insert_header #(
        .DATA_WD(DATA_WD)
    ) uut (
        .clk(clk), 
        .rst_n(rst_n), 
        .valid_in(valid_in), 
        .data_in(data_in), 
        .keep_in(keep_in), 
        .las_in(las_in), 
        .ready_in(ready_in), 
        .valid_out(valid_out), 
        .data_out(data_out), 
        .keep_out(keep_out), 
        .last_out(last_out), 
        .ready_out(ready_out), 
        .valid_insert(valid_insert), 
        .data_insert(data_insert), 
        .keep_insert(keep_insert), 
        .byte_insert_cnt(byte_insert_cnt), 
        .ready_insert(ready_insert)
    );

    initial begin
        // Initialize Inputs
        clk = 0;
        rst_n = 0;
        valid_in = 0;
        data_in = 0;
        las_in = 0;
        ready_out = 0; // Assuming ready_out is always high for simplicity
        valid_insert = 0;
        data_insert = 0;     
        byte_insert_cnt = 0;
        
        
          keep_in = 4'b1111;
          keep_insert = 4'b1111;     
          random_value=0;  

        #105;

         rst_n = 1;  
       repeat(20)begin

        #10;
        valid_in = 1;
        ready_out=1;
        valid_insert = 1;
        las_in = 0;
        
        #10;
        data_in = $random;
        //keep_in = 4'b1111; // All bytes are valid
        las_in = 0;          // Not the last data
        data_insert = $random;
        //keep_insert = 4'b1111; // Assume all bytes of header are valid for simplicity
        byte_insert_cnt =3; // Header size in bytes
		
	
		#10; // wait 10ns
        valid_in = 1;
        data_in = $random;
        //keep_in = 4'b1111; // All bytes are valid
        las_in = 0; // Not the last data
		
		
		#10; // wait 10ns
		 data_insert = $random;
        valid_in = 1;
        data_in = $random;
       // keep_in = 4'b1111; // All bytes are valid
        las_in = 0; // Not the last data
		
		
		#10; // wait 10ns
		data_insert = $random;       
        valid_in = 1;
        data_in = $random;
        //keep_in = 4'b1111; // All bytes are valid
        las_in = 1; // the last data

		// Continue adding more cases as needed
    end 
 end   
 
 
	   always @(posedge clk) begin
        random_value <= $random % 4; 
        keep_in <= 4'b1111 <<random_value;//"1111 "1110 "1100 "1000 ""0000"
        keep_insert<= 4'b1111 >>random_value;//"1111""0111""0011""0001"
    end
       
	
    always #5 clk = ~clk; // Clock with period of 10ns

endmodule