ORDER_RULES = './day_5_order_rules.txt'
PAGE_LIST = './day_5_pages.txt'
RULES = {}
RULE_PAIRS = []

=begin
Problem (1):
- given a list of page order rules, transform this into a look-up that can verify
  if a print run obeys all rules
- rules are in the form of 2 numbers - "A|B" where A must be earlier than B on a 
  print list

Note: Investigate the rules 
  - is it possible for pages in a print request to unrelated to one another? In other
    words, they have no before-after relationship at all?

input : two non-identical numbers, formatted as "A|B"
output: an algorithm or function that returns a boolean representing
  whether or not the pages conform to the order rules

Data Structure: a hash with the key being the later page number (B) and the values
  being all page numbers which are explicitly listed as needing to occur prior
  to the key (an array of A's)

Algorithm:
- read order rules from text file
- split "A|B" into a pair of values - [A, B]
- for each A|B pair, create a hash entry B => [A]
  - remap each string number into an integer
=end

def naive_ingest(file)
  contents = []
  File.open (file) do |f|
    f.each_line { |line| contents << line.gsub("\n", "") }
  end
  contents
end

rules = naive_ingest(ORDER_RULES).map { |pairing| pairing.split("|") }
rules.each do |rule_pair|
  precedent  = rule_pair[0].to_i
  antecedent = rule_pair[1].to_i
  RULE_PAIRS << [precedent, antecedent]
  if RULES.key?(precedent)
    RULES[precedent] << antecedent
  else
    RULES[precedent] = [antecedent]
  end
end

=begin
Problem (2): 
- Using the order rules, identify all print requests that are in the right order
- Identify the *middle page* of each valid print order
- Calculate the sum of all valid middle pages

input : an array representing a print request
intermediate (1): a collection of valid print requests
intermediate (2): a sub-collection of middle pages
output: an integer sum of middle pages

Data Structure: array

Algorithm:
- read page print orders from text file
- convert each line of text into an array
  - convert each string value into an integer value
- for each list of pages, determine if it is valid
  - helper method can only check for rule violations; lack of violation = confirmation
  - for each number, verify that no future numbers are included in its precedents array,
    since those numbers must occur before the given number, and not after
- keep only the valid print requests
- for each print request, obtain just the middle value
  - is each print request an odd-sized array?  If not, what is the middle of an even-sized array?
- sum up the middle values
=end

print_orders = naive_ingest(PAGE_LIST).map { |list| list.split(',').map(&:to_i) }

def is_valid?(order)
  order.each_with_index do |antecedent, idx|
    order[0...idx].each do |precedent|
      return false if RULES.fetch(antecedent) {[]}.include?(precedent)
    end
  end
end

def get_midpoints(orders)
  orders.map do |order|
    midpoint = (order.size / 2.0).floor
    order[midpoint]
  end
end

def reorder(order)
  new_order = order.map { |page| page }
  RULE_PAIRS.each do |precedent, antecedent|
    if new_order.include?(precedent) && new_order.include?(antecedent)
      while new_order.index(precedent) > new_order.index(antecedent)
        reference_index = new_order.index(precedent)
        new_order = swap_positions(new_order, reference_index)
      end
    end
  end
  new_order
end

def swap_positions(order, idx)
  order[idx], order[idx - 1] = order[idx - 1], order[idx]
  order
end

valid_orders = print_orders.select { |order| is_valid?(order) }
p get_midpoints(valid_orders).reduce(:+)

invalid_orders = print_orders.reject { |order| is_valid?(order) }
reordered_orders = invalid_orders.map { |order| reorder(order) }

# I am not proud of this.
# This is an iterative approach resulting from some lists being reordered to satisfy
# one set of rules and as a result breaking a new set of previously unbroken rules.
# So essentially this while loop will iterate through the collection until every order
# is considered valid, which will take between 0 and n-1 number of passes, where n is the
# size of the largest order array (but hopefully far fewer than that)

additional_passes = 0
until reordered_orders.size == reordered_orders.select { |order| is_valid?(order) }.size
  reordered_orders = reordered_orders.map { |order| reorder(order) }
  additional_passes += 1
end
puts "#{additional_passes} additional pass/passes performed"
p get_midpoints(reordered_orders).reduce(:+)
