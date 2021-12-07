--Author: Aaron Nanas
--File: motor_controller.vhd
--Purpose:
--    The top-level controller for the four DC motors of the Telemetry Bot.
--    Contains four instances of the PWM generator
--    Receives the duty cycle, motor direction, and PWM enable from the instruction register
--    Outputs a total of 8 PWM signals (two per motor due to direction)
--    Motor Driver Used: DRV8771

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;

entity motor_controller is
    generic (
        data_width:             integer := 8;
        num_motors:             integer := 4;
        clk_freq:               integer := 125
    );
    port (
        i_clk:                  in std_logic;
        i_reset:                in std_logic;
        start_drive_mode:       in std_logic;
        duty_cycle_value_reg:   in std_logic_vector(data_width-1 downto 0);
        PWM_enable_reg:         in std_logic_vector(num_motors-1 downto 0);
        motor_direction_reg:    in std_logic_vector(num_motors-1 downto 0);
        sensor_pulse:           in std_logic;
        sensor_enable:          out std_logic;
        o_PWM_1:                out std_logic;
        o_PWM_2:                out std_logic;
        o_PWM_3:                out std_logic;
        o_PWM_4:                out std_logic;
        o_PWM_5:                out std_logic;
        o_PWM_6:                out std_logic;
        o_PWM_7:                out std_logic;
        o_PWM_8:                out std_logic;
        o_ssd:                  out std_logic_vector(6 downto 0);
        o_ssd_cat:              out std_logic
    );
end motor_controller;

architecture Behavioral of motor_controller is

signal s_enable_PWM:            std_logic_vector(num_motors-1 downto 0) := (others => '0');
signal s_motor_direction:       std_logic_vector(num_motors-1 downto 0) := (others => '0');
signal s_duty_cycle:            integer range 0 to 255 := 0;
signal max_close_distance_flag: std_logic;
signal sensor_distance:         std_logic_vector(7 downto 0);

component pwm_generator is
    Port (
        i_clk:              in std_logic;
        i_reset:            in std_logic;
        i_enable:           in std_logic;
        i_set_direction:    in std_logic;
        i_duty_cycle:       in integer range 0 to 255;
        o_PWM_1:            out std_logic;
        o_PWM_2:            out std_logic
     );
end component pwm_generator;

component maxsonar_sensor is
    generic (
        clk_freq:                   integer := 125
    );
    port (
        i_clk:                      in std_logic;
        i_reset:                    in std_logic;
        sensor_pulse:               in std_logic;
        sensor_enable:              out std_logic;
        max_close_distance_flag:    out std_logic;
        sensor_distance:            out std_logic_vector(7 downto 0);
        o_ssd:                      out std_logic_vector(6 downto 0);
        o_ssd_cat:                  out std_logic
    );
end component maxsonar_sensor;

begin

maxsonar_sensor_instance: maxsonar_sensor
    generic map (
        clk_freq => clk_freq
    )
    port map (
        i_clk => i_clk,
        i_reset => i_reset,
        sensor_pulse => sensor_pulse,
        sensor_enable => sensor_enable,
        max_close_distance_flag => max_close_distance_flag,
        sensor_distance => sensor_distance,
        o_ssd => o_ssd,
        o_ssd_cat => o_ssd_cat
    );

pwm_generator_instance_1: pwm_generator
    port map (
        i_clk               =>  i_clk,
        i_reset             =>  i_reset,
        i_enable            =>  s_enable_PWM(0),
        i_set_direction     =>  s_motor_direction(0),
        i_duty_cycle        =>  s_duty_cycle,
        o_PWM_1             =>  o_PWM_1,
        o_PWM_2             =>  o_PWM_2
    );
    
pwm_generator_instance_2: pwm_generator
    port map (
        i_clk               =>  i_clk,
        i_reset             =>  i_reset,
        i_enable            =>  s_enable_PWM(1),
        i_set_direction     =>  s_motor_direction(1),
        i_duty_cycle        =>  s_duty_cycle,
        o_PWM_1             =>  o_PWM_3,
        o_PWM_2             =>  o_PWM_4
    );

pwm_generator_instance_3: pwm_generator
    port map (
        i_clk               =>  i_clk,
        i_reset             =>  i_reset,
        i_enable            =>  s_enable_PWM(2),
        i_set_direction     =>  s_motor_direction(2),
        i_duty_cycle        =>  s_duty_cycle,
        o_PWM_1             =>  o_PWM_5,
        o_PWM_2             =>  o_PWM_6
    );
    
pwm_generator_instance_4: pwm_generator
    port map (
        i_clk               =>  i_clk,
        i_reset             =>  i_reset,
        i_enable            =>  s_enable_PWM(3),
        i_set_direction     =>  s_motor_direction(3),
        i_duty_cycle        =>  s_duty_cycle,
        o_PWM_1             =>  o_PWM_7,
        o_PWM_2             =>  o_PWM_8
    );
    
motor_control_proc: process(i_clk)
begin
    if (rising_edge(i_clk)) then
        if (i_reset = '1') then
            s_motor_direction <= (others => '0');
            s_enable_PWM <= (others => '0');
            s_duty_cycle <= 0;
            sensor_enable <= '0';
        else
            if (start_drive_mode = '1') then
                s_duty_cycle <= to_integer(unsigned(duty_cycle_value_reg));
                for i in 0 to (num_motors-1) loop
                    s_enable_PWM(i) <= PWM_enable_reg(i);
                    s_motor_direction(i) <= motor_direction_reg(i);
                end loop;
--                -- Detect if the bot is too close to an object. If so, then stop PWM
--                -- Current threshold set to 8 inches in front of the bot
--                if (max_close_distance_flag = '0') then 
--                    s_duty_cycle <= to_integer(unsigned(duty_cycle_value_reg));
--                    for i in 0 to (num_motors-1) loop
--                        s_enable_PWM(i) <= PWM_enable_reg(i);
--                        s_motor_direction(i) <= motor_direction_reg(i);
--                    end loop;
--                else
--                    s_enable_PWM <= (others => '0');
--                end if;
            else
                s_enable_PWM <= (others => '0');
                s_motor_direction <= (others => '0');
                s_duty_cycle <= 0;
            end if;
        end if;
    end if;
end process motor_control_proc;

end Behavioral;