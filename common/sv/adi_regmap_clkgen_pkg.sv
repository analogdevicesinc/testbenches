/* Auto generated Register Map */
/* Fri May 28 12:27:32 2021 */

package adi_regmap_clkgen_pkg;
  import adi_regmap_pkg::*;


/* Clock Generator (axi_clkgen) */

  const reg_t AXI_CLKGEN_REG_RSTN = '{ 'h0040, "REG_RSTN" , '{
    "MMCM_RSTN": '{ 1, 1, RW, 'h0 },
    "RSTN": '{ 0, 0, RW, 'h0 }}};
  `define SET_AXI_CLKGEN_REG_RSTN_MMCM_RSTN(x) SetField(AXI_CLKGEN_REG_RSTN,"MMCM_RSTN",x)
  `define GET_AXI_CLKGEN_REG_RSTN_MMCM_RSTN(x) GetField(AXI_CLKGEN_REG_RSTN,"MMCM_RSTN",x)
  `define SET_AXI_CLKGEN_REG_RSTN_RSTN(x) SetField(AXI_CLKGEN_REG_RSTN,"RSTN",x)
  `define GET_AXI_CLKGEN_REG_RSTN_RSTN(x) GetField(AXI_CLKGEN_REG_RSTN,"RSTN",x)

  const reg_t AXI_CLKGEN_REG_CLK_SEL = '{ 'h0044, "REG_CLK_SEL" , '{
    "CLK_SEL": '{ 0, 0, RW, 'h0 }}};
  `define SET_AXI_CLKGEN_REG_CLK_SEL_CLK_SEL(x) SetField(AXI_CLKGEN_REG_CLK_SEL,"CLK_SEL",x)
  `define GET_AXI_CLKGEN_REG_CLK_SEL_CLK_SEL(x) GetField(AXI_CLKGEN_REG_CLK_SEL,"CLK_SEL",x)

  const reg_t AXI_CLKGEN_REG_MMCM_STATUS = '{ 'h005c, "REG_MMCM_STATUS" , '{
    "MMCM_LOCKED": '{ 0, 0, RO, 'h0 }}};
  `define SET_AXI_CLKGEN_REG_MMCM_STATUS_MMCM_LOCKED(x) SetField(AXI_CLKGEN_REG_MMCM_STATUS,"MMCM_LOCKED",x)
  `define GET_AXI_CLKGEN_REG_MMCM_STATUS_MMCM_LOCKED(x) GetField(AXI_CLKGEN_REG_MMCM_STATUS,"MMCM_LOCKED",x)

  const reg_t AXI_CLKGEN_REG_DRP_CNTRL = '{ 'h0070, "REG_DRP_CNTRL" , '{
    "DRP_RWN": '{ 28, 28, RW, 'h0 },
    "DRP_ADDRESS": '{ 27, 16, RW, 'h000 },
    "DRP_WDATA": '{ 15, 0, RW, 'h0000 }}};
  `define SET_AXI_CLKGEN_REG_DRP_CNTRL_DRP_RWN(x) SetField(AXI_CLKGEN_REG_DRP_CNTRL,"DRP_RWN",x)
  `define GET_AXI_CLKGEN_REG_DRP_CNTRL_DRP_RWN(x) GetField(AXI_CLKGEN_REG_DRP_CNTRL,"DRP_RWN",x)
  `define SET_AXI_CLKGEN_REG_DRP_CNTRL_DRP_ADDRESS(x) SetField(AXI_CLKGEN_REG_DRP_CNTRL,"DRP_ADDRESS",x)
  `define GET_AXI_CLKGEN_REG_DRP_CNTRL_DRP_ADDRESS(x) GetField(AXI_CLKGEN_REG_DRP_CNTRL,"DRP_ADDRESS",x)
  `define SET_AXI_CLKGEN_REG_DRP_CNTRL_DRP_WDATA(x) SetField(AXI_CLKGEN_REG_DRP_CNTRL,"DRP_WDATA",x)
  `define GET_AXI_CLKGEN_REG_DRP_CNTRL_DRP_WDATA(x) GetField(AXI_CLKGEN_REG_DRP_CNTRL,"DRP_WDATA",x)

  const reg_t AXI_CLKGEN_REG_DRP_STATUS = '{ 'h0074, "REG_DRP_STATUS" , '{
    "MMCM_LOCKED": '{ 17, 17, RO, 'h0 },
    "DRP_STATUS": '{ 16, 16, RO, 'h0 },
    "DRP_RDATA": '{ 15, 0, RO, 'h0000 }}};
  `define SET_AXI_CLKGEN_REG_DRP_STATUS_MMCM_LOCKED(x) SetField(AXI_CLKGEN_REG_DRP_STATUS,"MMCM_LOCKED",x)
  `define GET_AXI_CLKGEN_REG_DRP_STATUS_MMCM_LOCKED(x) GetField(AXI_CLKGEN_REG_DRP_STATUS,"MMCM_LOCKED",x)
  `define SET_AXI_CLKGEN_REG_DRP_STATUS_DRP_STATUS(x) SetField(AXI_CLKGEN_REG_DRP_STATUS,"DRP_STATUS",x)
  `define GET_AXI_CLKGEN_REG_DRP_STATUS_DRP_STATUS(x) GetField(AXI_CLKGEN_REG_DRP_STATUS,"DRP_STATUS",x)
  `define SET_AXI_CLKGEN_REG_DRP_STATUS_DRP_RDATA(x) SetField(AXI_CLKGEN_REG_DRP_STATUS,"DRP_RDATA",x)
  `define GET_AXI_CLKGEN_REG_DRP_STATUS_DRP_RDATA(x) GetField(AXI_CLKGEN_REG_DRP_STATUS,"DRP_RDATA",x)

  const reg_t AXI_CLKGEN_REG_FPGA_VOLTAGE = '{ 'h0140, "REG_FPGA_VOLTAGE" , '{
    "FPGA_VOLTAGE": '{ 15, 0, RO, 'h0 }}};
  `define SET_AXI_CLKGEN_REG_FPGA_VOLTAGE_FPGA_VOLTAGE(x) SetField(AXI_CLKGEN_REG_FPGA_VOLTAGE,"FPGA_VOLTAGE",x)
  `define GET_AXI_CLKGEN_REG_FPGA_VOLTAGE_FPGA_VOLTAGE(x) GetField(AXI_CLKGEN_REG_FPGA_VOLTAGE,"FPGA_VOLTAGE",x)


endpackage
