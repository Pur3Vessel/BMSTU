import javax.swing.*;
import java.util.ArrayList;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.awt.Color;
import org.jfree.chart.ChartFactory;
import org.jfree.chart.ChartPanel;
import org.jfree.chart.JFreeChart;
import org.jfree.chart.plot.XYPlot;
import org.jfree.data.xy.XYDataset;
import org.jfree.data.xy.XYSeries;
import org.jfree.data.xy.XYSeriesCollection;

/*
Разбирается библиотека java.util.regex.

Класс Pattern представляет собой компилированное представление регулярного выражения. Далее на основе объекта класса Pattern создается объект класса
Matcher, в котором уже реализована логика сопоставления произвольной строки и регулярки (но это уже другая история).

Если в процессе парсинга возникает ошибка, связанная с неправльной формой регулярного выражения,тогда вызывается исключение PatternSyntaxException.

Сам парсинг регулярного выражения начинается с вызова метода compile, который создает объект класса Pattern, посредством вызова приватного конструктора.
Важную роль в обработке строки играют флаги, которые можно задать в аргументах метода compile: UNIX_LINES - включает режим строк Unix, CASE_INSENSITIVE - сопоставление без учета регистра,
COMMENTS - разрешает пробельные символы и комментарии в шаблоне, MULTLINE - включает многострочный режим, LITERAL - литеральный разбор шаблона,
UNICODE_CASE - если включен CASE_INSENSITIVE, то нечуствительное к регистру сопоставление выполнется в соответствии с Unicode. DOTALL - включает режим dotall,
CANON_EQ - включает каноническую эквивалентность, UNICODE_CHARACTER_CLASS - Включает версию Unicode для классов предопределенных символов и классов символов POSIX.

Главная задача приватного конструктора - инициализировать приватное поле re типа RE (в конструкторе класса RE как раз и происходит весь парсинг).
Кроме того, одним из аргументов конструктора RE, является класс RESyntax. Он задает способ составления регулярного выражения и предоставляет ряд предопределенных полезных констант для эмуляции популярных синтаксисов регулярных выражений.
Более того, он позволяет пользователю создать свой собственный синтаксис, используя любую комбинацию битовых констант синтаксиса. (сложно)
В общем, то именно этот класс и позволяет удобно пользоваться флагами, описанными выше.

Конструктор класса RE вызывает метод initialize, который заполняет связный список токенов. Принцип работы этого метода заключается в линейном проходе по массиву символов и их обработке.
Токены могут быть различными (соотвествуя разным "сущностям" регулярного выражения).
Альтернативы считаются подвыражениями текущего регулярного выражения и выносятся в отдельный массив, (Каждая альтернатива считается RE, что по идее должно быть удобно при сопоставлении).
В случае, если при обработке символьного массива будет замечено несоответвие синтаксису, будет порождено исключение REException, которое на более высоком уровне приведет к PatternSyntaxException.

Дальнейшие действия со связным списком токенов проводятся уже непосредственно при сопоставлении (поэтому именно при сопоставлении зависимость времени от k становится достаточно заметной, чего не скажешь про компиляцию).

*/

interface regexChanger {
    public String changeRule(String regex);
}
public class Task extends JFrame {
    public Task(String title) {
        super(title);


        regexChanger changer1 = s -> "(" + s + "a" + ")*";
        //var dataset = timeline("(a)*", changer1);
        regexChanger changer2 = s -> "(a?)" + s + "a";
        //var dataset = timeline("(a?)a", changer2);
        regexChanger changer3 = s -> ".b*.{" + (Integer.parseInt(s.substring(5, s.length() - 1)) + 1) + "}";
        //var dataset = timeline(".b*.{1}", changer3);
        regexChanger changer4 = s -> "(" + s + ")" + "| a* | b?"; // какого-то смысла она не несет, зато чуть дольше остальных компилится из-за альтернатив
        //var dataset = timeline("a* | b?", changer4);
        regexChanger changer5 = s -> s + "a*a?.b*b?.";
        var dataset = timeline("a*a?.b*b?.", changer5);


        JFreeChart chart = ChartFactory.createScatterPlot(
                "",
                "k", "t, мкс", dataset);


        XYPlot plot = (XYPlot)chart.getPlot();
        plot.setBackgroundPaint(new Color(255,228,196));

        ChartPanel panel = new ChartPanel(chart);
        setContentPane(panel);
    }
    public static XYDataset timeline (String start, regexChanger stepRule) {
        int kStep = 10;
        int kMax = 7000;
        ArrayList<Double> times = new ArrayList<>();
        XYSeries series1 = new XYSeries(start);
        String regex = start;
        for (int k = 0; k <= kMax; k += kStep) {
            long startTime = System.nanoTime();
            Pattern p = Pattern.compile(regex);
            //Matcher m = p.matcher("a");
            //boolean a = m.matches();
            long finishTime = System.nanoTime();
            times.add((double) (finishTime - startTime) / 1000);
            for (int i = 0; i < 3; i++) {
                regex = stepRule.changeRule(regex);
            }
            series1.add(k, (double) (finishTime - startTime) / 1000);
        }
        System.out.println(times);
        var dataset = new XYSeriesCollection();
        dataset.addSeries(series1);
        return dataset;
    }
    public static void main (String[] args) {
        SwingUtilities.invokeLater(() -> {
            Task example = new Task("");
            example.setSize(800, 400);
            example.setLocationRelativeTo(null);
            example.setDefaultCloseOperation(WindowConstants.EXIT_ON_CLOSE);
            example.setVisible(true);
        });
    }
}
