    ;;    game state memory location
    .equ CURR_STATE, 0x1000              ; current game state
    .equ GSA_ID, 0x1004                  ; gsa currently in use for drawing
    .equ PAUSE, 0x1008                   ; is the game paused or running
    .equ SPEED, 0x100C                   ; game speed
    .equ CURR_STEP,  0x1010              ; game current step
    .equ SEED, 0x1014                    ; game seed
    .equ GSA0, 0x1018                    ; GSA0 starting address
    .equ GSA1, 0x1038                    ; GSA1 starting address
    .equ SEVEN_SEGS, 0x1198              ; 7-segment display addresses
    .equ CUSTOM_VAR_START, 0x1200        ; Free range of addresses for custom variable definition
    .equ CUSTOM_VAR_END, 0x1300
    .equ LEDS, 0x2000                    ; LED address
    .equ RANDOM_NUM, 0x2010              ; Random number generator address
    .equ BUTTONS, 0x2030                 ; Buttons addresse

    ;; states
    .equ INIT, 0
    .equ RAND, 1
    .equ RUN, 2

    ;; constants
    .equ N_SEEDS, 4
    .equ N_GSA_LINES, 8
    .equ N_GSA_COLUMNS, 12
    .equ MAX_SPEED, 10
    .equ MIN_SPEED, 1
    .equ PAUSED, 0x00
    .equ RUNNING, 0x01
	.equ COUNTER, 0x7FFF

	;; masks
	.equ 12_DOWNTO_9, 0x000F00
	.equ INITIAL_MASK_LEDS, 0x80808080
	
	

main:
    ;; TODO

;; ---------------------------------------------------------------------------------------------
;; ------------------------------------------------------------------------------------------

; BEGIN:clear_leds
clear_leds:
	addi t1, zero, LEDS ; load the LEDS in t1
	addi t2, t1, 4 ; load the LEDS in t2
	addi t3, t2, 4 ; load the LEDS in t3
	stw zero, 0(t1); store in 0x2000 (LED1) 0
	stw zero, 0(t2); store in 0x2004 (LED2) 0
	stw zero, 0(t3); store in 0x2008 (LED3) 0
	ret
; END:clear_leds

;; ---------------------------------------------------------------------------------------------
;; ------------------------------------------------------------------------------------------

; BEGIN:wait
wait: 
	addi t1, zero, COUNTER ; store value of counter in t1
	addi t2, zero, SPEED ; store address of speed in t2
	ldw t3, 0(t2) ; load speed of game from memory to t3
	bne t1, zero, decrement ; if t1 is different than 0 then we loop
	ret
; END:wait

decrement:
	sub t1, t1, t3 ; substract the speed of game from the counter value in t1
	bne t1, zero, decrement ; if t1 is different than 0 then we loop

;; ---------------------------------------------------------------------------------------------
;; ------------------------------------------------------------------------------------------

; BEGIN:get_gsa
get_gsa:
	ldw t1, GSA_ID(zero) ;; load GSA ID
	beq zero, t1, curr_state
	;; if gsa id = 1 meaning we are using next state gsa
	addi t1, zero, GSA1 ;; store address of first GSA element
	add t2, t1, a0  ;; store address for getting the right element
	ldw v0, 0(t2) ;; load index y from gsa element
	ret
; END:get_gsa
	
curr_state:
	addi t1, zero, GSA0 ;; store address of first GSA element
	add t2, t1, a0 ;; store address for getting the right element
	ldw v0, 0(t2) ;; load index y from gsa element
	ret

; BEGIN:set_gsa
set_gsa:
	ldw t1, GSA_ID(zero) ;; load GSA ID
	beq zero, t1, curr_state
	;; if gsa id = 1 meaning we are using next state gsa
	addi t1, zero, GSA1
	add t2, t1, a1 ;; store address for getting the right element
	stw a0, 0(t2) ;; store the line a0 in the GSA element
	ret
; END:set_gsa

;; ---------------------------------------------------------------------------------------------
;; ---------------------------------------------------------------------------------------------

; BEGIN:change_speed
change_speed:
	ldw t0, SPEED(zero) ;; load SPEED value in t0
	beq a0, zero, increment_speed ;; if a0 is 0 then we want to increment the speed
	;; if a0 is something else, then we want to decrease the speed
	addi t1, zero, MIN_SPEED ;; min value of speed
	blt t1, t0, decrement_really ;; if the speed is greater than 1
	ret
; END:change_speed

decrement_really:
	addi t3, zero, 1
	addi t0, t0, -1 
	sub t0, t0, t3 ;; decrease by 1 the speed of the game if the speed was 10 or less
	stw t0, SPEED(zero) ;; store new value of speed
	ret

increment_speed:
	addi t1, zero, MAX_SPEED ;; max value of speed
	blt t0, t1, increment_really ;; if the speed if less than 10
	ret

increment_really:
	addi t0, t0, 1 ;; increment by 1 the speed of the game if the speed was 9 or less
	stw t0, SPEED(zero) ;; store new value of speed
	ret

;; ---------------------------------------------------------------------------------------------
;; ---------------------------------------------------------------------------------------------

; BEGIN:change_steps
change_steps:
	ldw t0, CURR_STEP(zero) ;; load the current number of steps
	addi t1, zero, 1 ;; store button4 value
	beq a0, t1, increment_unit ;; check if should increment units
l1:
	beq a1, t1, imcrement_tens ;;check if should increment tens
l2:
	beq a2, t1, incremenent_hundreds ;; check if should increment hundreds
l3: 
	stw t0, CURR_STEP(zero) ;; store current step incremented
	ret
; END:change_steps

increment_unit:
	addi t0, t0, 1 ;; increment by 1 
	jmpi l1 ;; return to fct
increment_tens:
	addi t0, t0, 10 ;; increment by 10
	jmpi l2;; return to fct
increment_hundres:
	addi t0, t0, 64 ;; incremnet by 100 (hexa:64)
	jmpi l3 ;; return to fct

;; ---------------------------------------------------------------------------------------------
;; ---------------------------------------------------------------------------------------------
; BEGIN:pause_game
pause_game:
	ldw t0, PAUSE(zero) ;; load if game is pause or running
	nor t1, t0, zero ;; nor the value in t0. If it's 0 nor 0 -> then 1, else if 1 nor 0 -> then 0
	stw t1, PAUSE(zero) ;; store the new value of pause/running
	ret
; END:pause_game

font_data:
    .word 0xFC ; 0
    .word 0x60 ; 1
    .word 0xDA ; 2
    .word 0xF2 ; 3
    .word 0x66 ; 4
    .word 0xB6 ; 5
    .word 0xBE ; 6
    .word 0xE0 ; 7
    .word 0xFE ; 8
    .word 0xF6 ; 9
    .word 0xEE ; A
    .word 0x3E ; B
    .word 0x9C ; C
    .word 0x7A ; D
    .word 0x9E ; E
    .word 0x8E ; F

seed0:
    .word 0xC00
    .word 0xC00
    .word 0x000
    .word 0x060
    .word 0x0A0
    .word 0x0C6
    .word 0x006
    .word 0x000

seed1:
    .word 0x000
    .word 0x000
    .word 0x05C
    .word 0x040
    .word 0x240
    .word 0x200
    .word 0x20E
    .word 0x000

seed2:
    .word 0x000
    .word 0x010
    .word 0x020
    .word 0x038
    .word 0x000
    .word 0x000
    .word 0x000
    .word 0x000

seed3:
    .word 0x000
    .word 0x000
    .word 0x090
    .word 0x008
    .word 0x088
    .word 0x078
    .word 0x000
    .word 0x000

    ;; Predefined seeds
SEEDS:
    .word seed0
    .word seed1
    .word seed2
    .word seed3

mask0:
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF

mask1:
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0x1FF
	.word 0x1FF
	.word 0x1FF

mask2:
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF

mask3:
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0x000

mask4:
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0x000

MASKS:
    .word mask0
    .word mask1
    .word mask2
    .word mask3
    .word mask4
