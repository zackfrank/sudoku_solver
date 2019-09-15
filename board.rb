class Board
  attr_accessor :cells

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
