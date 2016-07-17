library ieee;
use ieee.std_logic_1164.all;
use work.cpu2j0_pack.all;

entity jcore_cpu is
    port(
        clk         : in  std_logic;
        rst         : in  std_logic;

        db_en       : out std_logic;
        db_a        : out std_logic_vector(31 downto 0);
        db_rd       : out std_logic;
        db_wr       : out std_logic;
        db_we       : out std_logic_vector(3 downto 0);
        db_do       : out std_logic_vector(31 downto 0);
        db_lock     : out std_logic;
        db_di       : in  std_logic_vector(31 downto 0);
        db_ack      : in  std_logic;

        inst_en     : out std_logic;
        inst_a      : out std_logic_vector(31 downto 1);
        inst_jp     : out std_logic;
        inst_d      : in  std_logic_vector(15 downto 0);
        inst_ack    : in  std_logic;

        debug_ack   : out std_logic;
        debug_do    : out std_logic_vector(31 downto 0);
        debug_rdy   : out std_logic;
        debug_en    : in  std_logic;
        debug_cmd   : in  std_logic_vector(1 downto 0);
        debug_ir    : in  std_logic_vector(15 downto 0);
        debug_di    : in  std_logic_vector(31 downto 0);
        debug_d_en  : in  std_logic;

        event_ack   : out std_logic;
        event_lvl_o : out std_logic_vector(3 downto 0);
        event_slp   : out std_logic;
        event_dbg   : out std_logic;
        event_en    : in  std_logic;
        event_cmd   : in  std_logic_vector(1 downto 0);
        event_vec   : in  std_logic_vector(7 downto 0);
        event_msk   : in  std_logic;
        event_lvl_i : in  std_logic_vector(3 downto 0));
end entity;

architecture arch of jcore_cpu is
    component cpu
        port ( 
           clk          : in  std_logic;
           rst          : in  std_logic;
           db_o         : out cpu_data_o_t;
           db_lock      : out std_logic;
           db_i         : in  cpu_data_i_t;
           inst_o       : out cpu_instruction_o_t;
           inst_i       : in  cpu_instruction_i_t;
           debug_o      : out cpu_debug_o_t;
           debug_i      : in  cpu_debug_i_t;
           event_o      : out cpu_event_o_t;
           event_i      : in  cpu_event_i_t);
    end component;

    signal debug_cmd_typed : cpu_debug_cmd_t;
    signal event_cmd_typed : cpu_event_cmd_t;
begin
    process(debug_cmd)
    begin
        case debug_cmd is
            when "00" =>
                debug_cmd_typed <= BREAK;
            when "01" =>
                debug_cmd_typed <= STEP;
            when "10" =>
                debug_cmd_typed <= INSERT;
            when "11" =>
                debug_cmd_typed <= CONTINUE;
            when others => null;
        end case;
    end process;

    process(event_cmd)
    begin
        case event_cmd is
            when "00" =>
                event_cmd_typed <= INTERRUPT;
            when "01" =>
                event_cmd_typed <= ERROR;
            when "10" =>
                event_cmd_typed <= BREAK;
            when "11" =>
                event_cmd_typed <= RESET_CPU;
            when others => null;
        end case;
    end process;

    jcore: cpu port map (
        clk => clk,
        rst => rst,
        db_o.en => db_en,
        db_o.a => db_a,
        db_o.rd => db_rd,
        db_o.wr => db_wr,
        db_o.we => db_we,
        db_o.d => db_do,
        db_lock => db_lock,
        db_i.d => db_di,
        db_i.ack => db_ack,
        inst_o.en => inst_en,
        inst_o.a => inst_a,
        inst_o.jp => inst_jp,
        inst_i.d => inst_d,
        inst_i.ack => inst_ack,
        debug_o.ack => debug_ack,
        debug_o.d => debug_do,
        debug_o.rdy => debug_rdy,
        debug_i.en => debug_en,
        debug_i.cmd => debug_cmd_typed, -- special!
        debug_i.ir => debug_ir,
        debug_i.d => debug_di,
        debug_i.d_en => debug_d_en,
        event_o.ack => event_ack,
        event_o.lvl => event_lvl_o,
        event_o.slp => event_slp,
        event_o.dbg => event_dbg,
        event_i.en => event_en,
        event_i.cmd => event_cmd_typed, -- special!
        event_i.vec => event_vec,
        event_i.msk => event_msk,
        event_i.lvl => event_lvl_i
    );
end architecture;
