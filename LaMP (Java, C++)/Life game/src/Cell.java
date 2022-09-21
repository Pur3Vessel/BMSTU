import java.util.ArrayList;
import java.util.HashMap;
import java.util.Optional;

public class Cell {
    // Подразумевается уже живая клетка
    private int x;
    private int y;
    private int neighbours;
    public Cell (int x, int y) {
        this.x = x;
        this.y = y;
    }
    public String toString() {
        return x + " " + y;
    }
    public int getX() {
        return x;
    }
    public int getY() {
        return y;
    }
    private void countNeighbours(HashMap<String, Cell> board) {
        neighbours = 0;
        if (Optional.ofNullable(board.get((x - 1) + " " + (y - 1))).isPresent()) neighbours++;
        if (Optional.ofNullable(board.get((x - 1) + " " + (y))).isPresent()) neighbours++;
        if (Optional.ofNullable(board.get((x - 1) + " " + (y + 1))).isPresent()) neighbours++;
        if (Optional.ofNullable(board.get((x + 1) + " " + (y - 1))).isPresent()) neighbours++;
        if (Optional.ofNullable(board.get((x + 1) + " " + (y))).isPresent()) neighbours++;
        if (Optional.ofNullable(board.get((x + 1) + " " + (y + 1))).isPresent()) neighbours++;
        if (Optional.ofNullable(board.get((x) + " " + (y - 1))).isPresent()) neighbours++;
        if (Optional.ofNullable(board.get((x) + " " + (y + 1))).isPresent()) neighbours++;
    }
    public boolean survive(Board board) {
        this.countNeighbours(board.getBoard());
        return neighbours == 2 || neighbours == 3;
    }
    public void birth(HashMap<String, Cell> newLife, ArrayList<Cell> potentialLife, Board board) {
        this.countNeighbours(board.getBoard());
        if (neighbours == 3) {
            if ((!Optional.ofNullable(board.getBoard().get(x + " " + y)).isPresent()) && (!Optional.ofNullable(newLife.get(x + " " + y)).isPresent())) {
                newLife.put(x + " " + y, new Cell(x, y));
                potentialLife.add(new Cell(x, y));
            }
        }
    }
    public void genesis(Board board,  ArrayList<Cell> potentialLife, HashMap<String, Cell> newLife) {
        new Cell(x - 1, y - 1).birth(newLife, potentialLife, board);
        new Cell(x - 1, y).birth(newLife, potentialLife, board);
        new Cell(x - 1, y + 1).birth(newLife, potentialLife, board);
        new Cell(x + 1, y - 1).birth(newLife, potentialLife, board);
        new Cell(x + 1, y).birth(newLife, potentialLife, board);
        new Cell(x + 1, y + 1).birth(newLife, potentialLife, board);
        new Cell(x, y - 1).birth(newLife, potentialLife, board);
        new Cell(x, y + 1).birth(newLife, potentialLife, board);
    }
}
