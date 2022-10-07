﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerControllerX : MonoBehaviour
{
    private float speed = 20f;
    private float rotationSpeed = 30f;
    private float verticalInput;
    private float rotationInput;
    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        // get the user's vertical input
        verticalInput = Input.GetAxis("Vertical");
        rotationInput = Input.GetAxis("Horizontal");

        // move the plane forward at a constant rate
        transform.Translate(Vector3.forward * Time.deltaTime * speed * verticalInput);

        // tilt the plane up/down based on up/down arrow keys
        transform.Rotate(Vector3.right,rotationSpeed * rotationInput * Time.deltaTime);
    }
}
