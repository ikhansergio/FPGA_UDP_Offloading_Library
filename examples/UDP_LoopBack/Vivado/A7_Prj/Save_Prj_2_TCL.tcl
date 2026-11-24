# #############################################################################
#MIT License
#
#Copyright (c) 2026 Sergio Batu    ikhan.sergio@gmail.com
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in all
#copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#SOFTWARE.
# #############################################################################

set origin_dir [get_property DIRECTORY [current_project]]
puts $origin_dir
#
#
set bd_files [get_files -quiet *.bd]
if {[llength $bd_files] > 0} {
	puts [llength $bd_files]
	puts "Block Design is found: [get_bd_designs]"
	# If a project contains a single block design, save it to a single Tcl file.
	if {[llength $bd_files] == 1} { 
		foreach bd_file $bd_files { puts "Processing Block Design: $bd_file" }
		set bd_name [file rootname [file tail $bd_file]]
		# If the BD is not open, open it for the write_bd_tcl export.
		if {[current_bd_design -quiet] ne $bd_name} {
			open_bd_design $bd_file
			puts "Opening Block Design"
			open_bd_design $bd_file
		} else {
			current_bd_design $bd_file
			puts "Block Design: [current_bd_design] is already opened"
		}
		write_bd_tcl -force $origin_dir/../Generate_Prj_Import_BD.tcl
		close_bd_design [current_bd_design]
		# else if a project contains multiple block designs, save them into separate Tcl files.
		} else {
		# Open/create the file `Generate_Prj_Import_BD.tcl` to generate a list of scripts,
		# containing references to the Tcl script used for regenerating an individual Block Design.
		set fp [open "../Generate_Prj_Import_BD.tcl" "w"]
		set gen_time [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"]

		puts $fp "# A list of Tcl scripts for regenerating block designs, created using the `write_bd_tcl` command."
		puts $fp "# Generated on: $gen_time"

		foreach bd_file $bd_files {
			puts "Processing Block Design: $bd_file"
			set bd_name [file rootname [file tail $bd_file]]
			# If the BD is not open, open it for the write_bd_tcl export.
			if {[current_bd_design -quiet] ne $bd_name} {
				open_bd_design $bd_file
				puts "Opening Block Design"
				open_bd_design $bd_file
			} else {
				current_bd_design $bd_file
				puts "Block Design: [current_bd_design] is already opened"
			}
			write_bd_tcl -force $origin_dir/../Generate_Prj_Import_BD_${bd_name}.tcl
			close_bd_design [current_bd_design]
			puts $fp "source Generate_Prj_Import_BD_${bd_name}.tcl"
			}
		# Close the file to save changes to the disk
		puts $fp "# Found [llength $bd_files] Block designs"
		close $fp	
		}
	} else {
		set fp [open "../Generate_Prj_Import_BD.tcl" "w"]
		set gen_time [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"]
		puts $fp "# A list of Tcl scripts for regenerating block designs, created using the `write_bd_tcl` command."
		puts $fp "# Generated on: $gen_time"
		puts $fp "# No Block designs Found"
		close $fp	
		puts "No Block designs Found"
	}
#
#
write_ip_tcl -force [get_ips] $origin_dir/../Generate_Prj_Import_IP.tcl
#
#
set dcp_files [get_files -quiet -of_objects [get_filesets utils_1] *.dcp]
if {[llength $dcp_files] > 0} {
    remove_files -fileset utils_1 $dcp_files
}
#
#
write_project_tcl -no_copy_sources -force -use_bd_files $origin_dir/../Generate_Prj.tcl
#
#
set filename "$origin_dir/../Generate_Prj.tcl"
set insert_str "source Generate_Prj_Import.tcl"


# 1. Read the file in binary mode (to preserve original line endings \r\n or \n)
set fp [open $filename rb]
set content [read $fp]
close $fp

# 2. Define the target second line (it is unique and follows immediately after the comment)
set anchor {set proj_dir [get_property directory [current_project]]}

# 3. Find the starting position of this line
set start_idx [string first $anchor $content]

if {$start_idx != -1} {

    # Calculate the index immediately after the end of the found line
    set end_idx [expr {$start_idx + [string length $anchor]}]
	
	puts $end_idx
	
    # Check which line ending is used in the file (\r\n for Windows or \n for Linux)
    if {[string range $content $end_idx [expr {$end_idx + 1}]] eq "\r\n"} {
        set nl "\r\n"
    } else {
        set nl "\n"
    }
    
    # Insert text at index end_idx (without deleting anything: range from end_idx to end_idx-1 is empty)
    set before [string range $content 0 [expr {$end_idx - 1}]]
    set after  [string range $content $end_idx end]
    set new_content "${before}${nl}${nl}${insert_str}${after}"
	
	puts $new_content
    
    # Write back in binary mode
    set fp [open $filename wb]
    puts -nonewline $fp $new_content
    close $fp
    puts "String '$insert_str' successfully inserted after the found fragment."
} else {
    puts "Error: string '$anchor' not found."
}