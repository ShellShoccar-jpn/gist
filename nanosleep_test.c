/*####################################################################
# clock_nanosleep(2)は遅すぎやしないかを検証するプログラム
####################################################################*/

#include <stdio.h>
#include <stdint.h>
#include <time.h>
int main(int argc, char *argv[]) {
  const uint64_t  ui8Sleep = 500000; /* sleepさせたい時間(ns) ←ここを設定せよ */

  struct timespec tsStart;  /* 最初の時刻 */
  struct timespec tsPlan;   /* 一定時間 sleep させたあとの復帰目標時刻 */
  struct timespec tsActual; /* 実際復帰時刻 */

  uint64_t        ui;

  /* 現在時刻を調べ、復帰目標時刻を決める */
  clock_gettime(CLOCK_MONOTONIC,&tsStart);
  ui = (uint64_t)tsStart.tv_nsec + ui8Sleep;
  tsPlan.tv_sec  = tsStart.tv_sec + (time_t)(ui/1000000000);
  tsPlan.tv_nsec = (long)(ui%1000000000);

  /* 復帰目標時刻まで休む */
  clock_nanosleep(CLOCK_MONOTONIC,TIMER_ABSTIME,&tsPlan,NULL);

  /* すぐさま復帰時刻を調べる */
  clock_gettime(CLOCK_MONOTONIC,&tsActual);

  /* 目標時刻と実際の時刻の差を表示する */
  ui = (uint64_t)tsActual.tv_sec*1000000000L+tsActual.tv_nsec
     - (uint64_t)tsPlan.tv_sec  *1000000000L-tsPlan.tv_nsec;
  printf("scheduled sleeping time: %lu[ns]\n",ui8Sleep);
  printf("actual sleeping time   : %lu[ns]\n",ui8Sleep+ui);

  return 0;
}
