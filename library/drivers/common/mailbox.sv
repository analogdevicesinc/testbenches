`include "utils.svh"

package mailbox_pkg;

  import logger_pkg::*;

  class mailbox_c #(type T) extends adi_component;

    T queue[$];

    int size_max;

    event q_event;

    // constructor
    function new(
      input string name,
      input int size_max = 0,
      input adi_component parent = null);

      super.new(name, parent);
      
      this.size_max = size_max;
    endfunction

    function int num();
      return this.queue.size();
    endfunction

    task get(ref T element);
      if (this.num() == 0)
        @this.q_event;
      element = this.queue.pop_back();
      ->this.q_event;
    endtask

    function int try_get(ref T element);
      if (this.num() == 0)
        return 0;
      element = this.queue.pop_back();
      ->this.q_event;
      return 1;
    endfunction

    task put(input T element);
      if (this.size_max == this.num() && this.size_max != 0)
        @this.q_event;
      this.queue.push_front(element);
      ->this.q_event;
    endtask

    function int try_put(input T element);
      if (this.size_max == this.num() && this.size_max != 0)
        return 0;
      this.queue.push_front(element);
      ->this.q_event;
      return 1;
    endfunction

    task flush();
      T element;
      while(this.try_get(element));
    endtask

  endclass

endpackage
