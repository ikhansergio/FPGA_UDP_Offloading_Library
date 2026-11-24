#******************************************************************************
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
#******************************************************************************

set origin_dir [get_property DIRECTORY [current_project]]
puts $origin_dir

#******************************************************************************
# Checking for the presence of a Block Design in the project:
#******************************************************************************

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
		puts $fp "# Block designs cores were not used"
		close $fp	
		puts "Block designs cores were not used"
	}
	
#******************************************************************************
# Checking for the presence of IP cores in the project:
#******************************************************************************

set ips [get_ips -quiet]
if {[llength $ips] > 0} {
	puts  "[llength $ips] IPs Found"
    write_ip_tcl -force $ips $origin_dir/../Generate_Prj_Import_IP.tcl
	} else {
	set fp [open "../Generate_Prj_Import_IP.tcl" "w"]
	set gen_time [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"]
	puts $fp "# Generated on: $gen_time"
	puts $fp "# IP cores were not used"
	close $fp	
	puts "IP cores were not used"
	}

#******************************************************************************
# Checking for the presence of *.dcp files in the project.
# If a *.dcp file is created as a result of project compilation,
# it must be excluded from the build process by removing it from the project.
#******************************************************************************

set dcp_files [get_files -quiet -of_objects [get_filesets utils_1] *.dcp]
if {[llength $dcp_files] > 0} {
    remove_files -fileset utils_1 $dcp_files
}
puts " Deleting *.DCP files is done."

#******************************************************************************
# Creating a list of external repositories used in the project
#******************************************************************************

# Calculating the relative path to the repository
proc relative_path {base_path repo_path} {
    set base_path_split_elements   [file split [file normalize $base_path]]
    set repo_path_split_elements [file split [file normalize $repo_path]]
    # Remove common parts of the paths
    while {[llength $base_path_split_elements] > 0 &&
           [llength $repo_path_split_elements] > 0 &&
           [string equal -nocase \
               [lindex $base_path_split_elements 0] \
               [lindex $repo_path_split_elements 0]]} {
        set base_path_split_elements   [lrange $base_path_split_elements 1 end]
        set repo_path_split_elements [lrange $repo_path_split_elements 1 end]
    }
	# For each remaining part of base_path, add ../
    set result {}
    foreach part $base_path_split_elements {
        lappend result ..
    }
    # Adding the remaining part of repo_path
    foreach part $repo_path_split_elements {
        lappend result $part
    }
    return [eval file join $result]
}

set ip_repo_paths [get_property ip_repo_paths [current_fileset]]

if {[llength $ip_repo_paths] > 0} {
	puts  "[llength $ip_repo_paths] Repositories found"
	
	set fp [open "../Generate_Prj_Import_Repo.tcl" "w"]
	set gen_time [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"]
	puts $fp "# List of external repositories used in the project."
	puts $fp "# Generated on: $gen_time"
	puts $fp "# [llength $ip_repo_paths] Repositories found"
	
	foreach repo_path $ip_repo_paths {
		set relative_path [relative_path $origin_dir $repo_path]
		puts $relative_path
		puts $fp "set_property  ip_repo_paths \[get_property DIRECTORY \[current_project]]/$relative_path  \[current_project]"
		}
	puts $fp " "
	puts $fp "update_ip_catalog"
	close $fp	
	
	} else {
	puts "External repositories were not used"
	
	set fp [open "../Generate_Prj_Import_Repo.tcl" "w"]
	set gen_time [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"]
	puts $fp "# List of external repositories used in the project."
	puts $fp "# Generated on: $gen_time"
	puts $fp "# External repositories were not used"
	puts $fp " "
	close $fp	
	}

puts "Creating a list of external repositories used in the project is done."

#******************************************************************************
# Creation of a common script for imported objects used in the project.
#******************************************************************************

set fp [open "../Generate_Prj_Import.tcl" "w"]
set gen_time [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"]
puts $fp "# List of imported objects used in the project."
puts $fp "# Generated on: $gen_time"

puts $fp "source Generate_Prj_Import_Repo.tcl"
puts $fp "source Generate_Prj_Import_IP.tcl"
puts $fp "source Generate_Prj_Import_BD.tcl"

puts $fp " "
close $fp

puts "Creation of a common script for imported objects used in the project is done."	

#******************************************************************************
# Saving the project to a Generate_Prj.tcl file, which is used to regenerate the project from source files.
#******************************************************************************

write_project_tcl -no_copy_sources -force -use_bd_files $origin_dir/../Generate_Prj.tcl

#******************************************************************************
# Patching the Generate_Prt.tcl file to insert the previously created scripts for importing IP and BD cores.
#******************************************************************************

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
	puts "Patching Done."
} else {
    puts "Error: string '$anchor' not found."
}

puts "Generation complete!!!"