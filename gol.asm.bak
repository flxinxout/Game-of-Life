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

clear_leds:
	addi t1, zero, LEDS ; load the LEDS in t1
	addi t2, t1, 4 ; load the LEDS in t2
	addi t3, t2, 4 ; load the LEDS in t3
	stw zero, 0(t1); store in 0x2000 (LED1) 0
	stw zero, 0(t2); store in 0x2004 (LED2) 0
	stw zero, 0(t3); store in 0x2008 (LED3) 0
	ret

;; ---------------------------------------------------------------------------------------------
;; ------------------------------------------------------------------------------------------

wait: 
	addi t1, zero, COUNTER ; store value of counter in t1
	addi t2, zero, SPEED ; store address of speed in t2
	ldw t3, 0(t2) ; load speed of game from memory to t3
	bne t1, zero, decrement ; if t1 is different than 0 then we loop
	ret

decrement:
	sub t1, t1, t3 ; substract the speed of game from the counter value in t1
	bne t1, zero, decrement ; if t1 is different than 0 then we loop
	ret

;; ---------------------------------------------------------------------------------------------
;; ------------------------------------------------------------------------------------------

get_gsa:
	ldw t1, GSA_ID(zero) ;; load GSA ID
	beq zero, t1, curr_state
	;; if gsa id = 1 meaning we are using next state gsa
	addi t1, zero, GSA1 ;; store address of first GSA element
	add t2, t1, a0  ;; store address for getting the right element
	ldw v0, 0(t2) ;; load index y from gsa element
	ret
	
curr_state:
	addi t1, zero, GSA0 ;; store address of first GSA element
	add t2, t1, a0 ;; store address for getting the right element
	ldw v0, 0(t2) ;; load index y from gsa element
	ret

set_gsa:
	ldw t1, GSA_ID(zero) ;; load GSA ID
	beq zero, t1, curr_state
	;; if gsa id = 1 meaning we are using next state gsa
	addi t1, zero, GSA1
	add t2, t1, a1 ;; store address for getting the right element
	stw a0, 0(t2) ;; store the line a0 in the GSA element
	ret

set_inCurr:
	addi t1, zero, GSA0 ;; store address of first GSA element
	add t2, t1, a1 ;; store address for getting the right element
	stw a0, 0(t2) ;; store the line a0 in the GSA element
	ret

;; ---------------------------------------------------------------------------------------------
;; ------------------------------------------------------------------------------------------

draw_gsa:
	;; store in stack the return address !!
	ldw t3, GSA_ID(zero) ;; load GSA ID

	add t4, zero, zero ;; start an counter for getting all the gsa elements from the current state
	addi t5, zero, 8 ;; store the last + 1 index

	addi t6, zero, LEDS ; load the address LEDS in t6
	addi t7, t6, 4 ; load the address LEDS in t7
	;; store in stack s0
	addi s0, t6, 4 ; load the address LEDS in s0

	;; store in stack s1, s2, s3
	ldw s1, 0(t4) ; store LEDS0
	ldw s2, 0(t5) ;; store LEDS1
	ldw s3, 0(t6) ;; store LEDS2
	;; restore in s0 the last value (don't use it anymore)

	blt t4, t5, display_line_leds ;; if the counter is less than 8 then we display the current line

	;; s0, s1, s2, s3 restore the last values (don't use them anymore)
	;; go back to current control flow 

display_line_leds:
	add a0, zero, t2 ;; store in a0 the correct line for the call of get_gsa
	call get_gsa ;; we get in v0 the correct line

	;; start a for loop from 0 to 11 on the bits of the GSA 
	addi t6, zero, 12 ;;  store the last + 1 index (11)
	add t7, zero, zero ;; start an counter for getting all the bits of GSA elements

	;; store in stack s0
	addi s0, zero, 0x800 ;; mask of 1 bit in MSB for getting the bits of the GSA element (will by shifted by 1)

	blt t7, t6, display_bit_on_led
	addi t2, t2, 1 ;; increment counter of GSA element

display_bit_on_led:
	;; get the correct bit
	addi s3, zero, 4 
	blt t7, s3, display_on_led_2 ;; if the j index is less than 4 then we display on LEDS2
	addi s3, zero, 8
	blt t7, s3, display_on_led_1 ;; if the j index is less than 8 and greater than 3 then we display on LEDS1
	addi s3, zero, 12
	blt t7, s3, display_on_led_0 ;; if the j index is less than 12 and greater than 7 then we display on LEDS0
	

	srl s0, s0, 1 ;; shift mask of GSA bits by 1 (JE SAIS PAS MDR COMMENT FAIRE POUR DIRE 1)
	addi t7, t7, 1 ;; increment counter of the bits of GSA element

display_on_led_0:	
display_on_led_1:
display_on_led_2:
	;; 
	
;; ---------------------------------------------------------------------------------------------
;; ---------------------------------------------------------------------------------------------

random_gsa:
	ldw t0, GSA_ID(zero) ;; load GSA ID
	beq zero, t1, random_gsa_current_0
	;; if gsa id = 1 meaning we are using next state gsa
	

random_gsa_current_0:

;; ---------------------------------------------------------------------------------------------
;; ---------------------------------------------------------------------------------------------

change_speed:
	ldw t0, SPEED(zero) ;; load SPEED value in t0
	beq a0, zero, increment_speed ;; if a0 is 0 then we want to increment the speed
	;; if a0 is something else, then we want to decrease the speed
	addi t1, zero, 1 ;; min value of speed
	beq t1, t0, ;; GO BACK TO CURRENT FLOW !! if the speed if already 1
	sub t0, t0, 1 ;; increment by 1 the speed of the game if the speed was 9 or less
	stw t0, SPEED(zero) ;; store new value of speed
	;; GO TO CURRENT FLOW

increment_speed:
	addi t1, zero, 10 ;; max value of speed
	beq t1, t0, ;; GO BACK TO CURRENT FLOW !! if the speed if already 10
	addi t0, t0, 1 ;; increment by 1 the speed of the game if the speed was 9 or less
	stw t0, SPEED(zero) ;; store new value of speed
	;; GO TO CURRENT FLOW

;; ---------------------------------------------------------------------------------------------
;; ---------------------------------------------------------------------------------------------

pause_game:
	ldw t0, PAUSE(zero) ;; load if game is pause or running
	nor t1, t0, zero ;; nor the value in t0. If it's 0 nor 0 -> then 1, else if 1 nor 0 -> then 0
	stw t1, PAUSE(zero) ;; store the new value of pause/running
	;; RETURN CURRENT FLOW


;; ---------------------------------------------------------------------------------------------
;; ---------------------------------------------------------------------------------------------

change_steps:


;; ---------------------------------------------------------------------------------------------
;; ---------------------------------------------------------------------------------------------

increment_seed:
	ldw t0, SEED(zero) ;; load the current seed of the game
	ldw t1, CURR_STATE(zero) ;; load the current state of the game
	beq t1, INIT, increment_seed_init_case ;; if we are in INIT state
	beq t1, RAND, increment_seed_rand_case ;; if we are in RAND state
	;; else we are in RUN state what do we do ??
	ret

increment_seed_init_case:
	addi t0, t0, 1 ;; increment the seed by 1
	;; SUITE
	ret

increment_seed_rand_case:

;; ---------------------------------------------------------------------------------------------
;; ---------------------------------------------------------------------------------------------

update_state:

;; ---------------------------------------------------------------------------------------------
;; ---------------------------------------------------------------------------------------------

select_action:

;; ---------------------------------------------------------------------------------------------
;; ---------------------------------------------------------------------------------------------


	

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
