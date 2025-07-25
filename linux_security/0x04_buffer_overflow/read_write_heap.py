#!/usr/bin/python3

"""
Read and write to the heap memory
"""
import sys


def find_and_replace_string(pid, search_string, replace_string):
    """This function finds a string in the heap of a process and replaces it"""
    try:
        with open(f"/proc/{pid}/maps", "r") as maps_file:
            for line in maps_file:
                if "[heap]" in line:
                    heap_range = line.split()[0]
                    heap_start = int(heap_range.split('-')[0], 16)
                    heap_end = int(heap_range.split('-')[1], 16)
                    break
            else:
                sys.exit(1)

        with open(f"/proc/{pid}/mem", "r+b") as mem_file:
            mem_file.seek(heap_start)
            data = mem_file.read(heap_end - heap_start)
            if search_string.encode() in data:
                new_data = data.replace(search_string.encode(),
                                        replace_string.encode())
                mem_file.seek(heap_start)
                mem_file.write(new_data)

    except Exception:
        sys.exit(1)


if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: read_write_heap.py pid search_string replace_string")
        sys.exit(1)

    pid = sys.argv[1]
    search_string = sys.argv[2]
    replace_string = sys.argv[3]

    find_and_replace_string(pid, search_string, replace_string)
