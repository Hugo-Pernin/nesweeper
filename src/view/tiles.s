update_tiles:
  lda #>$20c2
  sta tilemap_address
  lda #<$20c2
  sta tilemap_address+1
  ldx #0
  
  jsr disable_rendering
  lda #>$20c2
  sta PPUADDR
  lda #<$20c2
  sta PPUADDR
update_tiles_loop:
  lda tiles, X
  and #%01000000
  bne :++
    ; if bit 6 == 0 / if is not discovered
    lda tiles, X
    and #%00100000
    beq :+
      ; if bit 5 == 1 / if has flag
      lda #$02 ; flag tile
      sta param1
      jmp :++++
    :
    lda #$01
    sta param1
    jmp :+++
  :
  lda tiles, x
  and #%00010000
  beq :+
    ; if bit 4 == 1 / if has a mine
    lda #$0c
    sta param1
    lda #1
    sta has_lost ; is a mine is shown, the player has lost
    jmp :++
  :
  lda tiles, X
  and #%00001111 ; we keep only the 4 last bits (number of mines)
  clc
  adc #3 ; offset of the nametable
  sta param1
  :

  lda param1
  sta PPUDATA
  inx

  ; check if we need to change line
  stx param1
  lda width
  sta param2
  jsr division
  lda result2
  cmp #0
  bne :++
    lda tilemap_address+1
    clc
    adc #32 ; we add 32 = a line
    sta tilemap_address+1
    bcc :+ ; if carry is clear, we do nothing
      inc tilemap_address ; else we add 1 to the high byte
    :
    lda tilemap_address
    sta PPUADDR
    lda tilemap_address+1
    sta PPUADDR
  :

  cpx number_of_tiles
  bne update_tiles_loop
  jsr draw_smiley
  rts