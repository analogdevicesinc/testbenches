/* Auto generated Register Map */
/* Fri May 28 12:27:32 2021 */

package adi_regmap_gpreg_pkg;
  import adi_regmap_pkg::*;


/* General Purpose Registers (axi_gpreg) */

  const reg_t AXI_GPREG_REG_IO_ENB = '{ 'h0400, "REG_IO_ENB" , '{
    "IO_ENB": '{ 31, 0, RW, 'h00000000 }}};
  `define SET_AXI_GPREG_REG_IO_ENB_IO_ENB(x) SetField(AXI_GPREG_REG_IO_ENB,"IO_ENB",x)
  `define GET_AXI_GPREG_REG_IO_ENB_IO_ENB(x) GetField(AXI_GPREG_REG_IO_ENB,"IO_ENB",x)

  const reg_t AXI_GPREG_REG_IO_OUT = '{ 'h0404, "REG_IO_OUT" , '{
    "IO_ENB": '{ 31, 0, RW, 'h00000000 }}};
  `define SET_AXI_GPREG_REG_IO_OUT_IO_ENB(x) SetField(AXI_GPREG_REG_IO_OUT,"IO_ENB",x)
  `define GET_AXI_GPREG_REG_IO_OUT_IO_ENB(x) GetField(AXI_GPREG_REG_IO_OUT,"IO_ENB",x)

  const reg_t AXI_GPREG_REG_IO_IN = '{ 'h0408, "REG_IO_IN" , '{
    "IO_IN": '{ 31, 0, RO, 'h00000000 }}};
  `define SET_AXI_GPREG_REG_IO_IN_IO_IN(x) SetField(AXI_GPREG_REG_IO_IN,"IO_IN",x)
  `define GET_AXI_GPREG_REG_IO_IN_IO_IN(x) GetField(AXI_GPREG_REG_IO_IN,"IO_IN",x)

  const reg_t AXI_GPREG_REG_CM_RESET = '{ 'h0800, "REG_CM_RESET" , '{
    "CM_RESET_N": '{ 0, 0, RW, 'h0 }}};
  `define SET_AXI_GPREG_REG_CM_RESET_CM_RESET_N(x) SetField(AXI_GPREG_REG_CM_RESET,"CM_RESET_N",x)
  `define GET_AXI_GPREG_REG_CM_RESET_CM_RESET_N(x) GetField(AXI_GPREG_REG_CM_RESET,"CM_RESET_N",x)

  const reg_t AXI_GPREG_REG_CM_COUNT = '{ 'h0808, "REG_CM_COUNT" , '{
    "CM_CLK_COUNT": '{ 31, 0, RO, 'h00000000 }}};
  `define SET_AXI_GPREG_REG_CM_COUNT_CM_CLK_COUNT(x) SetField(AXI_GPREG_REG_CM_COUNT,"CM_CLK_COUNT",x)
  `define GET_AXI_GPREG_REG_CM_COUNT_CM_CLK_COUNT(x) GetField(AXI_GPREG_REG_CM_COUNT,"CM_CLK_COUNT",x)


endpackage
