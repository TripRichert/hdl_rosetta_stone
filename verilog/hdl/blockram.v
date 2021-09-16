
module blockram

  #(parameter DATA_WIDTH=32,
    parameter ADDR_WIDTH=10)
    (
     input 			   clk,
     input [(DATA_WIDTH-1):0] 	   dia,
     input [(ADDR_WIDTH-1):0] 	   addra,
     input [(ADDR_WIDTH-1):0] 	   addrb,
     input                         ena,
     input 			   wea,
     input 			   enb,
     output reg [(DATA_WIDTH-1):0] dob
     );

   (* ram_style = "block" *) reg [DATA_WIDTH-1:0] ram[2**ADDR_WIDTH-1:0];
   
   always @ (posedge clk) begin     
     if (ena) begin 
	if (wea) begin
	   ram[addra] <= dia;
	end
     end
   end
  
   always @ (posedge clk) begin
      if (enb) begin
	 dob <= ram[addrb];
      end
   end

endmodule
