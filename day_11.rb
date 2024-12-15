def update_stone(stone)
  if stone.zero?
    update_from_zero
  elsif stone.to_i.to_s.length.even?
    split_stone(stone)
  else
    twenty_twenty_four(stone)
  end
end

def update_from_zero
  [1]
end

def twenty_twenty_four(stone)
  [stone * 2024]
end

def split_stone(stone)
  halfway = stone.to_s.size / 2
  left_half = stone.to_s[0..(halfway-1)].to_i
  right_half = stone.to_s[halfway..-1].to_i
  [left_half, right_half]
end

initial_conditions = []

STONE_MEMO = {}
ITERATIONS = {0 => initial_conditions.tally}

blink = 0

while blink < 75

  ITERATIONS[blink].each do |stone, count|
    STONE_MEMO.fetch(stone) {STONE_MEMO[stone] = update_stone(stone).tally}.each do |key, value|
      ITERATIONS[blink + 1] ||= {}

      if ITERATIONS[blink + 1].key?(key)
        ITERATIONS[blink + 1][key] += value * count
      else
        ITERATIONS[blink + 1][key] = value * count
      end
    end
  end

  blink += 1
end

p ITERATIONS[75].values.sum
