clear all; clc;


%measApp = measApp();


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
dataToWrite = {1};
x = readtable('newMeasurement_16:14:36.csv');
S11 = x.Var3;
azInterval = -90:5:90;
rollInterval = -90:5:90;

freqInterval = 1.00:10.00;

for j = 1:size(freqInterval,2)
    rollIntervalOnesMat = ones(size(rollInterval',1),1);
    currentFreqMat = freqInterval(j) * rollIntervalOnesMat;
    for i = 1:size(rollInterval',1)
        rollIntervalMat = rollInterval(i) * rollIntervalOnesMat;
        currentFreqCell(:,:,i) = [currentFreqMat rollIntervalMat azInterval' S11];
    end
    dataToWrite = {dataToWrite{1:end} currentFreqCell};
end

freqToInspect = 5.00;
% 
% for i = 1:size(dataToWrite,2)
%     S21ValFromData = 
% end
plot(dataToWrite{6}(:,3,1),20*log10(abs(dataToWrite{6}(:,4,1))),dataToWrite{6}(:,3,2),20.1*log10(abs(dataToWrite{6}(:,4,2))),dataToWrite{6}(:,3,3),20.2*log10(abs(dataToWrite{6}(:,4,3))))
