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
	.equ COUNTER, 0x8000

	;; masks
	.equ 12_DOWNTO_9, 0xF00
	.equ INITIAL_MASK_LEDS, ox80808080
	
	

main:
    ;; TODO


clear_leds:
	addi t1, zero, LEDS ; load the LEDS in t1
	addi t2, t1, 4 ; load the LEDS in t2
	addi t3, t2, 4 ; load the LEDS in t3
	stw zero, 0(t1); store in 0x2000 (LED1) 0
	stw zero, 0(t2); store in 0x2004 (LED2) 0
	stw zero, 0(t3); store in 0x2008 (LED3) 0
	ret

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

draw_gsa:
	ldw t1, GSA_ID(zero) ;; load GSA ID
	addi t2, zero, zero ;; start an counter for getting all the gsa elements from the current state
	addi t3, zero, 8 ;; store the last + 1 index
	blt t2, t3, display_line_leds ;; if the counter is less than 8 then we display the current line

display_line_leds:
	add a0, zero, t2 ;; store in a0 the correct line for the call of get_gsa
	addi t4, zero, LEDS ; load the LEDS in t1
	addi t5, t4, 4 ; load the LEDS in t2
	addi t6, t4, 4 ; load the LEDS in t3
	ldw s0, 0(t4)
	ldw s1, 0(t5)
	ldw s2, 0(t6)
	call get_gsa ;; we get in v0 the correct line
	and s3, v0, 12_DOWNTO_9 ;; get the 4 most significant bits
	and s4, s0, INITIAL_MASK_LEDS ;; get the bits of the led line
	
	
	


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
