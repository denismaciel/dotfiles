#!/bin/bash

# Define the names or indexes of the two sinks
SINK1="alsa_output.usb-Generic_Lenovo_USB-C_Mini_Dock-00.analog-stereo"
SINK2="alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__hw_sofhdadsp__sink"

# Get the current default sink
CURRENT_SINK=$(pacmd stat | awk -F": " '/^Default sink name:/{print $2}')

# Determine the sink to switch to
if [ "$CURRENT_SINK" = "$SINK1" ]; then
    SWITCH_TO_SINK="$SINK2"
else
    SWITCH_TO_SINK="$SINK1"
fi

# Switch the default sink
pacmd set-default-sink "$SWITCH_TO_SINK"

# Move existing streams to the new sink
for INPUT_INDEX in $(pacmd list-sink-inputs | awk '/index:/{print $2}')
do
    pacmd move-sink-input "$INPUT_INDEX" "$SWITCH_TO_SINK"
done
