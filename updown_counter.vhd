library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity updown_counter is
    Port (
        clk       : in  STD_LOGIC;
        reset     : in  STD_LOGIC; -- Sinyal Reset dari btnC
        freeze    : in  STD_LOGIC; -- Kontrol Freeze/Pause dari sw(0)
        inc       : in  STD_LOGIC; -- Pulsa dari btnU (edge_detect)
        dec       : in  STD_LOGIC; -- Pulsa dari btnD (edge_detect)
        count_out : out STD_LOGIC_VECTOR (15 downto 0)
    );
end updown_counter;

architecture Behavioral of updown_counter is
    signal count_reg : unsigned(15 downto 0) := (others => '0');
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                count_reg <= (others => '0');
            elsif freeze = '0' then -- Pencacah hanya merespons jika freeze matikan ('0')
                if inc = '1' then
                    count_reg <= count_reg + 1;
                elsif dec = '1' then
                    count_reg <= count_reg - 1;
                end if;
            end if;
        end if;
    end process;

    count_out <= std_logic_vector(count_reg);
end Behavioral;