### Assignment 1 by Samar Sajnani (250633960)

## Below are the constants that are used to create our parser
# e represents epsilon
# # L represents letters
# # D represents digits
# # Q represents question mark ? in input
# # E represents exclamation mark ! in input
# # P represents period . in input
# # C represents comma , in input
# # K represents colon : in input
# # M represents minus sign - in input
# # A represents addition operator + in input
# # B represents binary operators * / % ^ in input
# # X represents left parenthesis ( in input
# # Y represents right parenthesis ) in input
# # S represents assignment operator = in input
# # T represents less than operator < in input
# # U represents greater than operator > in input
# # Z represents anything else
# # regular expression operators
# # ( opens a regular expression in prefix notation
# # ) closes a regular expression in prefix notation
# # . represents concatenation of one or more subtrees in regular expression
# # + represents the concatenation of one or more copies of the first subtree
# # | represents any one of the subtrees
OPERATORS = [".", "|", "+", ")", "("]
OPERANDS = ["e", "L", "D", "Q", "E", "P", "C", "K", "M", "A", "B", "X", "Y", "S", "T", "U","Z"]

### PrefixToTree takes a string and converts the regular expression to a expression tree
# Expression tree uses class TreeNode to build the tree and the tree is built based on recursive building of the smallest to largest bracket notation strings
class PrefixToTree 
    
    NON_DELIMITERS = /[^(){}\[\]]*/
    PAIRED = /\(#{NON_DELIMITERS}\)|\{#{NON_DELIMITERS}\}|\[#{NON_DELIMITERS}\]/
    DELIMITER = /[(){}\[\]]/
    attr_accessor :root, :prefix
    def initialize(prefix)
	@prefix = prefix
	@leaf = TreeNode.new("", "", [])
    end
    def to_tree
	@root = create_sub_tree(prefix)
	return @root
    end

    ### Recursive function used to generate subtree
    def create_sub_tree(prefix)
    	if OPERANDS.include?prefix[0]
	    return TreeNode.new("leaf", prefix[0], [@leaf])
	else
	   new_node = 0
	   subtrees = []
	   subtree_indices = find_subtrees(prefix, 2)
	   (0..subtree_indices.length-2).each do |subtree_index_iter|
		subtrees.push(create_sub_tree(prefix[subtree_indices[subtree_index_iter], subtree_indices[subtree_index_iter+1]-subtree_indices[subtree_index_iter]]))
	   end	
	   return TreeNode.new("internal", prefix[1], subtrees)
	end   	
    end
    ### Function uses a regular expression to identify the different subtrees per tree
    def find_subtrees(tree_string, initial_index)
	subtree_size = 0
	find_index = false
	indices = [initial_index]
	while find_index == false
           subtree_size += 1
	   subtree_end_flag = balanced?tree_string[initial_index,subtree_size]
	   if tree_string[initial_index, subtree_size] == ")"
		break
	   end
	
	   if subtree_end_flag
		indices.push(initial_index + subtree_size)
		subtree_end_flag = false
		initial_index = initial_index + subtree_size
		subtree_size = 0
	   end
	end
	indices
    end

    # Uses the balanced parentheses language to identify subtree boundaries
    def balanced? s
        s = s.dup
        s.gsub!(PAIRED, "".freeze) while s =~ PAIRED
        s !~ DELIMITER
    end

end 
	
### Class creates an NFA from the tree by breaking the tree down in to the smallest automata and building the larger automata recursively
class TreeToNFA 
    
    attr_accessor :nfa, :tree
    def initialize(tree)
	@tree = tree
    end
    def to_nfa
        @nfa = create_nfa_from_tree(tree)
	return @nfa[0] 
    end

    #Recursive function called to generate a NFA
    def create_nfa_from_tree(tree)
	initial_state = State.new("",[])
	intermediate_state = initial_state
        final_state = State.new("Accepting",[])
	
	#Base Case
	if tree.type == "leaf"
	    initial_state.next_states = [{tree.value => final_state}]
	else 
	    tree.subtrees.each do |subtree|
		if OPERATORS.include?(tree.value)
		    substate = create_nfa_from_tree(subtree)
		    substate[1].type = ""
		    substate[1].next_states = [{"e" => final_state}]
		end
                # Inductive Cases
	        case tree.value
	        when OPERATORS[1]
		    initial_state.next_states.push({"e" => substate[0]})
	        when OPERATORS[2]
		    initial_state.next_states.push({"e" => substate[0]})
		    substate[1].next_states.push({"e" => substate[0]})
                when OPERATORS[0]
		    intermediate_state.next_states = [{"e" => substate[0]}]
		    intermediate_state = substate[1] 
		end
	    end
	end
	return [initial_state, final_state]	
    end
end 


### Class used to convert a NFA to a DFA 
class NFAToDFA 
    
    attr_accessor :dfa, :nfa
    def initialize(nfa)
	@nfa = nfa
    end
    def to_dfa
        @dfa = create_dfa_from_nfa(@nfa)
	return @dfa
    end

    ### Finds if an array of next_states contains an accepting state or not
    # Returns boolean
    def find_accepting_states(nodes) 
	    nodes.sub.any? { |state| 
		return "Accepting"  if state.any? { |result| 
		    result.accepting? 
		} 
	    }
	    return ""
    end

    # Iterative function used to iterate through all possible cases and create the states of the DFA using epsilon_closures of the different states
    def create_dfa_from_nfa(nfa)
	first_state = State.new("", [], true, [nfa.epsilon_closure(nfa)])
	# Need a stack to ensure that nodes are processed in order
	stack = [first_state]
	# Array of states used to store all possible states with their epsilon closures
	epsilon_closures = [first_state]
	while stack.length > 0
	    nodes = stack.pop
	    #Find whether an accepting state exists, if it does the node is assigned to be accepting
	    nodes.type = find_accepting_states(nodes)
	    #Iterate over all the operands to find all possible transitions out of a node
	    OPERANDS.each do |operand|
		# Iteratively identify which transitions exist, and their respective epsilon closures and store in check_states
	        check_states = get_transition_epsilon_closure(nodes, operand)
		# If a transition with operand exists then
		if check_states.key?(operand)
                    concatenated = check_states[operand]
		    #Check if the epsilon closure of the transition state is equivalent to an epsilon closure that we have in our epsilon closure array, if we have seen it before identify the index so we can use that state again
		    closure_index = included_in_closures(epsilon_closures, concatenated)
		    next_state = nil
		    # If we have seen the closure before direct the transition out of our state toward the same state for which that epsilon closure exists, 
		    if closure_index != -1
			next_state = epsilon_closures[closure_index]
		    # if we have not seen it before then create a new state and add a transition to it
		    else
		        next_state = State.new("", [], true, concatenated)
		        epsilon_closures.push(next_state)
		        stack.push(next_state)
		    end
		    nodes.next_states.push({operand => next_state})
		end 
	    end
	end
	# After the stack is empty and there are no more nodes to process, return the root of the DFA
    	return first_state
    end

    # Identify the epsilon_closures of transitions
    def get_transition_epsilon_closure(nodes, operand)
        check_states = {}
	#Iterate to the state level
        nodes.sub.each do |nfa_states|
	    nfa_states.each do |nfa_state|
	        nfa_state.next_states.each do |state|
		    # If the state transition contains the operand we are looking for add it to the checked states
	            if state.key?(operand) and operand != "e"
		        (check_states[operand] ||= []) << state[operand].epsilon_closure(state[operand])
	            end
		end
	    end
        end
	return check_states
    end
    #Check if the concatenated epsilon closure exists in our array of states called epsilon closures
    def included_in_closures(epsilon_closures, concatenated)
	(0..epsilon_closures.length-1).each do |closure_index|
	    arrayA = epsilon_closures[closure_index].sub
            arrayB = concatenated
	    # Does an array subtraction either way to identify if there is equality between the arrays
	    if ((arrayA-arrayB) + (arrayB-arrayA)).empty?
		#return the index for this equality
		return closure_index
	    end
	end
	return -1
    end
end
 # Supplementary class used to create the expression tree
class TreeNode
    def initialize(type, value, subtrees)
	@type = type
	@value = value 
	@subtrees = subtrees
	@root = value
    end
    attr_accessor :type, :value, :subtrees, :root
end

# Supplementary class used for finite automata building, used for the states of the automata
class State
    def initialize(type, next_states, deterministic=false, sub=[])
        @type = type
	@sub = sub
        @next_states = next_states
        @start = self
        @deterministic = deterministic
    end
    #Check if the state is an accepting state
    def accepting?
	return self.type == "Accepting"
    end

    #Find the next states that the parameterized state can transition to given a particular expression as a category
    def next(state, category)
	states = []
	state.next_states.each do |substate| 
	    if substate.key?(category)
	        return substate[category] if (@deterministic)
		states.push(substate[category])
            end
	end
	return NullState if (@deterministic)
	return states
    end

    # Identify the epsilon closure for the parameterized state
    def epsilon_closure(state)
	stack = [state]
	# Runs a DFS
	states = []
	while stack.length != 0
	    state = stack.pop
	    state.next_states.each do |substate|
	        if substate.key?("e") and !states.include?(substate["e"])
	            states.push(substate["e"])
		    stack.push(substate["e"])
	        end
	    end
	end
	return states
    end
    attr_accessor :type, :next_states, :sub, :start
end
# Create null class for identification of Failing states
class NullState
end
