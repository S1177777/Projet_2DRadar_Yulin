library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity Telemetre_tb is
end entity;

architecture Bench of Telemetre_tb is
    -- 信号声明
    signal CLK         : std_logic := '0';  -- 时钟信号
    signal Rst_n       : std_logic := '0';  -- 复位信号（低电平有效）
    signal trig        : std_logic := '0';  -- 输出触发信号
    signal echo        : std_logic := '0';  -- 模拟回波信号
    signal chipselect  : std_logic := '1';  -- Avalon 片选信号（默认选中）
    signal Read_n      : std_logic := '1';  -- Avalon 读信号（高电平无效）
    signal readdata    : std_logic_vector(31 downto 0); -- Avalon 数据输出
    signal Dist_cm     : std_logic_vector(9 downto 0);  -- 测距数据
begin

    -- 实例化被测试模块（DUT）
    G1: entity work.IPtelemetre port map (
        CLK        => CLK,
        Rst_n      => Rst_n,
        echo       => echo,
        trig       => trig,
        chipselect => chipselect,
        Read_n     => Read_n,
        readdata   => readdata,
        Dist_cm    => Dist_cm
    );

    -- 时钟生成器
    Clock: process
    begin
        while now <= 200 ms loop
            CLK <= '0';
            wait for 10 ns;
            CLK <= '1';
            wait for 10 ns;
        end loop;
        wait;
    end process;

    -- 复位信号生成
    Rst_gen: process
    begin
        Rst_n <= '0';         -- 初始复位
        wait for 100 ns;
        Rst_n <= '1';         -- 结束复位
        wait;
    end process;

    -- 模拟回波信号生成器
    echon: process
    begin
        -- 第一次测量（2 ms 回波信号，~68 cm）
        wait until trig = '1';
        wait until trig = '0';
        wait for 100 ns;
        echo <= '1';
        wait for 2 ms; -- 模拟 2 ms 的回波时间
        echo <= '0';

        -- 第二次测量（5 ms 回波信号，~171 cm）
        wait until trig = '1';
        wait until trig = '0';
        wait for 100 ns;
        echo <= '1';
        wait for 5 ms; -- 模拟 5 ms 的回波时间
        echo <= '0';

        -- 第三次测量（10 ms 回波信号，~343 cm）
        wait until trig = '1';
        wait until trig = '0';
        wait for 100 ns;
        echo <= '1';
        wait for 10 ms; -- 模拟 10 ms 的回波时间
        echo <= '0';

        wait;
    end process;

    -- Avalon 接口读操作仿真
    Avalon_Read: process
    begin
        wait for 500 ns;  -- 等待触发完成

        chipselect <= '1';  -- 激活片选
        wait for 2000000 ns;
        Read_n <= '0';      -- 激活读信号
        wait for 1 ms;
        Read_n <= '1';      -- 停止读信号
        wait for 50 ms;      -- 等待下一个测量周期
        Read_n <= '0';
        wait for 1 ms;
        Read_n <= '1';
        wait;
    end process;

end architecture;
