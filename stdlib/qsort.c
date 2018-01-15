/*
 * Phoenix-RTOS
 *
 * Operating system kernel
 *
 * Quicksort
 *
 * Copyright 2018 Phoenix Systems
 * Author: Jan Sikorski
 *
 * This file is part of Phoenix-RTOS.
 *
 * %LICENSE%
 *
 */

#include <stdlib.h>


static void qsort_swap(char *a, char *b, size_t size)
{
	int s;
	char tmp;

	for (s = 0; s < size; ++s) {
		tmp = *a;
		*(a++) = *b;
		*(b++) = tmp;
	}
}


static void qsort_aux(void *base, size_t first, size_t last, size_t size, int (*compar)(const void *, const void*))
{
	int middle = (first + last) / 2, stop = first;

	if (first >= last)
		return;

	qsort_swap(base + first * size, base + middle * size, size);

	for (middle = first + 1; middle <= last; ++middle) {
		if (compar(base + middle * size, base + first * size) < 0)
			qsort_swap(base + (++stop) * size, base + middle * size, size);
	}

	qsort_swap(base + first * size, base + stop * size, size);
	qsort_aux(base, size, first, stop - 1, compar);
	qsort_aux(base, size, stop, last, compar);
}


void qsort(void *base, size_t nitems, size_t size, int (*compar)(const void *, const void*))
{
	qsort_aux(base, 0, nitems - 1, size, compar);
}
