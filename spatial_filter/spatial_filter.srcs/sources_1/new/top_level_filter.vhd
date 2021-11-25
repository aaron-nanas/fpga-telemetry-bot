-- Author: Jose L Martinez
-- File: top_level_filter.vhd
--
-- Function: Used to select which filter to use and apply it to the image
--           stored in bram1 and store the result in bram2. 
--
-- Top Level Filter FSM Configuration:
--     FSM And Datapath module tkaing in start_filtering as control bits filter_select.
--     Data Width: 8 bits
--     Bram1 Address Width: 18 bits (with 242,004 elements)
--     Bram2 Address Width: 18 bits (with 240,000 elements)
--     Parameterization allows for different sized images to be used.
--          data_width : size of data being processed and transfered
--          addr_width : width for the addresses in BRAM
--          num_filters : number of filters used for this FSM
--          addr_width : amount of pixels being processe
--          num_elements_input: number of elements stored to BRAM1 
--          num_elements_output: number of elements stored in BRAM2

--  filter selection:
--  "00" = Average Filter
--  "01" = Lapacian Filter
--  "10" = Threshold Filter
--  "11" = N/A


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;

entity top_level_filter_fsm is
    generic(
        data_width:         integer := 8;
        addr_width:         integer := 18;
        filters_width:        integer := 2;
        num_elements_input:       integer := 242_004;
        num_elements_output:       integer := 240_000
    );
    Port (  clk, rst: in std_logic;
            wea1, wea2, rea1, rea2: in  std_logic;
            start_filtering: in std_logic;
            filter_select: in std_logic_vector(filters_width - 1 downto 0);
            bram1_a, bram2_a: in std_logic_vector(addr_width-1 downto 0);
            bram1_din, bram2_din: in std_logic_vector(data_width-1 downto 0);
            bram1_dout, bram2_dout: out std_logic_vector(data_width-1 downto 0);
            done, busy: out std_logic);
end top_level_filter_fsm;

architecture Behavioral of top_level_filter_fsm is
    
    -- Infered BRAM Module
    component inferred_bram_for_image is
        generic(
            data_width:         integer := 8;
            addr_width:         integer := 18;
            num_elements:       integer := 240_000
         );
        Port (
            i_clk:              in std_logic;
            write_ena:          in std_logic;
            read_enable:        in std_logic;
            addr:               in std_logic_vector(addr_width-1 downto 0);
            data_in:            in std_logic_vector(data_width-1 downto 0);
            data_out:           out std_logic_vector(data_width-1 downto 0)
             );
    end component inferred_bram_for_image;

    -- Average Filter Module
    component average_filter is
        generic(
            data_width:         integer := 8;
            addr_width:         integer := 18;
            num_elements:       integer := 240_000
        );
        Port ( clk, rst, ena: in std_logic;
            done, wea: out std_logic;
            addr0: out std_logic_vector(addr_width-1 downto 0);
            din0: in std_logic_vector(data_width-1 downto 0);
            output_a: out std_logic_vector(addr_width-1 downto 0);
            output_d: out std_logic_vector(data_width-1 downto 0));
    end component average_filter;
    
    -- Lapacian Filter Module
    component lapacian_filter is
        Port ( clk, rst, ena: in std_logic;
            done: out std_logic;
            addr0: out std_logic_vector(17 downto 0);
            din0: in std_logic_vector(7 downto 0);
            wea: out std_logic;
            output_a: out std_logic_vector(17 downto 0);
            output_d: out std_logic_vector(7 downto 0));
    end component lapacian_filter;
    
    -- Threshold Filter Module
    component threshold_filter is
    Port ( clk, rst, ena: in std_logic;
           done: out std_logic;
           addr0: out std_logic_vector(17 downto 0);
           din0: in std_logic_vector(7 downto 0);
           wea: out std_logic;
           output_a: out std_logic_vector(17 downto 0);
           output_d: out std_logic_vector(7 downto 0));
    end component threshold_filter;
    
    -- Filter State Type and Signal
    -- These states will determin what current action the FSM will be performing.
    type FILTER_STATE is (IDLE, A_AVE_F, A_LAP_F, A_THR_F, F_DONE);
    signal f_state: FILTER_STATE := IDLE;
    
    -- Signals for the Average Filter Module
    signal avg_ena, avg_done, avg_wea: std_logic;
    signal avg_addr0, avg_output_a: std_logic_vector(addr_width-1 downto 0);
    signal avg_din, avg_output_d: std_logic_vector(data_width-1 downto 0);
    
    -- Signals for the Lapacian Filter Module
    signal lap_ena, lap_done, lap_wea: std_logic;
    signal lap_addr0, lap_output_a: std_logic_vector(addr_width-1 downto 0);
    signal lap_din, lap_output_d: std_logic_vector(data_width-1 downto 0);
    
    -- Signals for the Threshold Filter Module
    signal thr_ena, thr_done, thr_wea: std_logic;
    signal thr_addr0, thr_output_a: std_logic_vector(addr_width-1 downto 0);
    signal thr_din, thr_output_d: std_logic_vector(data_width-1 downto 0);
    
    -- Signals to control and connect the BRAM to the filter modules.
    signal sel_bram1_a: std_logic_vector(filters_width - 1 downto 0);
    signal bram1_a_mux, bram2_a_mux: std_logic_vector(addr_width-1 downto 0);
    signal bram_dout_in, bram2_d_mux: std_logic_vector(data_width-1 downto 0);
    signal wea1_in, wea2_in, rea1_in, rea2_in: std_logic;
    signal wea1_fsm, wea2_fsm, rea1_fsm, rea2_fsm: std_logic;
    
begin

bram1_dout <= bram_dout_in;

-- BRAM1 is an infered BRAM module used to contain the original image padded with zeros.
-- The filters will access this BRAM and read the data in their respective States.
BRAM1: inferred_bram_for_image generic map (data_width => data_width, addr_width => addr_width, num_elements => num_elements_input)
                               port map (i_clk => clk, write_ena => wea1_in, read_enable => rea1_in, 
                                         addr => bram1_a_mux, data_in => bram1_din, data_out => bram_dout_in);
                                         
-- BRAM2 is an infered BRAM module used to contain the processed image.
-- The filters will access this BRAM and write the processed image in their respective States.
BRAM2: inferred_bram_for_image port map (i_clk => clk, write_ena => wea2_in, read_enable => rea2_in, 
                                         addr => bram2_a_mux, data_in => bram2_d_mux, data_out => bram2_dout);
                                         
-- Average Filter module used in the A_AVE_F state to read from BRAM1 and conduct smoothing on the image.
-- The processed image is stored in BRAM2.
AVE_FILTER: average_filter port map (clk => clk, rst => rst, ena => avg_ena, done => avg_done, addr0 => avg_addr0, 
                                         din0 => bram_dout_in, wea => avg_wea, output_a => avg_output_a, output_d => avg_output_d);

-- Average Filter module used in the A_LAP_F state to read from BRAM1 and conduct edge detection on the image.
-- The processed image is stored in BRAM2.
LAP_FILTER: lapacian_filter port map (clk => clk, rst => rst, ena => lap_ena, done => lap_done, addr0 => laP_addr0, 
                                         din0 => bram_dout_in, wea => lap_wea, output_a => lap_output_a, output_d => lap_output_d);
                                         
-- Average Filter module used in the A_THR_F state to read from BRAM1 and conduct thresholding on the image.
-- The processed image is stored in BRAM2.
THR_FILTER: threshold_filter port map (clk => clk, rst => rst, ena => thr_ena, done => thr_done, addr0 => thr_addr0, 
                                         din0 => bram_dout_in, wea => thr_wea, output_a => thr_output_a, output_d => thr_output_d);

-- Mux for BRAM1 Address   
-- sel_bram1 is determined by the FSM                                 
bram1_a_mux <= bram1_a when (sel_bram1_a = "00") else
               avg_addr0 when (sel_bram1_a = "01") else
               lap_addr0 when (sel_bram1_a = "10") else
               thr_addr0;
       
-- Mux for BRAM2 Address  
-- sel_bram1 is determined by the FSM      
bram2_a_mux <= bram2_a when (sel_bram1_a = "00") else
               avg_output_a when (sel_bram1_a = "01") else
               lap_output_a when (sel_bram1_a = "10") else
               thr_output_a;

-- Mux for BRAM2 Data
-- sel_bram1 is determined by the FSM
bram2_d_mux <= bram2_din when (sel_bram1_a = "00") else
               avg_output_d when (sel_bram1_a = "01") else
               lap_output_d when (sel_bram1_a = "10") else
               thr_output_d;

-- Write and Read enables for BRAM1 & BRAM2
wea1_in <= wea1 or wea1_fsm;
wea2_in <= wea2 or wea2_fsm;
rea1_in <= rea1 or rea1_fsm;
rea2_in <= rea2 or rea2_fsm;

-- FSM control
filter_fsm_control: process(clk) 
begin
    if (rising_edge(clk)) then -- rising edge FSM control with synchronous reset
        if (rst = '1') then
            wea1_fsm <= '0';
            rea1_fsm <= '0';
            wea2_fsm <= '0';
            rea2_fsm <= '0';
            f_state <= IDLE;
            busy <= '0';
            done <= '0';
            avg_ena <= '0';
        else
            case (f_state) is -- Switch State logic with outputs.
                -- Idle state is the default state of FSM in which the FSM will wait for the start_filtering signal to move '1'.
                -- In this state the BRAM modules can be freely accessed without worry.
                -- filter_select will determine which state will be the next when start_filtering is '1'.
                when IDLE => 
                    busy <= '0';
                    done <= '0';
                    sel_bram1_a <= "00";
                    if(start_filtering = '1') then
                        case (filter_select) is
                            when "00" =>
                                f_state <= A_AVE_F;
                            when "01" =>
                                f_state <= A_LAP_F;
                            when "10" =>
                                f_state <= A_THR_F;
                            when others =>
                                f_state <= IDLE;
                        end case;
                    end if;
                
                -- A_AVE_F is the state when the start_filtering was '1' and filter_select was "00".
                -- In this state the average_filter module will process the image in BRAM1 using averaging kernel and store in BRAM2.
                -- In this state the BRAM modules cannot be freely accessed and tyring to do so will result in unpredictable results.
                -- The FSM will stay in this state until avg_done = '1' is detected.
                when A_AVE_F =>
                    busy <= '1';
                    sel_bram1_a <= "01";
                    done <= '0';
                    avg_ena <= '1';
                    wea1_fsm <= '0';
                    rea1_fsm <= '1';
                    wea2_fsm <= '1';
                    rea2_fsm <= '0';
                    if(avg_done = '1') then
                        f_state <= F_DONE;
                    end if;
                    
                -- A_LAP_F is the state when the start_filtering was '1' and filter_select was "01".
                -- In this state the lapacian_filter module will process the image in BRAM1 using lapacian kernel and store in BRAM2.
                -- In this state the BRAM modules cannot be freely accessed and tyring to do so will result in unpredictable results.
                -- The FSM will stay in this state until lap_done = '1' is detected.                    
                when A_LAP_F =>
                    busy <= '1';
                    sel_bram1_a <= "10";
                    done <= '0';
                    lap_ena <= '1';
                    wea1_fsm <= '0';
                    rea1_fsm <= '1';
                    wea2_fsm <= '1';
                    rea2_fsm <= '0';
                    if(lap_done = '1') then
                        f_state <= F_DONE;
                    end if;
                    
                -- A_THR_F is the state when the start_filtering was '1' and filter_select was "10".
                -- In this state the threshold_filter module will process the image in BRAM1 using thresholding and store in BRAM2.
                -- In this state the BRAM modules cannot be freely accessed and tyring to do so will result in unpredictable results.
                -- The FSM will stay in this state until thr_done = '1' is detected.   
                when A_THR_F =>
                    busy <= '1';
                    sel_bram1_a <= "11";
                    done <= '0';
                    thr_ena <= '1';
                    wea1_fsm <= '0';
                    rea1_fsm <= '1';
                    wea2_fsm <= '1';
                    rea2_fsm <= '0';
                    if(thr_done = '1') then
                        f_state <= F_DONE;
                    end if;
                
                -- A_F_DONE is the state when any of the filters are done processing the image.
                -- In this state the BRAM modules can be freely accessed without worry.
                -- The FSM will stay in this state until either rst = '1' or is wea1 is = '1'.   
                when F_DONE =>
                    busy <= '0';
                    done <= '1'; 
                    avg_ena <= '0';
                    wea1_fsm <= '0';
                    rea1_fsm <= '0';
                    wea2_fsm <= '0';
                    rea2_fsm <= '0';
                    sel_bram1_a <= "00";
                    if (wea1 = '1') then 
                        f_state <= IDLE;
                    else     
                        f_state <= F_DONE;
                    end if;
                when others =>
                    f_state <= IDLE;
            end case;
        end if;
    end if;
end process;

end Behavioral;

