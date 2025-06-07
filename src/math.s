; Little maths library that I made

; Multiplies two 1-byte numbers without modifying the parameters
; param1: first factor
; param2: second factor
; result1: param1 * param2 (between 0 and 255)
multiplication:
  ; checks if the first factor is equal to 0
  lda param1
  cmp #0
  bne :+
    lda #0
    jmp multiplication_end
  :
  ; checks if the second factor is equal to 0
  lda param2
  cmp #0
  bne :+
    lda #0
    jmp multiplication_end
  :
  lda #0
  ldx param1
multiplication_loop:
  clc
  adc param2
  dex
  cpx #0
  bne multiplication_loop
multiplication_end:
  sta result1
  rts

; Does an euclidean division between two 1-byte numbers without modfying the parameters
; param1: dividend
; param2: divisor
; result1: quotient
; result2: remainder
division:
  lda #0
  sta result1
  lda param1
division_loop:
  cmp param2
  bmi :+ ; if param1 >= param2
    inc result1
    sec
    sbc param2
    jmp division_loop
  :
  sta result2
  rts