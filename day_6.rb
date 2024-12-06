STARTING_MAP = './day_6_input.txt'
OPEN_SPACE = '.'
OBSTACLE   = '#'
VISITED = 'X'

FACING = {
  up:    '^',
  down:  'v',
  left:  '<',
  right: '>'
}

# Note: It should just be "Map" but since that's the name of a popular method,
# I'm calling it "PuzzleMap" just to avoid a potential headache in the future
class PuzzleMap
  attr_accessor :layout, :x_pos, :y_pos, :facing
  attr_reader :map_width, :map_length

  def initialize(layout)
    @layout = layout
    @map_width = layout.size - 1
    @map_length = layout.first.size - 1

    get_starting_position and initial_facing
    update_map
  end

  def to_s
    puts layout
  end

  def get_starting_position
    layout.each_with_index do |row, idx|
      intersection = row.chars & (FACING.values)
      if intersection.any?
        self.x_pos = idx
        self.y_pos = row.index(intersection.first)
      end
    end
  end

  def initial_facing
    self.facing = FACING.key(layout[x_pos][y_pos])
  end

  def value_at_position(x, y)
    layout[x][y]
  end

  def update_facing
    self.facing = case facing
                  when :up    then :right
                  when :right then :down
                  when :down  then :left
                  when :left  then :up
                  end
  end

  def update_position(new_position)
    self.x_pos, self.y_pos = new_position
  end

  def next_position
    position = [x_pos, y_pos]
    case facing
    when :up    then position[0] -= 1
    when :right then position[1] += 1
    when :down  then position[0] += 1
    when :left  then position[1] -= 1
    end
    position
  end

  def off_the_map?(next_x, next_y)
    true unless next_x.between?(0, map_width) && next_y.between?(0, map_length)
  end

  def move_through_map
    loop do
      if off_the_map?(*next_position)
        count_visited_spaces
        break
      elsif value_at_position(*next_position) == OBSTACLE
        update_facing
      else
        update_position(next_position) and update_map
      end
    end
  end

  def update_map
    self.layout[x_pos][y_pos] = VISITED
  end

  def count_visited_spaces
    puts "#{layout.join.count(VISITED)} steps visited before leaving the map"
  end

  def find_visited_spaces
    spaces = []
    layout.each_with_index do |row, x_idx|
      row.chars.each_with_index do |space, y_idx|
        spaces << [x_idx, y_idx] if space == VISITED
      end
    end
    spaces
  end
end

class ObstructionMap < PuzzleMap
  @@loops = 0
  @@exits = 0

  def self.total_loops
    @@loops
  end

  def self.total_exits
    @@exits
  end

  def initialize(layout, obstacle_position)
    super(layout)
    generate_obstacle(obstacle_position)
    make_countable_spaces
  end

  def generate_obstacle(position)
    self.layout[position[0]][position[1]] = OBSTACLE
  end

  def make_countable_spaces
    layout.map! { |row| row.gsub(OPEN_SPACE,'0') }
  end

  def update_map
    value = self.layout[x_pos][y_pos]
    self.layout[x_pos][y_pos] = (value.to_i + 1).to_s
  end

  # This is an inelegant way of saying "you can only walk down a path up to
  # <POSSIBLE_DIRECTIONS> number of different ways." Once you have exceeded
  # that number,the only possible explanation is that you are walking in a
  # direction previously walked.  This is inelegant because a space still needs
  # to be visisted a minimum of <POSSIBLE_DIRECTIONS + 1> times before it is
  # recognized as a loop, even though it is unlikely most loops will involve
  # this much backtracking. 
  def loop_discovered?
    value_at_position(x_pos, y_pos).to_i > FACING.size
  end

  def move_through_map
    loop do
      if off_the_map?(*next_position)
        # count_visited_spaces
        @@exits += 1
        break
      elsif loop_discovered?
        @@loops += 1
        break
      elsif value_at_position(*next_position) == OBSTACLE
        update_facing
      else
        update_position(next_position) and update_map
      end
    end
  end
end

def naive_ingest(file)
  contents = []
  File.open (file) do |f|
    f.each_line { |line| contents << line.gsub("\n", "") }
  end
  contents
end

# Part 1 Solution
layout = naive_ingest(STARTING_MAP)
my_map = PuzzleMap.new(layout)
my_map.move_through_map

# Part 2 Solution
my_map.find_visited_spaces.each_with_index do |visited_space, idx|
  layout = naive_ingest(STARTING_MAP)
  modified_map = ObstructionMap.new(layout, visited_space)
  modified_map.move_through_map
end

puts "total possibly obstruction positions: #{ObstructionMap.total_loops}"
