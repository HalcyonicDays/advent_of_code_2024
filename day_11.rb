initial_contiditions = [0, 7, 6618216, 26481, 885, 42, 202642, 8791]

=begin
Problem: Given some initial starting conditions, apply rules to create new conditions

Explicit Rules:
- A stone with value 0 is set to 1
- A stone with an even number of digits is split into two halves
  made up of the front-half and back-half of digits
- otherwise if no other rule applies - multiply stone's value by 2024

Implicit Rules:
- As time increases (# of blinks), number of stones increases
- Stone seems to be irrelevant (at least for Part 1)
  - But the story is so explicitly stating "order is preserved!"
  - Perhaps it's relevant for Part 2
  - It was not relevant for Part 2 -_-

Data Structure: Recursive count

Algorithm:
- Create a LinkedStone class
  - class has attributes: value, next_node
  - class has methods: next and blink; also helper methods for each explicit rule
- Initialize Start - possibly a nil-value Stone (so the reference doesn't change with splits)
- Initialize Head and set to first stone
- For each new Stone: 
  - assign a value 
  - for the Stone at HEAD, update the value of "next_node" to newly-created Stone
  - update the value of HEAD to newly-created Stone

Algorithm:
- In general, loop through each stone and perform an action based on the value
- if the value is not a single-digit number follow the standard rules:
  - split if the number of digits is even,
  - or multiply by 2024 if the number of digits is odd
- if the value IS a single-digit number
  - refer to the SPLIT_COUNTS dictionary which keeps tack of each number's
    progression from itself back to a series of single digits 
- so there is a recursive algorithm responsible for evaluating a given single digit & number of cycles
- there also needs to be a process for getting to a single digit given any other number
  - while <stone> is greater than 9, continue updating it's value per the blink rules
  - subtract a blink (cycle count) for each blink update
  - once the value is a single digit, kick it over to the other algorithm along with remaining # of cycles
  - if cycles hit zero, return 1 for each number

What do we know?
  - each stone, at every blink, either splits or it doesn't
    - this means that after each blink, each stone (one at a time) either increases the total count by 1,
      or it is left unchanged.
  - once any stone has a single-digit value, the final number of stones after n blinks can be calculated
    without going through each step since each single-digit number will undergo a known number of splits
    before being transformed into another single-digit value

    

=end
def update_from_zero
  [1]
end

def twenty_twenty_four(stone)
  [stone * 2024]
end

def update_stone(stone)
  if stone.zero?
    [1]
  elsif stone.to_s.length.even?
    split_stone(stone)
  else
    [stone * 2024]
  end
end

def split_stone(stone)
  halfway = stone.to_s.size / 2
  left_half = stone.to_s[0..(halfway-1)].to_i
  right_half = stone.to_s[halfway..-1].to_i
  [left_half, right_half]
end

SPLIT_COUNTS = {}
def build_split_math
  0.upto(9) do |single_digit|
    SPLIT_COUNTS[single_digit] = []
    stones = [single_digit]
    first_loop = true

    while stones.any? { |stone| stone > 9 } || first_loop
      SPLIT_COUNTS[single_digit] << stones
      stones = stones.map do |stone|
        if stone > 9 || first_loop
          update_stone(stone)
        else
          stone
        end
      end
      first_loop = false if first_loop
      stones = stones.flatten
    end
    SPLIT_COUNTS[single_digit] << stones
  end
end

build_split_math

def handle_single_digits(digit, remaining_cycles, total_count=0)
  return total_count if remaining_cycles.zero?

  depth_to_singles = SPLIT_COUNTS[digit].index(SPLIT_COUNTS[digit].last)
  depth = [depth_to_singles, remaining_cycles].min
  
  if remaining_cycles > depth_to_singles
    remaining_cycles -= depth
    split_results = SPLIT_COUNTS[digit][depth]

    split_results.each do |single_digit|
      total_count = handle_single_digits(single_digit, remaining_cycles, total_count)
    end

  else
    split_results = SPLIT_COUNTS[digit][depth]
    total_count += split_results.size
  end

  return total_count
end

def recursive_blinks(value, blinks, count=1)
  return count if blinks.zero?

  if value.zero?
    count = recursive_blinks(1, blinks - 1, count)
  elsif value.to_s.length.even?
    count += 1
    split_stone(value).each do |stone|
      count = recursive_blinks(stone, blinks - 1, count)
    end
  else
    count = recursive_blinks(value * 2024, blinks - 1, count)
  end

  return count
end

=begin
- there also needs to be a process for getting to a single digit given any other number
  - while <stone> is greater than 9, continue updating it's value per the blink rules
  - subtract a blink (cycle count) for each blink update
  - once the value is a single digit, kick it over to the other algorithm along with remaining # of cycles
  - if cycles hit zero, return 1 for each number
=end

total_stones = 0

def get_to_singles(stones, blinks, total_stones=0)
  return stones.size if blinks.zero?

  stones.each do |stone|
    if stone <= 9
      total_stones += handle_single_digits(stone, blinks, total_stones)
    else
      new_stones = update_stone(stone)
      total_stones += get_to_singles(new_stones, blinks - 1, total_stones)
    end
  end
  return total_stones
end

test_conditions = [125, 17]
initial_values = [1, 3, 17]
1.upto(3) do |cycle|
  p [cycle, 
     get_to_singles(initial_values, cycle), 
    # initial_values.map {|value| recursive_blinks(value, cycle)}.reduce(:+), 
     initial_values.map {|value| recursive_blinks(value, cycle)}.reduce(:+)].inspect
end
puts "all done"
