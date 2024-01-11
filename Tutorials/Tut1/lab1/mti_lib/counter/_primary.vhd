library verilog;
use verilog.vl_types.all;
entity counter is
    port(
        clock           : in     vl_logic;
        \in\            : in     vl_logic_vector(3 downto 0);
        latch           : in     vl_logic;
        dec             : in     vl_logic;
        zero            : out    vl_logic
    );
end counter;
