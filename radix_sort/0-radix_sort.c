#include "sort.h"
#include <stdlib.h>

/**
 * get_max - Get the maximum value in an array
 * @array: The array to search
 * @size: Size of the array
 *
 * Return: The maximum integer in the array
 */
int get_max(int *array, size_t size)
{
	int max = array[0];
	size_t i;

	for (i = 1; i < size; i++)
	{
		if (array[i] > max)
			max = array[i];
	}
	return (max);
}

/**
 * counting_sort_radix - Counting sort by specific digit
 * @array: The array to sort
 * @size: Size of the array
 * @exp: The exponent (digit position)
 * @output: Output array
 */
void counting_sort_radix(int *array, size_t size, int exp, int *output)
{
	int count[10] = {0};
	size_t i;

	for (i = 0; i < size; i++)
		count[(array[i] / exp) % 10]++;

	for (i = 1; i < 10; i++)
		count[i] += count[i - 1];

	for (i = size - 1; (int)i >= 0; i--)
	{
		output[count[(array[i] / exp) % 10] - 1] = array[i];
		count[(array[i] / exp) % 10]--;
	}

	for (i = 0; i < size; i++)
		array[i] = output[i];
}

/**
 * radix_sort - Sort an array using LSD Radix sort algorithm
 * @array: The array to sort
 * @size: Size of the array
 */
void radix_sort(int *array, size_t size)
{
	int max, exp;
	int *output;

	if (!array || size < 2)
		return;

	max = get_max(array, size);
	output = malloc(sizeof(int) * size);
	if (!output)
		return;

	for (exp = 1; max / exp > 0; exp *= 10)
	{
		counting_sort_radix(array, size, exp, output);
		print_array(array, size);
	}

	free(output);
}
