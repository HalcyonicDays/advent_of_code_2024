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

initial_conditions = []
final = blink(initial_conditions, 25)
p final.size
