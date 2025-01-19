library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity IPtelemetre is
    port (
        trig        : out std_logic;                     -- 触发超声波信号
        echo        : in std_logic;                      -- 接收回波信号
        Dist_cm     : out std_logic_vector(9 downto 0);  -- 测距数据输出
        CLK         : in std_logic;                      -- 系统时钟
        Rst_n       : in std_logic;                      -- 复位信号（低电平有效）
        chipselect  : in std_logic;                      -- Avalon MM 片选信号
        Read_n      : in std_logic;                      -- Avalon MM 读信号（低电平有效）
        readdata    : out std_logic_vector(31 downto 0)  -- Avalon MM 数据输出
    );
end entity;

architecture RTL of IPtelemetre is
    -- 内部信号定义
    signal cnt_dist1, dist, cnt_trig, cnt_total : integer := 0; -- 多个计数器信号
    signal distance_internal : std_logic_vector(9 downto 0) := (others => '0'); -- 内部存储的距离
    type StateType is (Init, Go1, Go2, Go3, Go4); -- 状态类型定义
    signal State : StateType := Init; -- 状态机当前状态
	 signal echo_r, echo_rr : std_logic;
begin

	 
		Dist_cm <= distance_internal;
		distance_internal <= std_logic_vector(to_unsigned((dist) / 2941, 10));
		
		process(chipselect, read_n, distance_internal)
		begin
		 readdata <= (others => '0'); -- 高位填充为 0
		 if chipselect = '1' and Read_n = '0' then
					 readdata(31 downto 10) <= (others => '0'); -- 高位填充为 0
                readdata(9 downto 0) <= distance_internal; -- 距离数据输出
            end if;
		 end process;
		 
    -- 主过程：状态机和 Avalon 接口逻辑
    process (Rst_n, CLK)
    begin
        if Rst_n = '0' then
            -- 复位所有信号
            State <= Init;
            cnt_dist1 <= 0;
            dist <= 0;
            cnt_trig <= 0;
            cnt_total <= 0;
            trig <= '0';
            
            
        elsif rising_edge(CLK) then
		  
				echo_r <= echo;
				echo_rr <= echo_r;
            -- 状态机逻辑
            case State is
                when Init =>
                    
                    
                        trig <= '1'; -- 激活触发信号
                        State <= Go1;
                    

                when Go1 =>
                    if cnt_trig > 1000 then -- 10µs 触发信号完成
                        trig <= '0'; -- 停止触发信号
                        cnt_total <= cnt_total + 1;
                        State <= Go2;
                    else
                        cnt_trig <= cnt_trig + 1;
                        
                    end if;

                when Go2 =>
                    
                    cnt_total <= cnt_total + 1; -- 等待回波信号开始
                        
                    if echo_rr = '1' then
                        cnt_dist1 <= cnt_dist1 + 1; -- 使用第一个计数器开始计时
                        
                        State <= Go3;
                    end if;
						
						  if cnt_total > 5e6 then
                        State <= Init;
                        cnt_dist1 <= 0;
                        cnt_trig <= 0;
                        cnt_total <= 0;
                        trig <= '0';
                    end if; 

                when Go3 =>
                    
                        cnt_dist1 <= cnt_dist1 + 1; --- 使用第二个计数器继续计时
                        cnt_total <= cnt_total + 1;
                        
                    if echo_rr = '0' then
               
                            --Dist_cm <= std_logic_vector(to_unsigned((cnt_dist1 + cnt_dist2) / 2941, 10)); -- 距离计算
                            dist <= cnt_dist1;
                            State <=Go4;
                    
                    end if;
						  
                when Go4 =>
                    
                        cnt_total <= cnt_total + 1;
                       
                      if cnt_total > 5e6 then
                        State <= Init;
                        cnt_dist1 <= 0;
                        
                        cnt_trig <= 0;
                        cnt_total <= 0;
                        trig <= '0';
                    end if;
            end case;

            -- Avalon 接口逻辑：读信号有效时输出测距数据
           
        end if;
    end process;

end architecture;
