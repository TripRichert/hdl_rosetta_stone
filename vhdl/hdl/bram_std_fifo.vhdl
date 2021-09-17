--! @file bram_std_fifo.v
--! @author Trip Richert

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! @interface bram_std_fifo
--! @brief dual port, single clock, block ram fifo.
--! data is output one clock cycle after read enable
--! data should be input at same time as write enable
--! reads are not allowed when fifo is empty, even if there a simulaneous write
--! writes are disallowed when fifo is full, even if there is a simultaneous read

entity bram_std_fifo is
  generic (
    data_width : natural := 32;
    addr_width : natural := 10
    );
  port (
    clk :  in std_ulogic;
    rst :  in std_ulogic;

    full       : out std_ulogic;
    empty      : out std_ulogic;

    rd_en      : in std_ulogic;
    wr_en      : in std_ulogic;

    src_data   : in std_ulogic_vector(data_width - 1 downto 0);
    dest_data  : out std_ulogic_vector(data_width - 1 downto 0);

    wr_err_flr : out std_ulogic; --! raised for one clock when write fails
    rd_err_flr : out std_ulogic; --! raised for one clock when read fails

    data_cnt   : out unsigned(addr_width downto 0)
    );
end entity bram_std_fifo;

architecture behavioral of bram_std_fifo is

  signal rd_ptr : unsigned(addr_width - 1 downto 0) := (others => '0');
  signal wr_ptr : unsigned(addr_width - 1 downto 0) := (others => '0');
  signal full_plausible  : std_ulogic := '0';

  signal wr_en_internal : std_ulogic := '0';

  signal cnt : unsigned(addr_width downto 0) := (others => '0');
  signal can_read : std_ulogic;
  signal can_write : std_ulogic;
  
begin
  data_cnt <= cnt;

  br : entity work.blockram
    generic map (
      data_width => data_width,
      addr_width => addr_width
      )
    port map (
      clk   => clk,
      wea   => wr_en_internal,
      ena   => wr_en_internal,
      enb   => rd_en,
      addrb => rd_ptr,
      addra => wr_ptr,
      dia   => src_data,
      dob   => dest_data
      );
  
  can_write  <= '1' when rd_ptr /= wr_ptr or full_plausible = '0' else '0';
  can_read <= '1' when rd_ptr /= wr_ptr or full_plausible = '1' else '0';

  empty <= '1' when rd_ptr = wr_ptr and full_plausible = '0' else '0';
  full <= '1' when rd_ptr = wr_ptr and full_plausible = '1' else '0';

  wr_en_internal <= wr_en when can_write = '1' else '0';
  
  process(clk)
  begin
    if rising_edge(clk) then
      wr_err_flr <= '0';
      rd_err_flr <= '0';
      if rst = '1' then
        rd_ptr <= (others => '0');
        wr_ptr <= (others => '0');
        full_plausible <= '0';
        cnt <= (others => '0');
      else
        if rd_en = '1' then
          if can_read = '1' then
            rd_ptr <= rd_ptr + 1;
            if wr_en /= '1' or can_write /= '1' then
              full_plausible <= '0';
              cnt <= cnt - 1;
            end if;
          else
            --attempted read when empty
            rd_err_flr <= '1';
          end if;
        end if;
        if wr_en = '1' then
          if can_write = '1' then
            wr_ptr <= wr_ptr + 1;
            full_plausible <= '1';
            if rd_en /= '1' or can_read = '0' then
              cnt <= cnt + 1;
            end if;
          else
            --attempted write when full
            wr_err_flr <= '1';
          end if;
        end if;
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
