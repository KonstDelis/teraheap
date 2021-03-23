/**************************************************
*
* file: test3.c
*
* @Author:   Iacovos G. Kolokasis
* @Version:  20-03-2021 
* @email:    kolokasis@ics.forth.gr
*
* Test to verify:
*	- allocator initialization
*	- object allocation in the correct positions
*	using asynchronous I/O
***************************************************/

#include <stdio.h>
#include "../include/sharedDefines.h"
#include "../include/regions.h"

#define CARD_SIZE 512
#define PAGE_SIZE 4096

int main() {
	int i;
	char *obj1, *obj2, *obj3, *obj4;
	char tmp[80]; 
	char tmp2[160]; 
	char tmp3[1048576]; 
	char tmp4[4194304]; 
	
	// Init allocator
	init(CARD_SIZE * PAGE_SIZE);

	// Check start and stop adddresses
	printf("Start Address: %p\n", start_addr_mem_pool());
	printf("Stop Address: %p\n", stop_addr_mem_pool());
	printf("Mem Pool Size: %lu\n", mem_pool_size());
	
	memset(tmp, '1', 80);
	tmp[79] = '\0';

	memset(tmp2, '2', 160);
	tmp2[159] = '\0';

	memset(tmp3, '3', 1048576);
	tmp3[1048575] = '\0';

	memset(tmp4, '4', 4194304);
	tmp4[4194303] = '\0';
	
	obj1 = allocate(10);
	r_awrite(tmp, obj1, 10);
	
	obj2 = allocate(20);
	r_awrite(tmp2, obj2, 20);
	
	obj3 = allocate(131072);
	r_awrite(tmp3, obj3, 131072);
	
	obj4 = allocate(524288);
	r_awrite(tmp4, obj4, 524288);

	while (!r_areq_completed());

	assertf(strlen(obj1) == 79, "Error in size %lu", strlen(obj1));
	assertf(strlen(obj2) == 159, "Error in size");
	assertf(strlen(obj3) == 1048575, "Error in size");
	assertf(strlen(obj4) == 4194303, "Error in size");
	
	for (i = 0; i < 4096; i++) {
		obj1 = allocate(10);
		r_awrite(tmp, obj1, 10);

		obj2 = allocate(20);
		r_awrite(tmp2, obj2, 20);

		obj3 = allocate(131072);
		r_awrite(tmp3, obj3, 131072);

		obj4 = allocate(524288);
		r_awrite(tmp4, obj4, 524288);
	}

	while (!r_areq_completed());

	assertf(strlen(obj1) == 79, "Error in size %lu", strlen(obj1));
	assertf(strlen(obj2) == 159, "Error in size");
	assertf(strlen(obj3) == 1048575, "Error in size");
	assertf(strlen(obj4) == 4194303, "Error in size");
	
	return 0;
}