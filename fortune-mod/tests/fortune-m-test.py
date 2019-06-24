#!/usr/bin/env python3

import os
import subprocess
inst_dir = os.getcwd() + "/fortune-m-INST_DIR"

subprocess.call([inst_dir + "/games/fortune", "-m", "giants"])
