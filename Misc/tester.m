clear all;

AZDegInterval = -90:1:90;
numPoints = 201;
rollDegInterval = 0:1:0;
dataToWrite = {datestr(now)};
startFreq = 1000000000;
stopFreq = 10000000000;
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

measApp.ExportDataAppObj.DataTable.Data = {false,'Freq','AZ','Roll','S21'};
measApp.ExportDataAppObj.DataTable.Data(1:201,1) = {false};
measApp.ExportDataAppObj.DataTable.Data(2:201,3) = {-90};
measApp.ExportDataAppObj.DataTable.Data(2:201,4) = {measApp.DataToWriteObj{2}(1,3,1)};
for i = 1:length(measApp.DataToWriteObj{2})
    measApp.ExportDataAppObj.DataTable.Data{i+1,2} = freqNums(i);
    drawnow();
end