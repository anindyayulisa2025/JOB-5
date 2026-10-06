library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity js05_top is
    Port (
        clk  : in  STD_LOGIC;
        sw   : in  STD_LOGIC_VECTOR (0 downto 0); -- Saklar sw(0) untuk Freeze
        btnU : in  STD_LOGIC;
        btnD : in  STD_LOGIC;
        btnC : in  STD_LOGIC;
        seg  : out STD_LOGIC_VECTOR (6 downto 0);
        dp   : out STD_LOGIC;
        an   : out STD_LOGIC_VECTOR (3 downto 0)
    );
end js05_top;

architecture Behavioral of js05_top is

    signal btnU_db, btnD_db, btnC_db : STD_LOGIC;
    signal pulseU, pulseD            : STD_LOGIC;
    signal count_val                 : STD_LOGIC_VECTOR(15 downto 0);

begin

    -- Debounce untuk tombol
    db_U : entity work.debounce generic map(STABLE_MS => 10) port map(clk => clk, btn_in => btnU, btn_out => btnU_db);
    db_D : entity work.debounce generic map(STABLE_MS => 10) port map(clk => clk, btn_in => btnD, btn_out => btnD_db);
    db_C : entity work.debounce generic map(STABLE_MS => 10) port map(clk => clk, btn_in => btnC, btn_out => btnC_db);

    -- Edge Detect
    ed_U : entity work.edge_detect port map(clk => clk, sig_in => btnU_db, pulse => pulseU);
    ed_D : entity work.edge_detect port map(clk => clk, sig_in => btnD_db, pulse => pulseD);

    -- Up/Down Counter dengan Freeze (sw(0))
    counter_inst : entity work.updown_counter
        port map (
            clk       => clk,
            reset     => btnC_db,
            freeze    => sw(0),
            inc       => pulseU,
            dec       => pulseD,
            count_out => count_val
        );

    -- Seven Segment Driver Heksadesimal
    driver_inst : entity work.seven_seg_driver
        generic map (DIGITS => 4)
        port map (
            clk  => clk,
            data => count_val,
            seg  => seg,
            dp   => dp,
            an   => an
        );

end Behavioral;