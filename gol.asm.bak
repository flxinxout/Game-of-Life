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
	addi sp, zero, CUSTOM_VAR_END

	call reset_game
	call get_input

loop_main:
	call select_action
	call update_state
	call update_gsa
	call mask
	call draw_gsa
	call wait
	call decrement_step
	call get_input
	ret	

; BEGIN:clear_leds
clear_leds:
	stw zero, LEDS(zero); store in 0x2000 (LED0)
	addi t1, zero, LEDS ; load the LEDS in t1
	addi t1, t1, 4 ; load the LEDS in t2
	stw zero, 0(t1); store in 0x2004 (LED1)
	addi t1, t1, 4
	stw zero, 0(t1); store in 0x2008 (LED2)
	ret
; END:clear_leds
; BEGIN:wait
wait: 
	addi t1, zero, COUNTER ; store value of counter in t1
	ldw t3, SPEED(zero) ; load speed of game from memory to t3
	blt zero, t1, decrement ; if t1 is greater  than 0 then we loop
	ret

decrement:
	sub t1, t1, t3 ; substract the speed of game from the counter value in t1
	blt zero, t1, decrement ; if t1 is greeater than 0 then we loop
	ret
; END:wait
; BEGIN:get_gsa
get_gsa:
	ldw t0, GSA_ID(zero) ;; load GSA ID
	beq zero, t0, curr_state_0
	;; if gsa id = 1 meaning we are using next state gsa
	addi t0, zero, GSA1 ;; store address of first GSA element
continue_get_gsa:
	addi t4, zero, 2
	sll t4, a0, t4 ;; 4*a0 for the correct word  
	add t0, t0, t4 ;; store address for getting the right element
	ldw v0, 0(t0) ;; load index y from gsa element
	ret
	
curr_state_0:
	addi t0, zero, GSA0 ;; store address of first GSA element
	jmpi continue_get_gsa
; END:get_gsa
; BEGIN:set_gsa
set_gsa:
	ldw t1, GSA_ID(zero) ;; load GSA ID
	beq zero, t1, curr_state_at_0
	;; if gsa id = 1 meaning we are using next state gsa
	addi t1, zero, GSA1
continue_set_gsa:
	addi t3, zero, 2
	sll t3, a1, t3 ;; multiply by 4
	add t3, t1, t3 ;; store address for getting the right element
	stw a0, 0(t3) ;; store the line a0 in the GSA element
	ret

curr_state_at_0:
	addi t1, zero, GSA0 ;; store address of first GSA element
	jmpi continue_set_gsa

; END:set_gsa
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
	addi t0, t0, 0x10 ;; increment by 16
	jmpi l2 ;; return to fct
increment_hundreds:
	addi t0, t0, 0x100 ;; increment by 256 (hexa:64)
	jmpi l3 ;; return to fct

; END:change_steps
; BEGIN:pause_game
pause_game:
	ldw t0, PAUSE(zero) ;; load if game is pause or running
	andi t0, t0, 1 ;; get the first bit for security
	beq t0, zero, change_to_1
	;; change to 0
	stw zero, PAUSE(zero) ;; store the new value of pause/running
	ret

change_to_1:
	addi t2, zero, 1
	stw t2, PAUSE(zero)
	ret
; END:pause_game
; BEGIN:random_gsa
random_gsa:
	addi sp, sp, -20
	stw s0, 16(sp)
	stw s1, 12(sp)
	stw s2, 8(sp)
	stw s3, 4(sp)
	stw ra, 0(sp)

	addi s0, zero, 8 ;; loop for all GSA element               
	add s1, zero, zero ;; start for the first GSA element
	jmpi continue_first_loop

continue_first_loop:
	blt s1, s0, loop_through_gsa_element
	ldw ra, 0(sp)
	addi sp, sp, 4
	ldw s3, 0(sp)
	addi sp, sp, 4
	ldw s2, 0(sp)
	addi sp, sp, 4
	ldw s1, 0(sp)
	addi sp, sp, 4
	ldw s0, 0(sp)
	addi sp, sp, 4
	ret
	
loop_through_gsa_element:
	addi s2, zero, 13 ;; second loop for pixels
	add s3, zero, zero ;; start second counter for the second loop
	add a0, zero, zero
	jmpi set_pixels_random

set_gsa_pixel:
	; set the a0 and a1
	add a1, zero, s1

	call set_gsa
	addi s1, s1, 1 ;; increment first oounter
	;ldw ra, 16(sp)
	jmpi continue_first_loop

set_pixels_random:
	ldw t5, RANDOM_NUM(zero) ;; load RANDOM_NUM                                         RESET AFTER!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	;addi t5, zero, 11
	andi t4, t5, 1 ;; and mask for getting the random number between 0 and 1
	or a0, a0, t4 ;; set the last bit to 0 or 1

	addi t5, zero, 11
	beq t5, s3, set_gsa_pixel
	jmpi not_last_shift
	
not_last_shift:	
	addi t6, zero, 1
	sll a0, a0, t6 ;; shift left logical of 1 for the next iteration

	addi s3, s3, 1 ;; increment second counter
	blt s3, s2, set_pixels_random
	jmpi set_gsa_pixel

; END:random_gsa
; BEGIN:set_pixel
set_pixel:
	addi t0, zero, 4 ;; set value 4
	addi t1, zero, LEDS ; load the LEDS in t1
	addi t3, zero, 1 ;; store the mask for getting the right pixel

	blt a0, t0, for_leds_0
	addi t0, zero, 8
	blt a0, t0, for_leds_1
	addi t0, zero, 12
	blt a0, t0, for_leds_2
	ret

store_leds:
	slli t4, a0, 3 ;; multiply the a0 by 8
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
; BEGIN:increment_seed
increment_seed:
	addi sp, sp, -16
	stw ra, 12(sp)
	stw s0, 8(sp)
	stw s1, 4(sp)
	stw s2, 0(sp)

	ldw s0, SEED(zero) ;; load the current seed of the game
	ldw t1, CURR_STATE(zero) ;; load the current state of the game
	addi t2, zero, INIT
	beq t1, t2, increment_seed_init_case ;; if we are in INIT state
	addi t2, zero, RAND
	beq t1, t2, increment_seed_rand_case ;; if we are in RAND state
	ret
	

increment_seed_init_case:
	addi t7, t7, 4
	beq s0, t7, end_seed
	addi s0, s0, 1 ;; increment the seed by 1
	stw s0, SEED(zero) ;; store new seed
	
	addi t2, zero, 8
	add s1, zero, zero
	add s2, zero, zero
	jmpi check_seed_to_go

check_seed_to_go:
	beq s0, zero, set_seed0
	addi t3, zero, 1
	beq s0, t3, set_seed1
	addi t3, zero, 2
	beq s0, t3, set_seed2
	addi t3, zero, 3
	beq s0, t3, set_seed3
	call random_gsa
	jmpi end_seed

continue_increment_seed:
	add a0, zero, t4 ;; store the word in a0 for set gsa
	add a1, zero, s2 ;; store the y-coord for set gsa with t6

	call set_gsa
	addi s2, s2, 1 ;; increment counter
	addi s1, s1, 4 ;; next word
	jmpi check_seed_to_go

end_seed:
	ldw s2, 0(sp)
	addi sp, sp, 4
	ldw s1, 0(sp)
	addi sp, sp, 4
	ldw s0, 0(sp)
	addi sp, sp, 4
	ldw ra, 0(sp)
	addi sp, sp, 4
	ret

set_seed0: 
	ldw t4, seed0(s1) ;; load the word of seed
	add a0, zero, t4 ;; store the word in a0 for set gsa
	add a1, zero, s2 ;; store the y-coord for set gsa with t6

	call set_gsa
	addi s2, s2, 1 ;; increment counter
	addi s1, s1, 4 ;; next word
	blt s2, t2, set_seed0
	jmpi end_seed

set_seed1:
	ldw t4, seed1(s1) ;; load the word of seed
	add a0, zero, t4 ;; store the word in a0 for set gsa
	add a1, zero, s2 ;; store the y-coord for set gsa with t6

	call set_gsa
	addi s2, s2, 1 ;; increment counter
	addi s1, s1, 4 ;; next word
	blt s2, t2, set_seed1
	jmpi end_seed

set_seed2:
	ldw t4, seed2(s1) ;; load the word of seed
	add a0, zero, t4 ;; store the word in a0 for set gsa
	add a1, zero, s2 ;; store the y-coord for set gsa with t6

	call set_gsa
	addi s2, s2, 1 ;; increment counter
	addi s1, s1, 4 ;; next word
	blt s2, t2, set_seed2
	jmpi end_seed

set_seed3:
	ldw t4, seed3(s1) ;; load the word of seed
	add a0, zero, t4 ;; store the word in a0 for set gsa
	add a1, zero, s2 ;; store the y-coord for set gsa with t6

	call set_gsa
	addi s2, s2, 1 ;; increment counter
	addi s1, s1, 4 ;; next word
	blt s2, t2, set_seed3
	jmpi end_seed

increment_seed_rand_case:
	call random_gsa
	jmpi end_seed
; END:increment_seed
; BEGIN:draw_gsa
draw_gsa:
	addi sp, sp, -16
	stw s2, 12(sp) ; store current mask
	stw ra, 8(sp)
	stw s0, 4(sp) ; counter for x in element
	stw s1, 0(sp) ; couner y in all gsa element
	
	addi s1, zero, 8 ; start att gsa number 7 / 8 for convenience
	jmpi foreach_gsa_el

foreach_gsa_el:
	addi s1, s1, -1 ; decrement y-coord
	blt s1, zero, finish_draw ; if s1 < 0, then we finish
	addi s0, zero, 12 ; start at last bit in gsa element / 12 for convenience
	add a0, zero, s1 ; set y-index for get_gsa
	call get_gsa ; get in v0 the correct line of gsa element
	addi s2, zero, 0x1000 ; 1000000000000 / 13 bit for convenient of shift
	jmpi foreach_bit

foreach_bit:
	addi s0, s0, -1 ; decrement x-coord
	blt s0, zero, foreach_gsa_el ; if s0 < 0, then we continue on next gsa elementa
	srli s2, s2, 1 ; shift to right mask for current bit
	and t0, v0, s2 ; and the v0 with the mask to know if it's 0 or 1
	beq t0, zero, foreach_bit ; if 0 we do nothing
	add a1, zero, s1 ; for set_pixel
	add a0, zero, s0 ; for set_pixel
	call set_pixel
	jmpi foreach_bit ; continue with current gsa element
			  
finish_draw:
	ldw s1, 0(sp)
	addi sp, sp, 4
	ldw s0, 0(sp)
	addi sp, sp, 4
	ldw ra, 0(sp)
	addi sp, sp, 4
	ldw s2, 0(sp)
	addi sp, sp, 4
	ret
; END:draw_gsa
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
; BEGIN:find_neighbours
find_neighbours:
	addi sp, sp, -28
	stw ra, 24(sp)
	stw s0, 20(sp) ;; counter loop i -1 to 1 for line gsa
	stw s1, 16(sp) ;; counter loop j -1 to 1 for column gsa
	stw s2, 12(sp) ;; number of living neighbours
	stw s5, 8(sp) ;;
	stw s6, 4(sp) ;; x 
	stw s7, 0(sp) ;; y
	
	addi s0, zero, -2 ; 
	addi s1, zero, -2 ; 
	addi s5, zero, 2 ;; fixed value

;; stocke x et y
	add s6, zero, a0
	add s7, zero, a1
	add v1, zero, zero
	
start_computation:
	addi s0, s0, 1
	bge s0, s5, end_computation
	add a0, s7, s0
	andi a0, a0, 7 ; mod 8

	call get_gsa
	addi s1, zero, -2 ; reset value of s1 for x-coord
	
inner_loop:
	addi s1, s1, 1
	bge s1, s5, start_computation
	add t0, s6, s1
	jmpi mod_12
	
continue_inner_loop:
	addi t2, zero, 1
	sll t1, t2, t0 ;; mask to get the correct cell in gsa
	and t3, v0, t1 ;; apply mask on v0
	bne t3, zero, add_neighbour
	jmpi inner_loop
	
add_neighbour: 
	addi s2, s2, 1
	or t4, s0, s1
	beq t4, zero, set_v1
	jmpi inner_loop

set_v1:
	addi v1, zero, 1 
	jmpi inner_loop

end_computation:
	add v0, s2, zero
	ldw ra, 0(sp)
	addi sp, sp, 4
	ldw s0, 0(sp)
	addi sp, sp, 4
	ldw s1, 0(sp)
	addi sp, sp, 4 
	ldw s2, 0(sp)
	addi sp, sp, 4
	ldw s5, 0(sp)
	addi sp, sp, 4
	ldw s6, 0(sp)
	addi sp, sp, 4
	ldw s7, 0(sp)
	addi sp, sp, 4
	ret

mod_12:
	addi t2, zero, 12
	beq t0, t2, map_to_0
	addi t2, zero, -1
	beq t0, t2, map_to_11
	jmpi continue_inner_loop

map_to_0:
	add t0, zero, zero
	jmpi continue_inner_loop

map_to_11:
	addi t0, zero, 11
	jmpi continue_inner_loop
; END:find_neighbours
; BEGIN:select_action
select_action:
	addi sp, sp, -4
	stw ra, 0(sp)
  	ldw t0, CURR_STATE(zero) ;; load the current state in t0

  	addi t1, zero, INIT
  	beq t0, t1, from_init_state

  	addi t1, zero, RUN
  	beq t0, t1, from_run_state

  	addi t1, zero, RAND
  	beq t0, t1, from_rand_state
	ret

from_init_state:
	addi sp, sp, -4
	stw s0, 0(sp)
  	;;CHECK BUTTON PRESSED: b0-b2-b3-b4
	add s0, a0, zero

  	andi t0, a0, 1 ;; mask the a0 for b0
  	bne t0, zero, b0_from_init ;; if b0 is different than 0, then we want to check if it's < N_SEEDS
  
  	andi t0, s0, 4 ;; mask the a0 for b2
  	bne t0, zero, b2_change_steps ;; if b2 is different than 0, then we want to stay in INIT
  
  	andi t0, s0, 8  ;; mask the a0 for b3
  	bne t0, zero, b3_change_steps  ;; if b3 is different than 0, then we want to stay in INIT

  	andi t0, s0, 16  ;; mask the a0 for b4
  	bne t0, zero, b4_change_steps  ;; if b4 is different than 0, then we want to stay in INIT
	jmpi end_action

end_action:
	ldw s0, 0(sp)
	addi sp, sp, 4
	ldw ra, 0(sp)	
	addi sp, sp, 4
	ret

b0_from_init:
  	call increment_seed ;; else we increment the seed by the rules
	jmpi end_action

b2_change_steps:
	add a0, zero, zero
	add a1, zero, zero
	addi a2, zero, 1 
	call change_steps
	jmpi end_action

b3_change_steps:
	add a0, zero, zero
	addi a1, zero, 1
	add a2, zero, zero 
	call change_steps
	jmpi end_action

b4_change_steps:
	addi a0, zero, 1
	add a1, zero, zero
	add a2, zero, zero 
	call change_steps
	jmpi end_action

from_run_state:
  	;;CHECK BUTTON PRESSED: b0-b1-b2-b4

  	andi t0, a0, 1
  	bne t0, zero, b_pause_game
  
  	andi t0, a0, 2
  	bne t0, zero, b1_from_run
  
  	andi t0, a0, 4
  	bne t0, zero, b2_from_run

  	andi t0, a0, 16
  	bne t0, zero, random_gsa
	ldw ra, 0(sp)
	addi sp, sp, 4
	ret

b_pause_game:
	call pause_game
	ldw ra, 0(sp)
	addi sp, sp, 4
	ret

b1_from_run:
  	add a0, zero, zero
  	call change_speed
	ldw ra, 0(sp)
	addi sp, sp, 4
	ret

b2_from_run:
  	addi a0, zero, 1
  	call change_speed
	ldw ra, 0(sp)
	addi sp, sp, 4
	ret
  
from_rand_state:
	addi sp, sp, -4
	stw s0, 0(sp)
	add s0, a0, zero
  	;;CHECK BUTTON PRESSED: b0-b1-b2-b3-b4

  	andi t0, a0, 4
  	bne t0, zero, b2_change_steps

  	andi t0, a0, 8
  	bne t0, zero, b3_change_steps

  	andi t0, a0, 16
  	bne t0, zero, b4_change_steps

	andi t0, a0, 1
  	bne t0, zero, random_gsa
	jmpi end_action
; END:select_action
; BEGIN:decrement_step
decrement_step:
  	addi sp, sp, -8
  	stw ra, 4(sp)
  	stw s1, 0(sp) ; counter of loop
	
	addi t2, zero, SEVEN_SEGS
	addi t7, zero, 0xF00 ; maska
	slli t7, t7, 4
	addi s1, zero, 3 ; counter

	ldw t1, CURR_STATE(zero)
	addi t4, zero, RUN
	add v0, zero, zero
	bne t1, t4, assign_segment ;; if not in run state (avoid decrementing)

  	ldw t1, PAUSE(zero)
	bne t1, zero, display_segments
	jmpi assign_segment

display_segments:
;; case where not paused
	ldw t0, CURR_STEP(zero)
	bne t0, zero, decrement_really_2
	addi v0, zero, 1
	jmpi assign_segment

decrement_really_2:
	addi t0, t0, -1 ; decrease if in run state
	add v0, v0, zero

assign_segment:
	and t1, t0, t7
	slli t3, s1, 2 ;; index *4
	addi t3	, t3, -2 ;; to get the right address for font data we have to sub 2 before shifting (avoid doing 2 shifts)
	srl t1, t1, t3 ;; number in font data containing the right 'digit' 0-F

	ldw t4, font_data(t1) ;; get in t4 the value of the correct char to store in seven seg display
	stw t4, 0(t2)
	addi t2, t2, 4
	srli t7, t7, 4 ;; shift the mask by 4 bits
	
	addi s1, s1, -1
	bge s1, zero, assign_segment
	jmpi reset_stack


reset_stack:
  	ldw s1, 0(sp)
  	addi sp, sp, 4
  	ldw ra, 0(sp)
  	addi sp, sp, 4
	ret

; END:decrement_step
; BEGIN:reset_game
reset_game:
	addi sp, sp, -4
  	stw ra, 0(sp)
	;; set step at 1
	call clear_leds
	;; game state to 0 and seed 0 on leds
  	stw zero, CURR_STATE(zero)

  	addi t1, zero, 1
  	stw t1, CURR_STEP(zero)

	addi t2, zero, SEVEN_SEGS
	stw zero, 0(t2)
	addi t2, t2, 4
	stw zero, 0(t2)
	addi t2, t2, 4
	stw zero, 0(t2)
	addi t2, t2, 4
	ldw t3, font_data+4(zero)
	stw t3, 0(t2)

	;; set seed at -1
	addi t0, zero, -1
  	stw t0, SEED(zero)
	;; set gsa id 0
  	stw zero, GSA_ID(zero)

	call increment_seed

	;; pause game
	stw zero, PAUSE(zero)
next_t:
	;; game speed at 1
  	addi t0, zero, MIN_SPEED
  	stw t0, SPEED(zero)

  	call draw_gsa ;; diplay seed on leds
  	ldw ra, 0(sp)
	addi sp, sp, 4
	ret

; END:reset_game
; BEGIN:get_input
get_input:
  	addi t0, zero, BUTTONS
  	addi t0, t0, 4 
  	ldw v0, 0(t0)
  	stw zero, 0(t0)
	ret
; END:get_input  
; BEGIN:mask
mask:  
  	add t0, zero, zero
  	addi sp, sp, -20
  	stw s0, 16(sp)
  	stw s1, 12(sp)
  	stw s2, 8(sp)
	stw s3, 4(sp)
	stw ra, 0(sp)
  	addi s0, zero, 0 ;; gsa line counter
  	addi s1, zero, 0 ;; mask counter
  	addi t5, zero, 7 ;; loop upper bound
  	;; test which mask must be used
	ldw s2, SEED(zero)
  	jmpi check_seed

end_mask:
  	ldw ra, 0(sp)
  	addi sp, sp, 4
	ldw s3, 0(sp)
	addi sp, sp, 4
  	ldw s2, 0(sp)
  	addi sp, sp, 4
  	ldw s1, 0(sp)
  	addi sp, sp, 4
  	ldw s0, 0(sp)
  	addi sp, sp, 4
  	ret						

check_seed:
  	beq s2, zero, mask_0
  	addi t0, zero, 1

  	beq s2, t0, mask_1
  	addi t0, t0, 1

  	beq s2, t0, mask_2
  	addi t0, t0, 1

  	beq s2, t0, mask_3
	jmpi mask_4
  
mask_0:
  ldw s3, mask0(s1) ;; load the mask at index s1
  bge t5, s0, apply_mask ;; while we reach 7 for the gsa elements
  jmpi end_mask

mask_1:
  ldw s3, mask1(s1) ;; load the mask at index t1
  bge t5, s0, apply_mask
  jmpi end_mask

mask_2:
  ldw s3, mask2(s1) ;; load the mask at index t1
  bge t5, s0, apply_mask
  jmpi end_mask

mask_3:
  ldw s3, mask3(s1) ;; load the mask at index t1
  bge t5, s0, apply_mask
  jmpi end_mask

mask_4:
  ldw s3, mask4(s1) ;; load the mask at index t1
  bge t5, s0, apply_mask
  jmpi end_mask
  
apply_mask:
  	add a0, s0, zero  ;; store in a0 which line should be 
  	call get_gsa   ;; get the t3 gsa element

  	and t0, v0, s3 ;; apply the mask to the gsa element
  	add a0, t0, zero ;; set line arg for set_gsa
  	add a1, s0, zero ;; set yth coordintate arg for set_gsa

  	call set_gsa

  	addi s1, s1, 4 ;; increment counter word mask
  	addi s0, s0, 1 ;; increment counter line gsa
   	jmpi check_seed
; END:mask
; BEGIN:update_gsa
update_gsa:
	ldw t0, PAUSE(zero)
	beq t0, zero, stop_procedure
	addi sp, sp, -16
	stw ra, 12(sp)
	stw s0, 8(sp)
	stw s1, 4(sp)
	stw s2, 0(sp)
  	addi s0, zero, 7 ;; counter i from 8
	ldw t6, GSA_ID(zero)
	beq t6, zero, loop_gsa0
	addi t6, zero, GSA0
	addi t6, t6, 0x1C
	ldw t6, 0(t6) ;; load the current gsa element starting from the end
	stw zero, GSA_ID(zero)
  	jmpi loop1 ;; if i>=0 loop

stop_procedure:
	ret

loop_gsa0:
	addi t6, zero, GSA1
	addi t6, t6, 0x1C
	ldw t6, 0(t6) ;; load the current gsa element starting from the end
	addi t7, zero, 1
	stw t7, GSA_ID(zero)
	jmpi loop1

loop1:
	bge s0, zero, continue_loop1
	ldw s2, 0(sp)
	addi sp, sp, 4
	ldw s1, 0(sp)
	addi sp, sp, 4
	ldw s0, 0(sp)
	addi sp, sp, 4
	ldw ra, 0(sp)
	addi sp, sp, 4
	ret

continue_loop1:  
  	addi s1, zero, 0xB ;; counter for y-coord
  	add a0, s1, zero ;; set the i coordinate for find_neighbours
  	bge s1, zero, loop2 ;; iterate on cell of line i
  
loop2:
  	add a1, s0, zero
  	call find_neighbours
 
  	add a0, v0, zero ;; argument for cell_fate: # of neighbours
  	add a1, v1, zero ;; argument for cell_fate: cell state

  	call cell_fate
  
  	add a0, s1, zero ;;arg for set_pixel: x coordinate
  	add a1, s0, zero ;;arg for set_pixel: y coordinate 

	sll v0, v0, s1 ;; shift result to set it in the right position of gsa element
	or s2, s2, v0 ;; set in s2

  	addi s1, s1,  -1 ;; decrement counter
  	bge s1, zero, loop2 ;; if counter >=0 then loop2

	add a0, zero, s2
	add a1, zero, s0
	call set_gsa
	addi s0, s0, -1 ;; decrement counter	
  	jmpi loop1
; END:update_gsa
; BEGIN:update_state
update_state:	
	ldw t0, CURR_STATE(zero) ;; load the current state
	addi t7, zero, INIT
	beq t0, t7, from_init ;; if we are in the INIT STATE
	addi t7, zero, RAND
	beq t0, t7, from_rand ;; if we are in the RAND STATE
	addi t7, zero, RUN
	beq t0, t7, from_run ;; if we are in the RUN STATE

from_init:
	andi t7, a0, 2 ;; and the edgecapture with the mask to get the value of the b1
	bne t7, zero, change_to_run ;; if b1 is pressed, then we go to RUN STATE
	
	andi t7, a0, 1 ;; and the edgecapture with the mask to get the value of the b0
	bne t7, zero, check_if_b0_pressed ;; if b0 is pressed
	ret

check_if_b0_pressed:
	addi t6, zero, 4
	ldw t4, SEED(zero) ;; load the current seed (0,1,2,3)
	beq t4, t6, change_to_rand ;; if N = 4
	ret

from_rand:
	andi t7, a0, 2 ;; and the edgecapture with the mask to get the value of the b1
	bne t7, zero, change_to_run ;; if b1 is pressed, then we go to RUN STATE
	ret

from_run:
	andi t7, a0, 8 ;; and the edgecapture with the mask to get the value of the b3
	bne t7, zero, change_to_init ;; if b3 is pressed, then we go to INIT STATE
	ldw t0, CURR_STEP(zero) ;; load the remaining steps
	beq t0, zero, change_to_init
	ret

change_to_init:
	addi t7, zero, INIT
	stw t7, CURR_STATE(zero) ;; store the new current state
	addi sp, sp, -4
	stw ra, 0(sp)
	call reset_game
	ldw ra, 0(sp)
	addi sp, sp, 4
	ret

change_to_run:
	addi t7, zero, RUN
	stw t7, CURR_STATE(zero) ;; store the new current state
	addi t7, zero, 1
	stw t7, PAUSE(zero)
	ret

change_to_rand:
	addi t7, zero, RAND
	stw t7, CURR_STATE(zero) ;; store the new current state
	ret

; END:update_state


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
