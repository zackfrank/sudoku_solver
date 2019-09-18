class Board
  attr_accessor :cells
  # validate cells.length == 81

  def initialize(cells:)
    @cells = cells
  end

  def set_value(x, y, value)
    index = coords_to_index(x, y)
    cells[index] = value
  end

  def cell_value(x, y)
    rows[y][x]
  end

  def coords_to_index(x, y)
    (9 * y + x)
  end

  # def rows
  #   @rows ||= construct_rows
  # end

  # def construct_rows
  def rows
    cells.each_slice(9).to_a
  end

  # def columns
  #   @columns ||= construct_columns
  # end

  # def construct_columns
  def columns
    columns = [[], [], [], [], [], [], [], [], []]
    columns.each do |column|
      rows.each { |row| column << row[columns.find_index(column)] }
    end
    columns
  end

  # def squares
  #   @squares ||= construct_squares
  # end

  # def construct_squares
  def squares
    squares = [[], [], [], [], [], [], [], [], []]
    square_index = 0
    rows.each_slice(3).each do |trio|
      cell_index = 0
      3.times do
        trio.each do |row|
          squares[square_index] << row.slice(cell_index..cell_index + 2)
        end
        squares[square_index].flatten!
        square_index += 1
        cell_index += 3
      end
    end
    squares
  end

  def row_contents(y)
    rows[y].tap { |row| row.delete(0) }
  end

  def column_contents(x)
    columns[x].tap { |column| column.delete(0) }
  end

  def square_contents(x, y)
    sq = determine_square(x, y)
    squares[sq].tap { |square| square.delete(0) }
  end

  def determine_square(x, y)
    return 0 if y < 3 && x < 3
    return 1 if y < 3 && x < 6
    return 2 if y < 3
    return 3 if y < 6 && x < 3
    return 4 if y < 6 && x < 6
    return 5 if y < 6
    return 6 if x < 3
    return 7 if x < 6
    return 8
  end

  def cell_possibilities(x, y)
    return unless empty_cell(x, y)

    [*1..9] - neighbor_contents(x, y)
  end

  def neighbor_contents(x, y)
    row_contents(y) | column_contents(x) | square_contents(x, y)
  end

  def empty_cell(x, y)
    cell_value(x, y).zero?
  end

  def print_rows
    rows.each { |row| p row }
  end

  def print_columns
    columns.each { |column| p column }
  end

  def print_squares
    squares.each { |square| p square }
  end
end

# NOTE:
#   - index/9 gives row --> y
#   - index%9 gives column --> x

# b = Board.new(cells:
#   [
#     0, 0, 2, 1, 0, 8, 5, 0, 3,
#     0, 0, 0, 0, 2, 0, 9, 0, 7,
#     8, 0, 0, 3, 9, 0, 0, 0, 0,
#     3, 1, 7, 6, 0, 0, 0, 0, 0,
#     4, 6, 0, 0, 5, 0, 0, 7, 2,
#     0, 0, 0, 0, 0, 4, 8, 1, 6,
#     0, 0, 0, 0, 7, 3, 0, 0, 5,
#     5, 0, 6, 0, 1, 0, 0, 0, 0,
#     1, 0, 3, 5, 0, 6, 7, 0, 0
#   ])

# b.print_rows
# puts '-'* 20
# b.print_squares
# puts b.cell_value(7, 1)
