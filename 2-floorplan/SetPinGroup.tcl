# ── Pin groups ───────────────────────────────────────────────────────────────
# Port names for each edit_pin in floorplan.tcl. Buses list bit 0 first.

# bus pe_psum_in 16 -> pe_psum_in[0] pe_psum_in[1] ... pe_psum_in[15]
proc bus {name width} {
    set pins {}
    for {set i 0} {$i < $width} {incr i} { lappend pins "$name\[$i\]" }
    return $pins
}

# ── Inputs ───────────────────────────────────────────────────────────────────
set CtrlIn   {clk rst pe_accept_w_in pe_valid_in pe_switch_in pe_enabled}
set PsumIn   [bus pe_psum_in    16]
set WeightIn [bus pe_weight_in  16] ; # create for weight in
set InputIn  [bus pe_input_in   16] ; # create for input in

# ── Outputs ──────────────────────────────────────────────────────────────────
set CtrlOut   {pe_valid_out pe_switch_out} ; # put your two output controls here
set PsumOut   [bus pe_psum_out   16]
set WeightOut [bus pe_weight_out 16] ; # create for weight out
set InputOut  [bus pe_input_out  16] ; # create for input out
