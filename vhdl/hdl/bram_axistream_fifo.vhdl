
--! @file bram_axistream_fifo.v
--! @author Trip Richert



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--! @interface bram_axistream_fifo
--! @brief dual port, single clock, block ram fifo
--! reads are disallowed when fifo is empty, even if there is simultaneous write
--! writes are disallowed when fifo is full, even if there is simultaneous read
--! capacity 2**addr_width + 1
entity bram_axistream_fifo is
  generic (
    data_width : natural := 32;
    addr_width : natural := 10
    );
  port (
    clk : in std_ulogic;
    rst : in std_ulogic;

    src_tvalid :  in std_ulogic;
    src_tready : out std_ulogic;
    src_tdata  :  in std_ulogic_vector(data_width - 1 downto 0);
    src_tlast  :  in std_ulogic;

    dest_tvalid : out std_ulogic;
    dest_tready :  in std_ulogic;
    dest_tdata  : out std_ulogic_vector(data_width - 1 downto 0);
    dest_tlast  : out std_ulogic;

    data_cnt    : out unsigned(addr_width downto 0)
    );
end entity bram_axistream_fifo;

architecture structural of bram_axistream_fifo is
  -- data includes tlast 
  signal fifo_src_tdata : std_ulogic_vector(data_width  downto 0);
  signal fifo_wr_en : std_ulogic;
  signal fifo_rd_en : std_ulogic;
  signal fifo_rd_en_1z : std_ulogic := '0';
  signal fifo_full : std_ulogic;
  signal fifo_empty : std_ulogic;
  --data includes tlast
  signal fifo_dest_tdata : std_ulogic_vector(data_width downto 0);
  signal data_buffer : std_ulogic_vector(data_width downto 0);
  signal is_data_buffered : std_ulogic;
  signal data_cnt_cpy : unsigned(addr_width downto 0) := (others => '0');

  signal dest_tvalid_cpy : std_ulogic;
  signal src_tready_cpy : std_ulogic;
begin

  dest_tvalid <= dest_tvalid_cpy;
  src_tready <= src_tready_cpy;
  data_cnt <= data_cnt_cpy;


  --data_cnt should be optimized away if unused
  process(clk)
  begin
    if rising_edge(clk) then
      if  rst = '1' then
        data_cnt_cpy <= (others => '0');
      else
        if (
          src_tvalid = '1' and src_tready_cpy = '1' and not (
            dest_tvalid_cpy = '1' and dest_tready = '1'
            )
          ) then

          data_cnt_cpy <= data_cnt_cpy + 1;
        elsif (
          not (src_tvalid = '1' and src_tready_cpy = '1') and
          dest_tvalid_cpy = '1' and dest_tready = '1'
          ) then
          data_cnt_cpy <= data_cnt_cpy - 1;
        else
          data_cnt_cpy <= data_cnt_cpy;
        end if;
      end if;
    end if;
  end process;


  fifo_src_tdata(data_width) <= src_tlast;
  fifo_src_tdata(data_width - 1 downto 0) <= src_tdata;
  src_tready_cpy <= not fifo_full and not rst;
  fifo_wr_en <= src_tvalid and src_tready_cpy;

  fifo : entity work.bram_std_fifo
    generic map (
      data_width => data_width,
      addr_width => addr_width
      )
    port map (
      clk => clk,
      rst => rst,

      src_data => fifo_src_tdata,
      wr_en    => fifo_wr_en,
      rd_en    => fifo_rd_en,
      full     => fifo_full,
      empty    => fifo_empty,
      dest_data => fifo_dest_tdata
      );

  fifo_rd_en <= ((not is_data_buffered and not fifo_rd_en_1z) or
                 (dest_tvalid_cpy and dest_tready)
                 ) and not rst and not fifo_empty;
  dest_tdata <= data_buffer(data_width - 1 downto 0);
  dest_tlast <= dest_tvalid_cpy and data_buffer(data_width);
  dest_tvalid_cpy <= is_data_buffered and not rst;
  
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        is_data_buffered <= '0';
        fifo_rd_en_1z <= '0';
      else
        if (fifo_rd_en_1z = '1') then
          data_buffer <= fifo_dest_tdata;
          is_data_buffered <= '1';
        elsif dest_tvalid_cpy = '1' and dest_tready = '1' then
          is_data_buffered <= '0';
        end if;
        fifo_rd_en_1z <= fifo_rd_en;
      end if;
    end if;
  end process;
  
end architecture structural;

-- Copyright 2021 Trip Richert

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), 
-- to deal in the Software without restriction, including without limitation 
-- the rights to use, copy, modify, merge, publish, distribute, sublicense, 
-- and/or sell copies of the Software, and to permit persons to whom the 
-- Software is furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in 
-- all copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN 
-- THE SOFTWARE.
