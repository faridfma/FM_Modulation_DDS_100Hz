library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--USE ieee.std_logic_arith.all;
use IEEE.numeric_std.all;

 
entity FM_ModulatorTopLevel is
  port (
    sys_clk : in std_logic; 
    reset_0 : in STD_LOGIC
  );
end FM_ModulatorTopLevel;

architecture behavioral of FM_ModulatorTopLevel is

signal clk_out_Sig : std_logic;            
signal locked_Sig  : std_logic;
signal m_axis_data_tvalid_Sig : std_logic;
signal Message_Tone : STD_LOGIC_VECTOR(31 DOWNTO 0); 

signal MessageMultiplied   : STD_LOGIC_VECTOR(39 DOWNTO 0); 
signal MessageMultipliedShifted   : STD_LOGIC_VECTOR(7 DOWNTO 0);
signal CarrierPlusMessage  : STD_LOGIC_VECTOR(39 DOWNTO 0); 

signal DDS1_data_in : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal DDS1_tvalid_out : STD_LOGIC;
signal ModulatedSignalOut : STD_LOGIC_VECTOR(31 DOWNTO 0); 

signal message_pm1 : signed(24 downto 0);
signal Fm_Plus_Carrier : STD_LOGIC_VECTOR(27 DOWNTO 0); 
signal Fm_Plus_Carrier_Pudded : STD_LOGIC_VECTOR(31 DOWNTO 0); 
 
 
component clk_wiz_0
port
 (
  clk_out1          : out    std_logic;
  locked            : out    std_logic;
  clk_in1           : in     std_logic
 );
end component;
 

COMPONENT dds_compiler_0
  PORT (
    aclk : IN STD_LOGIC;
    m_axis_data_tvalid : OUT STD_LOGIC;
    m_axis_data_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END COMPONENT;

COMPONENT mult_gen_0
  PORT (
    CLK : IN STD_LOGIC;
    A : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    P : OUT STD_LOGIC_VECTOR(39 DOWNTO 0)
  );
END COMPONENT;


COMPONENT c_addsub_0
 PORT (
    A   : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    CLK : IN STD_LOGIC;
    S   : OUT STD_LOGIC_VECTOR(27 DOWNTO 0)
  );
END COMPONENT;


COMPONENT dds_compiler_1
  PORT (
    aclk : IN STD_LOGIC;
    s_axis_phase_tvalid : IN STD_LOGIC;
    s_axis_phase_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axis_data_tvalid : OUT STD_LOGIC;
    m_axis_data_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END COMPONENT;


begin

Clk_Wizard: clk_wiz_0
   port map (  
   clk_out1 => clk_out_Sig,             
   locked => locked_Sig,
   clk_in1 => sys_clk
 );
    
DDS_0 : dds_compiler_0
  PORT MAP (
    aclk => clk_out_Sig,
    m_axis_data_tvalid => m_axis_data_tvalid_Sig,
    m_axis_data_tdata => Message_Tone
  ); 
  
Multiplier : mult_gen_0
  PORT MAP (
    CLK => clk_out_Sig,  
    A => Message_Tone,
    P => MessageMultiplied
  );

MessageMultipliedShifted <= MessageMultiplied(39 downto 32); 

AdderSub : c_addsub_0
  PORT MAP (
    A => MessageMultipliedShifted, 
    CLK => clk_out_Sig, 
    S => Fm_Plus_Carrier
 );
 

Fm_Plus_Carrier_Pudded <= "0000"&Fm_Plus_Carrier; 
 
 
DDS1 : dds_compiler_1
 PORT MAP (   
   aclk => clk_out_Sig,
   s_axis_phase_tvalid => '1',
   s_axis_phase_tdata => Fm_Plus_Carrier_Pudded,
   m_axis_data_tvalid => DDS1_tvalid_out,
   m_axis_data_tdata => ModulatedSignalOut
);

               
end behavioral; 
