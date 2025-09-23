`define GPIO_REGMAP_BA        32'h50040000
`define GPIO_REG_RST          (`GPIO_REGMAP_BA + 4 * 32'h20)
`define GPIO_REG_DATA         (`GPIO_REGMAP_BA + 4 * 32'h21)
`define GPIO_REG_INPUT        (`GPIO_REGMAP_BA + 4 * 32'h22)
`define GPIO_REG_TRI          (`GPIO_REGMAP_BA + 4 * 32'h24)
`define GPIO_REG_IRQ_MASK     (`GPIO_REGMAP_BA + 4 * 32'h23)
`define GPIO_REG_IRQ_CLEAR    (`GPIO_REGMAP_BA + 4 * 32'h11)