/* Auto generated Register Map */
/* Fri Jul  6 13:42:34 2018 */

package adi_regmap_doffload_pkg;

  class adi_regmap_doffload extends adi_regmap;
  
  /* Data Offload IP (data_offload) */
  
    const reg_t VERSION = '{ 'h0000, "VERSION" , RO, '{
      "VERSION_MAJOR": '{ 31, 16, 'h0000 },
      "VERSION_MINOR": '{ 15, 8, 'h01 },
      "VERSION_PATCH": '{ 7, 0, 'h00 }}};
    const reg_t PERIPHERAL_ID = '{ 'h0004, "PERIPHERAL_ID" , RO, '{
      "PERIPHERAL_ID": '{ 31, 0, 'h0000 }}};
    const reg_t SCRATCH = '{ 'h0008, "SCRATCH" , RO, '{
      "SCRATCH": '{ 31, 0, 'h0000 }}};
    const reg_t IDENTIFICATION = '{ 'h000c, "IDENTIFICATION" , RO, '{
      "IDENTIFICATION": '{ 31, 0, 'h44414F46 }}};
    const reg_t CONFIGURATION = '{ 'h0010, "CONFIGURATION" , RO, '{
      "MEMORY_TYPE": '{ 2, 2, 'h00 },
      "TX_PATH": '{ 1, 1, 'h01 },
      "RX_PATH": '{ 0, 0, 'h01 }}};
    const reg_t CONFIG_RX_SIZE_0 = '{ 'h0014, "CONFIG_RX_SIZE_0" , RO, '{
      "CONFIG_RX_SIZE_LSB": '{ 31, 0, 'h400 }}};
    const reg_t CONFIG_RX_SIZE_1 = '{ 'h0018, "CONFIG_RX_SIZE_1" , RO, '{
      "CONFIG_RX_SIZE_MSB": '{ 1, 0, 'h0 }}};
    const reg_t CONFIG_TX_SIZE_0 = '{ 'h001c, "CONFIG_TX_SIZE_0" , RO, '{
      "CONFIG_TX_SIZE_LSB": '{ 31, 0, 'h400 }}};
    const reg_t CONFIG_TX_SIZE_1 = '{ 'h0020, "CONFIG_TX_SIZE_1" , RO, '{
      "CONFIG_TX_SIZE_MSB": '{ 1, 0, 'h0 }}};
    const reg_t MEM_PHY_STATE = '{ 'h0080, "MEM_PHY_STATE" , RO, '{
      "CALIBRATION_COMPLETE": '{ 0, 0, 'h0 }}};
    const reg_t RESET_OFFLAOD = '{ 'h0084, "RESET_OFFLAOD" , RO, '{
      "RESET_TX": '{ 1, 1, 'h0 },
      "RESET_RX": '{ 0, 0, 'h0 }}};
    const reg_t RX_CONTROL_REG = '{ 'h0088, "RX_CONTROL_REG" , RW, '{
      "OFFLOAD_BYPASS": '{ 0, 0, 'h0 }}};
    const reg_t TX_CONTROL_REG = '{ 'h008c, "TX_CONTROL_REG" , RW, '{
      "ONESHOT_ENABLE": '{ 1, 1, 'h0 },
      "OFFLOAD_BYPASS": '{ 0, 0, 'h0 }}};
    const reg_t SYNC_OFFLOAD = '{ 'h0100, "SYNC_OFFLOAD" , RW, '{
      "TX_SYNC": '{ 1, 1, 'h0 },
      "RX_SYNC": '{ 0, 0, 'h0 }}};
    const reg_t SYNC_RX_CONFIG = '{ 'h0104, "SYNC_RX_CONFIG" , RW, '{
      "SYNC_CONFIG": '{ 1, 0, 'h0 }}};
    const reg_t SYNC_TX_CONFIG = '{ 'h0108, "SYNC_TX_CONFIG" , RW, '{
      "SYNC_CONFIG": '{ 1, 0, 'h0 }}};
    const reg_t RX_FSM_BDG = '{ 'h0200, "RX_FSM_BDG" , RW, '{
      "FSM_CONTROL": '{ 15, 8, 'h0 },
      "FSM_STATE": '{ 7, 0, 'h0 }}};
    const reg_t TX_FSM_BDG = '{ 'h0204, "TX_FSM_BDG" , RW, '{
      "NO_TLAST": '{ 16, 16, 'h0 },
      "FSM_CONTROL": '{ 15, 8, 'h0 },
      "FSM_STATE": '{ 7, 0, 'h0 }}};
    const reg_t RX_SAMPLE_COUNT_LSB = '{ 'h0208, "RX_SAMPLE_COUNT_LSB" , RW, '{
      "RX_SAMPLE_COUNT_LSB": '{ 31, 0, 'h0 }}};
    const reg_t RX_SAMPLE_COUNT_MSB = '{ 'h020c, "RX_SAMPLE_COUNT_MSB" , RO, '{
      "RX_SAMPLE_COUNT_MSB": '{ 31, 0, 'h0 }}};
    const reg_t TX_SAMPLE_COUNT_LSB = '{ 'h0210, "TX_SAMPLE_COUNT_LSB" , RO, '{
      "TX_SAMPLE_COUNT_LSB": '{ 31, 0, 'h0 }}};
    const reg_t TX_SAMPLE_COUNT_MSB = '{ 'h0214, "TX_SAMPLE_COUNT_MSB" , RO, '{
      "TX_SAMPLE_COUNT_MSB": '{ 31, 0, 'h0 }}};
  
  function new();
    regmap_array = new[21] ({
  		VERSION,
  		PERIPHERAL_ID,
  		SCRATCH,
  		IDENTIFICATION,
  		CONFIGURATION,
  		CONFIG_RX_SIZE_0,
  		CONFIG_RX_SIZE_1,
  		CONFIG_TX_SIZE_0,
  		CONFIG_TX_SIZE_1,
  		MEM_PHY_STATE,
  		RESET_OFFLAOD,
  		RX_CONTROL_REG,
  		TX_CONTROL_REG,
  		SYNC_OFFLOAD,
  		SYNC_RX_CONFIG,
  		SYNC_TX_CONFIG,
  		RX_FSM_BDG,
  		TX_FSM_BDG,
  		RX_SAMPLE_COUNT_LSB,
  		RX_SAMPLE_COUNT_MSB,
  		TX_SAMPLE_COUNT_LSB,
  		TX_SAMPLE_COUNT_MSB
  });
  endfunction
  
  endclass

endpackage
