--! @file
--! @author Trip Richert
--! block ram meant to match xilinx UG901 simple_dual_one_clock block ram


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! @interface blockram dual port random access memory, meant to use block ram
entity blockram is
  generic (
    data_width : natural := 32;
    addr_width : natural := 10
    );
  port (
    clk   :  in std_ulogic;
    dia   :  in std_ulogic_vector(data_width - 1 downto 0);--! data in
    addrb :  in unsigned(addr_width - 1 downto 0);--! read address
    addra :  in unsigned(addr_width - 1 downto 0);--! write address
    ena   :  in std_ulogic;--! write enable (need to raise wea too)
    wea   :  in std_ulogic;--! write enable
    enb   :  in std_ulogic;--! read enable
    dob   : out std_ulogic_vector(data_width - 1 downto 0)--! data output
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
