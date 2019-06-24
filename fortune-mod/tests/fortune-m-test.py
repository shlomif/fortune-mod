#!/usr/bin/env python3

import glob
import os
import subprocess
from os.path import join
inst_dir = join(os.getcwd(), "fortune-m-INST_DIR")

subprocess.check_call([
    glob.glob(join(inst_dir, "games", "fortune")+'*')[0], "-m", "giants"])
