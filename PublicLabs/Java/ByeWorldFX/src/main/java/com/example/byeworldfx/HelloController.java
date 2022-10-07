package com.example.byeworldfx;

import javafx.fxml.FXML;
import javafx.scene.control.Label;

public class HelloController {
    @FXML
    private Label greeting;

    @FXML
    protected void onHelloButtonClick() {
        greeting.setText("God hlep us all what are we doing?");
    }
}