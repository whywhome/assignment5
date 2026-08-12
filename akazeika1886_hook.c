/*
 *  C to assembler menu hook - Assignment 4/5
 *
 *  Modified by akazeika1886
 */

#include <stdio.h>
#include <stdint.h>
#include <ctype.h>

#include "stm32f3_discovery_gyroscope.h"
#include "common.h"

#define N 500

// A4 functions - implemented in akazeika1886_asm.s
void akazeika1886_a4_btn(void);
void akazeika1886_a4_tick(void);

// A5 function - implemented in akazeika1886_asm.s
void akazeika1886_a5_tick(void);

// Timer tick hook for our interrupt driven programming.
// Called from SysTick_Handler in main.c on every system tick.
// Downsamples to the A5 tick every N calls.
void akazeika1886_tick(void)
{
  static int32_t ticks;
  ticks++;

  if (ticks > N)
  {
    ticks = 0;
    akazeika1886_a5_tick();
  }
}

// Button press hook. Called from EXTI0_IRQHandler in main.c.
void akazeika1886_btn(void)
{
  akazeika1886_a4_btn();
}

int akazeika1886_lab8(void);

void Lab8_akazeika1886(int action)
{
  if(action==CMD_SHORT_HELP) return;
  if(action==CMD_LONG_HELP) {
    printf("Lab 8\n\n"
           "This command tests the lab 8 LED toggle function\n"
           );
    return;
  }

  printf("akazeika1886_lab8 returned: %d\n", akazeika1886_lab8() );
}

ADD_CMD("akazeika1886_lab8", Lab8_akazeika1886,"Test the new lab 8 function")

int akazeika1886_a4(int status, int num_to_skip, int direction);

void A4_akazeika1886(int action)
{
  if(action==CMD_SHORT_HELP) return;
  if(action==CMD_LONG_HELP) {
    printf("Assignment 4 - More Blinking Lights\n\n"
           "Usage: akazeika1886_a4 <status> <num_to_skip> <direction>\n"
           "  status      : >0 to run, <=0 to stop (default 1)\n"
           "  num_to_skip : tick calls to skip between LED moves (default 0)\n"
           "  direction   : +1 increasing, -1 decreasing, 0 = keep current direction (default 1)\n"
           );
    return;
  }

  int rc;
  int32_t a4_status;
  int32_t a4_num_to_skip;
  int32_t a4_direction;

  rc = fetch_int32_arg(&a4_status);
  if (rc) {
    a4_status = 1;
  }

  rc = fetch_int32_arg(&a4_num_to_skip);
  if (rc) {
    a4_num_to_skip = 0;
  }

  rc = fetch_int32_arg(&a4_direction);
  if (rc) {
    a4_direction = 1;
  }

  printf("akazeika1886_a4 returned: %d\n",
         akazeika1886_a4(a4_status, a4_num_to_skip, a4_direction) );
}

ADD_CMD("akazeika1886_a4", A4_akazeika1886,"Run the A4 blinking light game: status num_to_skip direction")

int akazeika1886_a5(int status, int num_to_skip, int direction);

void A5_akazeika1886(int action)
{
  if(action==CMD_SHORT_HELP) return;
  if(action==CMD_LONG_HELP) {
    printf("Assignment 5 - Watchdogs and LEDs\n\n"
           "Usage: akazeika1886_a5 <status> <num_to_skip> <direction>\n"
           "  status : >0 to run, <=0 to stop (default 1)\n"
           );
    return;
  }

  int rc;
  int32_t a5_status;
  int32_t a5_num_to_skip;
  int32_t a5_direction;

  rc = fetch_int32_arg(&a5_status);
  if (rc) {
    a5_status = 1;
  }

  rc = fetch_int32_arg(&a5_num_to_skip);
  if (rc) {
    a5_num_to_skip = 0;
  }

  rc = fetch_int32_arg(&a5_direction);
  if (rc) {
    a5_direction = 1;
  }

  printf("akazeika1886_a5 returned: %d\n",
         akazeika1886_a5(a5_status, a5_num_to_skip, a5_direction) );
}

ADD_CMD("akazeika1886_a5", A5_akazeika1886,"Run the A5 watchdog/LED assignment: status num_to_skip direction")