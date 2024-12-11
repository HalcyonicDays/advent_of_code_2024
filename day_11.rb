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

SPLIT_COUNTS = {0 => [1]}
def build_split_math
  1.upto(9) do |single_digit|
    SPLIT_COUNTS[single_digit] = []
    stones = [single_digit * 2024]

    while stones.any? { |stone| stone > 9 }
      SPLIT_COUNTS[single_digit] << stones
      stones = stones.map do |stone|
        if stone > 9
          update_stone(stone)
        else
          stone
        end
      end

      stones = stones.flatten
    end
    SPLIT_COUNTS[single_digit] << stones
  end
end

build_split_math

def single_digit_impact(single_digit, remaining_cycles, total_count=1)

  while remaining_cycles > 0
    idx = [SPLIT_COUNTS[single_digit].size - 1, total_count].min
    remaining_cycles -= idx
    total_count = SPLIT_COUNTS[single_digit][idx].size - 1

    SPLIT_COUNTS[single_digit][idx].each do |single| 
      total_count += single_digit_impact(single_digit, remaining_cycles, total_count)
    end
  end

  return total_count
end

initial_value = 1
0.upto(2) do |cycles|
  p [single_digit_impact(initial_value, cycles), blink([1], cycles).size]
end
