library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_js05_top is
-- Testbench tidak memiliki port masukan/keluaran
end tb_js05_top;

architecture Behavioral of tb_js05_top is

    -- Komponen Top-Level
    component js05_top is
        Port (
            clk  : in  STD_LOGIC;
            btnU : in  STD_LOGIC;
            btnD : in  STD_LOGIC;
            btnC : in  STD_LOGIC;
            sw   : in  STD_LOGIC_VECTOR (0 downto 0);
            seg  : out STD_LOGIC_VECTOR (6 downto 0);
            dp   : out STD_LOGIC;
            an   : out STD_LOGIC_VECTOR (3 downto 0)
        );
    end component;

    -- Sinyal Stimulus
    signal clk   : STD_LOGIC := '0';
    signal btnU  : STD_LOGIC := '0';
    signal btnD  : STD_LOGIC := '0';
    signal btnC  : STD_LOGIC := '0';
    signal sw    : STD_LOGIC_VECTOR(0 downto 0) := "0";

    -- Sinyal Output
    signal seg   : STD_LOGIC_VECTOR (6 downto 0);
    signal dp    : STD_LOGIC;
    signal an    : STD_LOGIC_VECTOR (3 downto 0);

    -- Periode Clock 100 MHz (10 ns)
    constant CLK_PERIOD : time := 10 ns;

begin

    -- Instansiasi UUT (Unit Under Test)
    uut: js05_top
        port map (
            clk  => clk,
            btnU => btnU,
            btnD => btnD,
            btnC => btnC,
            sw   => sw,
            seg  => seg,
            dp   => dp,
            an   => an
        );

    -- Pembangkit Clock 100 MHz
    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- Proses Stimulus
    stim_proc: process
    begin
        -- Kondisi awal
        btnU <= '0';
        btnD <= '0';
        btnC <= '0';
        sw   <= "0"; -- Freeze MATI
        wait for 100 ns;

        ------------------------------------------------------------------
        -- 1. Uji Penekanan btnU (Up Counter) + Bouncing Mekanik
        ------------------------------------------------------------------
        -- Memantul (bouncing)
        btnU <= '1'; wait for 20 us;
        btnU <= '0'; wait for 10 us;
        btnU <= '1'; wait for 30 us;
        btnU <= '0'; wait for 15 us;
        btnU <= '1'; -- Sinyal stabil '1'
        wait for 12 ms; -- Menunggu lewati filter debounce 10 ms

        -- Melepas tombol dengan bouncing
        btnU <= '0'; wait for 10 us;
        btnU <= '1'; wait for 20 us;
        btnU <= '0'; -- Sinyal stabil '0'
        wait for 12 ms;

        ------------------------------------------------------------------
        -- 2. Uji Penekanan btnU Kedua (Nilai Pencacah menjadi 2)
        ------------------------------------------------------------------
        btnU <= '1'; wait for 12 ms;
        btnU <= '0'; wait for 12 ms;

        ------------------------------------------------------------------
        -- 3. Uji Penekanan btnD (Down Counter -> Nilai Pencacah kembali ke 1)
        ------------------------------------------------------------------
        btnD <= '1'; wait for 12 ms;
        btnD <= '0'; wait for 12 ms;

        ------------------------------------------------------------------
        -- 4. Uji Fitur Freeze/Pause (Tugas 2)
        ------------------------------------------------------------------
        sw <= "1"; -- Aktifkan Freeze (sw(0) = '1')
        wait for 100 us;

        -- Tekan btnU saat Freeze aktif (Nilai pencacah TIDAK Boleh bertambah)
        btnU <= '1'; wait for 12 ms;
        btnU <= '0'; wait for 12 ms;

        sw <= "0"; -- Matikan Freeze
        wait for 100 us;

        ------------------------------------------------------------------
        -- 5. Uji Reset (btnC)
        ------------------------------------------------------------------
        btnC <= '1'; wait for 12 ms;
        btnC <= '0'; wait for 12 ms;

        wait;
    end process;

end Behavioral;