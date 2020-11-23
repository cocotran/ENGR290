long lastObstacleTime;
#define PI 3.1415926535897932384626433832795
float servo_position = 0;
int thrustState;
float throttle;
int liftState;

void setup() {
  // put your setup code here, to run once:
  pinMode(LED_BUILTIN, OUTPUT);
  Serial.begin(115200); 
  Serial.setTimeout(5);
  lastObstacleTime = -1;
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

void turn_right() {
  thrustState = 1; //  fan_on
  throttle = 0.5;
  servo_position = PI/-2;
  delay(500);
  servo_position = PI/2;
}

void go_forward() {
  thrustState = 1; //  thrust_fan_on
  throttle = 1;
  servo_position = 0;
}

void turn_left() {
  thrustState = 1; //  thrust_fan_on
  servo_position = PI/2;
  throttle = 0.5;
  delay(500);
  servo_position = PI/-2;
}

void loop() {  
  //Read serial port until sensor data is sent
  serialWait();
  //Interpret the data String
  float sensor_front_distance = Serial.parseFloat();
  float sensor_right_distance = Serial.parseFloat();

  if (sensor_front_distance >= 0.45 && sensor_right_distance >= 0.45) { //00
    // Robot is driving away from the right wall with no obstacles in front
    turn_right();
  }
  if (sensor_front_distance <= 0.20 && sensor_right_distance >= 0.45) { //10
    // Robot is away from the wall but headed towards a wall or obstacle.
    turn_right();
  }

  if (sensor_front_distance > 0.20 && sensor_right_distance <= 0.20) {  //01
    // Robot is following the wall at a distance less than 20cm.
    go_forward();
  }
  if (sensor_front_distance <= 0.20 && sensor_right_distance <= 0.20) { //11
    // Robot is at a corner
    turn_left();
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