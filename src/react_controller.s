; File containing the subroutines called when each button is pressed

b_pressed:
  ; Checks if we are in the main menu
  lda main_menu_selection
  cmp #0
  beq :+
    ; If that's the case: do nothing
    rts
  :
  ; Checks if the player has lost
  lda has_lost
  cmp #1
  bne :+
    ; If that's the case: do nothing
    rts
  :
  
  lda cursor_y
  sta param1
  lda width
  sta param2
  jsr multiplication
  lda result1
  clc
  adc cursor_x
  tax
  lda tiles, X
  and #%00100000 ; checks if the tile has a flag
  bne :+
    ; if the tile isn't flagged
    lda tiles, X
    ora #%01000000 ; sets is_discovered to 1
    sta tiles, X
    jsr check_if_player_has_won
    jsr update_tiles
  :
  rts

a_pressed:
  ; Checks if we are in the main menu
  lda main_menu_selection
  cmp #0
  beq :+
    ; If that's the case: do nothing
    rts
  :
  ; Checks if the player has lost
  lda has_lost
  cmp #1
  bne :+
    ; If that's the case: do nothing
    rts
  :

  lda cursor_y
  sta param1
  lda width
  sta param2
  jsr multiplication
  lda result1
  clc
  adc cursor_x
  tax
  lda tiles, X
  eor #%00100000 ; inverts has_flag
  sta tiles, X
  jsr update_tiles
  rts

select_pressed:
  ; Checks if we are in the main menu
  lda main_menu_selection
  cmp #0
  beq :+++
    lda main_menu_selection
    cmp #4
    bne :+ ; If cursor is on custom
      lda #1
      sta main_menu_selection
      jmp :++
    : ; Else
    inc main_menu_selection
    :
    jsr draw_main_menu_cursor
    rts
  :
  jmp main_menu
  rts

start_pressed:
  ; Checks if we are in the main menu
  lda main_menu_selection
  cmp #0
  beq :+
    lda #0
    sta main_menu_selection
    jmp start_game
  :
  lda has_lost
  cmp #1
  bne :+
    jmp initialize
  :
  lda has_won
  cmp #1
  bne :+
    jmp initialize
  :
  rts

up_pressed:
  ; Checks if we are in the main menu
  lda main_menu_selection
  cmp #0
  beq :+
    ; If that's the case: do nothing
    rts
  :
  ; Else if cursor_y != 0: cursor_y--
  lda cursor_y
  cmp #0
  beq :+
    dec cursor_y
  :
  rts

down_pressed:
  ; Checks if we are in the main menu
  lda main_menu_selection
  cmp #0
  beq :+
    ; If that's the case: do nothing
    rts
  :
  ; Else if cursor_y != last_line: cursor_y++
  lda cursor_y
  cmp last_line
  beq :+
    inc cursor_y
  :
  rts

left_pressed:
  ; Checks if we are in the main menu
  lda main_menu_selection
  cmp #0
  beq :+
    ; If that's the case: do nothing
    rts
  :
  ; Else if cursor_x != 0: cursor_x--
  lda cursor_x
  cmp #0
  beq :+
    dec cursor_x
  :
  rts

right_pressed:
  ; Checks if we are in the main menu
  lda main_menu_selection
  cmp #0
  beq :+
    ; If that's the case: do nothing
    rts
  :
  ; Else if cursor_x != last_column: cursor_x++
  lda cursor_x
  cmp last_column
  beq :+
    inc cursor_x
  :
  rts