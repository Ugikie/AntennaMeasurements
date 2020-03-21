clear all; clc;


measApp = measApp();

%Use this for testing creating a data structure containing 
%{freqIntervalStart ... freqIntervalStop}
%where freqIntervalStart is a cell containing a 3D matrix of
%[degIntervalAZStart  S21]
%| .                   . |
%| .                   . |
%| .                   . |
%[degIntervalAZStop   S21]
%And the third dimention, is the degInterval for the Roll
%startFreqMat = [degInterval' S11]  
%startFreqMat(:,:,2) = [degInterval' 2*S11]
%startFreqMat(:,:,3) = [degInterval' 3*S11]
%dataToWrite = {startFreqMat startFreqMat}

% dataToWrite = {datestr(now)};
% x = readtable('newMeasurement_16:14:36.csv');
% S11 = x.Var3;
% azInterval = -90:5:90;
% rollInterval = -90:5:90;
% 
% freqInterval = 1.00:0.5:10.00;
% 
% for j = 1:size(freqInterval,2)
%     rollIntervalOnesMat = ones(size(rollInterval',1),1);
%     currentFreqMat = freqInterval(j) * rollIntervalOnesMat;
%     for i = 1:size(rollInterval',1)
%         rollIntervalMat = rollInterval(i) * rollIntervalOnesMat;
%         currentFreqCell(:,:,i) = [currentFreqMat rollIntervalMat azInterval' S11];
%     end
%     dataToWrite = {dataToWrite{1:end} currentFreqCell};
% end



% for freq = freqInterval
%     [~,idx] = find(freqInterval == freq);
%     varName = [num2str(freqInterval(idx)) ' GHz'];
%     
%     nccreate('data.nc',varName,'Dimensions', {'x',size(dataToWrite{2},1),'y',size(dataToWrite{2},2),'z',size(dataToWrite{2},3)});
%     ncwrite('data.nc',varName,dataToWrite{2},[1 1 1]);
% end
% 
% ncdisp('data.nc');


%Turns dataToWrite into a table for writing in a csv file.
%T = cell2table(dataToWrite(1:end,:));

% Write the table to a CSV file
%writetable(T,'myDataFile.csv')




freqToInspect = 5.00;
% 
% for i = 1:size(dataToWrite,2)
%     S21ValFromData = 
% end


% hold on
% for i = 1:size(dataToWrite{6},3)
%     plot(dataToWrite{6}(:,3,i),20*log10(abs(dataToWrite{6}(:,4,i))))
% end

