class Solver
  attr_accessor :board

  def initialize(board:)
    @board = board
  end

  def solve_cell(x, y)
    return unless board.cell_value(x, y) == 0

    possibilities = analyze_cell(x, y)
    if possibilities.length == 1
      board.set_value(x, y, possibilities[0])
    end
  end

  def fill_in
    while board.cells.include? 0 do
      [*0..8].each do |x|
        [*0..8].each do |y|
          solve_cell(x, y)
        end
      end
    end
  end

  def analyze_cell(x, y)
    possibilities = [*1..9]
    possibilities -= analyze_row(x, y)
    possibilities -= analyze_column(x, y)
    possibilities -= analyze_square(x, y)
  end

  def analyze_row(x, y)
    board.rows[y].tap {|row| row.delete(0)}
  end

  def analyze_column(x, y)
    board.columns[x].tap {|column| column.delete(0)}
  end

  def analyze_square(x, y)
    sq = determine_square(x, y)
    board.squares[sq].tap {|square| square.delete(0)}
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
end

# square 0 = row 0, 1, 2 || col 0, 1, 2
# square 1 = row 0, 1, 2 || col 3, 4, 5
# square 2 = row 0, 1, 2 || col 6, 7, 8
# square 3 = row 3, 4, 5 || col 0, 1, 2
# square 4 = row 3, 4, 5 || col 3, 4, 5
# square 5 = row 3, 4, 5 || col 6, 7, 8
# square 6 = row 6, 7, 8 || col 0, 1, 2
# square 7 = row 6, 7, 8 || col 3, 4, 5
# square 8 = row 6, 7, 8 || col 6, 7, 8 
