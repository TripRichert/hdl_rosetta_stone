 library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bram_std_fifo_testbench is
  generic (
    timeout : time := 1 us
    );
end entity bram_std_fifo_testbench;

architecture simOnly of bram_std_fifo_testbench is

  constant data_width : natural := 8;
  constant addr_width : natural := 3;
  constant clk_period : time    := 10 ns;
  
  signal clk : std_ulogic := '0';
  signal rst : std_ulogic := '1';

  signal full : std_ulogic;
  signal empty : std_ulogic;

  signal rd_en : std_ulogic := '0';
  signal wr_en : std_ulogic := '0';

  signal src_data : std_ulogic_vector(data_width - 1 downto 0);
  signal log_data : std_ulogic_vector(data_width - 1 downto 0);

  signal wr_err_flr : std_ulogic := '0';
  signal rd_err_flr : std_ulogic := '0';

  signal data_cnt : unsigned(addr_width downto 0);

  signal timed_out : boolean := false;
begin
  
  process
  begin
    wait for clk_period/2;
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    if (timed_out) then
      wait;
    end if;
  end process;
  process
  begin
    wait for timeout;
    timed_out <= true;
    wait;
  end process;

  process
  begin
    src_data <= (others => '0');
    wait for 50 ns;
    wait until rising_edge(clk);
    rst <= '0';
    wr_en <= '1';
    wait until rising_edge(clk);
    src_data <= std_ulogic_vector(unsigned(src_data) + 1);
    wait until rising_edge(clk);
    src_data <= std_ulogic_vector(unsigned(src_data) + 1);
    wait until rising_edge(clk);
    src_data <= std_ulogic_vector(unsigned(src_data) + 1);
    wait until rising_edge(clk);
    src_data <= std_ulogic_vector(unsigned(src_data) + 1);
    wait until rising_edge(clk);
    src_data <= std_ulogic_vector(unsigned(src_data) + 1);
    wait until rising_edge(clk);
    src_data <= std_ulogic_vector(unsigned(src_data) + 1);
    wait until rising_edge(clk);
    src_data <= std_ulogic_vector(unsigned(src_data) + 1);
    wait until rising_edge(clk);
    wr_en <= '0';
    wait until rising_edge(clk);
    rd_en <= '1';
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    rd_en <= '0';
    wait;
  end process;
  
  uut: entity work.bram_std_fifo
    generic map (
      data_width => data_width,
      addr_width => addr_width
      )
    port map (
      clk => clk,
      rst => rst,
      full => full,
      empty => empty,
      rd_en => rd_en,
      wr_en => wr_en,
      src_data => src_data,
      dest_data => log_data,

      wr_err_flr => wr_err_flr,
      rd_err_flr => rd_err_flr,
      data_cnt   => data_cnt
      );
    
end architecture simOnly;
