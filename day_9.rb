=begin
Given a long string of numbers, such as '12345' interpret its meaning:
- numbers alternate between blocks of data & blocks of free space
- 1 block of data, then 2 blocks free, then 3 blocks of data, then 4 free,
  then finally 5 blocks of data
  - This suggests that the total disk size here is 15 blocks (9 in use; 6 free)
- each file has a unique ID that represents its current state before rearrangement
  - so every other index (every EVEN index) corresponds to some object ID
  - this suggests that there should be n/2 (rounding up) unique file IDs
- The disk map really just represents where there are and are not gaps between files

- The goal is to identify these gaps and then fill them with the files furthest away
  (i.e. from th end of the list)
- a free block can only hold as much of a part of a file as its size

In the example above, 12345, the 2 free blocks would be filled with the file at idx 4 (ID 2)
- 1020343, and then the 4 open spaces would be filled again with 3 pieces of ID 2.
  of ID 1 => 10203036; Then all the free space is left at the end as a single block of 6
  blocks: 12345 => 10203036
  IDs:    0-1-2 => 0-2-1-2-

For a case of 19,999, that creates 10,000 unique IDs.

Final output could look like: a0b0c0d0e... with [a] number of ID 0, then 0 free blocks, then [b]
number of ID 1, then 0 free blocks, then [c] number of ID 2, etc.

OR

Final output could look like abcde7 - with [a] number of ID 0, [b] number of ID 2, [c] number of
ID 3 and 7 free blocks at the very end.

In either case, ever block of data needs to know several things:
  - original ID of a give block of data
  - it's current/new position within the compacted disk map

In the example of 12345 => 10203036, it would then be unpacked into 022111222[6]
So the sequence 12336, represents 1, then 2, then 3, and then 3 of an element, where no adjacent
elements share an ID.  How can each element be aware of both its position and its ID?

Summary => Unpacked
1233[6] => 022111222
counts  &  IDs        Counts (1-n); IDs (0-10,000)

- Initialize an array representing compacted map
- convert disk_map into an array of integers by splitting into characters and mapping &:to_i
- initialize disk_map_tail at -1
- Loop through each character of the disk map array, along with its index value |amount, idx|
  - If index is even: push [amount] many instances of value [idx] into compacted array
  - If index is odd: pull_from_the_back helper(disk_map, amount) method
    - amount represents amount of available space
    - initialize sequence array
    - guard clause: return [<tail>, []] if <tail> is greater than -1 * initial disk_map size
      - begin a loop - while the amount element is greater than zero:
        - if the <tail> element is zero, update <tail> & NEXT
          - update_tail helper method: <tail> -= 2
        - push <tail> (index) into sequence
        - subtract 1 from the <tail> value and amount
        - update <tail> element of disk_map to be one less
      - return [tail, [sequence]] when the amount reaches zero
  - This method will return the tail of the disk map array and the compacted sequence to 
    push into the compacted array
  - This will require looping through sequence to insert it into the compacted array
    - loop though <sequence> pushing each value into the compacted array
- determine checksum
  - map across each element, multiplying value * position
    - use [].each_with_index.map 
  - checksum.reduce(:+)
=end

def pull_from_the_back(disk_map, amount, tail)
  sequence = []
  
  while amount > 0
    return [tail, sequence] if tail.abs >= MAX_TAIL
    if disk_map[tail].zero?
      tail -= 2
      next
    end
  
    sequence << current_position(tail)
    disk_map[tail] -= 1
    amount -= 1
  end
  
  [tail, sequence]
end

def current_position(tail)
  MAX_TAIL + tail + 1
end

disk_map = []
INPUT = './day_9_input.txt'
File.open(INPUT, "r").each_line { |row| disk_map << row }

disk_map = disk_map.first.chars.map(&:to_i)
MAX_TAIL = disk_map.size

compacted = []
free_blocks = 0
tail = -1

disk_map.each_with_index do |amount, id|
  if id.even?
    amount.times { compacted << (id / 2) }
  else
    tail, sequence = pull_from_the_back(disk_map, amount, tail)
    sequence.each { |seq_id| compacted << (seq_id / 2) }
  end
  disk_map[id] = 0
end

checksum = compacted.each_with_index.map { |id, idx| id * idx }
p checksum.reduce(:+)

