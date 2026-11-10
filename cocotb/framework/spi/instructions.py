"""SPI Engine 16-bit command encoding.

Mirrors the command decoder in ``spi_engine_execution.v``::

    inst = cmd[14:12]

    CMD_TRANSFER   = 3'b000
    CMD_CHIPSELECT = 3'b001
    CMD_WRITE      = 3'b010   (configuration register write)
    CMD_MISC       = 3'b011   (sync / sleep)
    CMD_CS_INV     = 3'b100

These encoders are the single source of truth shared by the stimulus and the
golden model, so a mis-encoded instruction can never silently agree with itself.
"""

from __future__ import annotations

# Instruction opcodes (cmd[14:12])
CMD_TRANSFER = 0b000
CMD_CHIPSELECT = 0b001
CMD_WRITE = 0b010
CMD_MISC = 0b011
CMD_CS_INV = 0b100

# MISC sub-op (cmd[8])
MISC_SYNC = 0
MISC_SLEEP = 1

# Configuration register addresses (cmd[10:8] for CMD_WRITE)
REG_CLK_DIV = 0b000
REG_CONFIG = 0b001
REG_WORD_LENGTH = 0b010
REG_SDI_LANE_CONFIG = 0b011
REG_SDO_LANE_CONFIG = 0b100


def _u(value, bits):
    if not (0 <= value < (1 << bits)):
        raise ValueError(f"value {value} does not fit in {bits} bits")
    return value


def _inst(op):
    return op << 12


def transfer(n_minus_1, *, write=True, read=False):
    """Transfer instruction.

    ``n_minus_1`` is the raw cmd[7:0] field; the engine transfers
    ``n_minus_1 + 1`` words (last_transfer = transfer_counter == cmd[7:0]).
    """
    cmd = _inst(CMD_TRANSFER)
    cmd |= (1 << 8) if write else 0
    cmd |= (1 << 9) if read else 0
    cmd |= _u(n_minus_1, 8)
    return cmd


def chipselect(cs_bits, *, delay=0):
    """Chip-select instruction. ``cs_bits`` drives cmd[NUM_OF_CS-1:0];
    ``delay`` is cmd[9:8] (0 => early-exit, no CS delay)."""
    cmd = _inst(CMD_CHIPSELECT)
    cmd |= _u(delay, 2) << 8
    cmd |= _u(cs_bits, 8)
    return cmd


def write_reg(reg, value):
    cmd = _inst(CMD_WRITE)
    cmd |= _u(reg, 3) << 8
    cmd |= _u(value, 8)
    return cmd


def config_clk_div(clk_div):
    return write_reg(REG_CLK_DIV, clk_div)


def config_spi_mode(*, cpha=0, cpol=0, three_wire=0, sdo_idle_state=0):
    val = (cpha & 1) | ((cpol & 1) << 1) | ((three_wire & 1) << 2) \
        | ((sdo_idle_state & 1) << 3)
    return write_reg(REG_CONFIG, val)


def config_word_length(word_length):
    return write_reg(REG_WORD_LENGTH, word_length)


def config_sdi_lane_mask(mask):
    return write_reg(REG_SDI_LANE_CONFIG, mask)


def config_sdo_lane_mask(mask):
    return write_reg(REG_SDO_LANE_CONFIG, mask)


def sync(sync_id):
    cmd = _inst(CMD_MISC)
    cmd |= MISC_SYNC << 8
    cmd |= _u(sync_id, 8)
    return cmd


def sleep(duration):
    cmd = _inst(CMD_MISC)
    cmd |= MISC_SLEEP << 8
    cmd |= _u(duration, 8)
    return cmd


def cs_invert(mask):
    cmd = _inst(CMD_CS_INV)
    cmd |= _u(mask, 8)
    return cmd


def decode(cmd):
    """Human-readable decode for logging/debug."""
    inst = (cmd >> 12) & 0b111
    if inst == CMD_TRANSFER:
        return (f"TRANSFER n={cmd & 0xFF} "
                f"w={(cmd >> 8) & 1} r={(cmd >> 9) & 1}")
    if inst == CMD_CHIPSELECT:
        return f"CHIPSELECT cs=0x{cmd & 0xFF:02x} delay={(cmd >> 8) & 3}"
    if inst == CMD_WRITE:
        reg = (cmd >> 8) & 0b111
        names = {REG_CLK_DIV: "CLK_DIV", REG_CONFIG: "CONFIG",
                 REG_WORD_LENGTH: "WORD_LENGTH",
                 REG_SDI_LANE_CONFIG: "SDI_LANE", REG_SDO_LANE_CONFIG: "SDO_LANE"}
        return f"WRITE {names.get(reg, reg)}=0x{cmd & 0xFF:02x}"
    if inst == CMD_MISC:
        sub = (cmd >> 8) & 1
        return (f"SLEEP {cmd & 0xFF}" if sub == MISC_SLEEP
                else f"SYNC id={cmd & 0xFF}")
    if inst == CMD_CS_INV:
        return f"CS_INV mask=0x{cmd & 0xFF:02x}"
    return f"UNKNOWN 0x{cmd:04x}"
