--! @file axistream_unpack
--! @author Trip Richert

-- license at bottom of file
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! @interface axistream_unpack
--! @brief splits up source data into NUM_PACK words, sent out dest one at a time

entity axistream_unpack is
  generic (
    DATA_WIDTH : natural := 8;
    NUM_PACK   : natural := 4;
    BIG_ENDIAN : boolean := false
    );
  port (
    clk : in std_ulogic;
    rst : in std_ulogic;

    src_tvalid : in std_ulogic;
    src_tready : out std_ulogic;
    src_tdata  :  in std_ulogic_vector(NUM_PACK * DATA_WIDTH - 1 downto 0);
    src_tlast  :  in std_ulogic;

    dest_tvalid : out std_ulogic;
    dest_tready :  in std_ulogic;
    dest_tdata  : out std_ulogic_vector(DATA_WIDTH - 1 downto 0);
    dest_tlast  : out std_ulogic
    );
end entity axistream_unpack;

architecture rtl of axistream_unpack is
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

  signal tlast_buf : std_ulogic;
  signal is_nempty : std_ulogic;
  signal data_buf  : std_ulogic_vector(NUM_PACK*DATA_WIDTH - 1 downto 0);
  type array_type is array(NUM_PACK - 1 downto 0) of std_ulogic_vector(DATA_WIDTH - 1 downto 0);
  signal data_arr : array_type;

  signal cnt : unsigned(log2(NUM_PACK) downto 0);
  signal inv_cnt : unsigned(log2(NUM_PACK) downto 0);

  signal dest_tvalid_cpy : std_ulogic;
  signal src_tready_cpy : std_ulogic;
  
begin
  
  dest_tvalid <= dest_tvalid_cpy;
  src_tready <= src_tready_cpy;

  dest_tvalid_cpy <= is_nempty and not rst;
  src_tready_cpy <= '0' when rst = '1' else
                    '1' when is_nempty = '0' else
                    dest_tvalid_cpy and dest_tready when cnt = NUM_PACK - 1 else
                    '0';
  dest_tlast <= tlast_buf and dest_tvalid_cpy;

  arr_transform: for i in 0 to NUM_PACK - 1 generate
    data_arr(i) <= data_buf((i + 1)*DATA_WIDTH - 1 downto i * DATA_WIDTH);
  end generate arr_transform;

  dest_tdata <= data_arr(to_integer(inv_cnt)) when BIG_ENDIAN else
                data_arr(to_integer(cnt));

  process(clk)
  begin
    if rising_edge(clk) then
      if (src_tvalid = '1' and src_tready_cpy = '1') then
        data_buf <= src_tdata;
        tlast_buf <= src_tlast;
        is_nempty <= '1';
      else
        data_buf <= data_buf;
        tlast_buf <= tlast_buf;
        if ((cnt = NUM_PACK - 1) and dest_tvalid_cpy = '1' and dest_tready = '1') then
          is_nempty <= '0';
        else
          is_nempty <= is_nempty;
        end if;
      end if;

      if (dest_tvalid_cpy = '1' and dest_tready = '1') then
        cnt <= (cnt + 1 ) mod NUM_PACK;
        if (inv_cnt = 0) then
          inv_cnt <= to_unsigned(NUM_PACK - 1, inv_cnt'length);
        else
          inv_cnt <= inv_cnt - 1;
        end if;
      else
        cnt <= cnt;
        inv_cnt <= inv_cnt;
      end if;
      if rst = '1' then
        cnt <= (others => '0');
        inv_cnt <= to_unsigned(NUM_PACK - 1, inv_cnt'length);
        is_nempty <= '0';
      end if;
    end if;
  end process;
  
end architecture rtl;
