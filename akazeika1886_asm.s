@ Assembly File - Assignment 4/5

    .code   16
    .text

    .align  2
    .syntax unified

.equ GPIOE_ODR, 0x48001014          @ Address of GPIOE->ODR (output data register)
.equ LEDS_CORNERS_MASK, 0x5500      @ Bits 8,10,12,14 = LED4(NW,UL) LED5(NE,UR) LED9(SE,LR) LED8(SW,LL)

    .global akazeika1886_lab8
    .code   16
    .thumb_func
    .type   akazeika1886_lab8, %function

@ Function Declaration : void akazeika1886_lab8(void)
@ Input: none
@ Returns: nothing
akazeika1886_lab8:
    push {lr}

    mov r0, #3
    bl BSP_LED_Toggle

    ldr r0, =0xFFFFFFF
    bl busy_delay

    mov r0, #3
    bl BSP_LED_Toggle

    pop {lr}
    bx lr
    .size   akazeika1886_lab8, .-akazeika1886_lab8


.global akazeika1886_a4
.type   akazeika1886_a4, %function

@ Function Declaration : int akazeika1886_a4(int status, int num_to_skip, int direction)
@ Input: r0 = status, r1 = num_to_skip, r2 = direction
@ Returns: r0 = 1 (success)
@
@ Saves the three parameters for use by akazeika1886_a4_tick, resets the
@ skip counter and current LED index to 0, and turns off all 8 LEDs.
akazeika1886_a4:
    push {r4, lr}

    ldr r3, =a4_status
    str r0, [r3]

    ldr r3, =a4_num_to_skip
    str r1, [r3]

    @ direction == 0 means "keep the previous direction"
    cmp r2, #0
    beq a4_keep_direction
        ldr r3, =a4_direction
        str r2, [r3]
    a4_keep_direction:

    mov r1, #0
    ldr r3, =a4_skip_counter
    str r1, [r3]
    ldr r3, =a4_current_led
    str r1, [r3]

    @ Turn off all 8 LEDs (index 0..7)
    mov r4, #0
    a4_off_loop:
        cmp r4, #8
        bge a4_off_done
        mov r0, r4
        bl BSP_LED_Off
        add r4, r4, #1
        b a4_off_loop
    a4_off_done:

    mov r0, #1
    pop {r4, lr}
    bx lr
    .size akazeika1886_a4, .-akazeika1886_a4


.global akazeika1886_a5
.type   akazeika1886_a5, %function

@ Function Declaration : int akazeika1886_a5(int status, int num_to_skip, int direction)
@ Input: r0 = status, r1 = num_to_skip (unused for now), r2 = direction (unused for now)
@ Returns: r0 = 1 (success)
@
@ Saves status into a5_running, turns off all 8 LEDs, then initializes
@ and starts the independent watchdog (reload = 8000).
akazeika1886_a5:
    push {r4, lr}

    ldr r3, =a5_running
    str r0, [r3]

    @ Turn off all 8 LEDs (index 0..7)
    mov r4, #0
    a5_off_loop:
        cmp r4, #8
        bge a5_off_done
        mov r0, r4
        bl BSP_LED_Off
        add r4, r4, #1
        b a5_off_loop
    a5_off_done:

    @ Initialize the independent watchdog with a reload value of 8000,
    @ then start the countdown
    ldr r0, =8000
    bl mes_InitIWDG
    bl mes_IWDGStart

    mov r0, #1
    pop {r4, lr}
    bx lr
    .size akazeika1886_a5, .-akazeika1886_a5


.global akazeika1886_a4_btn
.type   akazeika1886_a4_btn, %function

@ Function Declaration : void akazeika1886_a4_btn(void)
@ Input: None
@ Returns: Nothing
@ Requires BSP_PB_Init(BUTTON_USER, BUTTON_MODE_EXTI) in main.c
akazeika1886_a4_btn:
    push {lr}

    ldr r1, =a4_button_count
    ldr r0, [r1]
    add r0, r0, #1
    and r0, #7
    str r0, [r1]

    bl BSP_LED_Toggle

    pop {lr}
    bx lr
    .size   akazeika1886_a4_btn, .-akazeika1886_a4_btn


.global akazeika1886_a4_tick
.type   akazeika1886_a4_tick, %function

@ Function Declaration : void akazeika1886_a4_tick(void)
@ Input: None
@ Returns: Nothing
@
@ No longer called automatically from the C hook (akazeika1886_tick now
@ calls akazeika1886_a5_tick instead) -- kept here for reference.
akazeika1886_a4_tick:
    push {r4, lr}

    ldr r1, =a4_status
    ldr r0, [r1]
    cmp r0, #0
    ble a4_tick_skip

    ldr r1, =a4_skip_counter
    ldr r0, [r1]
    ldr r2, =a4_num_to_skip
    ldr r2, [r2]
    cmp r0, r2
    blt a4_tick_not_yet

        @ Time to act: reset the skip counter
        mov r0, #0
        str r0, [r1]

        @ Toggle the current LED
        ldr r1, =a4_current_led
        ldr r4, [r1]
        mov r0, r4
        bl BSP_LED_Toggle

        @ Advance: current_led = (current_led + direction) & 7
        ldr r2, =a4_direction
        ldr r2, [r2]
        add r4, r4, r2
        and r4, r4, #7

        ldr r1, =a4_current_led
        str r4, [r1]

        b a4_tick_skip

    a4_tick_not_yet:
        add r0, r0, #1
        str r0, [r1]

    a4_tick_skip:
    pop {r4, lr}
    bx lr
    .size akazeika1886_a4_tick, .-akazeika1886_a4_tick


.global akazeika1886_a5_tick
.type   akazeika1886_a5_tick, %function

@ Function Declaration : void akazeika1886_a5_tick(void)
@ Input: None
@ Returns: Nothing
akazeika1886_a5_tick:
    push {lr}

    ldr r1, =a5_running
    ldr r0, [r1]

    cmp r0, #0
    ble a5_skip

    @ DO NOT PUT LOGIC FOR A5 ABOVE THIS LINE ------------------------

    @ Confirm to the watchdog that the system is still alive
    bl mes_IWDGRefresh

    @ Toggle the 4 corner LEDs (Upper Left/Right, Lower Left/Right) in
    @ one operation, via direct GPIOE ODR register access (no BSP call)
    ldr r1, =GPIOE_ODR
    ldr r0, [r1]
    ldr r2, =LEDS_CORNERS_MASK
    eor r0, r0, r2
    str r0, [r1]

    @ DO NOT PUT LOGIC FOR A5 BELOW THIS LINE ------------------------

    a5_skip:
    pop {lr}
    bx lr
    .size akazeika1886_a5_tick, .-akazeika1886_a5_tick


@ Function Declaration : int busy_delay(int cycles)
@ Input: r0 = number of cycles to delay
@ Returns: r0
@ Legacy delay helper from earlier labs, not used by A4/A5 logic
busy_delay:
    push {r6}
    mov r6, r0

    d3lay_loop:
        subs r6, r6, #1
        bge d3lay_loop
        mov r0, #0

    pop {r6}
    bx lr


.data
a4_status:       .word 0    @ >0 = running, <=0 = stopped
a4_num_to_skip:  .word 0    @ tick calls to skip between actions
a4_direction:    .word 1    @ +1 or -1 (default +1); 0 is never stored here
a4_skip_counter: .word 0    @ calls skipped since the last action
a4_current_led:  .word 0    @ index of the currently active LED (0-7)
a4_button_count: .word 0    @ used only by akazeika1886_a4_btn
a5_running:      .word 0    @ >0 = running, <=0 = stopped (A5)

.end