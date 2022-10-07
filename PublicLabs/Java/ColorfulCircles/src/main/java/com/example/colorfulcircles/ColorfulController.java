package com.example.colorfulcircles;

import javafx.fxml.FXML;
import javafx.scene.control.Label;

public class ColorfulController {
    @FXML
    private Label welcomeText;

    @FXML
    protected void onHelloButtonClick() {
        welcomeText.setText("Welcome to JavaFX Application!");
    }
}