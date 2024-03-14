global ad_project_params

# Source data generation mode

# 1) - 1 descriptor
# 2) - Multiple descriptors
# 3) - Infinite descriptors
set ad_project_params(SRC_DESCRIPTORS) 1

# #) - Inter-beat valid delays
set ad_project_params(SRC_BEAT_DELAY) 0

# #) - Inter-descriptor valid delays
set ad_project_params(SRC_DESCRIPTOR_DELAY) 0


# Destination data generation mode

# 1) - Backpressure
# 2) - No Backpressure
set ad_project_params(DEST_BACKPRESSURE) 2

# #) - Inter-beat ready delays high and low time
set ad_project_params(DEST_BEAT_DELAY_HIGH) 1
set ad_project_params(DEST_BEAT_DELAY_LOW) 5
