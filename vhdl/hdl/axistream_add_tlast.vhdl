library ieee;
use ieee.std_logic_1164.all;

entity axistream_add_tlast is
  generic (
    DATA_WIDTH : natural := 8
    );
  port (
    clk : in std_ulogic;
    rst : in std_ulogic;
    
    src_tvalid : in std_ulogic;
    src_tready : out std_ulogic;
    src_tdata  : in std_ulogic_vector(DATA_WIDTH - 1 downto 0);

    dest_tvalid : out std_ulogic;
    dest_tready : in std_ulogic;
    dest_tdata  : out std_ulogic_vector(DATA_WIDTH - 1 downto 0);
    dest_tlast  : out std_ulogic;

    add_tlast   : in std_ulogic
    );
end entity axistream_add_tlast;

architecture behavioral of axistream_add_tlast is

  signal data_buf : std_ulogic_vector(DATA_WIDTH - 1 downto 0);
  signal buffered : std_ulogic := '0';
  signal hold_tlast : std_ulogic := '0';

  signal dest_tvalid_cpy : std_ulogic;
  signal src_tready_cpy  : std_ulogic;
begin
  dest_tvalid <= dest_tvalid_cpy;
  src_tready <= src_tready_cpy;

  dest_tvalid_cpy <= not rst and ((src_tvalid and buffered) or
                                  (buffered and (add_tlast or hold_tlast)));

  src_tready_cpy <= not rst;
  dest_tlast <= dest_tvalid_cpy and (add_tlast or hold_tlast);

  dest_tdata <= data_buf;

  process(clk)
  begin
    if rising_edge(clk) then
      if(src_tvalid and src_tready_cpy) = '1' then
        data_buf <= src_tdata;
        buffered <= '1';
        hold_tlast <= '0';
      elsif (dest_tvalid_cpy and dest_tready) = '1' then
        buffered <= '0';
        data_buf <= data_buf;
        hold_tlast <= '0';
      else
        buffered <= buffered;
        data_buf <= data_buf;
        if(buffered and add_tlast) = '1' then
          hold_tlast <= '1';
        else
          hold_tlast <= '0';
        end if;
      end if;
      if rst = '1' then
        hold_tlast <= '0';
        buffered <= '0';
      end if;
    end if;
  end process;
  
end architecture behavioral;
