module com.example.byeworldfx {
    requires javafx.controls;
    requires javafx.fxml;


    opens com.example.byeworldfx to javafx.fxml;
    exports com.example.byeworldfx;
}