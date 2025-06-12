draw_main_menu_cursor:
  ; Calculate the cursor address
  lda #$22
  sta tilemap_address
  lda main_menu_selection
  sta param1
  lda #64
  sta param2
  jsr multiplication
  lda result1
  clc
  adc #$cc
  sta tilemap_address+1
  jsr disable_rendering

  ; Delete the other cursors
  lda #>$220c
  sta PPUADDR
  lda #<$220c
  sta PPUADDR
  lda #$00
  sta PPUDATA
  lda #>$224c
  sta PPUADDR
  lda #<$224c
  sta PPUADDR
  lda #$00
  sta PPUDATA
  lda #>$228c
  sta PPUADDR
  lda #<$228c
  sta PPUADDR
  lda #$00
  sta PPUDATA
  lda #>$22cc
  sta PPUADDR
  lda #<$22cc
  sta PPUADDR
  lda #$00
  sta PPUDATA

  ; Draw the cursor
  lda tilemap_address
  sta PPUADDR
  lda tilemap_address+1
  sta PPUADDR
  lda #$4c
  sta PPUDATA

  jsr reset_scroll
  jsr enable_rendering
  rts