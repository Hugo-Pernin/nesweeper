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
  ; Time counters
  FrameCounter: .res 1
  SecondCounter: .res 1
  ; Procedures
  param1: .res 1
  param2: .res 1
  result1: .res 1
  result2: .res 1
  temp: .res 1
  ; Controller/buttons
  controller: .res 1
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
  .incbin "assets/patterntable.chr" ; Pattern table 0

; Main code segment for the program
.segment "CODE"

; PPU registers
PPUCTRL = $2000
PPUMASK = $2001
PPUSTATUS = $2002
OAMADDR = $2003
OAMDATA = $2004
PPUSCROLL = $2005
PPUADDR = $2006
PPUDATA = $2007
OAMDMA = $4014

reset:
  sei		; disable IRQs
  cld		; disable decimal mode
  ldx #$40
  stx $4017	; disable APU frame IRQ
  ldx #$ff 	; Set up stack
  txs		;  .
  inx		; now X = 0
  stx PPUCTRL	; disable NMI
  stx PPUMASK 	; disable rendering
  stx $4010 	; disable DMC IRQs

;; first wait for vblank to make sure PPU is ready
vblankwait1:
  bit PPUSTATUS
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
  bit PPUSTATUS
  bpl vblankwait2

main: ; useful?
main_menu:
load_main_menu_palettes:
  lda PPUSTATUS ; useful?

  lda #>$3f00
  sta PPUADDR
  lda #<$3f00
  sta PPUADDR

  ldx #$00
@loop:
  lda main_menu_palettes, x
  sta PPUDATA
  inx
  cpx #$20
  bne @loop

load_main_menu_background:
  jsr disable_rendering

  lda PPUSTATUS ; useful?

  lda #>$2000
  sta PPUADDR
  lda #<$2000
  sta PPUADDR

  ldx #$00
@loop1:
  lda main_menu_background1, x
  sta PPUDATA
  inx
  cpx #$00
  bne @loop1
@loop2:
  lda main_menu_background2, x
  sta PPUDATA
  inx
  cpx #$00
  bne @loop2
@loop3:
  lda main_menu_background3, x
  sta PPUDATA
  inx
  cpx #$00
  bne @loop3
@loop4:
  lda main_menu_background4, x
  sta PPUDATA
  inx
  cpx #$c0
  bne @loop4

  ldx #$00
@loop5:
  lda main_menu_attributetable, x
  sta PPUDATA
  inx
  cpx #$40
  bne @loop5

  lda #%10000000 ; Enable NMI
  sta PPUCTRL
  jsr enable_rendering

lda #1
sta main_menu_selection
main_menu_loop:
  jsr read_controller
  jmp main_menu_loop

start_game:
load_palettes:
  lda PPUSTATUS ; useful?

  lda #>$3f00
  sta PPUADDR
  lda #<$3f00
  sta PPUADDR

  ldx #$00
@loop:
  lda palettes, x
  sta PPUDATA
  inx
  cpx #$20
  bne @loop

load_background:
  jsr disable_rendering

  lda PPUSTATUS ; useful?

  lda #>$2000
  sta PPUADDR
  lda #<$2000
  sta PPUADDR

  ldx #$00
@loop1:
  lda background1, x
  sta PPUDATA
  inx
  cpx #$00
  bne @loop1
@loop2:
  lda background2, x
  sta PPUDATA
  inx
  cpx #$00
  bne @loop2
@loop3:
  lda background3, x
  sta PPUDATA
  inx
  cpx #$00
  bne @loop3
@loop4:
  lda background4, x
  sta PPUDATA
  inx
  cpx #$c0
  bne @loop4

  ldx #$00
@loop5:
  lda attributetable, x
  sta PPUDATA
  inx
  cpx #$40
  bne @loop5

  lda #%10000000 ; Enable NMI
  sta PPUCTRL
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
  jsr read_controller
  ;lda FrameCounter
  ;cmp #$ff
  ;bne :+
    ;inc mines_total
  ; :
  jsr update_clock
  jsr draw_cursor
  jmp forever

.include "read_controller.s"

.include "react_controller.s"

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

.include "view/main_menu_cursor.s"

.include "view/tiles.s"

.include "view/smiley.s"

.include "view/cursor.s"

.include "clock.s"

.include "view/digits.s"

; Resets FrameCounter and increments SecondCounter every 60 frames
nmi:
  ; back up registers (important)
  pha
  txa
  pha
  tya
  pha

  lda #$00 ; Set SPR-RAM address to 0
  sta OAMADDR
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
  
  ; restore regs and exit
  pla
  tay
  pla
  tax
  pla
  rti

; Enable background and sprites
enable_rendering:
  lda #%00011000
  sta PPUMASK
  rts

; Disable rendering
disable_rendering:
  lda #%00000000
  sta PPUMASK
  rts

; Reset scroll coordinates
reset_scroll:
  lda #$00
  sta PPUSCROLL
  sta PPUSCROLL
  rts

; Wait for the next vblank
wait_for_vblank:
  lda FrameCounter
@loop:
  cmp FrameCounter
  beq @loop
  rts

.include "random.s"

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

.include "assets/game_background.s"

.include "assets/main_menu_background.s"