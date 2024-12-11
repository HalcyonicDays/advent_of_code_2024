initial_contiditions = []

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

Data Structure: Linked-List
- Since elements will be constantly splitting, this is the most efficient
  way to preserve the order of the list.  I hope this is rewarded in Part 2...

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

- Research linked list creation in ruby


NEVERMIND
Input:  stone (value)
Output: value or array of values (if split)

=end

def update_stone(stone)
  if stone.zero?
    update_from_zero
  elsif stone.to_s.length.even?
    split_stone(stone)
  else
    stone *= 2024
  end
end

def update_from_zero
  1
end

def split_stone(stone)
  halfway = stone.to_s.size / 2
  left_half = stone.to_s[0..(halfway-1)].to_i
  right_half = stone.to_s[halfway..-1].to_i
  [left_half, right_half]
end

def blink(stones, blinks)
  blinks.times do
    stones.map! { |stone| update_stone(stone) }.flatten!
  end
  stones
end

p blink(initial_contiditions, 5).size
