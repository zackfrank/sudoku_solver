require_relative 'board.rb'

class Solver
  attr_accessor :board, :filled_in_board

  def initialize(board:)
    @board = board
  end

  def fill_in_board
    @filled_in_board ||= board.dup

    while filled_in_board.cells.include? 0 do
      [*0..8].each do |x|
        [*0..8].each do |y|
          solve_cell(x, y)
        end
      end
    end
  end

  def solve_cell(x, y)
    return unless filled_in_board.cell_value(x, y) == 0

    possibilities = filled_in_board.cell_possibilities(x, y)
    if possibilities.length == 1
      filled_in_board.set_value(x, y, possibilities[0])
    end
  end
end

# EASY
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

# MEDIUM
# b = Board.new(cells:
#   [
#     0, 9, 0, 4, 0, 6, 0, 3, 0,
#     8, 0, 0, 0, 0, 7, 0, 0, 9,
#     2, 0, 3, 0, 8, 0, 0, 0, 4,
#     0, 2, 9, 1, 0, 0, 0, 0, 0,
#     0, 0, 0, 0, 0, 0, 0, 0, 0,
#     0, 0, 0, 0, 0, 5, 8, 2, 0,
#     5, 0, 0, 0, 7, 0, 6, 0, 1,
#     3, 0, 0, 9, 0, 0, 0, 0, 7,
#     0, 8, 0, 6, 0, 1, 0, 4, 0
#   ])

# HARD
# b = Board.new(cells:
#   [
#     0, 0, 0, 3, 0, 6, 0, 5, 0,
#     0, 0, 3, 1, 0, 0, 9, 4, 0,
#     5, 0, 0, 0, 2, 0, 0, 0, 0,
#     2, 8, 0, 0, 0, 0, 7, 0, 0,
#     0, 3, 0, 0, 8, 0, 0, 6, 0,
#     0, 0, 6, 0, 0, 0, 0, 9, 4,
#     0, 0, 0, 0, 9, 0, 0, 0, 7,
#     0, 7, 9, 0, 0, 1, 5, 0, 0,
#     0, 2, 0, 8, 7, 0, 0, 0, 0
#   ])

##########################
s = Solver.new(board: b)
s.fill_in_board
s.filled_in_board.print_rows