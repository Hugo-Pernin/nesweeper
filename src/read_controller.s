; Read controller inputs
read_controller:
  ; Initialize the output memory
  lda #1
  sta controller

  ; Send the latch pulse down to the 4021
  sta $4016
  lda #0
  sta $4016

  ; Read the buttons from the data line
controller_loop:
  lda $4016
  lsr a
  rol controller
  bcc controller_loop

  ; newly pressed buttons: not held last frame, and held now
  lda last_frame_buttons
  eor #%11111111
  and controller
  sta pressed_buttons

  ; newly released buttons: not held now, and held last frame
  lda controller
  eor #%11111111
  and last_frame_buttons
  sta released_buttons

  ; Check which buttons are pressed
  lda pressed_buttons
  and #%10000000
  beq :+
    jsr a_pressed
  :
  lda pressed_buttons
  and #%01000000
  beq :+
    jsr b_pressed
  :
  lda pressed_buttons
  and #%00100000
  beq :+
    jsr select_pressed
  :
  lda pressed_buttons
  and #%00010000
  beq :+
    jsr start_pressed
  :
  lda pressed_buttons
  and #%00001000
  beq :+
    jsr up_pressed
  :
  lda pressed_buttons
  and #%00000100
  beq :+
    jsr down_pressed
  :
  lda pressed_buttons
  and #%00000010
  beq :+
    jsr left_pressed
  :
  lda pressed_buttons
  and #%00000001
  beq :+
    jsr right_pressed
  :

  lda controller
  sta last_frame_buttons

  rts