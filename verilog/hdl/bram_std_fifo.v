module bram_std_fifo

  #(parameter DATA_WIDTH=32,
    parameter ADDR_WIDTH=10)
   (
    input                     clk,
    input                     rst,
    input [(DATA_WIDTH-1):0]  src_data,
    input                     wr_en,
    input                     rd_en,
    output                    full,
    output                    empty,
    output reg                wr_err_flr,
    output reg                rd_err_flr,
    output [(ADDR_WIDTH):0]    data_cnt,
    output [(DATA_WIDTH-1):0] dest_data
    );

   reg [(ADDR_WIDTH-1):0]      rd_ptr;
   reg [(ADDR_WIDTH-1):0]      wr_ptr;
   reg                         full_plausible;
   wire                        wr_en_internal;

   reg [(ADDR_WIDTH):0]        cnt;
   wire                        can_read;
   wire                        can_write;

   assign data_cnt = cnt;
   assign can_write = (rd_ptr != wr_ptr || full_plausible == 1'b0)? 1'b1 : 1'b0;
   assign can_read =  (rd_ptr != wr_ptr || full_plausible == 1'b1)? 1'b1 : 1'b0;

   assign empty = (rd_ptr == wr_ptr && full_plausible == 1'b0)? 1'b1 : 1'b0;
   assign full  = (rd_ptr == wr_ptr && full_plausible == 1'b1)? 1'b1 : 1'b0;
   assign wr_en_internal = (can_write)? wr_en : 1'b0;

   always @ (posedge clk) begin
      wr_err_flr <= 1'b0;
      rd_err_flr <= 1'b0;
      if (rst) begin
         rd_ptr <= 0;
         wr_ptr <= 0;
         cnt <= 0;
         full_plausible <= 1'b0;
      end else begin
         if (rd_en) begin
            if (can_read) begin
               rd_ptr <= rd_ptr + 1;
               if (!(wr_en && can_write)) begin
                  cnt <= cnt - 1;
		  full_plausible <= 1'b0;
               end
            end else begin
              rd_err_flr <= 1'b1;          
            end 
         end   // if (rd_en)
         if (wr_en) begin
            if (can_write) begin
               wr_ptr <= wr_ptr + 1;
               full_plausible <= 1'b1;
               if (!(rd_en && can_read)) begin
                 cnt <= cnt + 1;
               end
            end else begin
                 wr_err_flr <= 1'b1;
            end
         end // if (wr_en)
      end 
   end // always @ (posedge clk)

   BlockRam #(
      .DATA_WIDTH(DATA_WIDTH), 
      .ADDR_WIDTH(ADDR_WIDTH)
    ) br (
      .clk(clk),
      .data_in(src_data),
      .read_addr(rd_ptr),
      .write_addr(wr_ptr),
      .wr_en(wr_en_internal),
      .data_out(dest_data)
      );
   
endmodule
