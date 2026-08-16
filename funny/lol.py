#!/bin/env python3

with open("floppy", "wb") as file:
  file.write(b"\xeb\xfe" + b"\x00"*508 + b"\x55\xaa")