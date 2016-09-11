library ieee;
use ieee.std_logic_1164.all;

entity dut_jcore_cpu is
end entity;

architecture arch of dut_jcore_cpu is
    component jcore_cpu
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
            db_nak      : in  std_logic;

            inst_en     : out std_logic;
            inst_a      : out std_logic_vector(31 downto 1);
            inst_jp     : out std_logic;
            inst_d      : in  std_logic_vector(15 downto 0);
            inst_ack    : in  std_logic;
            inst_nak    : in  std_logic;

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
    end component;

    signal from_myhdl_clk         : std_logic;
    signal from_myhdl_rst         : std_logic;
    signal from_myhdl_db_di       : std_logic_vector(31 downto 0);
    signal from_myhdl_db_ack      : std_logic;
    signal from_myhdl_db_nak      : std_logic;
    signal from_myhdl_inst_d      : std_logic_vector(15 downto 0);
    signal from_myhdl_inst_ack    : std_logic;
    signal from_myhdl_inst_nak    : std_logic;
    signal from_myhdl_debug_en    : std_logic;
    signal from_myhdl_debug_cmd   : std_logic_vector(1 downto 0);
    signal from_myhdl_debug_ir    : std_logic_vector(15 downto 0);
    signal from_myhdl_debug_di    : std_logic_vector(31 downto 0);
    signal from_myhdl_debug_d_en  : std_logic;
    signal from_myhdl_event_en    : std_logic;
    signal from_myhdl_event_cmd   : std_logic_vector(1 downto 0);
    signal from_myhdl_event_vec   : std_logic_vector(7 downto 0);
    signal from_myhdl_event_msk   : std_logic;
    signal from_myhdl_event_lvl_i : std_logic_vector(3 downto 0);
    signal to_myhdl_db_en       : std_logic;
    signal to_myhdl_db_a        : std_logic_vector(31 downto 0);
    signal to_myhdl_db_rd       : std_logic;
    signal to_myhdl_db_wr       : std_logic;
    signal to_myhdl_db_we       : std_logic_vector(3 downto 0);
    signal to_myhdl_db_do       : std_logic_vector(31 downto 0);
    signal to_myhdl_db_lock     : std_logic;
    signal to_myhdl_inst_en     : std_logic;
    signal to_myhdl_inst_a      : std_logic_vector(31 downto 1);
    signal to_myhdl_inst_jp     : std_logic;
    signal to_myhdl_debug_ack   : std_logic;
    signal to_myhdl_debug_do    : std_logic_vector(31 downto 0);
    signal to_myhdl_debug_rdy   : std_logic;
    signal to_myhdl_event_ack   : std_logic;
    signal to_myhdl_event_lvl_o : std_logic_vector(3 downto 0);
    signal to_myhdl_event_slp   : std_logic;
    signal to_myhdl_event_dbg   : std_logic;
begin
    dut: jcore_cpu port map (
        clk         => from_myhdl_clk,
        rst         => from_myhdl_rst,

        db_en       => to_myhdl_db_en,
        db_a        => to_myhdl_db_a,
        db_rd       => to_myhdl_db_rd,
        db_wr       => to_myhdl_db_wr,
        db_we       => to_myhdl_db_we,
        db_do       => to_myhdl_db_do,
        db_lock     => to_myhdl_db_lock,
        db_di       => from_myhdl_db_di,
        db_ack      => from_myhdl_db_ack,
        db_nak      => from_myhdl_db_nak,

        inst_en     => to_myhdl_inst_en,
        inst_a      => to_myhdl_inst_a,
        inst_jp     => to_myhdl_inst_jp,
        inst_d      => from_myhdl_inst_d,
        inst_ack    => from_myhdl_inst_ack,
        inst_nak    => from_myhdl_inst_nak,

        debug_ack   => to_myhdl_debug_ack,
        debug_do    => to_myhdl_debug_do,
        debug_rdy   => to_myhdl_debug_rdy,
        debug_en    => from_myhdl_debug_en,
        debug_cmd   => from_myhdl_debug_cmd,
        debug_ir    => from_myhdl_debug_ir,
        debug_di    => from_myhdl_debug_di,
        debug_d_en  => from_myhdl_debug_d_en,

        event_ack   => to_myhdl_event_ack,
        event_lvl_o => to_myhdl_event_lvl_o,
        event_slp   => to_myhdl_event_slp,
        event_dbg   => to_myhdl_event_dbg,
        event_en    => from_myhdl_event_en,
        event_cmd   => from_myhdl_event_cmd,
        event_vec   => from_myhdl_event_vec,
        event_msk   => from_myhdl_event_msk,
        event_lvl_i => from_myhdl_event_lvl_i
    );
end architecture;
