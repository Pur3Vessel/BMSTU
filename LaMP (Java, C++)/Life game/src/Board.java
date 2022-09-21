import java.sql.Array;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.stream.Stream;

public class Board {
    private HashMap<String, Cell> board;
    private ArrayList<Cell> life;
    private ArrayList<Cell> potentialLife;

    public Board (){
        board = new HashMap<>();
        life = new ArrayList<>();
    }
    public ArrayList<Cell> getLife() {
        return life;
    }

    public HashMap<String, Cell> getBoard() {
        return board;
    }

    public void addCell(int x, int y) {
        String c = x + " " + y;
        Cell cell = new Cell(x, y);
        board.put(c, cell);
        life.add(cell);
    }
    public Stream<Cell> createSurviveStream (){
        return life.stream().filter(c -> c.survive(this));
    }
    public Stream<Cell> createGenesisStream () {
        potentialLife = new ArrayList<Cell>();
        HashMap<String, Cell> newLife = new HashMap<>();
        life.stream().forEach(c -> c.genesis(this, potentialLife, newLife));
        return potentialLife.stream();
    }
    public Board cycle() {
        Board board = new Board();
        this.createSurviveStream().forEach(cell -> board.addCell(cell.getX(), cell.getY()));
        this.createGenesisStream().forEach(cell -> board.addCell(cell.getX(), cell.getY()));
        return board;
    }
}
