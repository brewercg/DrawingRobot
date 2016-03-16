function[paths] = drawPaths(robot)

paths = findPaths;
paths = double(paths);
paths = paths ./ 17; %convert from pixels to cm

paths(:, 1) = paths(:, 1) - 12.5; %shift y coords 
paths(:, 2) = paths(:, 2) + 14; %shift x coords down

allCenter(robot);

for i = 1 : length(paths) - 1

      if [paths(i, 1), paths(i,2)] == [-12.5, 14]
          
          %pick up the pen between paths
          move(robot, 1000, paths(i-1, 2), paths(i-1, 1), 12, 0, .2);
          pause(1);
          
          %move to point above start of next path
          move(robot, 3000, paths(i+1, 2), paths(i+1, 1), 12, 0, .2);
          pause(3);
          
          %put the pen back down at beginning of next path
          move(robot, 1000, paths(i+1, 2), paths(i+1, 1), 9.5, 0, .2);
          pause(1);
          continue;
      end
    
      if i == 1
          %move to point above starting point
          move(robot, 1000, paths(i, 2), paths(i, 1), 12, 0, .2);
          pause(1);
          
          %put the pen down
          move(robot, 1000, paths(i, 2), paths(i, 1), 9.5, 0, .2);
          pause(1);
      end
          
    %calculate time required to move to next point
    yDist = abs(paths(i,1) - paths(i+1, 1));
    xDist = abs(paths(i,2) - paths(i+1, 2));
    dist = sqrt(xDist^2 + yDist^2);
    time = dist * 500; %move 1cm in 500ms
    
    %move to next point
    move(robot, time, paths(i, 2), paths(i, 1), 9.5, 0, .2);
    pause(time/1000);
end

allCenter(robot);



