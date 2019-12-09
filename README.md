## Sudoku Solver
A fun personal project to work on translating mental analytical skills to Ruby code.

### Board Class
Initialize a board by adding a one-dimensional array of all cells of a sudoku to
a new instance of Board:
```
board = Board.new(cells: 
  [
    0, 0, 2, 1, 0, 8, 5, 0, 3,
    0, 0, 0, 0, 2, 0, 9, 0, 7,
    8, 0, 0, 3, 9, 0, 0, 0, 0,
    3, 1, 7, 6, 0, 0, 0, 0, 0,
    4, 6, 0, 0, 5, 0, 0, 7, 2,
    0, 0, 0, 0, 0, 4, 8, 1, 6,
    0, 0, 0, 0, 7, 3, 0, 0, 5,
    5, 0, 6, 0, 1, 0, 0, 0, 0,
    1, 0, 3, 5, 0, 6, 7, 0, 0
  ])
```
### NOTE: empty cells are represented by 0s

Individual cell values can be evaluated with x, y coordinates 
(using array-style values - ie value at top-left corner is 0, 0)
- Left to right is x value of 0-8
- Top to bottom is y value of 0-8

Method to obtain cell value at coordinates is:
```
board.cell_value(x, y)
```


Board class can print sub-arrays of rows, columns, and squares:
```
board.print_rows # etc
```

### Solver Class
Inject board into new instance of Solver class:
```
solver = Solver.new(board: board)
```

Solver can fill in the whole board (as long as the level is such that the board
can be solved through basic analysis of rows, columns, and squares):
```
solver.fill_in
```

Solver can also solve a single cell at a time (if solvable at board's current state):
```
solver.solve_cell(x, y)
```

Solver can also analyze a single cell at a time and provide all possibilities for the cell:
```
solver.analyze_cell(x, y)
```

### Solver Spec
Run spec with:
```
rspec solver_spec.rb
```

### Aspirations
- Add final solving technique of testing possibilities to see if it will solve the puzzle
  - If set of tests solves the puzzle, fill in board
  - If set of tests do not solve the puzzle, go back to test inception and try other possibilities
- Extract all solver strategies to their own separate classes
  - Consider using a yaml config file to list all available strategies through which the solver
    can iterate
  - This architechture may warrant a solver helper file of common functions used for solving strategies
- Create browser frontend
  - Interactive user interface
  - User can choose to be shown hints for individual cells
  - Possibly update cell colors if they conflict with user input
    - ie an 8 in the column will turn red if user enters 8 into a cell within that column