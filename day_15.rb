DIRECTIONS = './day_15_input_instructions.txt'
LAYOUT = './day_15_input_map.txt'

imported_map = File.read(LAYOUT).split("\n")
INSTRUCTIONS = File.read(DIRECTIONS).split("\n")

WIDE_SAMPLE ='##############
##......##..##
##..........##
##....[][]@.##
##....[]....##
##..........##
##############'

WIDE_SAMPLE_I = '<vv<<^^<<^^'

class WarehouseObject
  attr_accessor :x_pos, :y_pos, :type
  attr_reader :width, :height

  def initialize(x_pos, y_pos, width=1, height=1)
    @x_pos = x_pos
    @y_pos = y_pos
    @type  = nil
    @width = width
    @height = height
  end

  def coordinates
    [x_pos, y_pos]
  end

  def get_space(direction)
    location = case direction
               when '^' then [x_pos, y_pos - 1 * height]
               when 'v' then [x_pos, y_pos + 1]
               when '>' then [x_pos + 1 * width, y_pos]
               when '<' then [x_pos - 1 * width, y_pos]
               end
    $MAP[location]
  end

  def report_gps_total
    0
  end
end

class Robot < WarehouseObject
  def initialize(x_pos, y_pos)
    super
    @type = '@'
    $ROBO_POS = coordinates
  end

  def move(direction)
    target = get_space(direction)
    new_location = target.coordinates
    
    if target.move(direction)
      clear_current_space
      update(new_location)
    end
  end

  def update(destination)
    self.x_pos, self.y_pos = destination
    $MAP[destination] = self
    $ROBO_POS = destination
  end

  def clear_current_space
    old_x, old_y = coordinates
    $MAP[coordinates] = EmptySpace.new(old_x, old_y)
  end
end

class Box < WarehouseObject
  def initialize(x_pos, y_pos)
    super
    @type = 'O'
  end
  
  def move(direction)
    target = get_space(direction)
    new_location = target.coordinates

    if target.move(direction)
      update(new_location)
      return true
    end
    false
  end

  def update(destination)
    self.x_pos, self.y_pos = destination
    $MAP[destination] = self
  end

  def report_gps_total
    100 * y_pos + x_pos
  end

  def clear_current_space
    old_x, old_y = coordinates
    $MAP[coordinates] = EmptySpace.new(old_x, old_y)
  end
end

class EmptySpace < WarehouseObject
  def initialize(x_pos, y_pos)
    super
    @type = '.'
  end
  
  def move(*direction)
    true
  end
end

class Wall < WarehouseObject
  def initialize(x_pos, y_pos)
    super
    @type = '#'
  end
  
  def move(*direction)
    false
  end
end

class LeftBox < Box
  attr_reader :right_side

  def initialize(x_pos, y_pos)
    super
    @right_side = nil
    @type = '['
  end

  def move(direction, first=true)
    get_right_side unless right_side
    if first && ['^','v'].include?(direction)
      return false unless right_side.move(direction, false)
      clear_current_space
    end

    target = get_space(direction)
    new_location = target.coordinates

    if target.move(direction, first)
      update(new_location)
      return true
    end
    false
  end

  def update(destination, first=true)
    # $MAP[[x_pos + 1, y_pos]] = EmptySpace.new(x_pos + 1, y_pos)
    self.x_pos, self.y_pos = destination
    $MAP[destination] = self
    
    new_right_postion = [x_pos + 1, y_pos]
    right_side.update(new_right_postion, false) if first
  end

  def get_right_side
    @right_side = $MAP[[x_pos + 1, y_pos]]
  end
end

class RightBox < Box
  attr_reader :left_side

  def initialize(x_pos, y_pos)
    super
    @left_side = nil
    @type = ']'
  end

  def move(direction, first=true)
    get_left_side unless left_side
    if first && ['^','v'].include?(direction)
      return false unless left_side.move(direction, false)
      clear_current_space
    end

    target = get_space(direction)
    new_location = target.coordinates

    if target.move(direction, first)
      update(new_location)
      return true
    end
    false
  end

  def update(destination, first=true)
    # $MAP[[x_pos - 1, y_pos]] = EmptySpace.new(x_pos - 1, y_pos)
    self.x_pos, self.y_pos = destination
    $MAP[destination] = self
    
    new_left_postion = [x_pos - 1, y_pos]
    left_side.update(new_left_postion, false) if first
  end

  def get_left_side
    @left_side = $MAP[[x_pos - 1, y_pos]]
  end

  def report_gps_total
    0
  end
end

def generate_warehouse(map)
  layout = {}
  map.split("\n").each_with_index do |row, y_pos|
    row.chars.each_with_index do |space, x_pos|
      location = [x_pos, y_pos]
      layout[location] = klass_for(space).new(*location)
    end
  end
  layout
end

def klass_for(space)
  case space
  when '.' then EmptySpace
  when 'O' then Box
  when '#' then Wall
  when '@' then Robot
  when '[' then LeftBox
  when ']' then RightBox
  end
end

def display_warehouse(width)
  $MAP.values.each_slice(width) do |row|
    puts row.map(&:type).join
  end
end

# MAP_WIDTH = imported_map.first.size
# $ROBO_POS = [nil, nil]

# $MAP = generate_warehouse(imported_map)
# display_warehouse(MAP_WIDTH)

# INSTRUCTIONS.join.chars.each do |direction|
#   $MAP[$ROBO_POS].move(direction)
# end

# p $MAP.map { |_, object| object.report_gps_total }.reduce(:+)

# wide_map = imported_map.map do |row|
#   row.chars.$map do |cell|
#     case cell
#     when '.' then '..'
#     when '#' then '##'
#     when 'O' then '[]'
#     when '@' then '@.'
#     end
#   end.join
# end
$MAP = {}
wide_map = WIDE_SAMPLE

WIDE_WIDTH = wide_map.split("\n").first.size
$ROBO_POS = [nil, nil]

$MAP = generate_warehouse(wide_map)
# $MAP.select {|location, space| ['['].include?(space.type)}.each { |elm, obj| obj.find_right_side }
display_warehouse(WIDE_WIDTH)

WIDE_SAMPLE_I.chars.each do |direction|
  $MAP[$ROBO_POS].move(direction)
  display_warehouse(WIDE_WIDTH)
end


# p $MAP.map { |_, object| object.report_gps_total }.reduce(:+)
