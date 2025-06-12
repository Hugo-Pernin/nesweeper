draw_smiley:
  lda has_lost
  cmp #1
  bne :+
    ; if the player has lost
    lda #>$204f
    sta PPUADDR
    lda #<$204f
    sta PPUADDR
    lda #$54 ; changer la tile
    sta PPUDATA
    lda #$55 ; ici aussi
    sta PPUDATA
    lda #>$206f
    sta PPUADDR
    lda #<$206f
    sta PPUADDR
    lda #$64 ; changer la tile
    sta PPUDATA
    lda #$65 ; ici aussi
    sta PPUDATA
    jmp :+++
  :
  lda has_won
  cmp #1
  bne :+
    ; if the player has won
    lda #>$204f
    sta PPUADDR
    lda #<$204f
    sta PPUADDR
    lda #$56 ; changer la tile
    sta PPUDATA
    lda #$57 ; ici aussi
    sta PPUDATA
    lda #>$206f
    sta PPUADDR
    lda #<$206f
    sta PPUADDR
    lda #$66 ; changer la tile
    sta PPUDATA
    lda #$67 ; ici aussi
    sta PPUDATA
    jmp :++
  :
    ; if the player hasn't lost & hasn't won
    lda #>$204f
    sta PPUADDR
    lda #<$204f
    sta PPUADDR
    lda #$52 ; changer la tile
    sta PPUDATA
    lda #$53 ; ici aussi
    sta PPUDATA
    lda #>$206f
    sta PPUADDR
    lda #<$206f
    sta PPUADDR
    lda #$62 ; changer la tile
    sta PPUDATA
    lda #$63 ; ici aussi
    sta PPUDATA
  :

  jsr reset_scroll
  jsr enable_rendering
  rts