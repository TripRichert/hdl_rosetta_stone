library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity blockram is
  generic (
    data_width : natural := 32;
    addr_width : natural := 10
    );
  port (
    clk   :  in std_ulogic;
    dia   :  in std_ulogic_vector(data_width - 1 downto 0);
    addrb :  in unsigned(addr_width - 1 downto 0);
    addra :  in unsigned(addr_width - 1 downto 0);
    ena   :  in std_ulogic;
    wea   :  in std_ulogic;
    enb   :  in std_ulogic;
    dob   : out std_ulogic_vector(data_width - 1 downto 0)
    );

end entity blockram;

architecture behavioral of blockram is
  type mem_type is array (2**addr_width - 1 downto 0)
    of std_ulogic_vector (data_width - 1 downto 0);
  
  signal mem: mem_type;
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if (ena = '1') then
        if (wea = '1') then
          mem(to_integer(addra)) <= dia;
        end if;
      end if;
    end if;
  end process;
  
  process(clk)
  begin
    if rising_edge(clk) then
      if enb = '1' then
        dob <= mem(to_integer(addrb));
      end if;
    end if;
  end process;
  
end architecture behavioral;
