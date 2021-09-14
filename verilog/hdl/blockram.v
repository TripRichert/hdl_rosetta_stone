module blockram

  #(parameter DATA_WIDTH=32,
    parameter ADDR_WIDTH=10)
    (
     input 		       clk,
     input [(DATA_WIDTH-1):0]  data_in,
     input [(ADDR_WIDTH-1):0]  read_addr,
     input [(ADDR_WIDTH-1):0]  write_addr,
     input 		       wr_en,
     output reg [(DATA_WIDTH-1):0] data_out
     );

   (* ram_style = "block" *) reg [DATA_WIDTH-1:0] ram[2**ADDR_WIDTH-1:0];
   
   always @ (posedge clk) begin
      
      if (wr_en) begin
       ram[write_addr] <= data_in;
     end
   end
  
   always @ (posedge clk) begin
       data_out <= ram[read_addr];
   end

endmodule
