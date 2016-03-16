%open serial port to robot
    Rob = serial('com1','BaudRate',115200,'DataBits',8,'StopBits',1);
    fopen(Rob); % connects port object to device
    set(Rob,'Terminator','CR');

%center robot prior to routine
    fprintf(Rob,'#0 P1500 T2000 #1 P1500 #2 P1500 #3 P1500 #4 P1500');
    pause(2.5)
    
%set calibration offsets
    setOffsets(Rob)
   
allCenter(Rob)