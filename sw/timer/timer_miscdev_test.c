/****************************************
** timer_miscdev_test.c, timer miscdev, EELE467 final
** Riley Holmes, Jonny Hughes
** 12/11/24
*****************************************/

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <errno.h>
#include <string.h>
#include <unistd.h>

#define START_OFFSET 0x00
#define TIME_OUT_OFFSET 0x04

int main () {
	FILE *timer_file;
	size_t timer_ret;
	uint32_t val;


	timer_file = fopen("/dev/timer" , "rb+" );
	if (timer_file == NULL) {
		printf("failed to open timer file\n");
		exit(1);
	}

	printf("\n Starting reaction timer.\n\n");
	printf("Press the button when the light goes off\n");
	printf("Get ready!!!");

	//start timer
	timer_ret = fseek(timer_file, START_OFFSET, SEEK_SET);
	val = 0x1;
	timer_ret = fwrite(&val, 4, 1, timer_file);
	fflush(timer_file);

	//turn off start register so it doesnt run multiple times
	timer_ret = fseek(timer_file, START_OFFSET, SEEK_SET);
	val = 0x0;
	timer_ret = fwrite(&val, 4, 1, timer_file);
	fflush(timer_file);

	sleep(2);

	timer_ret = fseek(timer_file, TIME_OUT_OFFSET, SEEK_SET);
	timer_ret = fread(&val, 4, 1, timer_file);

	printf("Reaction time in clock cycles: 0x%x\n\n", val);
	
	fclose(timer_file);
	return 0;
}
