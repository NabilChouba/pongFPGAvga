
library ieee;
use ieee.std_logic_1164.all;
entity top is
   port (
      clk,reset: in std_logic;
	   kbdata    : in  STD_LOGIC; -- input keyboard data 
	   kbclk     : in  STD_LOGIC; -- input keyboard clock 
      hsync, vsync: out  std_logic;
      rgb: out std_logic_vector(2 downto 0)
   );
end top;

architecture arch of top is

component keyPS2controller 
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
			  ack : in  STD_LOGIC;
           kbdata : in  STD_LOGIC;
           kbclk : in  STD_LOGIC;
			  data_ready : out  STD_LOGIC;
			  kbdatarx : out  STD_LOGIC_VECTOR (7 downto 0)
  );
end component;


   signal pixel_x, pixel_y: std_logic_vector (9 downto 0);
   signal video_on, pixel_tick: std_logic;
   signal rgb_reg, rgb_next: std_logic_vector(2 downto 0);
	
	 -- keyboard signal
 signal kb_ack : STD_LOGIC;
 signal kb_data_ready : STD_LOGIC;
 signal kb_kbdatarx : STD_LOGIC_VECTOR (7 downto 0);

signal btn : STD_LOGIC_VECTOR (1 downto 0);

begin
  u_keyPS2controller:  keyPS2controller 
  port map( 
	    clk => clk,
       rst => reset,
	    ack => kb_ack,
       kbdata =>kbdata,
       kbclk =>kbclk,
		 data_ready =>kb_data_ready,
		 kbdatarx =>kb_kbdatarx
  );

-- left detection signal "Q" code is hex 15
btn(0)  <= '1' when kb_kbdatarx = x"15" else
           '0';

-- right detection signal "W" code is hex 1D
btn(1)   <= '1' when kb_kbdatarx = x"1D" else
            '0';


   -- instantiate VGA sync
   vga_sync_unit: entity work.vga_sync
      port map(clk=>clk, reset=>reset,
               video_on=>video_on, p_tick=>pixel_tick,
               hsync=>hsync, vsync=>vsync,
               pixel_x=>pixel_x, pixel_y=>pixel_y);
   -- instantiate graphic generator
   pong_graph_an_unit: entity work.pong_graph_animate
      port map (clk=>clk, reset=>reset,
                btn=>btn, video_on=>video_on,
                pixel_x=>pixel_x, pixel_y=>pixel_y,
                graph_rgb=>rgb_next);
   -- rgb buffer
   process (clk)
   begin
      if (clk'event and clk='1') then
         if (pixel_tick='1') then
            rgb_reg <= rgb_next;
         end if;
      end if;
   end process;
   rgb <= rgb_reg;
end arch;