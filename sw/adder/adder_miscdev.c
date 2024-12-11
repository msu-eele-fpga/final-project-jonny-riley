#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <errno.h>
#include <string.h>
#include <unistd.h>

#define AMOUNT_OFFSET 0x00


int main () {
	FILE *adder_file;

	size_t amount_ret;	

	uint32_t val;


	adder_file = fopen("/dev/adder" , "rb+" );
	if (adder_file == NULL) {
		printf("failed to open adder file\n");
		exit(1);
	}
	

	while(1){
		//Blue LED Control
		amount_ret = fseek(adder_file, AMOUNT_OFFSET, SEEK_SET);
		amount_ret = fread(&val, 4, 1, adder_file);
        printf("Amount added by: ");
        printf("0x%x\n", val);


        sleep(3);

        printf("New amount is 10\n");
        val = 0xA;
		amount_ret = fseek(adder_file, AMOUNT_OFFSET, SEEK_SET);
		amount_ret = fwrite(&val, 4, 1, adder_file);

        sleep(3);


        printf("New amount is 5\n");
        val = 0x5;
		amount_ret = fseek(adder_file, AMOUNT_OFFSET, SEEK_SET);
		amount_ret = fwrite(&val, 4, 1, adder_file);
		fflush(adder_file);

        sleep(3);
	}

	fclose(adder_file);
	return 0;
}
