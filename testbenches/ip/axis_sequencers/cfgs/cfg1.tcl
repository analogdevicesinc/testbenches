global ad_project_params

# Source data generation mode

# 1) - 1 descriptor
# 2) - Multiple descriptors
# 3) - Infinite descriptors
set ad_project_params(SRC_DESCRIPTORS) 3

# #) - Inter-beat valid delays
set ad_project_params(SRC_TRANSACTION_DELAY) 0

# #) - Inter-descriptor valid delays
set ad_project_params(SRC_PACKET_DELAY) 0


# Destination data generation mode

# 1) - Backpressure
# 2) - No Backpressure
set ad_project_params(DEST_BACKPRESSURE) 2

# #) - Inter-beat ready delays high and low time
set ad_project_params(DEST_TRANSACTION_HIGH) 1
set ad_project_params(DEST_TRANSACTION_LOW) 5
