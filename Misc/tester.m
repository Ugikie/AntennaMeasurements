clear all;

AZDegInterval = -90:1:90;
numPoints = 201;
rollDegInterval = 0:1:360;
dataToWrite = {datestr(now)};
startFreq = 1000000;
stopFreq = 10000000;
VNAFreqPointsObj = 1e5 * round((startFreq:(stopFreq - startFreq) / (numPoints - 1):stopFreq) / 1e5);
for AZCurrentDegree = AZDegInterval
                
    %Calculate the current iteration of the loop
    [~,AZLoopIdx] = find(AZDegInterval == AZCurrentDegree);
    
    for rollCurrentDegree = rollDegInterval

        %Calculate the current iteration of the loop
        [~,rollLoopIdx] = find(rollDegInterval == rollCurrentDegree);
        
        SObj(:,1,rollLoopIdx) = VNAFreqPointsObj';
        SObj(:,2,rollLoopIdx) = AZCurrentDegree * ones(length(VNAFreqPointsObj),1);
        SObj(:,3,rollLoopIdx) = rollCurrentDegree * ones(length(VNAFreqPointsObj),1);
        SObj(:,4,rollLoopIdx) = (1+2*j) * ones(length(VNAFreqPointsObj),1);
    end
    
    dataToWrite = {dataToWrite{1:end} SObj};
end

dataToWrite