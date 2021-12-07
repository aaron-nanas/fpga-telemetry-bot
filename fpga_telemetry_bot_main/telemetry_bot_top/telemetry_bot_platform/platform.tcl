# 
# Usage: To re-create this platform project launch xsct with below options.
# xsct /home/aaronnanas/vivado_projects/ece524_final_proj/telemetry_bot_top/telemetry_bot_platform/platform.tcl
# 
# OR launch xsct and run below command.
# source /home/aaronnanas/vivado_projects/ece524_final_proj/telemetry_bot_top/telemetry_bot_platform/platform.tcl
# 
# To create the platform in a different location, modify the -out option of "platform create" command.
# -out option specifies the output directory of the platform project.

platform create -name {telemetry_bot_platform}\
-hw {/home/aaronnanas/vivado_projects/ece524_final_proj/telemetry_bot_top/telemetry_bot_wrapper.xsa}\
-proc {ps7_cortexa9_0} -os {standalone} -fsbl-target {psu_cortexa53_0} -out {/home/aaronnanas/vivado_projects/ece524_final_proj/telemetry_bot_top}

platform write
platform generate -domains 
platform active {telemetry_bot_platform}
platform generate
bsp reload
bsp setlib -name xilffs -ver 4.4
bsp write
bsp reload
catch {bsp regenerate}
platform generate -domains standalone_domain 
