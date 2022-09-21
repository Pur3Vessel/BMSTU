import java.util.Scanner;
import java.util.stream.Stream;

public class Test {
    public static void main(String[] args) {
        Board board = new Board();
        board.addCell(1, 1);
        board.addCell(2, 2);
        board.addCell(3, 3);
        board.addCell(3, 1);
        board.addCell(8, 1);
        board.addCell(8, 2);
        board.addCell(9, 2);
        board.addCell(9, 3);
        board.addCell(5, 6);
        board.addCell(6, 7);
        board.addCell(7, 8);
        board.createSurviveStream().forEach(System.out :: println);
        System.out.println();
        board.createGenesisStream().forEach(System.out :: println);
        board = board.cycle();
        System.out.println("Прошел ход");
        board.createSurviveStream().forEach(System.out :: println);
        System.out.println();
        board.createGenesisStream().forEach(System.out :: println);
    }
}
