#include "utils.h"

char* bga_strcat_retEnd(char* dest, const char* src) {
	while(dest[0]) dest += 1;
	while(src[0]) {
		dest[0] = src[0];
		src += 1;
		dest += 1;
	}
	dest[0] = 0;
	return dest;
}

char bga_digitToChar(unsigned int n) {
	return '0' + n;
}
char* bga_sitoa(char* dest, int n) {
	if(n < 0) {
		dest[0] = '-';
		dest += 1;
		n = -n;
	}
	else {

	}

	char out[10];
	unsigned int i = 0; while(n != 0) {
		int nDiv10 = n / 10;
		out[i] = bga_digitToChar(n - nDiv10 * 10);
		n = nDiv10;
		i += 1;
	}
	while(i--) {
		dest[0] = out[i];
		dest += 1;
	}
	dest[0] = 0;

	return dest;
}
