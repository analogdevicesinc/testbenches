global ad_project_params

#------------------------------------------------------------------------------
# AXI4 Stream VIP Configuration
#------------------------------------------------------------------------------

# Data width in bits (must be multiple of 8)
set ad_project_params(DATA_WIDTH) 32

# Enable TKEEP signal (0 - disabled, 1 - enabled)
set ad_project_params(TKEEP_EN) 1

# Enable TSTRB signal (0 - disabled, 1 - enabled)
set ad_project_params(TSTRB_EN) 0

# Enable TLAST signal (0 - disabled, 1 - enabled)
set ad_project_params(TLAST_EN) 1

# Enable TUSER signal (0 - disabled, 1 - enabled)
set ad_project_params(TUSER_EN) 0

# Enable TID signal (0 - disabled, 1 - enabled)
set ad_project_params(TID_EN) 0

# Enable TDEST signal (0 - disabled, 1 - enabled)
set ad_project_params(TDEST_EN) 0

# TUSER width in bits (1-8, only used if TUSER_EN is 1)
set ad_project_params(TUSER_WIDTH) 1

# TID width in bits (1-8, only used if TID_EN is 1)
set ad_project_params(TID_WIDTH) 1

# TDEST width in bits (1-8, only used if TDEST_EN is 1)
set ad_project_params(TDEST_WIDTH) 1
