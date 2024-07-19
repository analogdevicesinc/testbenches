package spi_engine_instr_pkg;
// Chip select instructions
`define INST_CS             (32'h0000_1000)
`define SET_CS(b)           (`INST_CS | (b & 8'hFF))
`define SET_CS_DELAY(m,d)   (`INST_CS | ((d & 2'h3) << 8) | (m & 8'hFF))
`define INST_CS_INV         (32'h0000_4000)
`define SET_CS_INV_MASK(m)  (`INST_CS_INV | (m & 8'hFF))

// Transfer instructions
`define INST_WR         (32'h0000_0100 | (`NUM_OF_WORDS-1))
`define INST_RD         (32'h0000_0200 | (`NUM_OF_WORDS-1))
`define INST_WRD        (32'h0000_0300 | (`NUM_OF_WORDS-1))

// Configuration register instructions
`define INST_CFG        (32'h0000_2100 | (`SDO_IDLE_STATE << 3) | (`THREE_WIRE << 2) | (`CPOL << 1) | `CPHA)
`define INST_PRESCALE   (32'h0000_2000 | `CLOCK_DIVIDER)
`define INST_DLENGTH    (32'h0000_2200 | `DATA_DLENGTH)
`define SET_DLENGTH(d)  (`INST_DLENGTH | (d & 8'hFF))

// Synchronization
`define INST_SYNC       (32'h0000_3000)

// Sleep instruction
`define INST_SLEEP      (32'h0000_3100)
`define SLEEP(a)        (`INST_SLEEP | (a & 8'hFF))

endpackage