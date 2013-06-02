
# PlanAhead Launch Script for Pre-Synthesis Floorplanning, created by Project Navigator

create_project -name Snake_Final_Project -dir "X:/Desktop/EK311/Snake_Final_Project/planAhead_run_1" -part xc6slx16csg324-3
set_param project.pinAheadLayout yes
set srcset [get_property srcset [current_run -impl]]
set_property top Snake $srcset
set_property target_constrs_file "Snake_UCF.ucf" [current_fileset -constrset]
set hdlfile [add_files [list {Snake.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
add_files [list {Snake_UCF.ucf}] -fileset [get_property constrset [current_run]]
open_rtl_design -part xc6slx16csg324-3
