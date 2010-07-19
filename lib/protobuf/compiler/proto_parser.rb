#
# DO NOT MODIFY!!!!
# This file is automatically generated by racc 1.4.5
# from racc grammer file "lib/protobuf/compiler/proto.y".
#
#
# lib/protobuf/compiler/proto_parser.rb: generated by racc (runtime embedded)
#
###### racc/parser.rb begin
unless $".index 'racc/parser.rb'
$".push 'racc/parser.rb'

self.class.module_eval <<'..end racc/parser.rb modeval..id24fd9e97a6', 'racc/parser.rb', 1
#
# $Id: parser.rb,v 1.7 2005/11/20 17:31:32 aamine Exp $
#
# Copyright (c) 1999-2005 Minero Aoki
#
# This program is free software.
# You can distribute/modify this program under the same terms of ruby.
#
# As a special exception, when this code is copied by Racc
# into a Racc output file, you may use that output file
# without restriction.
#

unless defined?(NotImplementedError)
  NotImplementedError = NotImplementError
end

module Racc
  class ParseError < StandardError; end
end
unless defined?(::ParseError)
  ParseError = Racc::ParseError
end

module Racc

  unless defined?(Racc_No_Extentions)
    Racc_No_Extentions = false
  end

  class Parser

    Racc_Runtime_Version = '1.4.5'
    Racc_Runtime_Revision = '$Revision: 1.7 $'.split[1]

    Racc_Runtime_Core_Version_R = '1.4.5'
    Racc_Runtime_Core_Revision_R = '$Revision: 1.7 $'.split[1]
    begin
      require 'racc/cparse'
    # Racc_Runtime_Core_Version_C  = (defined in extention)
      Racc_Runtime_Core_Revision_C = Racc_Runtime_Core_Id_C.split[2]
      unless new.respond_to?(:_racc_do_parse_c, true)
        raise LoadError, 'old cparse.so'
      end
      if Racc_No_Extentions
        raise LoadError, 'selecting ruby version of racc runtime core'
      end

      Racc_Main_Parsing_Routine    = :_racc_do_parse_c
      Racc_YY_Parse_Method         = :_racc_yyparse_c
      Racc_Runtime_Core_Version    = Racc_Runtime_Core_Version_C
      Racc_Runtime_Core_Revision   = Racc_Runtime_Core_Revision_C
      Racc_Runtime_Type            = 'c'
    rescue LoadError
      $stderr.puts $!
      Racc_Main_Parsing_Routine    = :_racc_do_parse_rb
      Racc_YY_Parse_Method         = :_racc_yyparse_rb
      Racc_Runtime_Core_Version    = Racc_Runtime_Core_Version_R
      Racc_Runtime_Core_Revision   = Racc_Runtime_Core_Revision_R
      Racc_Runtime_Type            = 'ruby'
    end

    def Parser.racc_runtime_type
      Racc_Runtime_Type
    end

    private

    def _racc_setup
      @yydebug = false unless self.class::Racc_debug_parser
      @yydebug = false unless defined?(@yydebug)
      if @yydebug
        @racc_debug_out = $stderr unless defined?(@racc_debug_out)
        @racc_debug_out ||= $stderr
      end
      arg = self.class::Racc_arg
      arg[13] = true if arg.size < 14
      arg
    end

    def _racc_init_sysvars
      @racc_state  = [0]
      @racc_tstack = []
      @racc_vstack = []

      @racc_t = nil
      @racc_val = nil

      @racc_read_next = true

      @racc_user_yyerror = false
      @racc_error_status = 0
    end

    ###
    ### do_parse
    ###

    def do_parse
      __send__(Racc_Main_Parsing_Routine, _racc_setup(), false)
    end

    def next_token
      raise NotImplementedError, "#{self.class}\#next_token is not defined"
    end

    def _racc_do_parse_rb(arg, in_debug)
      action_table, action_check, action_default, action_pointer,
      goto_table,   goto_check,   goto_default,   goto_pointer,
      nt_base,      reduce_table, token_table,    shift_n,
      reduce_n,     use_result,   * = arg

      _racc_init_sysvars
      tok = act = i = nil
      nerr = 0

      catch(:racc_end_parse) {
        while true
          if i = action_pointer[@racc_state[-1]]
            if @racc_read_next
              if @racc_t != 0   # not EOF
                tok, @racc_val = next_token()
                unless tok      # EOF
                  @racc_t = 0
                else
                  @racc_t = (token_table[tok] or 1)   # error token
                end
                racc_read_token(@racc_t, tok, @racc_val) if @yydebug
                @racc_read_next = false
              end
            end
            i += @racc_t
            unless i >= 0 and
                   act = action_table[i] and
                   action_check[i] == @racc_state[-1]
              act = action_default[@racc_state[-1]]
            end
          else
            act = action_default[@racc_state[-1]]
          end
          while act = _racc_evalact(act, arg)
            ;
          end
        end
      }
    end

    ###
    ### yyparse
    ###

    def yyparse(recv, mid)
      __send__(Racc_YY_Parse_Method, recv, mid, _racc_setup(), true)
    end

    def _racc_yyparse_rb(recv, mid, arg, c_debug)
      action_table, action_check, action_default, action_pointer,
      goto_table,   goto_check,   goto_default,   goto_pointer,
      nt_base,      reduce_table, token_table,    shift_n,
      reduce_n,     use_result,   * = arg

      _racc_init_sysvars
      tok = nil
      act = nil
      i = nil
      nerr = 0

      catch(:racc_end_parse) {
        until i = action_pointer[@racc_state[-1]]
          while act = _racc_evalact(action_default[@racc_state[-1]], arg)
            ;
          end
        end
        recv.__send__(mid) do |tok, val|
          unless tok
            @racc_t = 0
          else
            @racc_t = (token_table[tok] or 1)   # error token
          end
          @racc_val = val
          @racc_read_next = false

          i += @racc_t
          unless i >= 0 and
                 act = action_table[i] and
                 action_check[i] == @racc_state[-1]
            act = action_default[@racc_state[-1]]
          end
          while act = _racc_evalact(act, arg)
            ;
          end

          while not (i = action_pointer[@racc_state[-1]]) or
                not @racc_read_next or
                @racc_t == 0   # $
            unless i and i += @racc_t and
                   i >= 0 and
                   act = action_table[i] and
                   action_check[i] == @racc_state[-1]
              act = action_default[@racc_state[-1]]
            end
            while act = _racc_evalact(act, arg)
              ;
            end
          end
        end
      }
    end

    ###
    ### common
    ###

    def _racc_evalact(act, arg)
      action_table, action_check, action_default, action_pointer,
      goto_table,   goto_check,   goto_default,   goto_pointer,
      nt_base,      reduce_table, token_table,    shift_n,
      reduce_n,     use_result,   * = arg
      nerr = 0   # tmp

      if act > 0 and act < shift_n
        #
        # shift
        #
        if @racc_error_status > 0
          @racc_error_status -= 1 unless @racc_t == 1   # error token
        end
        @racc_vstack.push @racc_val
        @racc_state.push act
        @racc_read_next = true
        if @yydebug
          @racc_tstack.push @racc_t
          racc_shift @racc_t, @racc_tstack, @racc_vstack
        end

      elsif act < 0 and act > -reduce_n
        #
        # reduce
        #
        code = catch(:racc_jump) {
          @racc_state.push _racc_do_reduce(arg, act)
          false
        }
        if code
          case code
          when 1 # yyerror
            @racc_user_yyerror = true   # user_yyerror
            return -reduce_n
          when 2 # yyaccept
            return shift_n
          else
            raise '[Racc Bug] unknown jump code'
          end
        end

      elsif act == shift_n
        #
        # accept
        #
        racc_accept if @yydebug
        throw :racc_end_parse, @racc_vstack[0]

      elsif act == -reduce_n
        #
        # error
        #
        case @racc_error_status
        when 0
          unless arg[21]    # user_yyerror
            nerr += 1
            on_error @racc_t, @racc_val, @racc_vstack
          end
        when 3
          if @racc_t == 0   # is $
            throw :racc_end_parse, nil
          end
          @racc_read_next = true
        end
        @racc_user_yyerror = false
        @racc_error_status = 3
        while true
          if i = action_pointer[@racc_state[-1]]
            i += 1   # error token
            if  i >= 0 and
                (act = action_table[i]) and
                action_check[i] == @racc_state[-1]
              break
            end
          end
          throw :racc_end_parse, nil if @racc_state.size <= 1
          @racc_state.pop
          @racc_vstack.pop
          if @yydebug
            @racc_tstack.pop
            racc_e_pop @racc_state, @racc_tstack, @racc_vstack
          end
        end
        return act

      else
        raise "[Racc Bug] unknown action #{act.inspect}"
      end

      racc_next_state(@racc_state[-1], @racc_state) if @yydebug

      nil
    end

    def _racc_do_reduce(arg, act)
      action_table, action_check, action_default, action_pointer,
      goto_table,   goto_check,   goto_default,   goto_pointer,
      nt_base,      reduce_table, token_table,    shift_n,
      reduce_n,     use_result,   * = arg
      state = @racc_state
      vstack = @racc_vstack
      tstack = @racc_tstack

      i = act * -3
      len       = reduce_table[i]
      reduce_to = reduce_table[i+1]
      method_id = reduce_table[i+2]
      void_array = []

      tmp_t = tstack[-len, len] if @yydebug
      tmp_v = vstack[-len, len]
      tstack[-len, len] = void_array if @yydebug
      vstack[-len, len] = void_array
      state[-len, len]  = void_array

      # tstack must be updated AFTER method call
      if use_result
        vstack.push __send__(method_id, tmp_v, vstack, tmp_v[0])
      else
        vstack.push __send__(method_id, tmp_v, vstack)
      end
      tstack.push reduce_to

      racc_reduce(tmp_t, reduce_to, tstack, vstack) if @yydebug

      k1 = reduce_to - nt_base
      if i = goto_pointer[k1]
        i += state[-1]
        if i >= 0 and (curstate = goto_table[i]) and goto_check[i] == k1
          return curstate
        end
      end
      goto_default[k1]
    end

    def on_error(t, val, vstack)
      raise ParseError, sprintf("\nparse error on value %s (%s)",
                                val.inspect, token_to_str(t) || '?')
    end

    def yyerror
      throw :racc_jump, 1
    end

    def yyaccept
      throw :racc_jump, 2
    end

    def yyerrok
      @racc_error_status = 0
    end

    #
    # for debugging output
    #

    def racc_read_token(t, tok, val)
      @racc_debug_out.print 'read    '
      @racc_debug_out.print tok.inspect, '(', racc_token2str(t), ') '
      @racc_debug_out.puts val.inspect
      @racc_debug_out.puts
    end

    def racc_shift(tok, tstack, vstack)
      @racc_debug_out.puts "shift   #{racc_token2str tok}"
      racc_print_stacks tstack, vstack
      @racc_debug_out.puts
    end

    def racc_reduce(toks, sim, tstack, vstack)
      out = @racc_debug_out
      out.print 'reduce '
      if toks.empty?
        out.print ' <none>'
      else
        toks.each {|t| out.print ' ', racc_token2str(t) }
      end
      out.puts " --> #{racc_token2str(sim)}"
          
      racc_print_stacks tstack, vstack
      @racc_debug_out.puts
    end

    def racc_accept
      @racc_debug_out.puts 'accept'
      @racc_debug_out.puts
    end

    def racc_e_pop(state, tstack, vstack)
      @racc_debug_out.puts 'error recovering mode: pop token'
      racc_print_states state
      racc_print_stacks tstack, vstack
      @racc_debug_out.puts
    end

    def racc_next_state(curstate, state)
      @racc_debug_out.puts  "goto    #{curstate}"
      racc_print_states state
      @racc_debug_out.puts
    end

    def racc_print_stacks(t, v)
      out = @racc_debug_out
      out.print '        ['
      t.each_index do |i|
        out.print ' (', racc_token2str(t[i]), ' ', v[i].inspect, ')'
      end
      out.puts ' ]'
    end

    def racc_print_states(s)
      out = @racc_debug_out
      out.print '        ['
      s.each {|st| out.print ' ', st }
      out.puts ' ]'
    end

    def racc_token2str(tok)
      self.class::Racc_token_to_s_table[tok] or
          raise "[Racc Bug] can't convert token #{tok} to string"
    end

    def token_to_str(t)
      self.class::Racc_token_to_s_table[t]
    end

  end

end
..end racc/parser.rb modeval..id24fd9e97a6
end
###### racc/parser.rb end


module Protobuf

  class ProtoParser < Racc::Parser

module_eval <<'..end lib/protobuf/compiler/proto.y modeval..id110d2bf917', 'lib/protobuf/compiler/proto.y', 158

  require 'strscan'

  def parse(f)
    @scanner = StringScanner.new(f.read)
    yyparse(self, :scan)
  end

  def scan_debug
    scan do |token, value|
      p [token, value]
      yield [token, value]
    end
  end

  def scan
    until @scanner.eos?
      case
      when match(/\s+/, /\/\/.*/)
        # skip
      when match(/\/\*/)
        # C-like comment
        raise 'EOF inside block comment' until @scanner.scan_until(/\*\//)
      when match(/(?:required|optional|repeated|import|package|option|message|extend|enum|service|rpc|returns|group|default|extensions|to|max|double|float|int32|int64|uint32|uint64|sint32|sint64|fixed32|fixed64|sfixed32|sfixed64|bool|string|bytes)\b/)
        yield [@token, @token.to_sym]
      when match(/[+-]?\d*\.\d+([Ee][\+-]?\d+)?/)
        yield [:FLOAT_LITERAL, @token.to_f]
      when match(/[+-]?[1-9]\d*(?!\.)/, /0(?![.xX0-9])/)
        yield [:DEC_INTEGER, @token.to_i]
      when match(/0[xX]([A-Fa-f0-9])+/)
        yield [:HEX_INTEGER, @token.to_i(0)]
      when match(/0[0-7]+/)
        yield [:OCT_INTEGER, @token.to_i(0)]
      when match(/(true|false)\b/)
        yield [:BOOLEAN_LITERAL, @token == 'true']
      when match(/"(?:[^"\\]+|\\.)*"/, /'(?:[^'\\]+|\\.)*'/)
        yield [:STRING_LITERAL, eval(@token)]
      when match(/[a-zA-Z_]\w*/)
        yield [:IDENT, @token.to_sym]
      when match(/[A-Z]\w*/)
        yield [:CAMEL_IDENT, @token.to_sym]
      when match(/./)
        yield [@token, @token]
      else
        raise "parse error around #{@scanner.string[@scanner.pos, 32].inspect}"
      end
    end
    yield [false, nil]
  end

  def match(*regular_expressions)
    regular_expressions.each do |re|
      if @scanner.scan(re)
        @token = @scanner[0]
        return true
      end
    end
    false
  end
..end lib/protobuf/compiler/proto.y modeval..id110d2bf917

##### racc 1.4.5 generates ###

racc_reduce_table = [
 0, 0, :racc_error,
 1, 53, :_reduce_1,
 2, 53, :_reduce_2,
 1, 54, :_reduce_none,
 1, 54, :_reduce_none,
 1, 54, :_reduce_none,
 1, 54, :_reduce_none,
 1, 54, :_reduce_none,
 1, 54, :_reduce_none,
 1, 54, :_reduce_none,
 1, 54, :_reduce_10,
 3, 58, :_reduce_11,
 4, 59, :_reduce_12,
 0, 62, :_reduce_13,
 3, 62, :_reduce_14,
 3, 60, :_reduce_15,
 4, 63, :_reduce_16,
 3, 55, :_reduce_17,
 5, 56, :_reduce_18,
 0, 67, :_reduce_19,
 2, 67, :_reduce_20,
 1, 68, :_reduce_none,
 1, 68, :_reduce_none,
 1, 68, :_reduce_23,
 5, 57, :_reduce_24,
 0, 71, :_reduce_25,
 2, 71, :_reduce_26,
 1, 72, :_reduce_none,
 1, 72, :_reduce_none,
 1, 72, :_reduce_29,
 4, 73, :_reduce_30,
 5, 61, :_reduce_31,
 0, 75, :_reduce_32,
 2, 75, :_reduce_33,
 1, 76, :_reduce_none,
 1, 76, :_reduce_none,
 1, 76, :_reduce_36,
 10, 77, :_reduce_37,
 0, 78, :_reduce_none,
 1, 78, :_reduce_none,
 3, 65, :_reduce_40,
 0, 79, :_reduce_41,
 2, 79, :_reduce_42,
 1, 80, :_reduce_none,
 1, 80, :_reduce_none,
 1, 80, :_reduce_none,
 1, 80, :_reduce_none,
 1, 80, :_reduce_none,
 1, 80, :_reduce_none,
 1, 80, :_reduce_none,
 1, 80, :_reduce_50,
 6, 70, :_reduce_51,
 6, 69, :_reduce_52,
 9, 69, :_reduce_53,
 1, 84, :_reduce_none,
 1, 84, :_reduce_none,
 1, 84, :_reduce_none,
 1, 84, :_reduce_none,
 1, 84, :_reduce_none,
 1, 84, :_reduce_none,
 1, 84, :_reduce_none,
 1, 84, :_reduce_none,
 1, 84, :_reduce_none,
 1, 84, :_reduce_none,
 1, 84, :_reduce_none,
 1, 84, :_reduce_none,
 1, 84, :_reduce_none,
 1, 84, :_reduce_none,
 1, 84, :_reduce_none,
 1, 84, :_reduce_none,
 1, 84, :_reduce_none,
 1, 84, :_reduce_none,
 1, 84, :_reduce_none,
 1, 84, :_reduce_none,
 1, 84, :_reduce_none,
 1, 84, :_reduce_none,
 1, 84, :_reduce_none,
 1, 84, :_reduce_none,
 1, 84, :_reduce_none,
 1, 84, :_reduce_none,
 1, 84, :_reduce_none,
 1, 84, :_reduce_none,
 1, 84, :_reduce_none,
 1, 84, :_reduce_none,
 1, 84, :_reduce_none,
 1, 84, :_reduce_none,
 1, 84, :_reduce_none,
 1, 85, :_reduce_87,
 3, 85, :_reduce_88,
 1, 86, :_reduce_none,
 3, 86, :_reduce_90,
 4, 81, :_reduce_91,
 0, 88, :_reduce_92,
 2, 88, :_reduce_93,
 1, 87, :_reduce_94,
 3, 87, :_reduce_95,
 3, 87, :_reduce_96,
 1, 82, :_reduce_none,
 1, 82, :_reduce_none,
 1, 82, :_reduce_none,
 1, 83, :_reduce_none,
 1, 83, :_reduce_none,
 1, 83, :_reduce_none,
 1, 83, :_reduce_none,
 1, 83, :_reduce_none,
 1, 83, :_reduce_none,
 1, 83, :_reduce_none,
 1, 83, :_reduce_none,
 1, 83, :_reduce_none,
 1, 83, :_reduce_none,
 1, 83, :_reduce_none,
 1, 83, :_reduce_none,
 1, 83, :_reduce_none,
 1, 83, :_reduce_none,
 1, 83, :_reduce_none,
 1, 83, :_reduce_none,
 2, 66, :_reduce_116,
 3, 66, :_reduce_117,
 1, 64, :_reduce_none,
 1, 64, :_reduce_none,
 1, 64, :_reduce_none,
 1, 64, :_reduce_none,
 1, 64, :_reduce_none,
 1, 74, :_reduce_none,
 1, 74, :_reduce_none,
 1, 74, :_reduce_none ]

racc_reduce_n = 126

racc_shift_n = 184

racc_action_table = [
    74,    51,    77,    19,    20,    74,    25,    77,    67,    60,
    32,    47,    53,    63,    14,    14,    43,   107,    39,    68,
    61,    38,    69,    50,    54,    56,   110,   170,   106,   109,
    94,    96,    97,    98,    99,   100,   101,   103,   104,   105,
   108,    93,    95,    72,    73,    75,    76,    78,    72,    73,
    75,    76,    78,   123,   111,   131,   134,    43,   141,    48,
   147,   116,    19,    20,   122,   126,   130,    19,    20,   140,
   144,    75,    76,    78,   120,   124,   127,   129,   133,   136,
   139,   143,   146,   115,   118,   119,   121,   125,   128,   132,
   135,   138,   142,   145,   114,   117,    83,   167,   176,    75,
    76,    78,    14,    25,    16,     1,   159,    85,     6,    75,
    76,    78,    75,    76,    78,    19,    20,   166,    50,    54,
    56,   177,    91,    35,   170,    75,    76,    78,    27,    34,
     4,     7,   148,    11,    33,   150,    14,   151,    16,     1,
   153,   154,     6,     9,     4,     7,   155,    11,   156,    43,
    14,    40,    16,     1,   161,    30,     6,     9,    75,    76,
    78,    29,    25,   165,    24,    40,   169,    23,   174,   175,
    22,    43,    21,   180,    59,   182,   183 ]

racc_action_check = [
    48,    42,    48,    58,    58,   175,   177,   175,    46,    45,
    20,    36,    42,    45,    46,    45,    36,    58,    27,    46,
    45,    26,    46,    42,    42,    42,    63,   177,    58,    58,
    58,    58,    58,    58,    58,    58,    58,    58,    58,    58,
    58,    58,    58,    48,    48,    48,    48,    48,   175,   175,
   175,   175,   175,   102,    69,   102,   102,    37,   102,    37,
   102,   102,   150,   150,   102,   102,   102,     1,     1,   102,
   102,    91,    91,    91,   102,   102,   102,   102,   102,   102,
   102,   102,   102,   102,   102,   102,   102,   102,   102,   102,
   102,   102,   102,   102,   102,   102,    49,   163,   172,   110,
   110,   110,    49,   166,    49,    49,   151,    49,    49,   154,
   154,   154,   153,   153,   153,   174,   174,   163,    49,    49,
    49,   172,    49,    23,   166,   151,   151,   151,    15,    22,
    15,    15,   107,    15,    21,   111,    15,   112,    15,    15,
   113,   137,    15,    15,     0,     0,   148,     0,   149,    44,
     0,    29,     0,     0,   152,    18,     0,     0,   155,   155,
   155,    16,    14,   158,    11,   164,   165,     9,   169,   170,
     7,    31,     6,   176,    43,   178,   182 ]

racc_action_pointer = [
   142,    61,   nil,   nil,   nil,   nil,   166,   166,   nil,   161,
   nil,   158,   nil,   nil,   156,   128,   155,   nil,   143,   nil,
     4,   122,   127,   111,   nil,   nil,    19,    18,   nil,   139,
   nil,   164,   nil,   nil,   nil,   nil,     9,    50,   nil,   nil,
   nil,   nil,    -1,   168,   142,     7,     6,   nil,    -4,    94,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,    -3,   nil,
   nil,   nil,   nil,    17,   nil,   nil,   nil,   nil,   nil,    48,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,    22,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,    50,   nil,   nil,   nil,   nil,   111,   nil,   nil,
    50,   118,   108,    94,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   132,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   137,   146,
    56,    76,   152,    63,    60,   109,   nil,   nil,   145,   nil,
   nil,   nil,   nil,    95,   153,   147,    97,   nil,   nil,   151,
   160,   nil,    75,   nil,   109,     1,   171,     0,   157,   nil,
   nil,   nil,   174,   nil ]

racc_action_default = [
  -126,  -126,    -3,    -4,   -10,    -5,  -126,  -126,    -6,  -126,
    -7,  -126,    -8,    -9,  -126,  -126,  -126,    -1,  -126,   -13,
  -126,  -126,  -126,  -126,   -13,   -13,  -126,  -126,    -2,  -126,
   -19,  -116,   -13,   -25,   -11,   -32,  -126,  -126,   -15,   184,
   -41,   -17,  -126,  -126,  -117,  -126,  -126,   -12,  -126,  -126,
   -97,   -23,   -20,   -18,   -98,   -21,   -99,   -22,  -126,   -14,
   -29,   -24,   -27,  -126,   -26,   -28,   -35,   -36,   -31,  -126,
   -34,   -33,  -120,  -122,  -121,  -123,  -124,  -118,  -125,  -119,
   -16,   -45,   -46,   -50,   -44,   -40,   -43,   -42,   -48,   -47,
   -49,  -126,  -115,  -113,  -102,  -114,  -103,  -104,  -105,  -106,
  -107,  -108,  -126,  -109,  -110,  -111,  -100,  -126,  -112,  -101,
  -126,  -126,   -94,   -92,   -85,   -74,   -62,   -86,   -75,   -76,
   -55,   -77,   -63,   -58,   -56,   -78,   -64,   -57,   -79,   -68,
   -65,   -59,   -80,   -69,   -54,   -81,   -70,  -126,   -82,   -71,
   -66,   -60,   -83,   -72,   -67,   -84,   -73,   -61,  -126,  -126,
   -38,  -126,  -126,  -126,  -126,  -126,   -30,   -39,  -126,   -96,
   -95,   -91,   -93,  -126,  -126,  -126,  -126,   -52,   -51,  -126,
  -126,   -89,  -126,   -87,   -38,  -126,  -126,  -126,  -126,   -90,
   -53,   -88,  -126,   -37 ]

racc_goto_table = [
    41,    80,   112,    18,   158,   113,    31,    17,    57,   173,
    55,    36,    37,    64,    42,    88,    26,    86,    45,    44,
   181,   149,    28,    62,    70,    52,    65,    90,   178,    84,
    46,    71,    66,    82,    49,    87,    89,   102,   137,   172,
    81,    15,   152,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
    92,   nil,   160,   nil,   112,   163,   164,   162,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   179,   nil,
   nil,   nil,   nil,   nil,   nil,   168 ]

racc_goto_check = [
    13,    12,    22,    14,    26,    35,    10,     2,    18,    34,
    17,    10,    10,    20,    15,    18,    11,    17,    19,    10,
    34,    22,     2,     8,     8,    16,    21,     8,    26,     5,
    23,    24,    25,     4,    27,    28,    29,    31,    32,    33,
     3,     1,    36,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
    14,   nil,    22,   nil,    22,    22,    22,    35,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,    12,   nil,
   nil,   nil,   nil,   nil,   nil,    13 ]

racc_goto_pointer = [
   nil,    41,     7,    -9,   -16,   -20,   nil,   nil,   -22,   nil,
   -13,     2,   -47,   -29,     2,   -16,   -17,   -32,   -34,   -15,
   -32,   -19,   -89,    -5,   -15,   -14,  -146,    -6,   -14,   -13,
   nil,   -21,   -64,  -127,  -157,   -86,   -71 ]

racc_goto_default = [
   nil,   nil,   nil,     2,     3,     5,     8,    10,    12,    13,
   nil,   171,   nil,   nil,   157,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,    79,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
    58,   nil,   nil,   nil,   nil,   nil,   nil ]

racc_token_table = {
 false => 0,
 Object.new => 1,
 ";" => 2,
 "import" => 3,
 :STRING_LITERAL => 4,
 "package" => 5,
 :IDENT => 6,
 "." => 7,
 "option" => 8,
 "=" => 9,
 "message" => 10,
 "extend" => 11,
 "{" => 12,
 "}" => 13,
 "enum" => 14,
 "service" => 15,
 "rpc" => 16,
 "(" => 17,
 ")" => 18,
 "returns" => 19,
 "group" => 20,
 :CAMEL_IDENT => 21,
 "[" => 22,
 "]" => 23,
 "required" => 24,
 "optional" => 25,
 "repeated" => 26,
 "default" => 27,
 "extensions" => 28,
 "to" => 29,
 "max" => 30,
 "double" => 31,
 "float" => 32,
 "int32" => 33,
 "int64" => 34,
 "uint32" => 35,
 "uint64" => 36,
 "sint32" => 37,
 "sint64" => 38,
 "fixed32" => 39,
 "fixed64" => 40,
 "sfixed32" => 41,
 "sfixed64" => 42,
 "bool" => 43,
 "string" => 44,
 "bytes" => 45,
 "," => 46,
 :FLOAT_LITERAL => 47,
 :BOOLEAN_LITERAL => 48,
 :DEC_INTEGER => 49,
 :HEX_INTEGER => 50,
 :OCT_INTEGER => 51 }

racc_use_result_var = true

racc_nt_base = 52

Racc_arg = [
 racc_action_table,
 racc_action_check,
 racc_action_default,
 racc_action_pointer,
 racc_goto_table,
 racc_goto_check,
 racc_goto_default,
 racc_goto_pointer,
 racc_nt_base,
 racc_reduce_table,
 racc_token_table,
 racc_shift_n,
 racc_reduce_n,
 racc_use_result_var ]

Racc_token_to_s_table = [
'$end',
'error',
'";"',
'"import"',
'STRING_LITERAL',
'"package"',
'IDENT',
'"."',
'"option"',
'"="',
'"message"',
'"extend"',
'"{"',
'"}"',
'"enum"',
'"service"',
'"rpc"',
'"("',
'")"',
'"returns"',
'"group"',
'CAMEL_IDENT',
'"["',
'"]"',
'"required"',
'"optional"',
'"repeated"',
'"default"',
'"extensions"',
'"to"',
'"max"',
'"double"',
'"float"',
'"int32"',
'"int64"',
'"uint32"',
'"uint64"',
'"sint32"',
'"sint64"',
'"fixed32"',
'"fixed64"',
'"sfixed32"',
'"sfixed64"',
'"bool"',
'"string"',
'"bytes"',
'","',
'FLOAT_LITERAL',
'BOOLEAN_LITERAL',
'DEC_INTEGER',
'HEX_INTEGER',
'OCT_INTEGER',
'$start',
'proto',
'proto_item',
'message',
'extend',
'enum',
'import',
'package',
'option',
'service',
'dot_ident_list',
'option_body',
'constant',
'message_body',
'user_type',
'extend_body_list',
'extend_body',
'field',
'group',
'enum_body_list',
'enum_body',
'enum_field',
'integer_literal',
'service_body_list',
'service_body',
'rpc',
'rpc_arg',
'message_body_body_list',
'message_body_body',
'extensions',
'label',
'type',
'field_name',
'field_option_list',
'field_option',
'extension',
'comma_extension_list']

Racc_debug_parser = false

##### racc system variables end #####

 # reduce 0 omitted

module_eval <<'.,.,', 'lib/protobuf/compiler/proto.y', 3
  def _reduce_1( val, _values, result )
 result = Protobuf::Node::ProtoNode.new(val)
   result
  end
.,.,

module_eval <<'.,.,', 'lib/protobuf/compiler/proto.y', 5
  def _reduce_2( val, _values, result )
 result.children << val[1] if val[1]
   result
  end
.,.,

 # reduce 3 omitted

 # reduce 4 omitted

 # reduce 5 omitted

 # reduce 6 omitted

 # reduce 7 omitted

 # reduce 8 omitted

 # reduce 9 omitted

module_eval <<'.,.,', 'lib/protobuf/compiler/proto.y', 14
  def _reduce_10( val, _values, result )
 result = nil
   result
  end
.,.,

module_eval <<'.,.,', 'lib/protobuf/compiler/proto.y', 17
  def _reduce_11( val, _values, result )
 result = Protobuf::Node::ImportNode.new(val[1])
   result
  end
.,.,

module_eval <<'.,.,', 'lib/protobuf/compiler/proto.y', 20
  def _reduce_12( val, _values, result )
 result = Protobuf::Node::PackageNode.new(val[2].unshift(val[1]))
   result
  end
.,.,

module_eval <<'.,.,', 'lib/protobuf/compiler/proto.y', 23
  def _reduce_13( val, _values, result )
 result = []
   result
  end
.,.,

module_eval <<'.,.,', 'lib/protobuf/compiler/proto.y', 25
  def _reduce_14( val, _values, result )
 result << val[2]
   result
  end
.,.,

module_eval <<'.,.,', 'lib/protobuf/compiler/proto.y', 28
  def _reduce_15( val, _values, result )
 result = Protobuf::Node::OptionNode.new(*val[1])
   result
  end
.,.,

module_eval <<'.,.,', 'lib/protobuf/compiler/proto.y', 31
  def _reduce_16( val, _values, result )
 result = [val[1].unshift(val[0]), val[3]]
   result
  end
.,.,

module_eval <<'.,.,', 'lib/protobuf/compiler/proto.y', 34
  def _reduce_17( val, _values, result )
 result = Protobuf::Node::MessageNode.new(val[1], val[2])
   result
  end
.,.,

module_eval <<'.,.,', 'lib/protobuf/compiler/proto.y', 37
  def _reduce_18( val, _values, result )
 result = Protobuf::Node::ExtendNode.new(val[1], val[3])
   result
  end
.,.,

module_eval <<'.,.,', 'lib/protobuf/compiler/proto.y', 40
  def _reduce_19( val, _values, result )
 result = []
   result
  end
.,.,

module_eval <<'.,.,', 'lib/protobuf/compiler/proto.y', 42
  def _reduce_20( val, _values, result )
 result << val[1] if val[1]
   result
  end
.,.,

 # reduce 21 omitted

 # reduce 22 omitted

module_eval <<'.,.,', 'lib/protobuf/compiler/proto.y', 46
  def _reduce_23( val, _values, result )
 result = nil
   result
  end
.,.,

module_eval <<'.,.,', 'lib/protobuf/compiler/proto.y', 49
  def _reduce_24( val, _values, result )
 result = Protobuf::Node::EnumNode.new(val[1], val[3])
   result
  end
.,.,

module_eval <<'.,.,', 'lib/protobuf/compiler/proto.y', 52
  def _reduce_25( val, _values, result )
 result = []
   result
  end
.,.,

module_eval <<'.,.,', 'lib/protobuf/compiler/proto.y', 54
  def _reduce_26( val, _values, result )
 result << val[1] if val[1]
   result
  end
.,.,

 # reduce 27 omitted

 # reduce 28 omitted

module_eval <<'.,.,', 'lib/protobuf/compiler/proto.y', 58
  def _reduce_29( val, _values, result )
 result = nil
   result
  end
.,.,

module_eval <<'.,.,', 'lib/protobuf/compiler/proto.y', 61
  def _reduce_30( val, _values, result )
 result = Protobuf::Node::EnumFieldNode.new(val[0], val[2])
   result
  end
.,.,

module_eval <<'.,.,', 'lib/protobuf/compiler/proto.y', 64
  def _reduce_31( val, _values, result )
 result = Protobuf::Node::ServiceNode.new(val[1], val[3])
   result
  end
.,.,

module_eval <<'.,.,', 'lib/protobuf/compiler/proto.y', 67
  def _reduce_32( val, _values, result )
 result = []
   result
  end
.,.,

module_eval <<'.,.,', 'lib/protobuf/compiler/proto.y', 69
  def _reduce_33( val, _values, result )
 result << val[1] if val[1]
   result
  end
.,.,

 # reduce 34 omitted

 # reduce 35 omitted

module_eval <<'.,.,', 'lib/protobuf/compiler/proto.y', 73
  def _reduce_36( val, _values, result )
 result = nil
   result
  end
.,.,

module_eval <<'.,.,', 'lib/protobuf/compiler/proto.y', 76
  def _reduce_37( val, _values, result )
 result = Protobuf::Node::RpcNode.new(val[1], val[3], val[7])
   result
  end
.,.,

 # reduce 38 omitted

 # reduce 39 omitted

module_eval <<'.,.,', 'lib/protobuf/compiler/proto.y', 82
  def _reduce_40( val, _values, result )
 result = val[1]
   result
  end
.,.,

module_eval <<'.,.,', 'lib/protobuf/compiler/proto.y', 85
  def _reduce_41( val, _values, result )
 result = []
   result
  end
.,.,

module_eval <<'.,.,', 'lib/protobuf/compiler/proto.y', 87
  def _reduce_42( val, _values, result )
 result << val[1] if val[1]
   result
  end
.,.,

 # reduce 43 omitted

 # reduce 44 omitted

 # reduce 45 omitted

 # reduce 46 omitted

 # reduce 47 omitted

 # reduce 48 omitted

 # reduce 49 omitted

module_eval <<'.,.,', 'lib/protobuf/compiler/proto.y', 96
  def _reduce_50( val, _values, result )
 result = nil
   result
  end
.,.,

module_eval <<'.,.,', 'lib/protobuf/compiler/proto.y', 99
  def _reduce_51( val, _values, result )
 result = Protobuf::Node::GroupNode.new(val[0], val[2], val[4], val[5])
   result
  end
.,.,

module_eval <<'.,.,', 'lib/protobuf/compiler/proto.y', 102
  def _reduce_52( val, _values, result )
 result = Protobuf::Node::FieldNode.new(val[0], val[1], val[2], val[4])
   result
  end
.,.,

module_eval <<'.,.,', 'lib/protobuf/compiler/proto.y', 104
  def _reduce_53( val, _values, result )
 result = Protobuf::Node::FieldNode.new(val[0], val[1], val[2], val[4], val[6])
   result
  end
.,.,

 # reduce 54 omitted

 # reduce 55 omitted

 # reduce 56 omitted

 # reduce 57 omitted

 # reduce 58 omitted

 # reduce 59 omitted

 # reduce 60 omitted

 # reduce 61 omitted

 # reduce 62 omitted

 # reduce 63 omitted

 # reduce 64 omitted

 # reduce 65 omitted

 # reduce 66 omitted

 # reduce 67 omitted

 # reduce 68 omitted

 # reduce 69 omitted

 # reduce 70 omitted

 # reduce 71 omitted

 # reduce 72 omitted

 # reduce 73 omitted

 # reduce 74 omitted

 # reduce 75 omitted

 # reduce 76 omitted

 # reduce 77 omitted

 # reduce 78 omitted

 # reduce 79 omitted

 # reduce 80 omitted

 # reduce 81 omitted

 # reduce 82 omitted

 # reduce 83 omitted

 # reduce 84 omitted

 # reduce 85 omitted

 # reduce 86 omitted

module_eval <<'.,.,', 'lib/protobuf/compiler/proto.y', 109
  def _reduce_87( val, _values, result )
 result = val
   result
  end
.,.,

module_eval <<'.,.,', 'lib/protobuf/compiler/proto.y', 111
  def _reduce_88( val, _values, result )
 result << val[2]
   result
  end
.,.,

 # reduce 89 omitted

module_eval <<'.,.,', 'lib/protobuf/compiler/proto.y', 115
  def _reduce_90( val, _values, result )
 result = [:default, val[2]]
   result
  end
.,.,

module_eval <<'.,.,', 'lib/protobuf/compiler/proto.y', 118
  def _reduce_91( val, _values, result )
 result = Protobuf::Node::ExtensionsNode.new(val[2].unshift(val[1]))
   result
  end
.,.,

module_eval <<'.,.,', 'lib/protobuf/compiler/proto.y', 121
  def _reduce_92( val, _values, result )
 result = []
   result
  end
.,.,

module_eval <<'.,.,', 'lib/protobuf/compiler/proto.y', 123
  def _reduce_93( val, _values, result )
 result << val[1]
   result
  end
.,.,

module_eval <<'.,.,', 'lib/protobuf/compiler/proto.y', 126
  def _reduce_94( val, _values, result )
 result = Protobuf::Node::ExtensionRangeNode.new(val[0])
   result
  end
.,.,

module_eval <<'.,.,', 'lib/protobuf/compiler/proto.y', 128
  def _reduce_95( val, _values, result )
 result = Protobuf::Node::ExtensionRangeNode.new(val[0], val[2])
   result
  end
.,.,

module_eval <<'.,.,', 'lib/protobuf/compiler/proto.y', 130
  def _reduce_96( val, _values, result )
 result = Protobuf::Node::ExtensionRangeNode.new(val[0], :max)
   result
  end
.,.,

 # reduce 97 omitted

 # reduce 98 omitted

 # reduce 99 omitted

 # reduce 100 omitted

 # reduce 101 omitted

 # reduce 102 omitted

 # reduce 103 omitted

 # reduce 104 omitted

 # reduce 105 omitted

 # reduce 106 omitted

 # reduce 107 omitted

 # reduce 108 omitted

 # reduce 109 omitted

 # reduce 110 omitted

 # reduce 111 omitted

 # reduce 112 omitted

 # reduce 113 omitted

 # reduce 114 omitted

 # reduce 115 omitted

module_eval <<'.,.,', 'lib/protobuf/compiler/proto.y', 141
  def _reduce_116( val, _values, result )
 result = val[1].unshift(val[0])
   result
  end
.,.,

module_eval <<'.,.,', 'lib/protobuf/compiler/proto.y', 143
  def _reduce_117( val, _values, result )
 result = val[1].unshift(val[0])
   result
  end
.,.,

 # reduce 118 omitted

 # reduce 119 omitted

 # reduce 120 omitted

 # reduce 121 omitted

 # reduce 122 omitted

 # reduce 123 omitted

 # reduce 124 omitted

 # reduce 125 omitted

 def _reduce_none( val, _values, result )
  result
 end

  end   # class ProtoParser

end   # module Protobuf
