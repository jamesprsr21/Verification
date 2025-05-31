//Counter Design code 
//............................RTL........................................//
//////////////////////////// AUTHOR ////////////////////////////////////////
////////////////////...James Parasar Rabha...//////////////////////////
module counter(clock,reset,load,up,down,in,out);
input bit clock,reset, load, up, down;
input bit[3:0]in;
output logic[3:0]out;

always@(posedge clock)
begin
if(reset)
 out<=3'b0;
	else if(load)
		begin
	 	if(in<=4'b1111)
	 	out<=in;
         	else 
         	out<=4'b0;
		end

	else
		begin
		if(up && !down)
			out<=out+1;
		if(down && !up)
			out<=out-1;
		if(up && down)
			out<=out;
		else
			out<=out;
		end
end

endmodule

//////////////////////////////////////////interface

interface counter_if(input bit clock);
 bit reset, load, up, down;
 bit[3:0]in;
 logic[3:0]out;

clocking drv_cb@(posedge clock);
   default input #1 output #0;
	output reset,load,up,down,in;
endclocking

clocking mon_cb@(posedge clock);
   default input #1 output #0;
   input out,reset, load, up, down, in;
endclocking

modport drive(clocking drv_cb);
modport mon(clocking mon_cb);

endinterface

////////////////////////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////TESTBENCH/////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

//UVM testbench for counter design verification

module top;

`include "uvm_macros.svh"
import uvm_pkg::*;

///////////////////////////////////////////////////////////SEQUENCER
class sequencer extends uvm_sequencer;
 `uvm_component_utils(sequencer)
function new(string name="sequencer",uvm_component parent);
super.new(name,parent);
endfunction
endclass


//////////////////////////////////////////////////////////////Monitor
class monitor extends uvm_monitor;
 `uvm_component_utils(monitor)
function new(string name="monitor",uvm_component parent);
super.new(name,parent);
endfunction

endclass



///////////////////////////////////////////////////////////Driver
class driver extends uvm_driver;
 `uvm_component_utils(driver)
function new(string name="driver",uvm_component parent);
super.new(name,parent);
endfunction
endclass


//////////////////////////////////////////////////////////////AGENT
class agent extends uvm_agent;
 driver drv;
 monitor mn;
 sequencer sqr;
 `uvm_component_utils(agent)
function new(string name="agent",uvm_component parent);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
drv=driver::type_id::create("drv",this);
sqr=sequencer::type_id::create("sqr",this);
mn=monitor::type_id::create("mn",this);
endfunction
endclass





///////////////////////////////////////////////////////////SB
class scoreboard extends uvm_scoreboard;
 `uvm_component_utils(scoreboard)
function new(string name="scoreboard",uvm_component parent);
super.new(name,parent);
endfunction
endclass


//////////////////////////////////////////////////////////////ENV
class environment extends uvm_env;
agent agt;
 `uvm_component_utils(environment)
function new(string name="environment",uvm_component parent);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
agt=agent::type_id::create("agt",this);
endfunction


endclass


///////////////////////////////////////////////////////////TEST
class test extends uvm_test;
 `uvm_component_utils(test)
environment env;
scoreboard scb;

function new(string name="test",uvm_component parent);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
env=environment::type_id::create("env",this);
scb=scoreboard::type_id::create("scb",this);
endfunction

function void end_of_elaboration_phase(uvm_phase phase);
uvm_top.print_topology;
endfunction

endclass

//////////////////////////////////////////////////////////////////



logic clock,reset,load, up, down;
logic[3:0] in,out;

counter dut(clock,reset,load,up,down,in,out);

/*always begin
 #5 clock<=~clock;
end
*/

initial
begin
clock<=1'b0;
forever
#5 clock<=~clock;
end

initial
begin
 run_test("test");
 end

initial 
begin
$dumpfile("counter.vcd");
$dumpvars;
end

initial 
begin
#1000;
$finish;
end

endmodule













