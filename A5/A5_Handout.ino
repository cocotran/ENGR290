long lastObstacleTime;
boolean turn;
boolean left;
boolean right;

void setup() {
  // put your setup code here, to run once:
  pinMode(LED_BUILTIN, OUTPUT);
  Serial.begin(115200); 
  Serial.setTimeout(5);
  lastObstacleTime = -1;
  turn = true;
  left = true;
  right = false;
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

float angularPosition(float v, float t) {
  float result = (v * t);
  return abs(result);
}

void loop() {  
  //Read serial port until sensor data is sent
  serialWait();
  
  //Interpret the data String
  // Section 1***************************************
  float simTime = Serial.parseFloat();
  int   result = Serial.parseInt();
  float defaultSpeed = Serial.parseFloat();
  float distance = Serial.parseFloat();
  float leftSpeed,rightSpeed = 0;
  long  timeNow = millis();

  float wx = Serial.parseFloat();
  float wy = Serial.parseFloat();
  float wz = Serial.parseFloat();
  
  //***************************************
  float p = angularPosition(wz, simTime);
//  int forward = int(p) % 6;
  if (turn == true) {
    lastObstacleTime = timeNow + 4700;
  }
  if (timeNow < lastObstacleTime) {
    leftSpeed = -defaultSpeed;
    rightSpeed = defaultSpeed;
  }
  if (timeNow > lastObstacleTime) {
      if (result == 0) {    
    //Action if there is no obstacle
    leftSpeed = defaultSpeed;
    rightSpeed = defaultSpeed;
    }
   if (result == 1 && distance > 0.30 && distance <= 0.40) {    
    leftSpeed = defaultSpeed;
    rightSpeed = defaultSpeed;
    }
    if (result == 1 && distance > 0.40) {    
    leftSpeed = defaultSpeed*1.5;
    rightSpeed = defaultSpeed*1.5;
    }
   if (result == 1 && distance <= 0.30 && distance >= 0.15) {
    leftSpeed = -defaultSpeed;
    rightSpeed = -defaultSpeed;
   }
   if (result == 1 && distance <= 0.15) {
    leftSpeed = -defaultSpeed*1.5;
    rightSpeed = -defaultSpeed*1.5;
   }
  }

  turn = false;
//  if (result == 0) {    
//    //Action if there is no obstacle
//    leftSpeed = defaultSpeed;
//    rightSpeed = defaultSpeed;
//    }
//   if (result == 1 && distance > 0.30 && distance <= 0.40) {    
//    leftSpeed = defaultSpeed;
//    rightSpeed = defaultSpeed;
//    }
//    if (result == 1 && distance > 0.40) {    
//    leftSpeed = defaultSpeed*1.5;
//    rightSpeed = defaultSpeed*1.5;
//    }
//   if (result == 1 && distance <= 0.30 && distance >= 0.15) {
//    leftSpeed = -defaultSpeed;
//    rightSpeed = -defaultSpeed;
//   }
//   if (result == 1 && distance <= 0.15) {
//    leftSpeed = -defaultSpeed*1.5;
//    rightSpeed = -defaultSpeed*1.5;
//   }
   
    //***************************************
    Serial.print(simTime);
    Serial.print(",");
    Serial.print(timeNow);
    Serial.print(",");
    Serial.print(leftSpeed);
    Serial.print(",");
    Serial.print(rightSpeed);
    Serial.print(",");
    Serial.print(lastObstacleTime);
    Serial.print(",");
    Serial.print(distance);
    Serial.print(",");
    Serial.print(p);
    Serial.print("\r\n");

  //***************************************
  
}
