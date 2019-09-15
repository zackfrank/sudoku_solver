class Board
  attr_accessor :cells

  def initialize(cells:)
    @cells = cells
  end

  def set_value(x, y, value)
    index = (9 * y + x)
    cells[index] = value
  end

  def cell_value(x, y)
    rows[y][x]
  end

  def rows
    cells.each_slice(9).to_a
  end

  def columns
    columns = [[],[],[],[],[],[],[],[],[]]
    columns.each do |column|
      rows.each { |row| column << row[columns.find_index(column)] }
    end
    columns
  end

  def squares
    squares = [[],[],[],[],[],[],[],[],[]]
    square_index = 0
    row_index = 0
    num_index = 0
    9.times do
      3.times do
        squares[square_index] << rows[row_index].slice(num_index..num_index + 2)
        row_index += 1
      end

      squares[square_index].flatten!
      square_index += 1

      num_index < 5 ? num_index += 3 : num_index = 0

      row_index = 0
      row_index = 3 if square_index > 2
      row_index = 6 if square_index > 5
    end

    squares
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
