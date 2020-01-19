#!/usr/bin/env python3

import glob
import os
import subprocess
from os.path import join
inst_dir = join(os.getcwd(), "fortune-m-INST_DIR")

exe = glob.glob(join(inst_dir, "games", "fortune")+'*')[0]
# subprocess.call(["objdump", "-p", exe])
rc = subprocess.call(
    [exe, "-m", "giants"],
)
