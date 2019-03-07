require_relative "phase_1_helpers"
require_relative "phase_2_helpers"
require_relative "../due190214"

@total = 0
@pass = 0
def assert(message, test)
   @total = @total + 1
   if test then
      @pass = @pass + 1
      puts "success: " + message
   else
      puts "failed: " + message
   end
end

@total = 0
@pass = 0

test_case = "(.(|LD)D(|LD(.DQ)))"
test_case_tree = PrefixToTree.new(test_case).to_tree
assert("can handle (.(|LD)D(|LD(.DQ)))",
       TreeHolder.new(test_case_tree).to_s == test_case)

test_case = "(+D)"
target = "111"
test_case_tree =  PrefixToTree.new(test_case).to_tree
test_case_nfa = TreeToNFA.new(test_case_tree).to_nfa
assert("NFA can match 111 against (+D)",
       NFAScanner.new(test_case_nfa).match(target))



puts @pass.to_s + " passed out of " + @total.to_s + " tests."
