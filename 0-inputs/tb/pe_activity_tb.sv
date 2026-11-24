// ── Activity testbench ─────────────────────────────────────────────

`timescale 1ns/1ps

`ifndef CLK_PERIOD
  `define CLK_PERIOD 4.0
`endif
`ifndef SWITCH_LEAD
  `define SWITCH_LEAD 0
`endif
`ifndef N_CYCLES
  `define N_CYCLES 4096
`endif
`ifndef SWAP_EVERY
  `define SWAP_EVERY 64
`endif
`ifndef SEED
  `define SEED 1
`endif
`ifndef VCD_FILE
  `define VCD_FILE "pe.vcd"
`endif

module pe_activity_tb;

  localparam QI = 8, QF = 8, DW = 16;
  localparam int LOAD_AT = 8;

  logic clk = 0, rst;
  always #( `CLK_PERIOD / 2.0 ) clk = ~clk;

  logic signed [DW-1:0] pe_psum_in, pe_weight_in, pe_input_in;
  logic                 pe_accept_w_in, pe_valid_in, pe_switch_in, pe_enabled;
  logic signed [DW-1:0] pe_psum_out, pe_weight_out, pe_input_out;
  logic                 pe_valid_out, pe_switch_out;

  pe #(QI,QF) dut (.*);

  // ── Stimulus ──

  function automatic logic signed [DW-1:0] rand_weight();
    return DW'( int'($urandom_range(511)) - 256 );
  endfunction

  int unsigned  pos;
  logic         valid;

  initial begin
    void'( $urandom( `SEED ) );

    rst = 1; pe_accept_w_in = 0; pe_valid_in = 0; pe_switch_in = 0;
    pe_enabled = 1; pe_psum_in = '0; pe_weight_in = '0; pe_input_in = '0;
    repeat (2) @( negedge clk );
    rst = 0;

    // First weight
    pe_accept_w_in = 1; pe_weight_in = rand_weight(); @( negedge clk );
    pe_accept_w_in = 0; pe_weight_in = '0;
    pe_switch_in   = 1;                               @( negedge clk );
    pe_switch_in   = 0;
    repeat (2) @( negedge clk );

    $dumpfile( `VCD_FILE );
    $dumpvars( 0, dut );

    for ( int c = 0; c < `N_CYCLES; c++ ) begin
      pos = c % `SWAP_EVERY;

      // Next weight
      pe_accept_w_in = ( pos == LOAD_AT );
      pe_weight_in   = ( pos == LOAD_AT ) ? rand_weight() : '0;

      // Weight promotion
      pe_switch_in   = ( c > 0 ) && ( ( c + `SWITCH_LEAD ) % `SWAP_EVERY == 0 );

      valid = ( $urandom_range(3) != 0 );
      pe_valid_in = valid;
      if ( valid ) begin
        pe_input_in = ( $urandom_range(1) == 0 ) ? '0 : DW'( $urandom_range(1023, 1) );
        pe_psum_in  = DW'( int'($urandom_range(4095)) - 2048 );
      end
      else begin
        pe_input_in = '0;
        pe_psum_in  = '0;
      end

      @( negedge clk );
    end

    $dumpflush;
    $display( "activity: %0d cycles at %0.3f ns, switch lead %0d, vcd %s",
              `N_CYCLES, `CLK_PERIOD, `SWITCH_LEAD, `VCD_FILE );
    $finish;
  end

endmodule
