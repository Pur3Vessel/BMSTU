import javax.swing.*;
import java.awt.*;

public class Drawer extends JPanel {
    private int height = 400;
    private int radius = 150;
    private int percent = 50;
    private int gR = 50;
    private int gH = 100;
    public void setDiam(int d) {
        radius = d/2;
        repaint();
    }
    public void setHeight(int h) {
        height = h;
        repaint();
    }
    public void setPercent(int p) {
        percent = p;
        repaint();
    }
    protected void paintComponent (Graphics g) {
        super.paintComponent(g);
        g.setColor(Color.WHITE);
        int startX = 400 - radius/2;
        int endX = 400 + radius/2;
        int startY = 500 + height/2;
        int endY = 500 - height/2;
        int startGY = endY - 45;
        int startGX = 400 + gR/2;
        int endGX = 400 - gR/2;
        int endGY = startGY - gH;
        g.drawLine(startX, startY, endX, startY);
        g.drawLine(startX, startY, startX, endY);
        g.drawLine(endX, startY, endX, endY);
        g.drawLine(startGX, startGY, startGX, endGY);
        g.drawLine(endGX, startGY, endGX, endGY);
        g.drawLine(startGX, endGY, endGX, endGY);
        g.drawLine(endX, endY, startGX, startGY);
        g.drawLine(startX, endY, endGX, startGY);
        g.setColor(Color.YELLOW);
        int fillEnd = startY - (height *  percent / 100);
        for (int i = startY + 1; i > fillEnd; i--) {
            g.drawLine(startX  + 2, i, endX - 2, i);
        }

    }
}
