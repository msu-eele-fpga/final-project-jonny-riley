#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <errno.h>
#include <string.h>
#include <unistd.h>


#define CH0 0x00
#define CH1 0x04
#define CH2 0x08

#define PERIOD_OFFSET 0x00
#define BLUE_DUTY_CYCLE_OFFSET 0x04
#define RED_DUTY_CYCLE_OFFSET 0x08
#define GREEN_DUTY_CYCLE_OFFSET 0x0C



uint32_t convert (uint32_t adc_value){				//to convert adc_value to pwm duty cycle
	uint32_t max_duty = 2 << 17;
	uint32_t max_adc = 2 << 12;
	
	uint32_t duty_adc_ratio = max_duty/max_adc;
	uint32_t result = adc_value * duty_adc_ratio;

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


	printf("\nControlling the led with the adc\n\n");
	

	while(1){
		//Blue LED Control
		adc_ret = fseek(adc_file, CH0, SEEK_SET);
		adc_ret = fread(&val, 4, 1, adc_file);
		scaled_val = convert(val);
		pwm_ret = fseek(pwm_file, BLUE_DUTY_CYCLE_OFFSET, SEEK_SET);
		pwm_ret = fwrite(&scaled_val, 4, 1, pwm_file);
		fflush(pwm_file);

		//Red LED Control
		adc_ret = fseek(adc_file, CH1, SEEK_SET);
		adc_ret = fread(&val, 4, 1, adc_file);
		scaled_val = convert(val);
		pwm_ret = fseek(pwm_file, RED_DUTY_CYCLE_OFFSET, SEEK_SET);
		pwm_ret = fwrite(&scaled_val, 4, 1, pwm_file);
		fflush(pwm_file);

		//Green LED Control
		adc_ret = fseek(adc_file, CH2, SEEK_SET);
		adc_ret = fread(&val, 4, 1, adc_file);
		scaled_val = convert(val);
		pwm_ret = fseek(pwm_file, GREEN_DUTY_CYCLE_OFFSET, SEEK_SET);
		pwm_ret = fwrite(&scaled_val, 4, 1, pwm_file);
		fflush(pwm_file);


	}

	fclose(pwm_file);
	fclose(adc_file);
	return 0;
}
