draw_cursor:
  ldy #0

  lda cursor_y
  sta param1
  lda #8
  sta param2
  jsr multiplication
  lda result1
  clc
  adc #48
  ;lda #48
  sta oam, y
  iny

  lda #1
  sta oam, y
  iny

  lda #%00000000
  sta oam, y
  iny

  lda cursor_x
  sta param1
  lda #8
  sta param2
  jsr multiplication
  lda result1
  clc
  adc #16
  ;lda #16
  sta oam, y
  iny

  lda #$02
  sta OAMDMA
  rts 