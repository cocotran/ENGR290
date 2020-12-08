function sysCall_threadmain()
print(_VERSION)
sim.setThreadSwitchTiming(10) -- Default timing for automatic thread switching
--defining the serial port according to arduino parameters
baudrate=115200
--Section 1.1 **************************************************
    --You MUST modify this to match the COM# of your arduino board
portName="/dev/tty.usbmodem14101"
--**************************************************************
sensorPrecision = 0.001
sim.setIntegerSignal('Consoles',0)
sim.setIntegerSignal('lift',0)

--Open serial port communication
print(portName)
serial = sim.serialOpen(portName,baudrate)
print(serial)
if serial == -1 then
    print("Serial COM port error. Check port number, port name and USB connection to Arduino board")
    print("Otherwise, keyboard control might be a way to control your hovercraft... (:")
end

--Section 1.2 **************************************************
--Retrieve the handles of your key components
--Main hovercraft body ground contact patch
body=sim.getObjectHandle("contactPatch")
--Sensor(s)
noseSensor_frontBase=sim.getObjectHandle("frontSensor") -- Handle of the proximity front sensor
noseSensor_rightBase=sim.getObjectHandle("rightSensor") -- Handle of the proximity right sensor
--Propeller(s)
thrust_fanBase=sim.getObjectHandle("thrust_fanBase") -- Handle of the thrust fan
--Dedicated Lift fan
lift_fanBase=sim.getObjectHandle("lift_fanBase") -- Handle of the lift fan
--Servo(s)
servoBase=sim.getObjectHandle("BigServo_Base") -- Handle of the servo

--**************************************************************

    -- Put your main loop here
while sim.getSimulationState() ~= sim.simulation_advancing_abouttostop do
    --*********************************************************
    --This section will run at each iteration of the simulation
        --Read your sensors
        --Send the sensor data to the Arduino 
        --Receive data from the arduino
        --Use received data to control hovercraft 
    
    --SENSING section ----------------------------------------------------
    frontSensor, distance_front = read_sensor(noseSensor_frontBase) -- Read the proximity sensor
    rightSensor, distance_right = read_sensor(noseSensor_rightBase) -- Read the proximity sensor


    --ACTUATION section ----------------------------------------------------
    simTime = round(sim.getSimulationTime(), 0.01)
    if serial ~= -1 then   
    -- If an arduino board is present, send sensor data to it and retrieve instructions from it
        send_data(serial, {simTime, distance_front, distance_right})
        dataReceived = receive_data()
    end
    
    -- Use the values received from the arduino to control your hovercraft 
   
    if dataReceived ~= nil then
        print(dataReceived)
        
        servo_position = dataReceived[1]            
        thrustState = dataReceived[2]
        thrustThrottle = dataReceived[3]
        liftState = dataReceived[4]
        
        
        set_servo(servoBase, servo_position)
        set_thrust(thrust_fanBase, thrustState, thrustThrottle)
        set_lift(lift_fanBase, liftState, body)
    end 
    --*********************************************************
    sim.switchThread() -- resume in next simulation step
end

end


function imu_init()    
-- This function will initialize the IMU communication
-- Run only once in the initialization section
-- Usage
    -- imu_init()
    
    gyroCommunicationTube=sim.tubeOpen(0,'gyroData'..sim.getNameSuffix(nil),1) 
    accelCommunicationTube=sim.tubeOpen(0,'accelerometerData'..sim.getNameSuffix(nil),1)
end

function read_imu()    
-- This function will read the IMU 
-- it will return instantaneous  values of angular speed (rad/s) and linear acceleration (m/s^2)
-- Returned values are 2 tables with 3 numbers each
-- {XangVel, YangVel, ZangVel}, {Xaccel, Yaccel, Zaccel}
-- Usage
    -- angVel, linAccel = read_imu()

    data1=sim.tubeRead(gyroCommunicationTube)
    if (data1) then
        angularSpeeds=sim.unpackFloatTable(data1)
        angularSpeeds = round(angularSpeeds, sensorPrecision)
    else
       angularSpeeds = {0,0,0}
    end
    data2=sim.tubeRead(accelCommunicationTube)
    if (data2) then
       acceleration=sim.unpackFloatTable(data2)
       acceleration = round(acceleration, sensorPrecision)
    else
       acceleration = {0,0,0}
    end    
    return angularSpeeds,acceleration
end

function read_sensor(sensorHandle) 
-- This function will read one proximity sensor using its Object Handle
-- sensorHandle: Input argument  must be the sensor model base's Object Handle
-- Output arguments are result & distance
-- If no object is sensed by the sensor, 
    -- result = 0, distance = -1 
-- If an object is sensed by the sensor, 
    -- result = 1, distance = distance (m) between sensor and object (rounded to mm)
-- Usage 
    -- result,distance = read_sensor(sensorHandle)

    result,distance = sim.readProximitySensor(sensorHandle)
    if distance == nil then
        distance = -1
    else 
        distance = round(distance,0.001)
    end
    
    return result,distance
end

function send_data(localSerial, data)
-- This function sends data to the arduino board 
-- nil values will be replaced, as much as possible, with -1
-- it may take the following arguments
    -- single number (single proximity sensors)
    -- array of numbers (multiple proximity sensors)
    -- array of arrays (proximity sensor(s) + IMU)
    -- numbers will be sent to the serial port as a string in this format
    -- "s #### #### #### ..."

    if type(data) == "number" then
        data = {data}
    end    
    ind = table.getn(data)
    data_str = ""
    for i = 1,ind do
        if type(data[i]) == "number" then
            data_str = data_str.." "..data[i]
        elseif type(data[i]) == "table" then
            subdata = data[i]
            ind2 = table.getn(subdata)
            ind = ind + ind2 - 1
            for j = 1,ind2 do
                if type(subdata[j]) == "number" then
                    data_str = data_str.." "..subdata[j]
                elseif type(subdata[j]) == "nil" then
                    data_str = data_str.." ".."-1"
                    print("Attempting to send nil, sending -1 instead")
                else
                    data_str = data_str.." ".."-1"
                    print("unknown data type in subtable, sending -1 instead")
                end
            end
        elseif type(data[i]) == "string" then
            data_str = data[i]
        elseif type(data[i]) == "nil" then
            data_str = "-1"
            print("Attempting to send nil, sending -1 instead")
        else
            print("unknown data type")
        end
    end
    
    print("Sending: ".."s ".." "..data_str)
    data_str = "s ".." "..data_str..'\n'
    if localSerial ~= -1 then    
        charsSent = sim.serialSend(localSerial, data_str)
    end

end

function receive_data()
-- This function receives data from the arduino board 
-- The data sent from the arduino MUST BE a comma-separated string
-- terminated by a carriage & line return "\r\n"
-- "###,###,###,###,...\r\n"
-- Those numbers are then returned by this function as a table 
    -- {###,###,###,###,...}

    if serial ~= -1 then  
        str = sim.serialRead(serial,300,true,'\n',2)
    else 
        return nil
    end
    if str ~= nil then
        local token
        ctrl_val = {}
        cpt=0
        for token in string.gmatch(str, "[^,]+") do
            if type(tonumber(token))=='number' then
                --print(token)
                cpt = cpt+1            
                ctrl_val[cpt] = tonumber(token)
            end            
        end
        --if ctrl_val == nil or cpt ~= arduino_arg_number then
        if ctrl_val == nil then
            print('unexpected data length, check arduino_arg_number var')
            return nil
        end
    else 
        return nil
    end
    --print(ctrl_val)
    return ctrl_val
end

function set_servo(servoHandle,posCmd)
-- This function will actuate the RC Servo to reach the commanded position
-- Only commanded position in the -pi/2 to pi/2 range are allowed
-- servoHandle: Input argument must be the servo model base's Object Handle
-- posCmd: angle in radian from -pi/2 to pi/2
-- Function usage
    -- set_servo(servoHandle,servoPosition)
    
    if (sim.getObjectType(servoHandle)==sim.object_forcesensor_type) then
        temp = sim.getObjectChild(servoHandle,0)
        child1 = sim.getObjectChild(temp,0)
        if sim.getObjectType(child1)==sim.object_joint_type then
            servoHandle = child1            
        else
            child2 = sim.getObjectChild(temp,1)
            if sim.getObjectType(child2)==sim.object_joint_type then
                servoHandle = child2
            end
        end
    end
    
    if posCmd > 3.1416/2 then
        print('Commanded servo position out of range')
        posCmd = 3.141/2
    elseif posCmd < -3.1416/2 then
        print('Commanded servo position out of range')
        posCmd = -3.141/2
    end
    sim.setJointTargetPosition(servoHandle,posCmd)
end

function set_thrust(fanHandle,state,localThrottle)
-- This function will control the thrust fan with three arguments
-- fanHandle: must be the handle of the component model base
-- state: Activity state of the fan 
    -- state = 0    (fan is OFF)
    -- state = 1    (fan is ON)
-- Throttle: should be a number between 0 and 1. 
    -- Throttle = 0     (will turn off the fan)
    -- Throttle = 0.5   (will give partial thrust from the fan)
    -- Throttle = 1     (will give the maximum thrust from the fan)
-- Function usage
    -- set_thrust(fanHandle, state,throttle)
    
    if (sim.getObjectType(fanHandle)==sim.object_forcesensor_type) then
        fanHandle = sim.getObjectChild(fanHandle,0)
    end
    
    
    if localThrottle > 1 then
        print('Throttle out of range')
        localThrottle = 1
    elseif localThrottle < 0 then
        print('Throttle out of range')
        localThrottle = 0
        state = 0
    elseif localThrottle == 0 then
        state = 0
    elseif state == 0 then
        localThrottle = 0
    else 
        state = 1
    end
    
    sim.setUserParameter(fanHandle,'state',state)
    sim.setUserParameter(fanHandle,'throttle',localThrottle)
    
end

function set_lift(lift_fanBase, liftState, contactPatch)
-- This function will activate and deactivate the lift simulation
-- This is done by setting the appropriate physical properties on the main hovercraft body
-- liftState: Activity state of the fan 
    -- liftState = 0     (lift OFF) 
    -- liftState = 1     (lift ON) 
-- liftfan: must be the handle of the fan providing lift component model base 
-- contactPatch: must be the handle of the contact patch of your hovercraft 
-- Function usage
    -- set_lift(liftFan, liftState, contactPatch)
    
    if (sim.getObjectType(lift_fanBase)==sim.object_forcesensor_type) then
        lift_fanBase = sim.getObjectChild(lift_fanBase,0)
    end

    sim.setUserParameter(lift_fanBase,'throttle',1)
    sim.setUserParameter(lift_fanBase,'lift',1)

    if liftState == 1 and sim.getIntegerSignal('lift') == 0 then

        XYSize = getBoundingBoxXYSize(contactPatch)
        meanRadius = (XYSize[1] + XYSize[2]) / 2 / 2
        area = XYSize[1] * XYSize[2]
        COMlocation, COMDelta, mass = getCenterOfMass(contactPatch)
        print("COMlocation X: "..COMlocation[1].."; COMlocation Y: ".. COMlocation[2].."; COMlocation Z: ".. COMlocation[3].."; area: "..area.."; meanRadius: "..meanRadius)
        body_pressure = mass * 9.8 / area
        fan_pressure = sim.getUserParameter(lift_fanBase,"fanPressure")
        
        if body_pressure >= fan_pressure then
            friction = 0.1
        elseif body_pressure >= fan_pressure/1.25 then
            friction = -0.07/0.25 * (fan_pressure/body_pressure)  + 0.38
        elseif body_pressure >= fan_pressure/2.5 then
            friction = -0.02/1.25 * (fan_pressure/body_pressure)  + 0.05
        elseif body_pressure < fan_pressure/2.5 then
            friction = 0.01
        end
        print("body_pressure: "..body_pressure.."; fan_pressure: "..fan_pressure.."; friction:"..friction)

        if COMDelta <= 0.01*meanRadius then
            --Friction coef is untouched
        elseif COMDelta <= 0.5*meanRadius then
            friction = friction + (0.1-friction)/0.49 * (COMDelta/meanRadius-0.01)
        elseif COMDelta > 0.5*meanRadius then
            friction = 0.1
        end 
        print("COMDelta: "..COMDelta.."; meanRadius: "..meanRadius.."; friction:"..friction)

        sim.setUserParameter(lift_fanBase,'state',1)
        sim.setIntegerSignal('lift',1)
        
        sim.setEngineFloatParameter(sim.newton_body_staticfriction,contactPatch,friction)
        sim.setEngineFloatParameter(sim.newton_body_kineticfriction,contactPatch,friction)
        sim.resetDynamicObject(contactPatch)
        
    elseif liftState == 0 and sim.getIntegerSignal('lift') == 1 then
        sim.setUserParameter(lift_fanBase,'state',0)
        sim.setIntegerSignal('lift',0)
        
        sim.setEngineFloatParameter(sim.newton_body_staticfriction,contactPatch,0.2)
        sim.setEngineFloatParameter(sim.newton_body_kineticfriction,contactPatch,0.09)
        sim.resetDynamicObject(contactPatch)            
    end
end

function getBoundingBoxXYSize(obj)
    a, size1min = sim.getObjectFloatParameter(obj, 15)
    a, size2min = sim.getObjectFloatParameter(obj, 16)
    a, size3min = sim.getObjectFloatParameter(obj, 17)
    a, size1max = sim.getObjectFloatParameter(obj, 18)
    a, size2max = sim.getObjectFloatParameter(obj, 19)
    a, size3max = sim.getObjectFloatParameter(obj, 20)
    size1 = size1max-size1min
    size2 = size2max-size2min
    size3 = size3max-size3min
    sizes = {size1, size2, size3}
    minSize = math.min(size1,size2,size3)
    for i = 1,3 do
        if sizes[i] == minSize then
            min = i
        end
    end
    table.remove(sizes,min)
    return sizes
end

function getCenterOfMass(modelBase)
-- reference: https://forum.coppeliarobotics.com/viewtopic.php?t=1719
-- Function returns the CoM for a given model in this format
-- {{CoMX, CoMY, CoMZ},{deltaX, deltaY, deltaZ},totalMass}
-- First find all non-static shapes in our model:

    allNonStaticShapes={}
    allObjectsToExplore={modelBase}
    while (#allObjectsToExplore>0) do
        obj=allObjectsToExplore[1]
        table.remove(allObjectsToExplore,1)
        if (sim.getObjectType(obj)==sim.object_shape_type) then
            --print("object# "..obj)
            r,v=sim.getObjectInt32Parameter(obj,3003)
            if (v==0) then -- is the shape non-static?
                table.insert(allNonStaticShapes,obj)
            end
        end
        index=0
        while true do
            child=sim.getObjectChild(obj,index)
            if (child==-1) then
                break
            end
            table.insert(allObjectsToExplore,child)
            index=index+1
        end
    end

    -- Now compute the center of mass of our model (in absolute coordinates):

    mass,inertia,base_com=sim.getShapeMassAndInertia(modelBase,nil)
    miri={0,0,0}
    totalMass=0
    loc_com = {}
    for i=1,#allNonStaticShapes,1 do
        --print(sim.getObjectName(allNonStaticShapes[i]))
        mass,inertia,com=sim.getShapeMassAndInertia(allNonStaticShapes[i],nil)
        miri[1]=miri[1]+mass*com[1]
        miri[2]=miri[2]+mass*com[2]
        miri[3]=miri[3]+mass*com[3]
        totalMass=totalMass+mass
    end
    final_com = {}
    final_com[1]=miri[1]/totalMass
    final_com[2]=miri[2]/totalMass
    final_com[3]=miri[3]/totalMass

    delta = math.sqrt((final_com[1]-base_com[1])^2+(final_com[2]-base_com[2])^2)

    return final_com,delta,totalMass
end


function round(exact, quantum)
-- Rounding function
-- https://stackoverflow.com/questions/18313171/lua-rounding-numbers-and-then-truncate
    if type(exact) == "number" then
        local quant,frac = math.modf(exact/quantum)
        return quantum * (quant + (frac > 0.5 and 1 or 0))
    elseif type(exact) == "table" then
        out = {}
        for i = 1,table.getn(exact) do
            out[i] = round(exact[i], quantum)
        end
        return out
    else
        error("Unexpected type sent to round() function")
    end
end




function sysCall_cleanup()
    -- Put some clean-up code here
    if serial ~= -1 then
        sim.serialClose(serial) 
    else
        print('Your serial port was not correctly opened at simulation start')
    end
end
-- See the user manual or the available code snippets for additional callback functions and details
