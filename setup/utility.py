#!/usr/bin/env python3

import fileinput


def search_and_replace(target_file, old_string, new_string):
    # TODO I think remote1.sh gets overwritten since it's called so many times in a row
    # with fileinput.FileInput(target_file, inplace=True, backup='.bak') as file:
    with fileinput.FileInput(target_file, inplace=True) as file:
        for line in file:
            print(line.replace(old_string, new_string), end='')