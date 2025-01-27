// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2014 - 2025 Analog Devices, Inc. All rights reserved.
//
// In this HDL repository, there are many different and unique modules, consisting
// of various HDL (Verilog or VHDL) components. The individual modules are
// developed independently, and may be accompanied by separate and unique license
// terms.
//
// The user should read each of these license terms, and understand the
// freedoms and responsabilities that he or she has by using this source/core.
//
// This core is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
// A PARTICULAR PURPOSE.
//
// Redistribution and use of source or resulting binaries, with or without modification
// of this file, are permitted under one of the following two license terms:
//
//   1. The GNU General Public License version 2 as published by the
//      Free Software Foundation, which can be found in the top level directory
//      of this repository (LICENSE_GPL2), and also online at:
//      <https://www.gnu.org/licenses/old-licenses/gpl-2.0.html>
//
// OR
//
//   2. An ADI specific BSD license, which can be found in the top level directory
//      of this repository (LICENSE_ADIBSD), and also on-line at:
//      https://github.com/analogdevicesinc/hdl/blob/main/LICENSE_ADIBSD
//      This will allow to generate bit files and not release the source code,
//      as long as it attaches to an ADI device.
//
// ***************************************************************************
// ***************************************************************************

`include "utils.svh"

package logger_pkg;

  typedef enum {
    ADI_VERBOSITY_NONE = 0,   // highest priority, test passed message, randomization state, cannot be disabled
    ADI_VERBOSITY_LOW = 1,    // test_program level debugging
    ADI_VERBOSITY_MEDIUM = 2, // driver level debugging
    ADI_VERBOSITY_HIGH = 3    // VIP, regmap, utilities level debugging
  } adi_verbosity_t;

  adi_verbosity_t verbosity = ADI_VERBOSITY_HIGH;

  function void PrintInfo(
    input string inStr,
    input adi_verbosity_t msgVerborisity);

    if (verbosity >= msgVerborisity) begin
      $display("[INFO] @ %0t: %s", $time, inStr);
    end
  endfunction: PrintInfo

  function void PrintWarning(input string inStr);
    $warning("%s", inStr);
  endfunction: PrintWarning

  function void PrintError(input string inStr);
    $error("%s", inStr);
  endfunction: PrintError

  function void PrintFatal(input string inStr);
    $fatal(1, "%s", inStr);
  endfunction: PrintFatal

  function void setLoggerVerbosity(input adi_verbosity_t value);
    verbosity = value;
  endfunction: setLoggerVerbosity

endpackage
