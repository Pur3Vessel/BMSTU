import javax.swing.*;
import javax.swing.event.ChangeEvent;
import javax.swing.event.ChangeListener;
import java.awt.*;

public class PictureForm {
    private JPanel mainPanel;
    private Drawer drawer1;
    private JSpinner heightSpinner;
    private JSpinner radiusSpinner;
    private JSpinner percentSpinner;
    public PictureForm() {
        SpinnerModel heightModel = new SpinnerNumberModel(400, 10, 500, 1);
        heightSpinner.setModel(heightModel);
        SpinnerModel radiusModel = new SpinnerNumberModel(300, 10, 500, 1);
        radiusSpinner.setModel(radiusModel);
        SpinnerModel percentModel = new SpinnerNumberModel(50, 0, 100, 1);
        percentSpinner.setModel(percentModel);
        heightSpinner.addChangeListener(new ChangeListener() {
            @Override
            public void stateChanged(ChangeEvent e) {
                drawer1.setHeight((int)heightSpinner.getValue());
            }
        });
        radiusSpinner.addChangeListener(new ChangeListener() {
            @Override
            public void stateChanged(ChangeEvent e) {
                drawer1.setDiam((int)radiusSpinner.getValue());
            }
        });
        percentSpinner.addChangeListener(new ChangeListener() {
            @Override
            public void stateChanged(ChangeEvent e) {
                drawer1.setPercent((int)percentSpinner.getValue());
            }
        });
    }


    public static void main(String[] args) {
        JFrame frame = new JFrame("Кресло");
        frame.setContentPane(new PictureForm().mainPanel);
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.pack();
        frame.setVisible(true);

    }
}
