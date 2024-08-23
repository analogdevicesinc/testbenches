`include "utils.svh"

package filter_pkg;

  import logger_pkg::*;

  class filter_class;

    protected bit [31:0] position;
    protected logic [7:0] value;
    protected bit equals;

    bit result;

    function new(
      input bit [31:0] position,
      input logic [7:0] value,
      input bit equals = 1);

      this.position = position;
      this.value = value;
      this.equals = equals;
      this.result = 0;
    endfunction: new

    function void apply_filter(input logic [7:0] packet[]);
      logic [7:0] value;

      value = packet[this.position];
      for (int i=0; i< $size(value); i++)
        if (this.value[i] == 1'bx || this.value[i] == 1'bz) continue;
        else if (this.value[i] != value[i]) begin
          this.result = !equals;
          return;
        end

      this.result = equals;
      return;
    endfunction: apply_filter

  endclass: filter_class


  class filter_tree_class;

    protected bit filter_type; // 0 - all leaf nodes/cells are evaluated with logical or
                     // 1 - all leaf nodes/cells are evaluated with logical and

    bit result;

    protected filter_class filter[];
    filter_tree_class ft[];

    function new(
      input bit filter_type,
      input bit [31:0] nr_of_filters,
      input bit [31:0] nr_of_filter_trees);

      this.filter_type = filter_type;
      this.result = filter_type;
      this.filter = new[nr_of_filters];
      this.ft = new[nr_of_filter_trees];
    endfunction: new

    function void add_filter(
      input bit [31:0] filter_nr,
      input bit [31:0] position,
      input logic [7:0] value,
      input bit equals = 1);

      this.filter[filter_nr] = new (position, value, equals);
    endfunction: add_filter

    function void add_filter_tree(
      input bit [31:0] filter_tree_nr,
      input bit filter_type,
      input bit [31:0] nr_of_filters,
      input bit [31:0] nr_of_filter_trees);
      
      this.ft[filter_tree_nr] = new (filter_type, nr_of_filters, nr_of_filter_trees);
    endfunction: add_filter_tree

    function void remove_filters();
      this.filter = new[0];
      this.ft = new[0];
    endfunction: remove_filters

    task apply_filter(input logic [7:0] packet[]);
      if (this.filter != null) begin
        for (int i=0; i<this.filter.size(); i++) begin
          fork
            automatic int j=i;
            this.filter[j].apply_filter(packet);
          join
        end
        for (int i=0; i<this.filter.size(); i++) begin
          if (filter_type)
            this.result = this.result & this.filter[i].result;
          else
            this.result = this.result | this.filter[i].result;
        end
      end

      if (this.ft != null) begin
        for (int i=0; i<this.ft.size(); i++) begin
          fork
            automatic int j=i;
            this.ft[j].apply_filter(packet);
          join
        end
        for (int i=0; i<this.ft.size(); i++) begin
          if (filter_type)
            this.result = this.result & this.ft[i].result;
          else
            this.result = this.result | this.ft[i].result;
        end
      end
    endtask: apply_filter

  endclass: filter_tree_class

endpackage: filter_pkg
