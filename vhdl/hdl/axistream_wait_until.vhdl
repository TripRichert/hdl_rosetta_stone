library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axistream_wait_until is
  generic (
    DATA_WIDTH : natural := 8
    );
  port (
    clk : in std_ulogic;
    rst : in std_ulogic;
    src_tvalid : in std_ulogic;
    src_tready : out std_ulogic;
    src_tdata  :  in std_ulogic_vector(DATA_WIDTH - 1 downto 0);
    src_tlast  :  in std_ulogic;

    dest_tvalid : out std_ulogic;
    dest_tready  :  in std_ulogic;
    dest_tdata   : out std_ulogic_vector(DATA_WIDTH - 1 downto 0);
    dest_tlast  : out std_ulogic;

    go          : in  std_ulogic
    );
end entity axistream_wait_until;

architecture behavioral of axistream_wait_until is

  type sm_type is (SM_WAIT, SM_GO);
  signal sm : sm_type := SM_WAIT;
  signal dest_tvalid_cpy : std_ulogic;
  signal dest_tlast_cpy : std_ulogic;
begin
  dest_tvalid <= dest_tvalid_cpy;
  dest_tlast <= dest_tlast_cpy;
  
  dest_tvalid_cpy <= src_tvalid and not rst when sm = SM_GO else '0';
  src_tready  <= dest_tready and not rst when sm = SM_GO else '0';
  dest_tlast_cpy <= src_tlast and dest_tvalid_cpy when sm = SM_GO else '0';
  dest_tdata <= src_tdata;

  process(clk)
  begin
    if rising_edge(clk) then
      case (sm) is
        when SM_WAIT =>
          if go = '1' then
            SM <= SM_GO;
          else
            SM <= SM_WAIT;
          end if;
        when SM_GO =>
          if (dest_tvalid_cpy and dest_tready and dest_tlast_cpy) = '1' then
            SM <= SM_WAIT;
          else
            SM <= SM_Go;
          end if;
      end case;
      if rst = '1' then
        sm <= SM_WAIT;
      end if;
    end if;
  end process;
  
end architecture behavioral;
