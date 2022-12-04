package Labs;

public class IntNode {
    private int dataVal;
    private IntNode nextNodePtr;

    //COnstructor
    public IntNode(){
        dataVal = 0;
        nextNodePtr = null;
    }
    //COnstructor
    public IntNode(int dataInit){
        this.dataVal = dataInit;
        this.nextNodePtr = null;
    }
    //COnstructor
    public IntNode(int dataInit, IntNode nextLoc){
        this.dataVal = dataInit;
        this.nextNodePtr = nextLoc;
    }

    public void insertAfter(IntNode nodeLoc){
        IntNode tmpNext;

        tmpNext = this.nextNodePtr;
        this.nextNodePtr = nodeLoc;
        nodeLoc.nextNodePtr = tmpNext;
    }

    public IntNode getNext(){
        return this.nextNodePtr;
    }

    public void printNodeData(){
        System.out.println(this.dataVal);
    }
}
