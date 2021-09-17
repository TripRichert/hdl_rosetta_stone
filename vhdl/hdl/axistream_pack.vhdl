--! @file axistream_pack
--! @author Trip Richert

-- license at bottom of file
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! @interface axistream_pack
--! @brief concatenates NUM_PACK elements from src_data and sends out dest
--! @param src_tlast may only be raised on multiples of NUM_PACK of src 

entity axistream_pack is
  generic (
    DATA_WIDTH : natural := 8;
    NUM_PACK : natural := 4;
    BIG_ENDIAN : boolean := false
    );
  port (
    clk : in std_ulogic;
    rst : in std_ulogic;

    src_tvalid : in std_ulogic;
    src_tready : out std_ulogic;
    src_tdata  :  in std_ulogic_vector(DATA_WIDTH - 1 downto 0);
    src_tlast  :  in std_ulogic;

    dest_tvalid : out std_ulogic;
    dest_tready :  in std_ulogic;
    dest_tdata  : out std_ulogic_vector(NUM_PACK * DATA_WIDTH - 1 downto 0);
    dest_tlast  : out std_ulogic;

    tlast_align_err : out std_ulogic
    );
end entity axistream_pack;

architecture rtl of axistream_pack is

  function log2 (val_cpy : natural) return natural is
    variable retVal : natural := 0;
    variable val : natural := val_cpy;
  begin
    while val > 1 loop
      val := val / 2;
      retVal := retVal + 1;
    end loop;
    return retVal;
  end function log2;

  function orReduce(vector : std_ulogic_vector) return std_ulogic is
    --make sure indexing is length - 1 downto 0
    variable vector_cpy : std_ulogic_vector(vector'length -1 downto 0)
      := vector;
    variable retVal : std_ulogic := '0';
  begin
    for i in 0 to vector'length - 1 loop
      retVal := vector_cpy(i) or retVal;
    end loop;
    return retVal;
  end function orReduce;

  signal data_buf : std_ulogic_vector(NUM_PACK * DATA_WIDTH - 1 downto 0);
  signal tlast_buf : std_ulogic_vector(NUM_PACK - 1 downto 0);

  signal cnt : unsigned(log2(NUM_PACK) downto 0) := (others => '0');

  signal dest_tvalid_cpy : std_ulogic;
  signal src_tready_cpy : std_ulogic;
begin
  dest_tvalid <= dest_tvalid_cpy;
  src_tready <= src_tready_cpy;

  dest_tvalid_cpy <= not rst when cnt = NUM_PACK else '0';
  src_tready  <= dest_tvalid_cpy and dest_tready when cnt = NUM_PACK
                 else not rst;
  dest_tdata <= data_buf;
  dest_tlast <= tlast_buf(0) when BIG_ENDIAN else tlast_buf(NUM_PACK - 1);

  process(clk)
  begin
    if rising_edge(clk) then
      if (src_tvalid = '1' and src_tready_cpy = '1') then
        if not BIG_ENDIAN then
          
          data_buf((NUM_PACK-1)*DATA_WIDTH -1 downto 0)
            <= data_buf(NUM_PACK* DATA_WIDTH - 1 downto DATA_WIDTH);

          data_buf(NUM_PACK*DATA_WIDTH - 1 downto (NUM_PACK - 1)*DATA_WIDTH)
            <= src_tdata;

          tlast_buf(NUM_PACK - 2 downto 0) <= tlast_buf(NUM_PACK - 1 downto 1);
          tlast_buf(NUM_PACK - 1) <= src_tlast;
        else
          
          data_buf(NUM_PACK*DATA_WIDTH - 1 downto (NUM_PACK - 1)*DATA_WIDTH)
            <= data_buf((NUM_PACK - 1)*DATA_WIDTH - 1 downto 0);
          
          data_buf(DATA_WIDTH - 1 downto 0) <= src_tdata;

          tlast_buf(NUM_PACK - 1 downto 1) <= tlast_buf(NUM_PACK - 2 downto 0);
          tlast_buf(0) <= src_tlast;
        end if;
      else
        data_buf <= data_buf;
        tlast_buf <= tlast_buf;
      end if;

      if (dest_tvalid_cpy = '1' and dest_tready = '1') then
        if (not BIG_ENDIAN) then
          tlast_align_err <= orReduce(tlast_buf(NUM_PACK-2 downto 0));
        else
          tlast_align_err <= orReduce(tlast_buf(NUM_PACK - 1 downto 1));
        end if;
      else
        tlast_align_err <= '0';
      end if;

      if rst = '1' then
        cnt <= (others => '0');
        tlast_align_err <= '0';
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
