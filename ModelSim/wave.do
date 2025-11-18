onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label CLOCK_50 -radix binary /testbench/CLOCK_50
add wave -noupdate -label LEDR -radix binary /testbench/LEDR
add wave -noupdate -label t -radix binary /testbench/t
add wave -noupdate -label index -radix binary /testbench/index
add wave -noupdate -label VGA_X -radix binary /testbench/VGA_X
add wave -noupdate -label VGA_Y -radix binary /testbench/VGA_Y
add wave -noupdate -label VGA_COLOR -radix binary /testbench/VGA_COLOR
add wave -noupdate -label sr -radix binary /testbench/sr
add wave -noupdate -label srd1 -radix binary /testbench/srd1
add wave -noupdate -label srd2 -radix binary /testbench/srd2
add wave -noupdate -label srd3 -radix binary /testbench/shsrd3ift_tile_x


add wave -noupdate -divider led
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {10000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 80
configure wave -valuecolwidth 40
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {120 ns}
