%Moves the center of the grabber tool to the given location

%PARAMS: robot - serial port object
%       t - time taken to perform move (ms)
%       x,y,z - coordinates WRT base frame (cm) 
%       phi - angle between base x-y plane and final link (degrees)
%       w - width of tool gap (cm)

function[] = move(robot,t,x,y,z,phi,w)

[t1, t2, t3, t4] = calcAngles(x,y,z,phi); % calculate angles
setAngles(robot, t, t1, t2, t3, t4, w); %set angles

end

