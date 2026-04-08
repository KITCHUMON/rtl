#!/bin/bash
# Local simulation script

set -e  # Exit on any error

echo "Starting RTL simulations..."

# Check if iverilog is available
if ! command -v iverilog &> /dev/null; then
    echo "iverilog not found. Install it with: sudo apt install iverilog"
    exit 1
fi

# Create results directory
mkdir -p results

# Find all modules and simulate
success_count=0
total_count=0

find rtl -name "rtl_*.v" -exec dirname {} \; | while read module_dir; do
    module_name=$(basename $module_dir)
    total_count=$((total_count + 1))
    echo "Testing $module_name..."
    
    # Check if required files exist
    if [ ! -f "$module_dir/rtl_${module_name}.v" ] || [ ! -f "$module_dir/tb_${module_name}.v" ]; then
        echo "❌ $module_name: Missing RTL or testbench file"
        continue
    fi
    
    # Create module-specific results directory
    mkdir -p "results/$module_name"
    
    # Compile
    if iverilog -o "results/$module_name/sim_$module_name.vvp" \
        "$module_dir/rtl_${module_name}.v" "$module_dir/tb_${module_name}.v"; then
        
        # Run simulation
        vvp "results/$module_name/sim_$module_name.vvp" +vcd="results/$module_name/sim_$module_name.vcd" +logfile="results/$module_name/log_$module_name.txt"
        echo "$module_name: Success"
        success_count=$((success_count + 1))
    else
        echo "$module_name: Compilation failed"
    fi
done

echo ""
echo "Simulation Summary:"
echo "Total modules: $total_count"
echo "Successful: $success_count"
echo "Failed: $((total_count - success_count))"

if [ $success_count -eq $total_count ]; then
    echo "All simulations passed!"
else
    echo "Some simulations failed. Check logs for details."
fi
