long lastObstacleTime;

void setup() {
  // put your setup code here, to run once:
  pinMode(LED_BUILTIN, OUTPUT);
  Serial.begin(115200); 
  Serial.setTimeout(5);
  lastObstacleTime = -1;
}

void serialWait(){
  while(Serial.peek() != 's') {
    char t = Serial.read();
    digitalWrite(LED_BUILTIN, HIGH);   // turn the LED on (HIGH is the voltage level)
    delay(1);                      
    digitalWrite(LED_BUILTIN, LOW);    // turn the LED off by making the voltage LOW
    delay(1);
  }
  char t = Serial.read(); //discard the s
}   

void loop() {  
  //Read serial port until sensor data is sent
  serialWait();
  
  //Interpret the data String
  //Arduino Section 1***************************************
  float simTime = Serial.parseFloat();
  int   result = Serial.parseInt();
  float defaultSpeed = Serial.parseFloat();
  float leftSpeed, rightSpeed = 0;
  long timeNow = millis();

  if (result == 0 && timeNow > lastObstacleTime) {
    leftSpeed = defaultSpeed;
    rightSpeed = defaultSpeed;
  }
  else if (result == 1) {
    lastObstacleTime = timeNow + 4000;
    leftSpeed = -defaultSpeed;
    rightSpeed = -defaultSpeed;
  }
  else if (timeNow < lastObstacleTime) {
    leftSpeed = defaultSpeed/4;
    rightSpeed = -defaultSpeed/4;
  }

  Serial.print(simTime);
  Serial.print(",");
  Serial.print(timeNow);
  Serial.print(",");
  Serial.print(leftSpeed);
  Serial.print(",");
  Serial.print(rightSpeed);
  Serial.print(",");
  Serial.print(lastObstacleTime);
  Serial.print("\r\n");


//  Serial.print("Hello CoppeliaSim! \r\n");



  //***************************************
  

}
