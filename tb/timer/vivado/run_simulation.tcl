set project_file [file join [file dirname [info script]] "rvx_timer_tests/rvx_timer_tests.xpr"]
if {[file exists $project_file]} {
  open_project $project_file
} else {
  source [file join [file dirname [info script]] "create_test_project.tcl"]
}
set_property top rvx_timer_tb [get_filesets sim_1]
launch_simulation -simset sim_1
run -all