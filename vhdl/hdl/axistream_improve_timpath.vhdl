--! @file axistream_improve_timepath.vhd
--! @author Trip Richert

-- license at bottom of file
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! @interface axistream_improve_timepath
--! @brief can improve timing on axistream pipeline by breaking path of src to
--dest

entity axistream_improve_timepath is
  generic (
    DATA_WIDTH : natural := 8
    );
  port (
    clk : in std_ulogic;
    rst : in std_ulogic;

    src_tvalid  :  in std_ulogic;
    src_tready  : out std_ulogic;
    src_tdata   :  in std_ulogic_vector(DATA_WIDTH - 1 downto 0);
    src_tlast   :  in std_ulogic;

    dest_tvalid : out std_ulogic;
    dest_tready :  in std_ulogic;
    dest_tdata  : out std_ulogic_vector(DATA_WIDTH - 1 downto 0);
    dest_tlast  : out std_ulogic
    );
end entity axistream_improve_timepath;

architecture rtl of axistream_improve_timepath is
  signal cnt : unsigned(1 downto 0);
  signal rd_ptr : unsigned(1 downto 0);

  signal src_tvalid_z : std_ulogic;
  signal dest_tready_z : std_ulogic;
  type arr_type is array(2 downto 0) of std_ulogic_vector(DATA_WIDTH downto 0);
  signal data_buf : arr_type;

  signal dest_tvalid_cpy : std_ulogic;
  signal src_tready_cpy : std_ulogic;
begin
  dest_tvalid <= dest_tvalid_cpy;
  src_tready <= src_tready_cpy;

  dest_tvalid_cpy <= not rst when (cnt /= 0) else '0';
  src_tready_cpy <= not rst when (cnt < 3) else '0';

  dest_tlast <= dest_tvalid_cpy and data_buf(to_integer(rd_ptr))(DATA_WIDTH);
  dest_tdata <= data_buf(to_integer(rd_ptr))(DATA_WIDTH - 1 downto 0);

  rd_ptr <= (others => '0') when cnt = 0 else cnt  - 1;

  process(clk)
  begin
    if rising_edge(clk) then
      src_tvalid_z <= src_tvalid;
      dest_tready_z <= dest_tready;

      if (src_tvalid = '1' and src_tready_cpy = '1') then
        data_buf(2) <= data_buf(1);
        data_buf(1) <= data_buf(0);
        data_buf(0) <= src_tlast & src_tdata;
      else
        data_buf <= data_buf;
      end if;

      if ((src_tvalid = '1' and src_tready_cpy = '1')
          and not (dest_tvalid_cpy = '1' and dest_tready = '1')) then
        
        cnt <= cnt + 1;
        
      elsif((dest_tvalid_cpy = '1' and dest_tready = '1')
            and not (src_tvalid = '1' and src_tready_cpy = '1')) then

        cnt <= cnt - 1;
      else
        cnt <= cnt;
      end if;

      if (rst = '1') then
        src_tvalid_z <= '0';
        dest_tready_z <= '0';
        cnt <= (others => '0');
      end if;
    end if;
  end process;
    
end architecture rtl;

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
