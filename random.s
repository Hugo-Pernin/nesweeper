; Pseudo-random generation subroutine found here: https://codebase64.org/doku.php?id=base:small_fast_8-bit_prng

; Generates a number using a seed
; param1: seed
; result1: generated number
rng:
  lda param1
  beq doEor
  asl ; shift left
  beq noEor ; if the input was $80, skip the EOR
  bcc noEor
    ; if the high bit was set
    doEor:
      eor #$1d
  noEor:
    sta result1
  rts