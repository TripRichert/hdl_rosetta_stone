//tlast is not a control signal
//
module axistream_pack
  (
   clk,
   rst,

   src_tvalid,
   src_tready,
   src_tdata,
   src_tlast,

   dest_tvalid,
   dest_tready,
   dest_tdata,
   dest_tlast,

   tlast_align_err
   );

   parameter DATA_WIDTH = 8;
   parameter NUM_PACK = 4;
   parameter BIG_ENDIAN = 1'b0;
   

   input                              clk;
   input                              rst;

   input                              src_tvalid;
   output                             src_tready;
   input [DATA_WIDTH-1:0]             src_tdata;
   input 		              src_tlast;

   output 		              dest_tvalid;
   input 		              dest_tready;
   output [(DATA_WIDTH*NUM_PACK)-1:0] dest_tdata;
   output 			      dest_tlast;
   
   output reg 			      tlast_align_err;
   
   

   reg [(NUM_PACK*DATA_WIDTH)-1:0]   data_buf;
   reg [NUM_PACK-1:0] 		     tlast_buf;
   
   reg [$clog2(NUM_PACK+1)-1:0]       cnt;

   assign dest_tvalid = (cnt == NUM_PACK) ? !rst : 1'b0;
   assign src_tready  = (cnt == NUM_PACK) ? dest_tvalid && dest_tready : !rst;

   assign dest_tdata = data_buf;
   assign dest_tlast = (!BIG_ENDIAN)?tlast_buf[NUM_PACK-1]:tlast_buf[0];

   initial begin
      cnt <= 0;
      tlast_align_err <= 1'b0;
   end
   
   always @(posedge clk) begin

      if (rst) begin
	 cnt <= 0;
	 tlast_align_err <= 1'b0;
	 
      end else begin
	 
	 if (src_tvalid && src_tready) begin
	    if (!BIG_ENDIAN) begin
	       
	       data_buf[((NUM_PACK-1)*DATA_WIDTH)-1:0] 
		 <= data_buf[NUM_PACK*DATA_WIDTH-1:DATA_WIDTH];
	       
	       data_buf[NUM_PACK*DATA_WIDTH-1:(NUM_PACK-1)*DATA_WIDTH] 
		 <= src_tdata;
	       
	       tlast_buf[NUM_PACK-2:0] <= tlast_buf[NUM_PACK-1:1];
	       tlast_buf[NUM_PACK-1] <= src_tlast;
	       
	    end else begin 
	       
	      data_buf[NUM_PACK*DATA_WIDTH-1:DATA_WIDTH] 
		<= data_buf[((NUM_PACK-1)*DATA_WIDTH)-1:0];
       
	       data_buf[DATA_WIDTH - 1 : 0] <= src_tdata;

	       tlast_buf[NUM_PACK-1:0] <= tlast_buf[NUM_PACK-2:1];
	       tlast_buf[0] <= src_tlast;
	       
	    end
	 end // move data
	 
	 if (src_tvalid && src_tready && dest_tvalid && dest_tready) begin
	    cnt <= 1;	    
	 end else if (dest_tvalid && dest_tready) begin
	    cnt <= 0;
	 end else if (src_tvalid && src_tready) begin
	    cnt <= cnt + 1;
	 end else begin
	    cnt <= cnt;
	 end

	 if (dest_tvalid && dest_tready) begin
	    if (!BIG_ENDIAN) begin
	       tlast_align_err <= (|tlast_buf[NUM_PACK-2:0])?1'b1:1'b0;
	    end else begin
	       tlast_align_err <= (|tlast_buf[NUM_PACK-1:1])?1'b1:1'b0;
	    end
	 end
	 
      end // else: !if(rst)
   end // always @ (posedge clk)
   
endmodule // axistream_pack
