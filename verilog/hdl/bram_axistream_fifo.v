module bram_axistream_fifo
  #(parameter DATA_WIDTH=32,
    parameter ADDR_WIDTH=10)
   (
    input  clk,
    input  rst,
    
    input  src_tvalid,
    output src_tready,
    input  [(DATA_WIDTH-1):0] src_tdata,
    input  src_tlast,

    output dest_tvalid,
    input  dest_tready,
    output [(DATA_WIDTH-1):0] dest_tdata,
    output dest_tlast,

    output reg [(ADDR_WIDTH):0] data_cnt
    );

   wire [DATA_WIDTH:0]       fifo_src_tdata;
   wire                      fifo_wr_en;
   wire                      fifo_rd_en;
   reg                       fifo_rd_en_1z;
   wire                      fifo_full;
   wire                      fifo_empty;
   wire [(DATA_WIDTH):0]     fifo_dest_data;
   reg  [DATA_WIDTH:0]       data_buffer;
   reg                       is_data_buffered;
   
   

   initial begin
      data_cnt = 0;
   end  
   //compute data_cnt (std fifo data count will be optimized out).
   always @ (posedge clk) begin
      if (rst) begin
         data_cnt <= 0;
      end else begin
         if ((src_tvalid && src_tready) && !(dest_tvalid && dest_tready)) begin
            data_cnt <= data_cnt + 1;
         end else if (!(src_tvalid && src_tready) && (dest_tvalid && dest_tready)) begin
            data_cnt <= data_cnt - 1;
         end else begin
            data_cnt <= data_cnt;
         end
      end
   end // always @ (posedge clk)   

   assign fifo_src_tdata = {src_tlast, src_tdata};
   assign src_tready = !fifo_full && !rst;
   assign fifo_wr_en = src_tvalid && src_tready;

   bram_std_fifo #(.DATA_WIDTH(DATA_WIDTH+1),.ADDR_WIDTH(ADDR_WIDTH)) fifo
     (
      .clk(clk),
      .rst(rst),
      .src_data(fifo_src_tdata),
      .wr_en(fifo_wr_en),
      .rd_en(fifo_rd_en),
      .full(fifo_full),
      .empty(fifo_empty),
      .dest_data(fifo_dest_data)
      );

   assign fifo_rd_en = ((!is_data_buffered && !fifo_rd_en_1z)  || (dest_tvalid && dest_tready)) && !rst && !fifo_empty;

   assign dest_tdata = data_buffer[DATA_WIDTH-1:0];
   assign dest_tlast = dest_tvalid && data_buffer[DATA_WIDTH];
   assign dest_tvalid = is_data_buffered && !rst;
   
   initial begin
      is_data_buffered = 0;
      fifo_rd_en_1z = 0;
   end
   always @ (posedge clk) begin
      if (rst) begin
         is_data_buffered <= 1'b0;
         fifo_rd_en_1z <= 1'b0;
      end else begin
         if (fifo_rd_en_1z) begin
            data_buffer <= fifo_dest_data;
            is_data_buffered <= 1'b1;       
         end else if (dest_tvalid && dest_tready) begin
	    is_data_buffered <= 1'b0;
	 end
         fifo_rd_en_1z <= fifo_rd_en;
      end
   end
   
   
endmodule // bram_axistream_fifo
