global ad_project_params

set tdd_cfg [list \
  ID 0 \
  CHANNEL_COUNT 8 \
  REGISTER_WIDTH 32 \
  BURST_COUNT_WIDTH 32 \
  SYNC_EXTERNAL 1 \
  SYNC_INTERNAL 1 \
  SYNC_EXTERNAL_CDC 1 \
  SYNC_COUNT_WIDTH 64 \
  ]

set ad_project_params(tdd_cfg) $tdd_cfg