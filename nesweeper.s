; Shout out to NesHacker for the base Hello World project and the videos ♥
; Big thanks for the NESdev Discord for the help ♥
; Thanks to NESdev wiki contributors for the ressources ♥

.segment "INESHDR"
  .byt "NES",$1A  ; magic signature
  .byt 1          ; PRG ROM size in 16384 byte units
  .byt 1          ; CHR ROM size in 8192 byte units
  .byt $00        ; mirroring type and mapper number lower nibble
  .byt $00        ; mapper number upper nibble

.segment "ZEROPAGE"
  avaluebeforenmi: .res 1
  ; Time counters
  FrameCounter: .res 1
  SecondCounter: .res 1
  ; Procedures
  param1: .res 1
  param2: .res 1
  result1: .res 1
  result2: .res 1
  temp: .res 1
  ; Gamepad/buttons
  gamepad: .res 1
  last_frame_buttons: .res 1
  pressed_buttons: .res 1
  released_buttons: .res 1
  ; Game-specific variables
  main_menu_selection: .res 1 ; 0 = not on the main menu
  tilemap_address: .res 2
  cursor_x: .res 1
  cursor_y: .res 1
  height: .res 1
  width: .res 1
  last_line: .res 1
  last_column: .res 1
  number_of_tiles: .res 1
  has_won: .res 1
  has_lost: .res 1
  mines_total: .res 1
  flags_total: .res 1
  mines_remaining: .res 1 ; mines_total - flags_total
  tiles: .res 200
  ; bit-7: unused
  ; bit-6: is discovered
  ; bit-5: has flag
  ; bit-4: has mine
  ; bit-3 to bit-0: number of mines around

.segment "OAM"
  oam: .res 256        ; sprite OAM data to be uploaded by DMA

.segment "VECTORS"
  ;; When an NMI happens (once per frame if enabled) the label nmi:
  .addr nmi
  ;; When the processor first turns on or is reset, it will jump to the label reset:
  .addr reset
  ;; External interrupt IRQ (unused)
  .addr 0

.segment "CHR"
  .incbin "patterntable.chr" ; Pattern table 0

; Main code segment for the program
.segment "CODE"

reset:
  sei		; disable IRQs
  cld		; disable decimal mode
  ldx #$40
  stx $4017	; disable APU frame IRQ
  ldx #$ff 	; Set up stack
  txs		;  .
  inx		; now X = 0
  stx $2000	; disable NMI
  stx $2001 	; disable rendering
  stx $4010 	; disable DMC IRQs

;; first wait for vblank to make sure PPU is ready
vblankwait1:
  bit $2002
  bpl vblankwait1

clear_memory:
  lda #$00
  sta $0000, x
  sta $0100, x
  sta $0200, x
  sta $0300, x
  sta $0400, x
  sta $0500, x
  sta $0600, x
  sta $0700, x
  inx
  bne clear_memory

;; second wait for vblank, PPU is ready after this
vblankwait2:
  bit $2002
  bpl vblankwait2

main: ; useful?
main_menu:
load_main_menu_palettes:
  lda $2002 ; useful?

  lda #$3f
  sta $2006
  lda #$00
  sta $2006

  ldx #$00
@loop:
  lda main_menu_palettes, x
  sta $2007
  inx
  cpx #$20
  bne @loop

load_main_menu_background:
  jsr disable_rendering

  lda $2002 ; useful?

  lda #$20
  sta $2006
  lda #$00
  sta $2006

  ldx #$00
@loop1:
  lda main_menu_background1, x
  sta $2007
  inx
  cpx #$00
  bne @loop1
@loop2:
  lda main_menu_background2, x
  sta $2007
  inx
  cpx #$00
  bne @loop2
@loop3:
  lda main_menu_background3, x
  sta $2007
  inx
  cpx #$00
  bne @loop3
@loop4:
  lda main_menu_background4, x
  sta $2007
  inx
  cpx #$c0
  bne @loop4

  ldx #$00
@loop5:
  lda main_menu_attributetable, x
  sta $2007
  inx
  cpx #$40
  bne @loop5

  lda #%10000000 ; Enable NMI
  sta $2000
  jsr enable_rendering

lda #1
sta main_menu_selection
main_menu_loop:
  jsr read_gamepad
  jmp main_menu_loop

start_game:
load_palettes:
  lda $2002 ; useful?

  lda #$3f
  sta $2006
  lda #$00
  sta $2006

  ldx #$00
@loop:
  lda palettes, x
  sta $2007
  inx
  cpx #$20
  bne @loop

load_background:
  jsr disable_rendering

  lda $2002 ; useful?

  lda #$20
  sta $2006
  lda #$00
  sta $2006

  ldx #$00
@loop1:
  lda background1, x
  sta $2007
  inx
  cpx #$00
  bne @loop1
@loop2:
  lda background2, x
  sta $2007
  inx
  cpx #$00
  bne @loop2
@loop3:
  lda background3, x
  sta $2007
  inx
  cpx #$00
  bne @loop3
@loop4:
  lda background4, x
  sta $2007
  inx
  cpx #$c0
  bne @loop4

  ldx #$00
@loop5:
  lda attributetable, x
  sta $2007
  inx
  cpx #$40
  bne @loop5

  lda #%10000000 ; Enable NMI
  sta $2000
  jsr enable_rendering

; Initialize the variables
initialize:
  ;-----TEST (REMOVE)------
  ;lda #130
  ;sta SecondCounter
  ;-----TEST-----
  lda #0
  sta cursor_x
  sta cursor_y
  sta has_lost
  sta has_won

  lda #10 ; hard coded height (testing purpose) (<=21)
  sta height
  lda #10 ; hard coded width (testing purpose) (<=28)
  sta width

  lda height
  sta last_line
  dec last_line
  ; last_line = height - 1

  lda width
  sta last_column
  dec last_column
  ; last_column = width - 1

  lda width
  sta param1
  lda height
  sta param2
  jsr multiplication
  lda result1
  sta number_of_tiles
  ; number_of_tiles = width * height

; Regarder si ça marche sur Mesen (je sais plus pourquoi j'ai mis ce comm ;-;)
lda #0
ldx #0
:
sta tiles, X
inx
cpx number_of_tiles
bne :-
;jsr clear_tiles

;lda #%00010000
;ldx #0
;sta tiles, x
;ldx #15
;sta tiles, x
;ldx #19
;sta tiles, x
;ldx #20
;sta tiles, x
lda #10
sta mines_total
jsr place_mines
jsr calculate_tiles_digits
jsr update_tiles

lda #0
sta SecondCounter

; -------------------- Main loop of the game --------------------

forever:
  jsr read_gamepad
  ;lda FrameCounter
  ;cmp #$ff
  ;bne :+
    ;inc mines_total
  ; :
  jsr update_clock
  jsr draw_cursor
  jmp forever

; Read gamepad inputs
read_gamepad:
  ; Initialize the output memory
  lda #1
  sta gamepad

  ; Send the latch pulse down to the 4021
  sta $4016
  lda #0
  sta $4016

  ; Read the buttons from the data line
gamepad_loop:
  lda $4016
  lsr a
  rol gamepad
  bcc gamepad_loop

  ; newly pressed buttons: not held last frame, and held now
  lda last_frame_buttons
  eor #%11111111
  and gamepad
  sta pressed_buttons

  ; newly released buttons: not held now, and held last frame
  lda gamepad
  eor #%11111111
  and last_frame_buttons
  sta released_buttons

  ; Check which buttons are pressed
  lda pressed_buttons
  and #%10000000
  beq :+
    jsr a_pushed
  :
  lda pressed_buttons
  and #%01000000
  beq :+
    jsr b_pushed
  :
  lda pressed_buttons
  and #%00100000
  beq :+
    jsr select_pushed
  :
  lda pressed_buttons
  and #%00010000
  beq :+
    jsr start_pushed
  :
  lda pressed_buttons
  and #%00001000
  beq :+
    jsr up_pushed
  :
  lda pressed_buttons
  and #%00000100
  beq :+
    jsr down_pushed
  :
  lda pressed_buttons
  and #%00000010
  beq :+
    jsr left_pushed
  :
  lda pressed_buttons
  and #%00000001
  beq :+
    jsr right_pushed
  :

  lda gamepad
  sta last_frame_buttons

  rts

b_pushed:
  ; Checks if we are in the main menu
  lda main_menu_selection
  cmp #0
  beq :+
    rts
  :
  ; Checks if the player has lost
  lda has_lost
  cmp #1
  bne :+
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

a_pushed:
  ; Checks if we are in the main menu
  lda main_menu_selection
  cmp #0
  beq :+
    rts
  :
  ; Checks if the player has lost
  lda has_lost
  cmp #1
  bne :+
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
select_pushed:
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
start_pushed:
  ; Checks if we are in the main menu
  lda main_menu_selection
  cmp #0
  beq :+
    lda #0
    sta main_menu_selection
    jmp start_game
    ;rts
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

up_pushed:
  ; Checks if we are in the main menu
  lda main_menu_selection
  cmp #0
  beq :+
    rts
  :
  lda cursor_y
  cmp #0
  beq :+
    dec cursor_y
  :
  rts
down_pushed:
  ; Checks if we are in the main menu
  lda main_menu_selection
  cmp #0
  beq :+
    rts
  :
  lda cursor_y
  ;clc
  ;adc #1 ; We add one to A before comparing to height so A is compared with height - 1 because the cursor can't take the height value
  ;cmp height
  cmp last_line
  beq :+
    inc cursor_y
  :
  rts
left_pushed:
  ; Checks if we are in the main menu
  lda main_menu_selection
  cmp #0
  beq :+
    rts
  :
  lda cursor_x
  cmp #0
  beq :+
    dec cursor_x
  :
  rts
right_pushed:
  ; Checks if we are in the main menu
  lda main_menu_selection
  cmp #0
  beq :+
    rts
  :
  lda cursor_x
  ;clc
  ;adc #1 ; We add one to A before comparing to width so A is compared with width - 1 because the cursor can't take the width value
  ;cmp width
  cmp last_column
  beq :+
    inc cursor_x
  :
  rts

clear_tiles:
  lda #0
  ldx #0
  :
  sta tiles, X
  inx
  cpx number_of_tiles
  bne :-
  rts

; Fully implemented
calculate_tiles_digits:
  ldx #0
calculate_loop:
  ;v1-----------------------------------------------------------------------
  ;cpx #0
  ;bne :+
    ; if tile == 0 / if tile is top-left corner
    ;jsr check_right
    ;jsr check_down
    ;jsr check_down_right
    ;jmp calculate_loop_end
  ; :

  ;lda width
  ;sta param1 ; We store accumulator to a variable so we can compare x to it
  ;dec param1
  ;cpx param1
  ;bne :+
    ; if x == width - 1 / if tile is top-right corner
    ;jsr check_left
    ;jsr check_down_left
    ;jsr check_down
    ;jmp calculate_loop_end
  ; :

  ;lda width
  ;sta param1
  ;lda height
  ;sta param2
  ;jsr multiplication
  ;lda result1
  ;sec
  ;sbc width
  ;sta param1
  ;cpx param1
  ;bne :+
    ; if x == width * height - width / if tile is bottom-left corner
    ;jsr check_up
    ;jsr check_up_right
    ;jsr check_right
    ;jmp calculate_loop_end
  ; :

  ;lda result1
  ;sta param1
  ;dec param1
  ;cpx param1
  ;bne :+
    ; if x == width * height - 1 / if tile is bottom-right corner
    ;jsr check_up_left
    ;jsr check_up
    ;jsr check_left
    ;jmp calculate_loop_end
  ; :

  ;stx param1
  ;lda width
  ;sta param2
  ;jsr division
  ;lda result2 ; remainder
  ;cmp #0
  ;bne :+
    ; if x mod width == 0 / if tile is in first column
    ;jsr check_up
    ;jsr check_up_right
    ;jsr check_right
    ;jsr check_down
    ;jsr check_down_right
    ;jmp calculate_loop_end
  ; :

  ;lda width
  ;sta param1 ; we use param1 to store the width - 1
  ;dec param1
  ;lda result2 ; remainder
  ;cmp param1
  ;bne :+
    ; if x mod width == width - 1 / if tile is in last column
    ;jsr check_up_left
    ;jsr check_up
    ;jsr check_left
    ;jsr check_down_left
    ;jsr check_down
    ;jmp calculate_loop_end
  ; :

  ;cpx width
  ;bpl :+
  ;beq :+ ; useful? no cause corner treated earlier
    ; if x < width / if tile is in first line
    ;jsr check_left
    ;jsr check_right
    ;jsr check_down_left
    ;jsr check_down
    ;jsr check_down_right
    ;jmp calculate_loop_end
  ; :

  ;lda width
  ;sta param1
  ;lda height
  ;sta param2
  ;jsr multiplication
  ;lda result1
  ;sec
  ;sbc width
  ;sta param1 ; we store a to param1 because we can't compare a and x
  ;cpx param1
  ;bmi :+
    ; if x >= width * height - width / if tile is in last line
    ;jsr check_up_left
    ;jsr check_up
    ;jsr check_up_right
    ;jsr check_left
    ;jsr check_right
    ;jmp calculate_loop_end
  ; :
  ;v2--------------------------------------------------------------------------
  ; utiliser last_line, last_column et number_of_tiles
  jsr get_tile_coordinates
  ; result1 = line
  ; result2 = column
  lda result1
  cmp #0
  beq :+++
    ; if tile is not in first line
    jsr check_up
    lda result2
    cmp #0
    beq :+
      ; if tile is also not in first column
      jsr check_up_left
    :
    lda result2
    cmp last_column
    beq :+
      ; if tile is also not in last column
      jsr check_up_right
    :
  :
  lda result1
  cmp last_line
  beq :+++
    ; if tile is not in last line
    jsr check_down
    lda result2
    cmp #0
    beq :+
      ; if tile is also not in first column
      jsr check_down_left
    :
    lda result2
    cmp last_column
    beq :+
      ; if tile is also not in last column
      jsr check_down_right
    :
  :
  lda result2
  cmp #0
  beq :+
    ; if tile is not in first column
    jsr check_left
  :
  lda result2
  cmp last_column
  beq :+
    ; if tile is not in last column
    jsr check_right
  :

; calculate_loop_end:
  inx
  cpx number_of_tiles
  bne calculate_loop
  rts

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

; parameter: the tile in x
; result1: y-coordinate / line of the tile
; result2: x-coordinate / column of the tile
get_tile_coordinates:
  stx param1
  lda width
  sta param2
  jsr division
  rts

check_if_player_has_won:
  ldx #0
  lda #1
  sta has_won
  @loop:
    lda tiles, x
    and #%00010000 ; checks if the tile soen't have a mine
    bne :+
      lda tiles, x
      and #%01000000 ; checks if the tile is discovered
      bne :+
        ; if it's not discovered
        lda #0
        sta has_won
        rts
    :
    ;lda has_won
    ;cmp #0
    ;bne :+
      ; if we already know that the player hasn't win, no need to continue the loop
      ;rts
    ; :
    inx
    cpx number_of_tiles
    bmi @loop
  rts

; -------------------- GRAPHICS --------------------

draw_main_menu_cursor:
  ; Calculate the cursor address
  lda #$22
  sta tilemap_address
  lda main_menu_selection
  sta param1
  lda #64
  sta param2
  jsr multiplication
  lda result1
  clc
  adc #$cc
  sta tilemap_address+1
  jsr disable_rendering

  ; Delete the other cursors
  lda #$22
  sta $2006
  lda #$0c
  sta $2006
  lda #$00
  sta $2007
  lda #$22
  sta $2006
  lda #$4c
  sta $2006
  lda #$00
  sta $2007
  lda #$22
  sta $2006
  lda #$8c
  sta $2006
  lda #$00
  sta $2007
  lda #$22
  sta $2006
  lda #$cc
  sta $2006
  lda #$00
  sta $2007

  ; Draw the cursor
  lda tilemap_address
  sta $2006
  lda tilemap_address+1
  sta $2006
  lda #$4c
  sta $2007

  jsr reset_scroll
  jsr enable_rendering
  rts

; 
update_tiles:
  lda #$20
  sta tilemap_address
  lda #$c2
  sta tilemap_address+1
  ldx #0
  
  jsr disable_rendering
  lda #$20
  sta $2006
  lda #$c2
  sta $2006
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
  sta $2007
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
    sta $2006
    lda tilemap_address+1
    sta $2006
  :

  cpx number_of_tiles
  bne update_tiles_loop
draw_smiley:
  lda has_lost
  cmp #1
  bne :+
    ; if the player has lost
    lda #$20
    sta $2006
    lda #$4f
    sta $2006
    lda #$54 ; changer la tile
    sta $2007
    lda #$55 ; ici aussi
    sta $2007
    lda #$20
    sta $2006
    lda #$6f
    sta $2006
    lda #$64 ; changer la tile
    sta $2007
    lda #$65 ; ici aussi
    sta $2007
    jmp :+++
  :
  lda has_won
  cmp #1
  bne :+
    ; if the player has won
    lda #$20
    sta $2006
    lda #$4f
    sta $2006
    lda #$56 ; changer la tile
    sta $2007
    lda #$57 ; ici aussi
    sta $2007
    lda #$20
    sta $2006
    lda #$6f
    sta $2006
    lda #$66 ; changer la tile
    sta $2007
    lda #$67 ; ici aussi
    sta $2007
    jmp :++
  :
    ; if the player hasn't lost & hasn't won
    lda #$20
    sta $2006
    lda #$4f
    sta $2006
    lda #$52 ; changer la tile
    sta $2007
    lda #$53 ; ici aussi
    sta $2007
    lda #$20
    sta $2006
    lda #$6f
    sta $2006
    lda #$62 ; changer la tile
    sta $2007
    lda #$63 ; ici aussi
    sta $2007
  :

  jsr reset_scroll
  jsr enable_rendering
  rts

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
  sta $4014
  rts 

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

; Renders the digit stocked in param1 and param2
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

; Renders the digit stocked in param1 and param2
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

; Renders the digit stocked in param1 and param2
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

; Renders the digit stocked in param1 and param2
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

; Renders the digit stocked in param1 and param2
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

; Renders the digit stocked in param1 and param2
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

; Loads the digit tiles addresses in param1 and param2
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

; Resets FrameCounter and increments SecondCounter every 60 frames
nmi:
  sta avaluebeforenmi
  lda #$00 ; Set SPR-RAM address to 0
  sta $2003
  inc FrameCounter
  ; I cheated! A "second" is 64 frames...
  lda #0
  cmp FrameCounter
  beq :+
    lda #64
    cmp FrameCounter
    beq :+
      lda #128
      cmp FrameCounter
      beq :+
        lda #192
        cmp FrameCounter
        beq :+
          jmp :++ ; if FrameCounter isn't 0, 64, 128 or 192
  :
  lda has_won
  cmp #1
  beq :+
    inc SecondCounter
  :
  lda #0
  lda avaluebeforenmi
  rti

; Enable background and sprites
enable_rendering:
  lda #%00011000
  sta $2001
  rts

; Disable rendering
disable_rendering:
  lda #%00000000
  sta $2001
  rts

; Reset scroll coordinates
reset_scroll:
  lda #$00
  sta $2005
  sta $2005
  rts

; Wait for the next vblank
wait_for_vblank:
  lda FrameCounter
@loop:
  cmp FrameCounter
  beq @loop
  rts

; https://codebase64.org/doku.php?id=base:small_fast_8-bit_prng
; Takes the number in param1 and use it to generate a new one in result1
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

; Places all the mines on the field
place_mines:
  lda #0
  sta mines_remaining
  lda FrameCounter
  sta result1
  place_mines_loop:
    lda result1
    generate_number:
      sta param1
      jsr rng
      lda result1
      cmp number_of_tiles
      bpl generate_number ; if the generated number is >= to the number of tiles, we generate another
    place_mine:
      ldx result1
      lda #%00010000
      sta tiles, x
      inc mines_remaining
      lda mines_remaining
      cmp mines_total
      bmi place_mines_loop
  rts

.include "math.s"

; -------------------- THINGS --------------------

palettes:
  .byte $10, $00, $16, $1d ; Background palette 0 (tiles palette: light gray = background, dark gray = outline, red = flag & numbers, black = flag & numbers)
  .byte $10, $06, $16, $1d ; Background palette 1 (digits palette: light gray = unused, dark red = segment off, light red = segment on, black = background)
  .byte $10, $00, $30, $10 ; Background palette 2 (outline palette: light gray = background, dark gray = shadow, white = glint, light gray = unused)
  .byte $10, $1d, $39, $10 ; Background palette 3 (smiley palette: light gray = background, black = outline / eyes / glasses, yellow = smiley, light gray = unused)
  .byte $10, $13, $00, $00 ; Sprite palette 0
  .byte $10, $19, $00, $00 ; Sprite palette 1
  .byte $10, $16, $00, $00 ; Sprite palette 2
  .byte $10, $1C, $00, $00 ; Sprite palette 3

background1:
  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
  .byte $00, $10, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $11, $00
  .byte $00, $15, $20, $20, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $15, $00
  .byte $00, $15, $27, $27, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $27, $27, $15, $00
  .byte $00, $16, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $17, $00
  .byte $00, $15, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $15, $00
  .byte $00, $15, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $15, $00
  .byte $00, $15, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $15, $00
  
background2:
  .byte $00, $15, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $15, $00
  .byte $00, $15, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $15, $00
  .byte $00, $15, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $15, $00
  .byte $00, $15, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $15, $00
  .byte $00, $15, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $15, $00
  .byte $00, $15, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $15, $00
  .byte $00, $15, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $15, $00
  .byte $00, $15, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $15, $00
  
background3:
  .byte $00, $15, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $15, $00
  .byte $00, $15, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $15, $00
  .byte $00, $15, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $15, $00
  .byte $00, $15, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $15, $00
  .byte $00, $15, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $15, $00
  .byte $00, $15, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $15, $00
  .byte $00, $15, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $15, $00
  .byte $00, $15, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $15, $00
  
background4:
  .byte $00, $15, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $15, $00
  .byte $00, $15, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $15, $00
  .byte $00, $15, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $15, $00
  .byte $00, $15, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $15, $00
  .byte $00, $12, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $13, $00
  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

attributetable:
  .byte %01101010, %10101010, %10101010, %11101010, %10111010, %10101010, %01101010, %10011010
  .byte %00101010, %00001010, %00001010, %00001010, %00001010, %00001010, %00001010, %10001010
  .byte %00100010, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %10001000
  .byte %00100010, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %10001000
  .byte %00100010, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %10001000
  .byte %00100010, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %10001000
  .byte %00100010, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %10001000
  .byte %10101010, %10101010, %10101010, %10101010, %10101010, %10101010, %10101010, %10101010

.include "main_menu_background.s"