#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <errno.h>
#include <string.h>
#include <unistd.h>

// TODO: update these offsets if your address are different
#define CH0 0x00
#define CH1 0x04
#define CH2 0x08

#define PERIOD_OFFSET 0x00
#define BLUE_DUTY_CYCLE_OFFSET 0x04
#define RED_DUTY_CYCLE_OFFSET 0x08
#define GREEN_DUTY_CYCLE_OFFSET 0x0C

uint32_t convert (uint32_t adc_value){
	uint32_t max_duty = 2 << 17;
	uint32_t max_adc = 2 << 12;
	uint32_t duty_adc_ratio = max_duty/max_adc;
	uint32_t result = adc_value * duty_adc_ratio;
	//result = result << 5;

	return(result);
}


int main () {
	FILE *pwm_file;
	FILE *adc_file;
	size_t adc_ret;	
	size_t pwm_ret;
	uint32_t val;
	uint32_t scaled_val;

	pwm_file = fopen("/dev/pwm" , "rb+" );
	if (pwm_file == NULL) {
		printf("failed to open pwm file\n");
		exit(1);
	}

	adc_file = fopen("/dev/adc" , "rb+" );
	if (adc_file == NULL) {
		printf("failed to open adc file\n");
		exit(1);
	}

	// Test reading the registers sequentially
	printf("\n************************************\n*");
	printf("* read initial register values\n");
	printf("************************************\n\n");

	pwm_ret = fread(&val, 4, 1, pwm_file);
	printf("Period  = 0x%x\n", val);

	pwm_ret = fread(&val, 4, 1, pwm_file);
	printf("Blue Duty Cycle = 0x%x\n", val);

	pwm_ret = fread(&val, 4, 1, pwm_file);
	printf("Red Duty Cycle = 0x%x\n", val);

	pwm_ret = fread(&val, 4, 1, pwm_file);
	printf("Green Duty Cycle = 0x%x\n", val);

	// Reset file position to 0
	pwm_ret = fseek(pwm_file, 0, SEEK_SET);
	printf("fseek ret = %d\n", pwm_ret);
	printf("errno =%s\n", strerror(errno));

	val = 0x00;
    //pwm_ret = fseek(pwm_file, HPS_LED_CONTROL_OFFSET, SEEK_SET);
	//ret = fwrite(&val, 4, 1, pwm_file);
	// We need to "flush" so the OS finishes writing to the file before our code continues.
	fflush(pwm_file);

	
	printf("\nControlling the led with the adc\n\n");
	

	while(1){
		//Blue adc write
		adc_ret = fseek(adc_file, CH0, SEEK_SET);
		adc_ret = fread(&val, 4, 1, adc_file);
		scaled_val = convert(val);
		pwm_ret = fseek(pwm_file, BLUE_DUTY_CYCLE_OFFSET, SEEK_SET);
		pwm_ret = fwrite(&scaled_val, 4, 1, pwm_file);
		fflush(pwm_file);

		//Red adc write
		adc_ret = fseek(adc_file, CH1, SEEK_SET);
		adc_ret = fread(&val, 4, 1, adc_file);
		scaled_val = convert(val);
		pwm_ret = fseek(pwm_file, RED_DUTY_CYCLE_OFFSET, SEEK_SET);
		pwm_ret = fwrite(&scaled_val, 4, 1, pwm_file);
		fflush(pwm_file);

		//Green adc write
		adc_ret = fseek(adc_file, CH2, SEEK_SET);
		adc_ret = fread(&val, 4, 1, adc_file);
		scaled_val = convert(val);
		pwm_ret = fseek(pwm_file, GREEN_DUTY_CYCLE_OFFSET, SEEK_SET);
		pwm_ret = fwrite(&scaled_val, 4, 1, pwm_file);
		fflush(pwm_file);


	}

	// Turn on hardware-control mode
	//printf("back to hardware-control mode....\n");
	//val = 0x01;
    //ret = fseek(file, HPS_LED_CONTROL_OFFSET, SEEK_SET);
	//ret = fwrite(&val, 4, 1, file);
	//fflush(file);

	/*
	printf("\n************************************\n*");
	printf("* write values\n");
	printf("************************************\n\n");
	// Turn on software-control mode
	val = 0x00;
    ret = fseek(file, HPS_LED_CONTROL_OFFSET, SEEK_SET);
	ret = fwrite(&val, 4, 1, file);
	// We need to "flush" so the OS finishes writing to the file before our code continues.
	fflush(file);

	// Write some values to the LEDs
	printf("writing patterns to LEDs....\n");
	val = 0x55;
    ret = fseek(file, LED_REG_OFFSET, SEEK_SET);
	ret = fwrite(&val, 4, 1, file);
	fflush(file);

	sleep(1);

	val = 0xaa;
    ret = fseek(file, LED_REG_OFFSET, SEEK_SET);
	ret = fwrite(&val, 4, 1, file);
	fflush(file);

	sleep(1);

	val = 0xff;
    ret = fseek(file, LED_REG_OFFSET, SEEK_SET);
	ret = fwrite(&val, 4, 1, file);
	fflush(file);

	usleep(0.5e6);

	val = 0x00;
    ret = fseek(file, LED_REG_OFFSET, SEEK_SET);
	ret = fwrite(&val, 4, 1, file);
	fflush(file);

	sleep(1);

	// Turn on hardware-control mode
	printf("back to hardware-control mode....\n");
	val = 0x01;
    ret = fseek(file, HPS_LED_CONTROL_OFFSET, SEEK_SET);
	ret = fwrite(&val, 4, 1, file);
	fflush(file);

	val = 0x12;
    ret = fseek(file, BASE_PERIOD_OFFSET, SEEK_SET);
	ret = fwrite(&val, 4, 1, file);
	fflush(file);

	sleep(5);

	// Speed up the base period!
	val = 0x02;
    ret = fseek(file, BASE_PERIOD_OFFSET, SEEK_SET);
	ret = fwrite(&val, 4, 1, file);
	fflush(file);


	printf("\n************************************\n*");
	printf("* read new register values\n");
	printf("************************************\n\n");
	
	// Reset file position to 0
	ret = fseek(file, 0, SEEK_SET);

	ret = fread(&val, 4, 1, file);
	printf("HPS_LED_control = 0x%x\n", val);

	ret = fread(&val, 4, 1, file);
	printf("base period = 0x%x\n", val);

	ret = fread(&val, 4, 1, file);
	printf("LED_reg = 0x%x\n", val);

	*/

	fclose(pwm_file);
	fclose(adc_file);
	return 0;
}
