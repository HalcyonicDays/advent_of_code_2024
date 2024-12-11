SAMPLE_1 = '..90..9
...1.98
...2..7
6543456
765.987
876....
987....'

SAMPLE_2 = '
10..9..
2...8..
3...7..
4567654
...8..3
...9..2
.....01'

SAMPLE_3 = '89010123
78121874
87430965
96549874
45678903
32019012
01329801
10456732'

SAMPLE_4 ='.....0.
..4321.
..5..2.
..6543.
..7..4.
..8765.
..9....'

SAMPLE_5 ='
..90..9
...1.98
...2..7
6543456
765.987
876....
987....'

SAMPLE_6 = '
012345
123456
234567
345678
4.6789
56789.'

SAMPLE_7 ='
89010123
78121874
87430965
96549874
45678903
32019012
01329801
10456732'

=begin
Part 1: Calculate the trailhead score for each trail head (and add them all up)

- Find all trailheads (coordinates of every zero)
  - For each trailhead:
    - Find all summits (coordinates of every nine) within 9 Manhattan spaces
      - Manhattan distance the total difference between X & Y positions cannot exceed 9, e.g. [0, 0]  & [3, 6]
    - For each summit within range of the trailhead:
      - Determine if a path exists between the trailhead and summit
      - Something like an A* algorithm might work here, though I'll need to remind myself of the details
      - From position 0, identify all neighboring spaces +/- 1X & +/- 1Y.  Find all possible 1s.
        - Establish a preference - since a given trailhead is some amount of X & Y spaces away, prioritize
          moving along a path at constantly minimizes this gap
          - .e.g if 0 is at [10, 10] and 9 is [13, 5], then any +X and -Y movements would be prioritized
      - Move forward recursively and with preference for moving "closer" to the summit
        - Method calls itself to find each new space, .e.g 0->1, 1->2, 2->3, and returns true if it ever find a 9
        - Otherwise, the method will keep recursively calling itself, returning false at the end if no 9 is ever found
      - For any "found" summit, store it in an array which itself is stored in a hash with the key being the trailhead
  - Summing all the "found" summits should provide the total score of each trailhead
  - All summit and origin coordinates are stored in relation to one another in case their positions will be needed
    for part 2, which is a little excessive, but the nature of these challenges is that I already know there will
    be a part 2, and I don't know what it will require, so there's inherently a little bit of over-engineering

=end

def retrieve_trail_map
  trail_map = []
  File.open(INPUT, "r").each_line { |row| trail_map << row } 
  trail_map.map do |row| 
    row.chars.map do |char|
      char.to_i.to_s == char.to_s ? char.to_i : nil
    end
  end
end

def retrieve_sample_map(sample_source)
  trail_map = []
  sample_source.each_line do |row|
    row = row.chars.map do |char|
      case char
      when "0".."9" then char.to_i
      else nil
      end
    end
    trail_map << row
  end
  trail_map
end

def find_all_trailheads
  trailheads = []

  MAP.each_with_index do |row, y_pos|
    row.each_with_index do |height, x_pos|
      next unless height
      trailheads << [x_pos, y_pos] if height.zero?
    end
  end

  trailheads
end

def find_nearby_summits(trailhead)
  summits = []

  MAP.each_with_index do |row, y_pos|
    row.each_with_index do |height, x_pos|
      next unless x_pos && y_pos && height == SUMMIT
      position = [x_pos, y_pos]
      summits << position if possible_summit(trailhead, position)
    end
  end

  summits
end

def possible_summit(trailhead, position)
  delta_x = (trailhead[0] - position[0]).abs
  delta_y = (trailhead[1] - position[1]).abs
  (delta_x + delta_y) <= SUMMIT
end

def walk_the_path(start, finish)
  local_height = MAP[start[1]][start[0]]
  return true if local_height == SUMMIT && start == finish

  neighbors = find_valid_neighbors(start)

  neighbors.each do |new_start|
    is_summit = walk_the_path(new_start, finish)
    return true if is_summit
  end

  return false
end

def find_valid_neighbors(position)
  x_pos, y_pos = position[0], position[1]
  local_height = MAP[y_pos][x_pos]

  neighboring_cells = []
  [[x_pos, y_pos - 1], 
   [x_pos, y_pos + 1], 
   [x_pos + 1, y_pos], 
   [x_pos - 1, y_pos]].each do |x_pos, y_pos|
    neighboring_cells << [x_pos, y_pos] if valid_position?(x_pos, y_pos)
  end
  
  neighbors = neighboring_cells.select do |new_x, new_y|
    MAP[new_y][new_x] == local_height + 1
  end

  neighbors
end

def valid_position?(x_pos, y_pos)
  MAP[y_pos] && MAP[y_pos][x_pos]
end

def walk_all_paths(start)
  local_height = MAP[start[1]][start[0]]
  $RATINGS += 1 if local_height == SUMMIT

  neighbors = find_valid_neighbors(start)
  
  neighbors.each do |neighbor|
    walk_all_paths(neighbor)
  end
end

INPUT = './day_10_input.txt'
SUMMIT = 9
MAP = retrieve_trail_map
# MAP = retrieve_sample_map(SAMPLE_8)

# Part 1
trailheads = find_all_trailheads
summits = {}

trailheads.each do |trailhead|
  summits[trailhead] = []
  potential_summits = find_nearby_summits(trailhead)
  potential_summits.each do |summit|
    is_path = walk_the_path(trailhead, summit)
    summits[trailhead] << summit if is_path
  end
end

puts "total trails: #{summits.map { |trailhead, summits| summits.size}.reduce(:+)}"

# Part 2
$RATINGS = 0
trailheads.each { |trailhead| walk_all_paths(trailhead) }
p $RATINGS
