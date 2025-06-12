; Not completely implemented, stucks at 138... why tf??
update_clock:
  lda SecondCounter
  sta param1
  lda #10
  sta param2
  jsr division

  lda result2

  cmp #0
  bne :+ 
    jsr load_digit_0
    jmp :++++++++++
  :
  cmp #1
  bne :+
    jsr load_digit_1
    jmp :+++++++++
  :
  cmp #2
  bne :+
    jsr load_digit_2
    jmp :++++++++
  :
  cmp #3
  bne :+
    jsr load_digit_3
    jmp :+++++++
  :
  cmp #4
  bne :+
    jsr load_digit_4
    jmp :++++++
  :
  cmp #5
  bne :+
    jsr load_digit_5
    jmp :+++++
  :
  cmp #6
  bne :+
    jsr load_digit_6
    jmp :++++
  :
  cmp #7
  bne :+
    jsr load_digit_7
    jmp :+++
  :
  cmp #8
  bne :+
    jsr load_digit_8
    jmp :++
  :
  cmp #9
  bne :+
    jsr load_digit_9
    jmp :+
  :
  jsr wait_for_vblank ; indispensable
  jsr render_sixth_digit

  lda result1
  sta param1
  lda #10
  sta param2
  jsr division

  lda result2

  cmp #0
  bne :+ 
    jsr load_digit_0
    jmp :++++++++++
  :
  cmp #1
  bne :+
    jsr load_digit_1
    jmp :+++++++++
  :
  cmp #2
  bne :+
    jsr load_digit_2
    jmp :++++++++
  :
  cmp #3
  bne :+
    jsr load_digit_3
    jmp :+++++++
  :
  cmp #4
  bne :+
    jsr load_digit_4
    jmp :++++++
  :
  cmp #5
  bne :+
    jsr load_digit_5
    jmp :+++++
  :
  cmp #6
  bne :+
    jsr load_digit_6
    jmp :++++
  :
  cmp #7
  bne :+
    jsr load_digit_7
    jmp :+++
  :
  cmp #8
  bne :+
    jsr load_digit_8
    jmp :++
  :
  cmp #9
  bne :+
    jsr load_digit_9
    jmp :+
  :
  ;jsr wait_for_vblank

  jsr render_fifth_digit

  lda result1

  cmp #0
  bne :+ 
    jsr load_digit_0
    jmp :++++++++++
  :
  cmp #1
  bne :+
    jsr load_digit_1
    jmp :+++++++++
  :
  cmp #2
  bne :+
    jsr load_digit_2
    jmp :++++++++
  :
  cmp #3
  bne :+
    jsr load_digit_3
    jmp :+++++++
  :
  cmp #4
  bne :+
    jsr load_digit_4
    jmp :++++++
  :
  cmp #5
  bne :+
    jsr load_digit_5
    jmp :+++++
  :
  cmp #6
  bne :+
    jsr load_digit_6
    jmp :++++
  :
  cmp #7
  bne :+
    jsr load_digit_7
    jmp :+++
  :
  cmp #8
  bne :+
    jsr load_digit_8
    jmp :++
  :
  cmp #9
  bne :+
    jsr load_digit_9
    jmp :+
  :
  ;jsr wait_for_vblank

  jsr render_fourth_digit
  rts