; Renders a digit in the 1st slot
; param1: tile index of top-half
; param2: tile index of bottom-half
render_first_digit:
  jsr disable_rendering

  ; Top-half
  lda #$20
  sta $2006
  lda #$42
  sta $2006
  lda param1
  sta $2007
  ; Bottom-half
  lda #$20
  sta $2006
  lda #$62
  sta $2006
  lda param2
  sta $2007

  jsr enable_rendering
  jsr reset_scroll
  rts

; Renders a digit in the 2nd slot
; param1: tile index of top-half
; param2: tile index of bottom-half
render_second_digit:
  jsr disable_rendering

  ; Top-half
  lda #$20
  sta $2006
  lda #$43
  sta $2006
  lda param1
  sta $2007
  ; Bottom-half
  lda #$20
  sta $2006
  lda #$63
  sta $2006
  lda param2
  sta $2007

  jsr enable_rendering
  jsr reset_scroll
  rts

; Renders a digit in the 3rd slot
; param1: tile index of top-half
; param2: tile index of bottom-half
render_third_digit:
  jsr disable_rendering

  ; Top-half
  lda #$20
  sta $2006
  lda #$44
  sta $2006
  lda param1
  sta $2007
  ; Bottom-half
  lda #$20
  sta $2006
  lda #$64
  sta $2006
  lda param2
  sta $2007

  jsr enable_rendering
  jsr reset_scroll
  rts

; Renders a digit in the 4th slot (timer hundreds)
; param1: tile index of top-half
; param2: tile index of bottom-half
render_fourth_digit:
  jsr disable_rendering

  ; Top-half
  lda #$20
  sta $2006
  lda #$5b
  sta $2006
  lda param1
  sta $2007
  ; Bottom-half
  lda #$20
  sta $2006
  lda #$7b
  sta $2006
  lda param2
  sta $2007

  jsr enable_rendering
  jsr reset_scroll
  rts

; Renders a digit in the 5th slot (timer tens)
; param1: tile index of top-half
; param2: tile index of bottom-half
render_fifth_digit:
  jsr disable_rendering

  ; Top-half
  lda #$20
  sta $2006
  lda #$5c
  sta $2006
  lda param1
  sta $2007
  ; Bottom-half
  lda #$20
  sta $2006
  lda #$7c
  sta $2006
  lda param2
  sta $2007

  jsr enable_rendering
  jsr reset_scroll
  rts

; Renders a digit in the 6th slot (timer units)
; param1: tile index of top-half
; param2: tile index of bottom-half
render_sixth_digit:
  jsr disable_rendering

  ; Top-half
  lda #$20
  sta $2006
  lda #$5d
  sta $2006
  lda param1
  sta $2007
  ; Bottom-half
  lda #$20
  sta $2006
  lda #$7d
  sta $2006
  lda param2
  sta $2007

  jsr enable_rendering
  jsr reset_scroll
  rts

; Loads the digit tiles indexes in param1 and param2
load_digit_0:
  lda #$20
  sta param1
  lda #$27
  sta param2
  rts
load_digit_1:
  lda #$21
  sta param1
  lda #$28
  sta param2
  rts
load_digit_2:
  lda #$22
  sta param1
  lda #$29
  sta param2
  rts
load_digit_3:
  lda #$22
  sta param1
  lda #$2a
  sta param2
  rts
load_digit_4:
  lda #$23
  sta param1
  lda #$2b
  sta param2
  rts
load_digit_5:
  lda #$24
  sta param1
  lda #$2a
  sta param2
  rts
load_digit_6:
  lda #$24
  sta param1
  lda #$2c
  sta param2
  rts
load_digit_7:
  lda #$25
  sta param1
  lda #$28
  sta param2
  rts
load_digit_8:
  lda #$26
  sta param1
  lda #$2c
  sta param2
  rts
load_digit_9:
  lda #$26
  sta param1
  lda #$2a
  sta param2
  rts