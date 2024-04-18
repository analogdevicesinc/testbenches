// TODO: not sure if this should be on interfaces.svh, but if so, maybe convert that to a package

import adi_spi_bfm_pkg::*;

interface spi_bfm_if `SPI_VIF_PARAM_DECL ();
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
    input #SLAVE_TSU mosi;
    input #MASTER_TSU miso;
  endclocking : sample_cb

  clocking drive_cb @( posedge drive_edge);
    output #MASTER_TH mosi;
    output #SLAVE_TH miso;
  endclocking : drive_cb

  clocking cs_cb @(cs);
    output #CS_TO_MISO miso;
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
    `ERROR(("Unsupported mode master")); //FIXME
  endfunction : set_master_mode

  function void set_monitor_mode();
    intf_slave_mode   = 0;
    intf_master_mode  = 0;
    intf_monitor_mode = 1;
    `ERROR(("Unsupported mode monitor")); //FIXME
  endfunction : set_monitor_mode




  

endinterface