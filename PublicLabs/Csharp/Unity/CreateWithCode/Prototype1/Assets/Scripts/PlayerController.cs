using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerController : MonoBehaviour
{
    private float speed = 25.0f;
    private float turnSpeed = 40.0f;
    private float horizontalInput;
    private float forwardInput;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        horizontalInput = Input.GetAxis("Horizontal");
        forwardInput = Input.GetAxis("Vertical");


        //Move vehicle forward    
        transform.Translate(Vector3.forward * Time.deltaTime * speed * forwardInput);
        //Turn vehicle left/right
        transform.Rotate(Vector3.right, turnSpeed * horizontalInput * Time.deltaTime);
    }
}
