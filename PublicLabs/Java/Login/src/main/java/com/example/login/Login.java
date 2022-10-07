package com.example.login;

import javafx.application.Application;
import javafx.event.ActionEvent;
import javafx.event.EventHandler;
import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.control.PasswordField;
import javafx.scene.control.TextField;
import javafx.scene.layout.GridPane;
import javafx.scene.layout.HBox;
import javafx.scene.text.Text;
import javafx.stage.Stage;

public class Login extends Application {
    @Override
    public void start(Stage primaryStage){
        primaryStage.setTitle("JavaFX Login Lab");

        GridPane grid = new GridPane();
        grid.setAlignment(Pos.CENTER);
        grid.setHgap(10);
        grid.setVgap(10);
        grid.setPadding(new Insets(25,25,25,25));

        Text sceneTitle = new Text("Welcome");
        grid.add(sceneTitle, 0, 0, 2, 1);
        sceneTitle.setId("welcome-text");


        Label userName = new Label("User Name:");
        grid.add(userName, 0, 1);

        TextField userTextField = new TextField();
        grid.add(userTextField, 1, 1);

        Label pw = new Label("Password:");
        grid.add(pw, 0, 2);

        PasswordField pwBox = new PasswordField();
        grid.add(pwBox, 1, 2);

        Button signIn = new Button("Sign in");
        HBox hBoxButton = new HBox(10);
        hBoxButton.setAlignment(Pos.BOTTOM_RIGHT);
        hBoxButton.getChildren().add(signIn);
        grid.add(hBoxButton,1,4);

        final Text actionTarget = new Text();
        grid.add(actionTarget,1, 6);

        signIn.setOnAction(new EventHandler<ActionEvent>(){
            @Override
                    public void handle(ActionEvent e){
                        actionTarget.setId("actiontarget");
                        actionTarget.setText("Sign in button pressed");
            }
        });

        Scene scene = new Scene(grid, 300,275);
        primaryStage.setScene(scene);
        scene.getStylesheets().add(Login.class.getResource("style.css").toExternalForm());

        primaryStage.show();
    }

    public static void main(String[] args) {
        launch();
    }
}