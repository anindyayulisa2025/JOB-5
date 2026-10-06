library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity seven_seg_driver is
    Generic (
        DIGITS : integer := 4
    );
    Port (
        clk  : in  STD_LOGIC;
        data : in  STD_LOGIC_VECTOR (15 downto 0); -- Input 16-bit
        seg  : out STD_LOGIC_VECTOR (6 downto 0);  -- Pola g f e d c b a
        dp   : out STD_LOGIC;                      -- Decimal point
        an   : out STD_LOGIC_VECTOR (3 downto 0)   -- Anoda (aktif-rendah)
    );
end seven_seg_driver;

architecture Behavioral of seven_seg_driver is

    -- Fungsi konversi Heksadesimal (0-F) ke pola segmen aktif-rendah (gfedcba)
    function hex_to_seg(digit : unsigned(3 downto 0)) return STD_LOGIC_VECTOR is
    begin
        case digit is
            when "0000" => return "1000000"; -- 0
            when "0001" => return "1111001"; -- 1
            when "0010" => return "0100100"; -- 2
            when "0011" => return "0110000"; -- 3
            when "0100" => return "0011001"; -- 4
            when "0101" => return "0010010"; -- 5
            when "0110" => return "0000010"; -- 6
            when "0111" => return "1111000"; -- 7
            when "1000" => return "0000000"; -- 8
            when "1001" => return "0010000"; -- 9
            when "1010" => return "0001000"; -- A
            when "1011" => return "0000011"; -- b
            when "1100" => return "1000111"; -- C
            when "1101" => return "0100001"; -- d
            when "1110" => return "0000110"; -- E
            when "1111" => return "0001110"; -- F
            when others => return "0111111"; -- '-' (tak terdefinisi)
        end case;
    end function;

    signal refresh_cnt   : unsigned(19 downto 0) := (others => '0');
    signal digit_sel     : unsigned(1 downto 0) := "00";
    signal current_digit : unsigned(3 downto 0);

begin

    -- Pembagi frekuensi clock
    process(clk)
    begin
        if rising_edge(clk) then
            refresh_cnt <= refresh_cnt + 1;
        end if;
    end process;

    -- Multiplexing digit (pembagi clock per digit ~1 kHz)
    digit_sel <= refresh_cnt(19 downto 18);

    process(digit_sel, data)
    begin
        case digit_sel is
            when "00" =>
                an <= "1110"; -- Digit 0 (paling kanan)
                current_digit <= unsigned(data(3 downto 0));
            when "01" =>
                an <= "1101"; -- Digit 1
                current_digit <= unsigned(data(7 downto 4));
            when "10" =>
                an <= "1011"; -- Digit 2
                current_digit <= unsigned(data(11 downto 8));
            when "11" =>
                an <= "0111"; -- Digit 3 (paling kiri)
                current_digit <= unsigned(data(15 downto 12));
            when others =>
                an <= "1111";
                current_digit <= "0000";
        end case;
    end process;

    seg <= hex_to_seg(current_digit);
    dp  <= '1'; -- Matikan titik desimal (aktif-rendah)

end Behavioral;