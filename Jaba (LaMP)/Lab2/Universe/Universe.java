import java.util.ArrayList;

public class Universe {
    private ArrayList<Element> elements;
    public Universe() {
        elements = new ArrayList<>();
    }
    public void addElement() {
        Element e = new Element();
        elements.add(e);
    }
    public void addElement(double m) {
        Element e = new Element(m);
        elements.add(e);
    }
    public void addElements(double []ms) {
        for (int i = 0; i < ms.length; i++) {
            Element e = new Element(ms[i]);
            elements.add(e);
        }
    }
    public double getCount() {
        return Element.getCount();
    }
    public double totalWeight() {
        double w = 0;
        for (int i = 0; i < elements.size(); i++) {
            w += elements.get(i).getWeight();
        }
        return w;
    }
    public double midWeight() {
        return totalWeight()/getCount();
    }
}
