function speedChange_callback(ui,id,newVal)
    speed=minMaxSpeed[1]+(minMaxSpeed[2]-minMaxSpeed[1])*newVal/100
end

function sysCall_init()
    --Section 1 ***********************
    serialPortNum = 9
    baudrate=115200
    --Open serial port communication
    portNumber="/dev/cu.usbmodem14101"
    print(portNumber.."@BAUD: "..baudrate)
    serial = sim.serialOpen(portNumber,baudrate)
    print("serial Handle: "..serial)
    --***********************

    -- This is executed exactly once, the first time this script is executed
    bubbleRobBase=sim.getObjectAssociatedWithScript(sim.handle_self) -- this is bubbleRob's handle
    leftMotor=sim.getObjectHandle("bubbleRob_leftMotor") -- Handle of the left motor
    rightMotor=sim.getObjectHandle("bubbleRob_rightMotor") -- Handle of the right motor
    noseSensor=sim.getObjectHandle("bubbleRob_sensingNose") -- Handle of the proximity sensor
    minMaxSpeed={50*math.pi/180,300*math.pi/180} -- Min and max speeds for each motor
    backUntilTime=-1 -- Tells whether bubbleRob is in forward or backward mode
    -- Create the custom UI:
        xml = '<ui title="'..sim.getObjectName(bubbleRobBase)..' speed" closeable="false" resizeable="false" activate="false">'..[[
        <hslider minimum="0" maximum="100" onchange="speedChange_callback" id="1"/>
        <label text="" style="* {margin-left: 300px;}"/>
        </ui>
        ]]
    ui=simUI.create(xml)
    speed=(minMaxSpeed[1]+minMaxSpeed[2])*0.5
    simUI.setSliderValue(ui,1,100*(speed-minMaxSpeed[1])/(minMaxSpeed[2]-minMaxSpeed[1]))
end


function sysCall_sensing()
    
    result=sim.readProximitySensor(noseSensor) -- Read the proximity sensor
    
    if result > 0 then
        print("Obstacle detected")
    end
    -- If we detected something (1), we set the backward mode:

    --Section 2***********************
    simTime = round(sim.getSimulationTime(), 0.01)
    roundSpeed = round(speed, 0.01)
    data = {simTime, result, roundSpeed}
    send_data(serial, data)
    --***********************
end

function sysCall_actuation()
    
    --Section 3***********************    
    receivedData = receive_data(serial)
    print(receivedData)
    if receivedData == nil then
        return
    end
    
    leftSpeed = receivedData[3]
    rightSpeed = receivedData[4]
    
    if type(leftSpeed) == "number" and type(rightSpeed) == "number" then
        sim.setJointTargetVelocity(leftMotor,leftSpeed)
        sim.setJointTargetVelocity(rightMotor,rightSpeed)
    end
    
    
    
    --***********************    
    
end

function sysCall_cleanup()

sim.serialClose(serial)
	simUI.destroy(ui)
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

function send_data(localSerial, data)
-- This function sends data to the arduino board 
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
                data_str = data_str.." "..subdata[j]
            end
        elseif type(data[i]) == "string" then
            data_str = data[i]
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

function receive_data(localSerial)
-- This function receives data from the arduino board 
-- The data sent from the arduino MUST BE a comma-separated string
-- "###,###,###,###,..."
-- Those numbers are then returned by this function as a table 
    -- {###,###,###,###,...}

    if localSerial ~= -1 then  
        str = sim.serialRead(localSerial,300,false,'\n',5)
        print(str)
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