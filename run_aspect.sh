#!/bin/bash
sudo service ssh start
cd /aspect_run
rm -rf output-shell_simple_3d
# Run the aspect model and redirect the output to a log file
mpirun -n 2 --mca btl self,vader \
       /build/aspect/build/aspect ./shell_simple_3d.prm \
       > screen_output 2>&1
