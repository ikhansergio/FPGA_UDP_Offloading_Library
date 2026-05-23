Сreating a script to generate IP Core used in the project

set proj_dir [get_property DIRECTORY [current_project]]
write_ip_tcl [get_ips] $proj_dir/../Generate_Prj_IPs.tcl
