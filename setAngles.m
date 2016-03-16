% Send a command to the robot to assume the given angles
% PARAMS: robot - serial port object
%         time - time in which to perform move (ms)
%         t1 -> t4 - given angles 
%         width - gap between tool grabbers

function [] = setAngles(robot, time, t1, t2, t3, t4, width)
 
%theta1 cannot be centered about P1500 because robot is mounted too far
 %off center to be able to correct with PO command (range +-100usec)
 ch0 = (1455 - 9.9222 * t1);
 ch1 = (1500 + 8.2111 * t2); 
 ch2 = (1500 - 9.2444 * t3);
 ch3 = (1500 + 10 * t4);
 %width of zero corresponds to the gripper pads just barely touching
 %but not applying pressure
 ch4 = (2040 - 460.6 * width);
 
out = sprintf('#0P%3.3f T%3.3f #1P%3.3f #2P%3.3f #3P%3.3f #4P%3.3f' ...
    ,ch0,time,ch1,ch2,ch3,ch4);

fprintf(robot, out)
end