package Labs;

import java.util.Random;

public class Main {
    public static void main(String[] args) {
        IntNode head;
        IntNode node1;
        IntNode node2;
        IntNode node3;
        IntNode currentObj;
        Random random = new Random();


        IntNode nodeList = new IntNode(random.nextInt(100));
        head = new IntNode(-1542);

        node1 = new IntNode(555);
        head.insertAfter(node1);
        node2 = new IntNode(434);
        node1.insertAfter(node2);
        node3 = new IntNode(446531);
        node1.insertAfter(node3);

        node1.insertAfter(nodeList);



        //print list
        currentObj = head;
        while(currentObj != null){
            currentObj.printNodeData();
            currentObj = currentObj.getNext();

        }
    }
}