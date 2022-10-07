module com.example.colorfulcircles {
    requires javafx.controls;
    requires javafx.fxml;


    opens com.example.colorfulcircles to javafx.fxml;
    exports com.example.colorfulcircles;
}