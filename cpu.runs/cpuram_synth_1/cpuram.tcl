# 
# Synthesis run script generated by Vivado
# 

set_param xicom.use_bs_reader 1
set_param project.vivado.isBlockSynthRun true
set_msg_config -msgmgr_mode ooc_run
create_project -in_memory -part xc7a35tcpg236-1

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_msg_config -source 4 -id {IP_Flow 19-2162} -severity warning -new_severity info
set_property webtalk.parent_dir {C:/Users/Jason/Desktop/EGR 426/Project3/EGR-426-Project-3/cpu.cache/wt} [current_project]
set_property parent.project_path {C:/Users/Jason/Desktop/EGR 426/Project3/EGR-426-Project-3/cpu.xpr} [current_project]
set_property XPM_LIBRARIES XPM_MEMORY [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language VHDL [current_project]
set_property ip_output_repo {c:/Users/Jason/Desktop/EGR 426/Project3/EGR-426-Project-3/cpu.cache/ip} [current_project]
set_property ip_cache_permissions {read write} [current_project]
read_ip -quiet {{C:/Users/Jason/Desktop/EGR 426/Project3/EGR-426-Project-3/cpu.srcs/sources_1/ip/cpuram/cpuram.xci}}
set_property used_in_implementation false [get_files -all {{c:/Users/Jason/Desktop/EGR 426/Project3/EGR-426-Project-3/cpu.srcs/sources_1/ip/cpuram/cpuram_ooc.xdc}}]
set_property is_locked true [get_files {{C:/Users/Jason/Desktop/EGR 426/Project3/EGR-426-Project-3/cpu.srcs/sources_1/ip/cpuram/cpuram.xci}}]

# Mark all dcp files as not used in implementation to prevent them from being
# stitched into the results of this synthesis run. Any black boxes in the
# design are intentionally left as such for best results. Dcp files will be
# stitched into the design at a later time, either when this synthesis run is
# opened, or when it is stitched into a dependent implementation run.
foreach dcp [get_files -quiet -all -filter file_type=="Design\ Checkpoint"] {
  set_property used_in_implementation false $dcp
}
read_xdc dont_touch.xdc
set_property used_in_implementation false [get_files dont_touch.xdc]

set cached_ip [config_ip_cache -export -no_bom -use_project_ipc -dir {C:/Users/Jason/Desktop/EGR 426/Project3/EGR-426-Project-3/cpu.runs/cpuram_synth_1} -new_name cpuram -ip [get_ips cpuram]]

if { $cached_ip eq {} } {

synth_design -top cpuram -part xc7a35tcpg236-1 -mode out_of_context

#---------------------------------------------------------
# Generate Checkpoint/Stub/Simulation Files For IP Cache
#---------------------------------------------------------
catch {
 write_checkpoint -force -noxdef -rename_prefix cpuram_ cpuram.dcp

 set ipCachedFiles {}
 write_verilog -force -mode synth_stub -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ cpuram_stub.v
 lappend ipCachedFiles cpuram_stub.v

 write_vhdl -force -mode synth_stub -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ cpuram_stub.vhdl
 lappend ipCachedFiles cpuram_stub.vhdl

 write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ cpuram_sim_netlist.v
 lappend ipCachedFiles cpuram_sim_netlist.v

 write_vhdl -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ cpuram_sim_netlist.vhdl
 lappend ipCachedFiles cpuram_sim_netlist.vhdl

 config_ip_cache -add -dcp cpuram.dcp -move_files $ipCachedFiles -use_project_ipc -ip [get_ips cpuram]
}

rename_ref -prefix_all cpuram_

write_checkpoint -force -noxdef cpuram.dcp

catch { report_utilization -file cpuram_utilization_synth.rpt -pb cpuram_utilization_synth.pb }

if { [catch {
  file copy -force {C:/Users/Jason/Desktop/EGR 426/Project3/EGR-426-Project-3/cpu.runs/cpuram_synth_1/cpuram.dcp} {C:/Users/Jason/Desktop/EGR 426/Project3/EGR-426-Project-3/cpu.srcs/sources_1/ip/cpuram/cpuram.dcp}
} _RESULT ] } { 
  send_msg_id runtcl-3 error "ERROR: Unable to successfully create or copy the sub-design checkpoint file."
  error "ERROR: Unable to successfully create or copy the sub-design checkpoint file."
}

if { [catch {
  write_verilog -force -mode synth_stub {C:/Users/Jason/Desktop/EGR 426/Project3/EGR-426-Project-3/cpu.srcs/sources_1/ip/cpuram/cpuram_stub.v}
} _RESULT ] } { 
  puts "CRITICAL WARNING: Unable to successfully create a Verilog synthesis stub for the sub-design. This may lead to errors in top level synthesis of the design. Error reported: $_RESULT"
}

if { [catch {
  write_vhdl -force -mode synth_stub {C:/Users/Jason/Desktop/EGR 426/Project3/EGR-426-Project-3/cpu.srcs/sources_1/ip/cpuram/cpuram_stub.vhdl}
} _RESULT ] } { 
  puts "CRITICAL WARNING: Unable to successfully create a VHDL synthesis stub for the sub-design. This may lead to errors in top level synthesis of the design. Error reported: $_RESULT"
}

if { [catch {
  write_verilog -force -mode funcsim {C:/Users/Jason/Desktop/EGR 426/Project3/EGR-426-Project-3/cpu.srcs/sources_1/ip/cpuram/cpuram_sim_netlist.v}
} _RESULT ] } { 
  puts "CRITICAL WARNING: Unable to successfully create the Verilog functional simulation sub-design file. Post-Synthesis Functional Simulation with this file may not be possible or may give incorrect results. Error reported: $_RESULT"
}

if { [catch {
  write_vhdl -force -mode funcsim {C:/Users/Jason/Desktop/EGR 426/Project3/EGR-426-Project-3/cpu.srcs/sources_1/ip/cpuram/cpuram_sim_netlist.vhdl}
} _RESULT ] } { 
  puts "CRITICAL WARNING: Unable to successfully create the VHDL functional simulation sub-design file. Post-Synthesis Functional Simulation with this file may not be possible or may give incorrect results. Error reported: $_RESULT"
}


} else {


if { [catch {
  file copy -force {C:/Users/Jason/Desktop/EGR 426/Project3/EGR-426-Project-3/cpu.runs/cpuram_synth_1/cpuram.dcp} {C:/Users/Jason/Desktop/EGR 426/Project3/EGR-426-Project-3/cpu.srcs/sources_1/ip/cpuram/cpuram.dcp}
} _RESULT ] } { 
  send_msg_id runtcl-3 error "ERROR: Unable to successfully create or copy the sub-design checkpoint file."
  error "ERROR: Unable to successfully create or copy the sub-design checkpoint file."
}

if { [catch {
  file rename -force {C:/Users/Jason/Desktop/EGR 426/Project3/EGR-426-Project-3/cpu.runs/cpuram_synth_1/cpuram_stub.v} {C:/Users/Jason/Desktop/EGR 426/Project3/EGR-426-Project-3/cpu.srcs/sources_1/ip/cpuram/cpuram_stub.v}
} _RESULT ] } { 
  puts "CRITICAL WARNING: Unable to successfully create a Verilog synthesis stub for the sub-design. This may lead to errors in top level synthesis of the design. Error reported: $_RESULT"
}

if { [catch {
  file rename -force {C:/Users/Jason/Desktop/EGR 426/Project3/EGR-426-Project-3/cpu.runs/cpuram_synth_1/cpuram_stub.vhdl} {C:/Users/Jason/Desktop/EGR 426/Project3/EGR-426-Project-3/cpu.srcs/sources_1/ip/cpuram/cpuram_stub.vhdl}
} _RESULT ] } { 
  puts "CRITICAL WARNING: Unable to successfully create a VHDL synthesis stub for the sub-design. This may lead to errors in top level synthesis of the design. Error reported: $_RESULT"
}

if { [catch {
  file rename -force {C:/Users/Jason/Desktop/EGR 426/Project3/EGR-426-Project-3/cpu.runs/cpuram_synth_1/cpuram_sim_netlist.v} {C:/Users/Jason/Desktop/EGR 426/Project3/EGR-426-Project-3/cpu.srcs/sources_1/ip/cpuram/cpuram_sim_netlist.v}
} _RESULT ] } { 
  puts "CRITICAL WARNING: Unable to successfully create the Verilog functional simulation sub-design file. Post-Synthesis Functional Simulation with this file may not be possible or may give incorrect results. Error reported: $_RESULT"
}

if { [catch {
  file rename -force {C:/Users/Jason/Desktop/EGR 426/Project3/EGR-426-Project-3/cpu.runs/cpuram_synth_1/cpuram_sim_netlist.vhdl} {C:/Users/Jason/Desktop/EGR 426/Project3/EGR-426-Project-3/cpu.srcs/sources_1/ip/cpuram/cpuram_sim_netlist.vhdl}
} _RESULT ] } { 
  puts "CRITICAL WARNING: Unable to successfully create the VHDL functional simulation sub-design file. Post-Synthesis Functional Simulation with this file may not be possible or may give incorrect results. Error reported: $_RESULT"
}

}; # end if cached_ip 

if {[file isdir {C:/Users/Jason/Desktop/EGR 426/Project3/EGR-426-Project-3/cpu.ip_user_files/ip/cpuram}]} {
  catch { 
    file copy -force {{C:/Users/Jason/Desktop/EGR 426/Project3/EGR-426-Project-3/cpu.srcs/sources_1/ip/cpuram/cpuram_stub.v}} {C:/Users/Jason/Desktop/EGR 426/Project3/EGR-426-Project-3/cpu.ip_user_files/ip/cpuram}
  }
}

if {[file isdir {C:/Users/Jason/Desktop/EGR 426/Project3/EGR-426-Project-3/cpu.ip_user_files/ip/cpuram}]} {
  catch { 
    file copy -force {{C:/Users/Jason/Desktop/EGR 426/Project3/EGR-426-Project-3/cpu.srcs/sources_1/ip/cpuram/cpuram_stub.vhdl}} {C:/Users/Jason/Desktop/EGR 426/Project3/EGR-426-Project-3/cpu.ip_user_files/ip/cpuram}
  }
}
