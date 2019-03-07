# classes useful for running test cases

# e represents epsilon
# L represents letters
# D represents digits
# Q represents question mark ? in input
# E represents exclamation mark ! in input
# P represents period . in input
# C represents comma , in input
# K represents colon : in input
# M represents minus sign - in input
# A represents addition operator + in input
# B represents binary operators * / % ^ in input
# X represents left parenthesis ( in input
# Y represents right parenthesis ) in input
# S represents assignment operator = in input
# T represents less than operator < in input
# U represents greater than operator > in input
# Z represents anything else
# regular expression operators
# ( opens a regular expression in prefix notation
# ) closes a regular expression in prefix notation
# . represents concatenation of one or more subtrees in regular expression
# + represents the concatenation of one or more copies of the first subtree
# | represents any one of the subtrees

class String
   def category
      return "L" if self =~ /[a-zA-Z]/
      return "D" if self =~ /[0-9]/
      return "Q" if self == "?"
      return "E" if self == "!"
      return "P" if self == "."
      return "C" if self == ","
      return "K" if self == ":"
      return "M" if self == "-"
      return "A" if self == "+"
      return "B" if self =~ /[\*\/\%\^]/
      return "X" if self == "("
      return "Y" if self == ")"
      return "S" if self == "="
      return "T" if self == "<"
      return "U" if self == ">"
      "Z"
   end
end

class DFAScanner 
   def initialize(dfa)
      @dfa = dfa
   end
   def match(string)
      state = @dfa.start
      match_helper(state, string)
   end

private

   def match_helper(state, string)
      current_state = state
      return accepting?(current_state)  if string.empty?
      next_state = move_forward(string[0].category, current_state)
      match_helper_try(next_state, string[1..-1])
   end
   def accepting?(state)
      state.accepting?
   end
   def move_forward(category, state)
      forward = @dfa.next(state,category)
   end
   def match_helper_try(state, string)
       return false if state == NullState
       match_helper(state, string)
   end
end
