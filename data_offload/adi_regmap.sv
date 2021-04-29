`include "utils.svh"

package adi_regmap_pkg::*;

  import logger_pkg::*;

  class adi_regmap;

    typedef enum {RO, RW, RW1C, RW1S} acc_t;

    typedef struct {
      int msb;
      int lsb;
      int value;
    } field_t;

    typedef struct{
      int addr;
      string name;
      acc_t access;
      field_t fields[string];
    } reg_t;

    reg_t regmap_array[];

    // Constructor
    function new();

    endfunction;

    function automatic void setRegister(ref reg_t register,
                                        int value);

      foreach ( register.fields [ field ]) begin
        automatic int msb = register.fields[field].msb;
        automatic int lsb = register.fields[field].lsb;
        for(int i=lsb; i<=msb; i++)
          register.fields[field].value[i] = value[i];
      end

    endfunction;

    function automatic int getRegister(input reg_t register);

      automatic int value = 0;

      foreach ( register.fields[field] ) begin
        value |= register.fields[field].value << register.fields[field].lsb;
      end

      return value;
    endfunction;

    function automatic void setField(ref reg_t register,
                                     string field,
                                     int value);
      automatic int lsb, msb;

      if (!register.fields.exists(field))
        `ERROR(("Field %s in reg %s does not exists", field, register.name));

      lsb = register.fields[field].lsb;
      msb = register.fields[field].msb;

      register.fields[field].value = value << lsb;
      for (int i=msb+1; i<=31; i++) begin
        register.fields[field].value[i]=1'b0;
      end

      `INFOV(("Setting reg %s[%0d:%0d] field %s with %h (%h)", register.name, msb, lsb, field, value), 4);

    endfunction;

    function automatic int getField(reg_t register,
                                    string field);

      automatic int lsb, msb;

      if (!register.fields.exists(field))
        `ERROR(("Field %s in reg %s does not exists", field, register.name));

      return register.fields[field].value;
    endfunction;

    function automatic int getAddrs(reg_t register);
      return register.addr;
    endfunction;

  endclass

endpackage
