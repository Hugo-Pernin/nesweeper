check_up_left:
  txa ; does this delete x?
  sec
  sbc width
  sbc #1
  tay
  lda tiles, y
  and #%00010000
  beq :+
    ; if bit 4 == 1 / if tile has a mine
    inc tiles, x
  :
  rts

check_up:
  txa
  sec
  sbc width
  tay
  lda tiles, y
  and #%00010000
  beq :+
    ; if bit 4 == 1 / if tile has a mine
    inc tiles, x
  :
  rts

check_up_right:
  txa
  sec
  sbc width
  clc
  adc #1
  tay
  lda tiles, y
  and #%00010000
  beq :+
    ; if bit 4 == 1 / if tile has a mine
    inc tiles, x
  :
  rts

check_left:
  txa
  sec
  sbc #1
  tay
  lda tiles, y
  and #%00010000
  beq :+
    ; if bit 4 == 1 / if tile has a mine
    inc tiles, x
  :
  rts

check_right:
  txa
  clc
  adc #1
  tay
  lda tiles, y
  and #%00010000
  beq :+
    ; if bit 4 == 1 / if tile has a mine
    inc tiles, x
  :
  rts

check_down_left:
  txa
  clc
  adc width
  sec
  sbc #1
  tay
  lda tiles, y
  and #%00010000
  beq :+
    ; if bit 4 == 1 / if tile has a mine
    inc tiles, x
  :
  rts

check_down:
  txa
  clc
  adc width
  tay
  lda tiles, y
  and #%00010000
  beq :+
    ; if bit 4 == 1 / if tile has a mine
    inc tiles, x
  :
  rts

check_down_right:
  txa
  clc
  adc width
  adc #1
  tay
  lda tiles, y
  and #%00010000
  beq :+
    ; if bit 4 == 1 / if tile has a mine
    inc tiles, x
  :
  rts