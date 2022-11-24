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
	.equ COUNTER, 0x005 ;; 0x7FF

	;; masks
	.equ 12_DOWNTO_9, 0x000F00
	.equ INITIAL_MASK_LEDS, 0x80808080
	
	

main:
    ;; TODO
	addi t0, zero, INIT
	stw t0, CURR_STATE(zero) ;; INIT

	add t0, zero, zero
	stw t0, SEED(zero) ;; seed0

	call increment_seed

	
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
	blt zero, t1, decrement ; if t1 is greater  than 0 then we loop
	ret

decrement:
	sub t1, t1, t3 ; substract the speed of game from the counter value in t1
	blt zero, t1, decrement ; if t1 is greeater than 0 then we loop
	ret

; END:wait

;; ---------------------------------------------------------------------------------------------
;; ------------------------------------------------------------------------------------------

; BEGIN:get_gsa
get_gsa:
	ldw t0, GSA_ID(zero) ;; load GSA ID
	beq zero, t0, curr_state_0
	;; if gsa id = 1 meaning we are using next state gsa
	addi t0, zero, GSA1 ;; store address of first GSA element
	addi t4, zero, 2
	sll t3, a0, t4 ;; 4*a0 for the correct word  
	add t2, t0, t3 ;; store address for getting the right element
	ldw v0, 0(t2) ;; load index y from gsa element
	ret
	
curr_state_0:
	addi t0, zero, GSA0 ;; store address of first GSA element
	addi t4, zero, 2
	sll t3, a0, t4 ;; 4*a0 for the correct word  
	add t2, t0, t3 ;; store address for getting the right element
	ldw v0, 0(t2) ;; load index y from gsa element
	ret
; END:get_gsa

; BEGIN:set_gsa
set_gsa:
	ldw t1, GSA_ID(zero) ;; load GSA ID
	beq zero, t1, curr_state_dd
	;; if gsa id = 1 meaning we are using next state gsa
	addi t1, zero, GSA1
	addi t3, zero, 2
	sll a1, a1, t3 ;; multiply by 4
	add t2, t1, a1 ;; store address for getting the right element
	stw a0, 0(t2) ;; store the line a0 in the GSA element
	ret

curr_state_dd:
	addi t1, zero, GSA0 ;; store address of first GSA element
	addi t3, zero, 2
	sll a1, a1, t3 ;; multiply by 4
	add t2, t1, a1 ;; store address for getting the right element
	stw a0, 0(t2) ;; load index y from gsa element
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

decrement_really:
	addi t0, t0, -1 
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
; END:change_speed
;; ---------------------------------------------------------------------------------------------
;; ---------------------------------------------------------------------------------------------

; BEGIN:change_steps
change_steps:
	ldw t0, CURR_STEP(zero) ;; load the current number of steps
	addi t1, zero, 1 ;; store button4 value
	beq a0, t1, increment_unit ;; check if should increment units
l1:
	beq a1, t1, increment_tens ;;check if should increment tens
l2:
	beq a2, t1, increment_hundreds ;; check if should increment hundreds
l3: 
	stw t0, CURR_STEP(zero) ;; store current step incremented
	ret

increment_unit:
	addi t0, t0, 0x1 ;; increment by 1 
	jmpi l1 ;; return to fct
increment_tens:
	addi t0, t0, 0xA ;; increment by 10
	jmpi l2 ;; return to fct
increment_hundreds:
	addi t0, t0, 0x64 ;; increment by 100 (hexa:64)
	jmpi l3 ;; return to fct

; END:change_steps

;; ---------------------------------------------------------------------------------------------
;; ---------------------------------------------------------------------------------------------
; BEGIN:pause_game
pause_game:
	ldw t0, PAUSE(zero) ;; load if game is pause or running
	andi t2, t0, 1 ;; get the first bit for security
	beq t2, zero, change_to_1
	;; change to 0
	stw zero, PAUSE(zero) ;; store the new value of pause/running
	ret

change_to_1:
	addi t2, zero, 1
	stw t2, PAUSE(zero)
	ret

; END:pause_game

;; ---------------------------------------------------------------------------------------------
;; ---------------------------------------------------------------------------------------------

; BEGIN:random_gsa
random_gsa:
	addi t0, zero, 8 ;; loop for all GSA element
	add t1, zero, zero ;; start for the first GSA element
	
	blt a1, t0, loop_through_gsa_element
	ret
	
loop_through_gsa_element:
	addi t2, zero, 13 ;; second loop for pixels
	add t3, zero, zero ;; start second counter for the second loop
	jmpi set_pixels_random

set_gsa_pixel:
	; set the a0 and a1
	add a1, zero, t1
	call set_gsa
	addi t1, t1, 1 ;; increment first oounter
	jmpi set_pixels_random

set_pixels_random:
	ldw t5, RANDOM_NUM(zero) ;; load RANDOM_NUM
	andi t4, t5, 1 ;; and mask for getting the random number between 0 and 1
	or t4, zero, t4 ;; if t4 is 1 then we store 1 in a0 and if t4 is 0 then we store 0 in a0 (OR OPERATION)
	addi t6, zero, 1
	sll a0, t4, t6 ;; shift left logical of 1 for the next iteration

	addi t3, t3, 1 ;; increment second counter
	blt t3, t2, set_pixels_random
	jmpi set_gsa_pixel

; END:random_gsa

;; ---------------------------------------------------------------------------------------------
;; ---------------------------------------------------------------------------------------------

; BEGIN:set_pixel
set_pixel:
	addi t0, zero, 4 ;; set value 4
	addi t1, zero, LEDS ; load the LEDS in t1
	addi t3, zero, 1 ;; store the mask for getting the right pixel
	addi t7, zero, 3 


	blt a0, t0, for_leds_0
	addi t0, zero, 8
	blt a0, t0, for_leds_1
	addi t0, zero, 12
	blt a0, t0, for_leds_2

store_leds:

	sll t4, a0, t7 ;; multiply the a0 by 8
	add t4, t4, a1 ;; add the y-coord to the value than we want to shift
	sll t3, t3, t4 ;; shift the mask from the right value (t4)

	ldw t2, 0(t1) ;; load the LEDS0 in t2 
	xor t5, t2, t3 ;; invert the correct pixel by and operation 
	stw t5, 0(t1) ;; store the LEDS0
	ret

for_leds_2:

	addi a0, a0, -8 ;; re-order the x-coord
	addi t1, t1, 8 ; add 8
	jmpi store_leds

for_leds_1:

	addi a0, a0, -4 ;; re-order the x-coord
	addi t1, t1, 4 ; add 4
	jmpi store_leds

for_leds_0:
	jmpi store_leds

; END:set_pixel

;; ---------------------------------------------------------------------------------------------
;; ---------------------------------------------------------------------------------------------

; BEGIN:increment_seed
increment_seed:
	ldw t0, SEED(zero) ;; load the current seed of the game
	ldw t1, CURR_STATE(zero) ;; load the current state of the game
	addi t2, zero, INIT
	beq t1, t2, increment_seed_init_case ;; if we are in INIT state
	addi t2, zero, RAND
	beq t1, t2, increment_seed_rand_case ;; if we are in RAND state
	;; else we are in RUN state what do we do ??
	ret

increment_seed_init_case:
	addi t0, t0, 1 ;; increment the seed by 1
	stw t0, SEED(zero) ;; store new seed
	
	;; copy the new seed

	addi t7, zero, 8
	add t5, zero, zero
	add t6, zero, zero
	beq t0, zero, set_seed0
	addi t3, zero, 1
	beq t0, t3, set_seed1
	addi t3, zero, 2
	beq t0, t3, set_seed2
	addi t3, zero, 3
	beq t0, t3, set_seed3

copy_seed:
	add a1, zero, t6 ;; store the y-coord for set gsa
	call set_gsa
	addi t6, t6, 1 ;; increment counter
	addi t5, t5, 4 ;; next word
	blt t6, t7, copy_seed
	ret

set_seed0: 
	ldw t4, seed0(t5) ;; load the word of seed
	add a0, zero, t4 ;; store the word in a0 for set gsa

	add a1, zero, t6 ;; store the y-coord for set gsa
	
	add s0, zero, ra
	call set_gsa
	addi t6, t6, 1 ;; increment counter
	addi t5, t5, 4 ;; next word
	blt t6, t7, set_seed0
	add t0, zero, s0
	
	jmp t0

set_seed1:
	ldw t4, seed1(t5) ;; load the word of seed
	add a0, zero, t4 ;; store the word in a0 for set gsa

	add a1, zero, t6 ;; store the y-coord for set gsa

	add s0, zero, ra
	call set_gsa
	addi t6, t6, 1 ;; increment counter
	addi t5, t5, 4 ;; next word
	blt t6, t7, set_seed1
	add t0, zero, s0
	
	jmp t0

set_seed2:
	ldw t4, seed2(t5) ;; load the word of seed
	add a0, zero, t4 ;; store the word in a0 for set gsa

	add a1, zero, t6 ;; store the y-coord for set gsa
	add s0, zero, ra
	call set_gsa
	addi t6, t6, 1 ;; increment counter
	addi t5, t5, 4 ;; next word
	blt t6, t7, set_seed1
	add t0, zero, s0
	
	jmp t0

set_seed3:
	ldw t4, seed3(t5) ;; load the word of seed
	add a0, zero, t4 ;; store the word in a0 for set gsa

	add a1, zero, t6 ;; store the y-coord for set gsa
	call set_gsa
	addi t6, t6, 1 ;; increment counter
	addi t5, t5, 4 ;; next word
	blt t6, t7, set_seed1
	add t0, zero, s0
	
	jmp t0

increment_seed_rand_case:
	call random_gsa
	ret

; END:increment_seed


;; ---------------------------------------------------------------------------------------------
;; ---------------------------------------------------------------------------------------------

; BEGIN:update_state
update_state:
	ldw t0, CURR_STATE(zero) ;; load the current state
	addi t1, zero, 4
	addi t1, t1, BUTTONS ;; store address of edgecapture
	addi t7, zero, INIT
	beq t0, t7, from_init ;; if we are in the INIT STATE
	addi t7, zero, RAND
	beq t0, t7, from_rand ;; if we are in the RAND STATE
	addi t7, zero, RUN
	beq t0, t7, from_run ;; if we are in the RUN STATE

from_init:
	addi t2, zero, 1 ;; store the mask
	addi t3, zero, 1
	sll t2, t2, t3 ;; shift by 1 for getting b1
	and t7, a0, t2 ;; and the edgecapture with the mask to get the value of the b1
	bne t7, zero, change_to_run ;; if b1 is pressed, then we go to RUN STATE
	
	ldw t4, SEED(zero) ;; load the current seed (0,1,2,3)
	addi t6, zero, 3
	andi t7, a0, 1 ;; and the edgecapture with the mask to get the value of the b0
	bne t7, zero, check_if_b1_pressed ;; if b0 is pressed
	ret
check_if_b1_pressed:
	beq t4, t6, change_to_rand ;; if N = 3
	ret

from_rand:
	andi t7, a0, 2 ;; and the edgecapture with the mask to get the value of the b1
	bne t7, zero, change_to_run ;; if b1 is pressed, then we go to RUN STATE
	ret

from_run:
	andi t7, a0, 8 ;; and the edgecapture with the mask to get the value of the b3
	bne t7, zero, change_to_init ;; if b3 is pressed, then we go to INIT STATE
	ret

change_to_init:
	addi t3, zero, INIT
	stw t3, 0(t1) ;; store the new current state
	call reset_game
	ret

change_to_run:
	addi t3, zero, RUN
	stw t3, 0(t1) ;; store the new current state
	ret

change_to_rand:
	addi t3, zero, RAND
	stw t3, 0(t1) ;; store the new current state
	ret

; END:update_state

;; ---------------------------------------------------------------------------------------------
;; ---------------------------------------------------------------------------------------------

; BEGIN:cell_fate
cell_fate:
	beq a1, zero, check_if_dead_has_to_become_alive 
	addi t1, zero, 1
	beq a1, t1, check_if_alive_has_to_become_dead

check_if_alive_has_to_become_dead:
	addi t0, zero, 2
	blt a0, t0, set_dead
	addi t0, zero, 4
	bge a0, t0, set_dead
	add v0, zero, a1 ;; stay alive
	ret

set_dead:
	add v0, zero, zero ;; become dead
	ret

check_if_dead_has_to_become_alive:
	addi t0, zero, 3
	beq a0, t0, set_alive
	add v0, zero, zero ;; stay dead
	ret

set_alive:
	addi t0, zero, 1
	add v0, zero, t0 ;; become alive
	ret

; END:cell_fate

;; ---------------------------------------------------------------------------------------------
;; ---------------------------------------------------------------------------------------------

; BEGIN:find neighbours
find_neighbours:
	addi t0, zero, LEDS ; load the LEDS in t0
	addi t1, zero, 4 ;; set value 4
	addi t3, zero, 1 ;; store the mask for getting the right pixel
	addi t7, zero, 3 
	sll t4, a0, t7 ;; multiply the a0 by 8 in t4
	add t4, t4, a1 ;; add the y-coord to the value than we want to shift
	sll t3, t3, t4 ;; shift the mask from the right value (t4)

	blt a0, t1, examine_leds0 ;; if the x-coord is in [0,3]
	addi t1, zero, 8
	blt a0, t1, examine_leds1
	addi t1, zero, 12
	blt a0, t1, examine_leds2
	ret

compute_neighbours:
	and t5, t2, t3 ;; get the correct pixel by and operation with the mask computed before
	bne t5, zero, alive_cell

alive_cell:
	

examine_leds0:
	ldw t2, 0(t0) ;; load the LEDS0 in t2 
	jmpi compute_neighbours

examine_leds1:
	addi t0, t0, 4 ; add 4
	ldw t2, 0(t0) ;; load the LEDS1 in t2 
	jmpi compute_neighbours

examine_leds2:
	addi t0, t0, 8 ; add 8
	ldw t2, 0(t0) ;; load the LEDS2 in t2 
	jmpi compute_neighbours

; END:find neighbours

;; ---------------------------------------------------------------------------------------------
;; ---------------------------------------------------------------------------------------------
select_action:
  	ldw t0, CURR_STATE(zero) ;; load the current state in t0

	;; CHECK STATE: INIT, RUN, RAND
  	addi t1, zero, INIT
  	beq t0, t1, from_init_state

  	addi t1, zero, RUN
  	beq t0, t1, from_run_state

  	addi t1, zero, RAND
  	beq t0, t1, from_rand_state
	ret

from_init_state:

  	;;CHECK BUTTON PRESSED: b0-b2-b3-b4

  	andi t0, a0, 1 ;; mask the a0 for b0
  	bne t0, zero, b0_from_init ;; if b0 is different than 0, then we want to check if it's < N_SEEDS
  
  	andi t0, a0, 4 ;; mask the a0 for b2
  	bne t0, zero, change_steps ;; if b2 is different than 0, then we want to stay in INIT
  
  	andi t0, a0, 8  ;; mask the a0 for b3
  	bne t0, zero, change_steps  ;; if b3 is different than 0, then we want to stay in INIT

  	andi t0, a0, 16  ;; mask the a0 for b4
  	bne t0, zero, change_steps  ;; if b4 is different than 0, then we want to stay in INIT
	ret

	;; CALL FUNCTION FROM INIT STATE

b0_from_init:
	addi t2, zero, 3
	ldw t3, SEED(zero) ;; load the seed
	bge t3, t2, update_state ;; if the seed is 3 or more then we change the state 
  	call increment_seed ;; else we increment the seed by the rules
	ret

from_run_state:

  	;;CHECK BUTTON PRESSED: b0-b1-b2-b4

  	andi t0, a0, 1
  	bne t0, zero, pause_game
  
  	andi t0, a0, 2
  	bne t0, zero, b1_from_run
  
  	andi t0, a0, 4
  	bne t0, zero, b2_from_run

  	andi t0, a0, 16
  	bne t0, zero, random_gsa ;; TO IMPLEMENT

	;;CALL FUNCTION FROM RUN STATE

b1_from_run:
  	add a0, zero, zero
  	call change_speed

b2_from_run:
  	addi a0, zero, 1
  	call change_speed
  
from_rand_state:

  	;;CHECK BUTTON PRESSED: b0-b1-b2-b3-b4

  	andi t0, a0, 1
  	bne t0, zero, random_gsa

  	andi t0, a0, 4
  	bne t0, zero, change_steps

  	andi t0, a0, 8
  	bne t0, zero, change_steps

  	andi t0, a0, 16
  	bne t0, zero, change_steps


;; ---------------------------------------------------------------------------------------------
;; ---------------------------------------------------------------------------------------------


; BEGIN:reset_game
reset_game:
	ret
; END:reset_game

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
