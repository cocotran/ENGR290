#define PI 3.14
float servo_position;
float throttle;
int thrustState;
int liftState;
boolean isStuck;
float stuckTime;
int state;
int oldState;
float initialTime;
float Time;

void setup() {
  // put your setup code here, to run once:
  pinMode(LED_BUILTIN, OUTPUT);
  Serial.begin(115200); 
  Serial.setTimeout(1);
  thrustState = 0;
  throttle = 0;
  liftState = 1;
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

void checkStuck(){
  if(state != oldState){
    oldState = state;
    initialTime = Time;
  }
  else
  stuckTime = Time - initialTime;

  if(stuckTime >= 7){
    isStuck = true;
  }
}

void turn_right() {
  thrustState = 1; //  fan_on
  throttle = 1;
  servo_position = -0.5*PI;
  state = 1;
}

void go_forward() {
  thrustState = 1; //  thrust_fan_on
  throttle = 1;
  servo_position = 0;
  state = 2;
}

void turn_left() {
  thrustState = 1; //  thrust_fan_on
  servo_position = 0.5*PI;
  throttle = 1;
  state = 3;
}

void loop() {  
  //Read serial port until sensor data is sent
  serialWait();
  
  //Interpret the data String
  float simTime = Serial.parseFloat();
  float sensor_front_distance = Serial.parseFloat();
  float sensor_right_distance = Serial.parseFloat();
  Time = simTime;
  checkStuck();
  if(isStuck == true){
    if(state == 1)
    turn_left();
    else if(state == 3)
    turn_right();
  }
  

  if (sensor_front_distance ==-1 && (sensor_right_distance ==-1 || sensor_right_distance >0.25 )) { //00
    // not detecting anything turn right to find right wall
    turn_right(); // should print {-1.57, 1, 1, 1}
  }

  else if (sensor_front_distance <= 0.12 && sensor_front_distance !=-1 && (sensor_right_distance ==-1 || sensor_right_distance>0.32)) {
    turn_right();
  }
    
  else if (sensor_front_distance == -1 && sensor_right_distance <=0.25 && sensor_right_distance!=-1) {  //01
    // Wall on the right, nothing in the front, go forward
    go_forward(); // should print {0, 1, 1, 1}
  }

  else if (sensor_front_distance >0.1 && sensor_right_distance <=0.25 && sensor_right_distance!=-1){
    go_forward();
  }
  
  else if (sensor_front_distance <=0.1 && sensor_front_distance !=-1  && sensor_right_distance<=0.25 && sensor_right_distance!=-1 ) { //11
      turn_left(); // {1.57, 1, 1, 1}
  }

  Serial.print(servo_position);
  Serial.print(",");
  Serial.print(thrustState);
  Serial.print(",");
  Serial.print(throttle);
  Serial.print(",");
  Serial.print(liftState);
  Serial.print("\r\n");


  //***************************************
}
