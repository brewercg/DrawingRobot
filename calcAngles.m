% Use inverse kinematice equations to calculate 
% theta1-theta4 for a given tool position and orientation

% PARAMS: x,y,z - coordinates WRT base frame (cm)
%         phi - tool angle WRT base x-y plane (mounting board)
% LINK MEASURED LENGTHS (cm): L1 = 7 , L2 = 15, L3 = 18.5, L4 = 7.25
function[t1 t2 t3 t4] = calcAngles(x,y,z,phi)

%theta 1 depends solely on x and y coordinates
t1 = atand(y/x);

%calculate position of O3 relative to O1 in plane of arm
alpha = sqrt(x^2 + y^2) - 7.25*cosd(phi); % "x" coordinate in plane
beta  = z - 7 + 7.25*sind(phi); % "y" coordinate in plane

% (L1)^2 + (L2)^2 = 567.25 ; 2*L1*L2 = 555
D = (alpha^2 + beta^2 - 567.25) / 555;

% Apply inverse kinematic equations for 2-link system
t3 = atan2d(sqrt(1 - D^2), D);
t2 = atan2d(beta, alpha) + atan2d( 18.5*sind(t3) , (15 + 18.5*cosd(t3)));

%Correction factors: Due to difference of where zero degrees is
%defined between equations and robot axes. 
t2 = t2 - 90;
t3 = 90 - t3;

% Calculate theta4 such that the tool is oriented with an angle of 
% phi relative to the base x-y plane
t4 = -t2 -t3 - phi;

end
