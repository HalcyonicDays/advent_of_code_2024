INPUT_FILE = './day_4_input.txt'
XMAS_PATTERN = /(XMAS)|(SAMX)/

def ingest_file(file)
  letter_grid = {}
  File.open (file) do |f|
    x = 0
    f.each_line do |line|
      y = 0
      line.gsub("\n", "").chars.each do |letter|
        letter_grid[[x, y]] = letter
        y += 1
      end
      x += 1
    end
  end
  letter_grid
end

def naive_ingest(file)
  contents = []
  File.open (file) do |f|
    f.each_line { |line| contents << line.gsub("\n", "") }
  end
  contents
end

def create_horizontals(letter_grid)
  rows = letter_grid.group_by { |position, letter| position.first }
  rows = rows.map do |row, values|
    values.map { |value| value.last }
  end
  rows.map { |row| row.join }
end

def create_verticals(letter_grid)
  cols = letter_grid.group_by { |position, letter| position.last }
  cols = cols.map do |col, values|
    values.map { |value| value.last }
  end
  cols.map { |row| row.join }
end

def create_foward_diagonals(letter_grid)
  initials = letter_grid.select do |position, letter| 
    position.first == 0 || position.last == 0
  end
  diags = {}

  initials.each do |position, value|
    x = position.first
    y = position.last
    loop do 
      letter = letter_grid[[x, y]]
      break unless letter
      diags[[position.first, position.last]] ||= []
      diags[[position.first, position.last]] << letter_grid[[x, y]]
      x += 1
      y += 1
    end
  end
  diags = diags.map do |position, line|
    line.join
  end
end

def create_backward_diagonals(letter_grid)
  initials = letter_grid.select do |position, letter| 
    position.first == 0 || position.last == 139
  end
  diags = {}

  initials.each do |position, value|
    x = position.first
    y = position.last
    loop do 
      letter = letter_grid[[x, y]]
      break unless letter
      diags[[position.first, position.last]] ||= []
      diags[[position.first, position.last]] << letter_grid[[x, y]]
      x += 1
      y -= 1
    end
  end
  diags = diags.map do |position, line|
    line.join
  end
end

def count_occurences(collection)
  forward  = collection.map { |line| line.gsub('XMAS', '0').count('0') }.reduce(:+)
  backward = collection.map { |line| line.gsub('SAMX', '0').count('0') }.reduce(:+)
  forward + backward
end

def is_edge?(position)
  [0, 139].include?(position.first) || 
  [0, 139].include?(position.last)
end

def find_x_mas(letter_grid)
  center_positions = letter_grid.select { |position, value| value == 'A'}.keys
  x_mas_found = center_positions.select do |center|
    next if is_edge?(center)
    corners = {
      top_left:     letter_grid[[center.first - 1, center.last - 1]],
      top_right:    letter_grid[[center.first + 1, center.last - 1]],
      bottom_left:  letter_grid[[center.first - 1, center.last + 1]],
      bottom_right: letter_grid[[center.first + 1, center.last + 1]]
    }
    valid_x?(corners)
  end
  x_mas_found.size
end

def valid_x?(corners)
  return false unless corners.values.all? (/M|S/)
  return false unless horizontal_match?(corners) || vertical_match?(corners)
  corners[:top_left] != corners[:bottom_right]
end

def horizontal_match?(corners)
  (corners[:top_left] == corners[:top_right]) &&
  (corners[:bottom_left] == corners[:bottom_right])
end

def vertical_match?(corners)
  (corners[:top_left] == corners[:bottom_left]) &&
  (corners[:top_right] == corners[:bottom_right])
end

letter_grid = ingest_file(INPUT_FILE)
contents = naive_ingest(INPUT_FILE)

rows    = create_horizontals(letter_grid)
columns = create_verticals(letter_grid)
f_diags = create_foward_diagonals(letter_grid)
b_diags = create_backward_diagonals(letter_grid)
all_combinations = rows + columns + f_diags + b_diags

p count_occurences(all_combinations)
p find_x_mas(letter_grid)
