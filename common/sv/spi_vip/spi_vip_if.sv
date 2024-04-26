interface spi_vip_if #(
  int CPOL=0,
  CPHA=0,
  INV_CS=0,
  DATA_DLENGTH=16,
  SLAVE_TSU=0,
  SLAVE_TH=0,
  MASTER_TSU=0,
  MASTER_TH=0,
  CS_TO_MISO=0
) ();
  logic sclk;
  wire  miso; // need net types here in case tb wants to tristate this
  wire  mosi; // need net types here in case tb wants to tristate this
  logic cs;

  // internal 
  logic intf_slave_mode;
  logic intf_master_mode;
  logic intf_monitor_mode;
  logic cs_active;
  localparam cs_active_level = (INV_CS) ? 1'b1 : 1'b0;



  // hack for parameterized edge. TODO: improve this
  logic sample_edge, drive_edge;
  assign sample_edge  = (CPOL^CPHA) ? !sclk : sclk;
  assign drive_edge   = (CPOL^CPHA) ? sclk : !sclk;
  assign cs_active = (cs == cs_active_level);

  clocking sample_cb @( posedge sample_edge);
    input #(SLAVE_TSU*1ns) mosi;
    input #(MASTER_TSU*1ns) miso;
  endclocking : sample_cb

  clocking drive_cb @( posedge drive_edge);
    output #(MASTER_TH*1ns) mosi;
    output #(SLAVE_TH*1ns) miso;
  endclocking : drive_cb

  clocking cs_cb @(cs);
    output #(CS_TO_MISO*1ns) miso;
  endclocking : cs_cb

  function void set_slave_mode();
    intf_slave_mode   = 1;
    intf_master_mode  = 0;
    intf_monitor_mode = 0;
  endfunction : set_slave_mode

  function void set_master_mode();
    intf_slave_mode   = 0;
    intf_master_mode  = 1;
    intf_monitor_mode = 0;
    $fatal("Unsupported mode master"); //FIXME
  endfunction : set_master_mode

  function void set_monitor_mode();
    intf_slave_mode   = 0;
    intf_master_mode  = 0;
    intf_monitor_mode = 1;
    $fatal("Unsupported mode monitor"); //FIXME
  endfunction : set_monitor_mode




  

endinterface