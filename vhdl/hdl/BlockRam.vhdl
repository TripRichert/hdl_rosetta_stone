library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity BlockRam is
  generic (
    data_width : natural := 32;
    addr_width : natural := 10
    );
  port (
    clk        :  in std_ulogic;
    data_in    :  in std_ulogic_vector(data_width - 1 downto 0);
    read_addr  :  in unsigned(addr_width - 1 downto 0);
    write_addr :  in unsigned(addr_width - 1 downto 0);
    wr_en      :  in std_ulogic;
    data_out   : out std_ulogic_vector(data_width - 1 downto 0)
    );

end entity BlockRam;

architecture behavioral of BlockRam is
  type mem_type is array (2**addr_width - 1 downto 0)
    of std_ulogic_vector (data_width-1 downto 0);
  
  signal mem: mem_type;
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if (wr_en = '1') then
        mem(to_integer(write_addr)) <= data_in;
      end if;
    end if;
  end process;
  
  process(clk)
  begin
    if rising_edge(clk) then
      data_out <= mem(to_integer(read_addr));
    end if;
  end process;
  
end architecture behavioral;
