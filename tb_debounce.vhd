library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_debounce is
end tb_debounce;

architecture Behavioral of tb_debounce is

    -- Komponent debounce dengan STABLE_MS diset kecil (1 ms) agar cepat disimulasikan
    component debounce is
        Generic (
            CLK_FREQ_HZ : integer := 100_000_000;
            STABLE_MS   : integer := 1
        );
        Port (
            clk     : in  STD_LOGIC;
            btn_in  : in  STD_LOGIC;
            btn_out : out STD_LOGIC
        );
    end component;

    signal clk     : STD_LOGIC := '0';
    signal btn_in  : STD_LOGIC := '0';
    signal btn_out : STD_LOGIC;

    constant CLK_PERIOD : time := 10 ns; -- 100 MHz

begin

    -- Instansiasi UUT
    uut: debounce
        generic map (
            CLK_FREQ_HZ => 100_000_000,
            STABLE_MS   => 1 -- 1 ms = 100.000 siklus
        )
        port map (
            clk     => clk,
            btn_in  => btn_in,
            btn_out => btn_out
        );

    -- Pembangkit Clock
    clk_process : process
    begin
        clk <= '0'; wait for CLK_PERIOD/2;
        clk <= '1'; wait for CLK_PERIOD/2;
    end process;

    -- Stimulus Simulasi Bouncing
    stim_proc: process
    begin
        btn_in <= '0';
        wait for 100 ns;

        -- Simulasi Transisi Penekanan Berisik (Glitch/Bounce 0 -> 1)
        btn_in <= '1'; wait for 20 us;
        btn_in <= '0'; wait for 10 us;
        btn_in <= '1'; wait for 30 us;
        btn_in <= '0'; wait for 15 us;
        btn_in <= '1'; -- Sinyal stabil '1'

        -- Menunggu durasi stabil (1.2 ms > 1 ms)
        wait for 1.2 ms; 
        -- Verifikasi: btn_out baru berubah menjadi '1' di titik ini!

        -- Simulasi Transisi Pelepasan Berisik (Glitch/Bounce 1 -> 0)
        btn_in <= '0'; wait for 10 us;
        btn_in <= '1'; wait for 20 us;
        btn_in <= '0'; wait for 15 us;
        btn_in <= '0'; -- Sinyal stabil '0'

        wait for 1.2 ms;
        -- Verifikasi: btn_out baru berubah menjadi '0' di titik ini!

        wait;
    end process;

end Behavioral;