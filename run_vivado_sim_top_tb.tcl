# run_vivado_sim_top_tb.sv
#
# The purpose of this script is to run the bdmca vivado
# simulation 'sim_top_tb' while another process builds a separate
# vivado project to support the bdtb build flow.
#
# In this way, the two processes can be run in parallel without
# access conflicts. They each have their own sandbox under
# $PWS/FPGA/BusDefenderFirst/vivado
#
# This tcl script is invoked by pre-commit perl script
#
######################################################################
# Pull in Environment Variables
set PWS               $::env(PWS)
set VIVADO_START_DIR  ${PWS}/FPGA/BusDefenderFirst
set VPJ               ${VIVADO_START_DIR}/vivado
set PROJECT_BUILD_TCL ${PWS}/FPGA/BusDefenderFirst/scripts/recreate_project.tcl
#set VIVADO_EXPORT     $::env(VIVADO_EXPORT)
#set EXPORT_XIP_TCL    $::env(EXPORT_XIP_TCL)
#set XIL_IP_DIR        $::env(XIL_IP_DIR)

# Set variables used by this script
set user_project_name "sim_top_tb"

# Put Vivado in the directory expected by the recreate_prj.tcl
cd $VIVADO_START_DIR

# First, build the Vivado project which is defined in a script
# which is maintained by the FPGA team
source $PROJECT_BUILD_TCL -notrace

# Run the simulation sim_top_tb
#start_gui
update_compile_order -fileset sources_1
generate_target Simulation \
    [get_files ${VIVADO_START_DIR}/bd/bd_top.bd]

export_ip_user_files \
    -of_objects [get_files ${VIVADO_START_DIR}/bd/bd_top.bd]          \
    -no_script -sync -force -quiet

export_simulation -of_objects                                         \
    [get_files ${VIVADO_START_DIR}/bd/bd_top.bd]                      \
    -directory ${VPJ}/project_1.ip_user_files/sim_scripts             \
    -ip_user_files_dir ${VPJ}/project_1.ip_user_files                 \
    -ipstatic_source_dir ${VPJ}/project_1.ip_user_files/ipstatic      \
    -lib_map_path                                                     \
    [list                                                             \
         {modelsim=${VPJ}/project_1.cache/compile_simlib/modelsim}    \
         {questa=${VPJ}/project_1.cache/compile_simlib/questa}        \
         {ies=${VPJ}/project_1.cache/compile_simlib/ies}              \
         {xcelium=${VPJ}/project_1.cache/compile_simlib/xcelium}      \
         {vcs=${VPJ}/project_1.cache/compile_simlib/vcs}              \
         {riviera=${VPJ}/project_1.cache/compile_simlib/riviera}]     \
    -use_ip_compiled_libs -force -quiet

launch_simulation
exit
