--reads are not allowed when empty, even if there is a simultaneous write
--writes are not allowed when full, even if there is a simultaneous read

library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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

    wr_err_flr : out std_ulogic;
    rd_err_flr : out std_ulogic;

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
      clk => clk,
      wr_en => wr_en_internal,
      read_addr => rd_ptr,
      write_addr => wr_ptr,
      data_in    => src_data,
      data_out   => dest_data
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
