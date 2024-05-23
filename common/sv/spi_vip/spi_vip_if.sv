`include "utils.svh"

interface spi_vip_if #(
  int CPOL              =0,
      CPHA              =0,
      INV_CS            =0,
      DATA_DLENGTH      =16,
      SLAVE_TIN         =0,
      SLAVE_TOUT        =0,
      MASTER_TIN        =0,
      MASTER_TOUT       =0,
      CS_TO_MISO        =0,
      DEFAULT_MISO_DATA ='hCAFE
) ();
  logic sclk;
  wire  miso; // need net types here in case tb wants to tristate this
  wire  mosi; // need net types here in case tb wants to tristate this
  logic cs;

  import logger_pkg::*;

  // internal 
  logic intf_slave_mode;
  logic intf_master_mode;
  logic intf_monitor_mode;
  logic miso_oen;
  logic miso_drive;
  logic cs_active;
  logic mosi_delayed;
  localparam CS_ACTIVE_LEVEL = (INV_CS) ? 1'b1 : 1'b0;

  // hack for parameterized edge. TODO: improve this
  logic sample_edge, drive_edge;
  assign sample_edge  = (CPOL^CPHA) ? !sclk : sclk;
  assign drive_edge   = (CPOL^CPHA) ? sclk : !sclk;
  assign cs_active = (cs == CS_ACTIVE_LEVEL);

  // miso tri-state handling
  assign miso = (!intf_slave_mode)  ? 'z          
              : (miso_oen)          ? miso_drive  
                /*default*/         : 'z;

  // mosi delay
  assign #(SLAVE_TIN*1ns) mosi_delayed =  mosi;

  function void set_slave_mode();
    intf_slave_mode   = 1;
    intf_master_mode  = 0;
    intf_monitor_mode = 0;
  endfunction : set_slave_mode

  function void set_master_mode();
    intf_slave_mode   = 0;
    intf_master_mode  = 1;
    intf_monitor_mode = 0;
    `ERROR(("Unsupported mode master")); //TODO
  endfunction : set_master_mode

  function void set_monitor_mode();
    intf_slave_mode   = 0;
    intf_master_mode  = 0;
    intf_monitor_mode = 1;
    `ERROR(("Unsupported mode monitor")); //TODO
  endfunction : set_monitor_mode

endinterface