% California State University, Northridge
% Brad Jackson, Ph.D.
% Feb. 9, 2020

% This script connects to the HP 8720B VNA using the Prologix GPIB to USB
% adaptor and reads the data of all four two-port S-parametes. After 
% reading the data it plots the log magnitudes and saves the data as a .s2p
% Touchstone file.

clc; clear all; close all;

% Specify the desired output file name
outputfile = input('Desired output filename: ','s');

% Specify the COM port below. You will need to select this based on your 
% computer's configuration. To get a list of serial ports use the command:
% seriallist
% e.g., COMport = 'COM1';
COMport = '/dev/ttyUSB0';

% Remove the output file extension if there is one
if length(outputfile) > 4
    if strcmp(outputfile(end-3:end),'.s1p') || strcmp(outputfile(end-3:end),'.s2p')
        outputfile = outputfile(1:end-4);
    end
end

% Check to see if serial port is already open and if so, close it
if ~isempty(instrfind)
    fclose(instrfind);
    delete(instrfind);
end

% Specify the virtual serial port created by USB driver. You will need to
% update this based on your computer's configuration 
% To get a list of serial ports use the command: seriallist
% e.g., vna = serial('COM1');
vna = serial(COMport);

% Prologix Controller 4.2 requires CR as command terminator, LF is
% optional. The controller terminates internal query responses with CR and
% LF. Responses from the instrument are passed through as is. (See Prologix
% Controller Manual)
vna.Terminator = 'CR/LF';

% Reduce the timeout from the default 10 seconds to speed things up
vna.Timeout = 0.5;

% Set input buffer to be large enough for trace data to be transferred
% The largest data set is 1601 points and this requires about 100 kB
vna.InputBufferSize = 100000;

% =========================================================================
% Method #1 uses fgets to read controller response. Since the Prologix
% controller always terminates internal query responses with CR/LF which is
% same as the currently specified serial port terminator, this method will
% work fine.
% =========================================================================

% Open virtual serial port
fopen(vna);

warning('off','MATLAB:serial:fread:unsuccessfulRead');

% Configure as Controller (++mode 1), instrument address #, and with
% read-after-write (++auto 1) enabled
fprintf(vna, '++mode 1');
fprintf(vna, '++addr 16');
fprintf(vna, '++auto 1');
fprintf(vna, '++eoi 0');

% Read the start/stop frequencies and number of points from the VNA:
fprintf(vna, 'STAR?');
startFreq = char(fread(vna, 30))';
startFreq = str2num(startFreq(1:24)); %Question for jackson: is this going to be replaced by the start and stop frequencies that the user wants to use as their span?

fprintf(vna, 'STOP?');
stopFreq = char(fread(vna, 30))';
stopFreq = str2num(stopFreq(1:24));

fprintf(vna, 'POIN1');
numPoints = char(fread(vna, 30))';
numPoints = 1;

fprintf(vna, 'SCAL?');
SCAL = char(fread(vna, 30))';
SCAL = str2num(SCAL(1:24));

fprintf(vna, 'REFP?');
REFP = char(fread(vna, 30))';
REFP = str2num(REFP(1:24));

fprintf(vna, 'REFV?');
REFV = char(fread(vna, 30))';
REFV = str2num(REFV(1:24));

% Compute the expected frequency points from the VNA. The 8720B has a 100
% KHz frequency resolution, so round to this.
freq = 1e5*round((startFreq:(stopFreq-startFreq + 1)/(numPoints-1):stopFreq)/1e5);

% Set the output data format
fprintf(vna, 'FORM4');

% Increase the timeout to give enough time for data transfer
% This is based on the number of points set on the VNA
% The following emperical formula is approximate
vna.Timeout = ceil(numPoints/100*0.5);

Snames = ['S11';'S21'];

for n = 1:length(Snames(:,1))##
    fprintf(vna,Snames(n,:))
    pause(2);
        
    % Perform a single sweep and pause to give time for a single sweep to 
    % complete. This may need to be adjusted based on the frequency span, 
    % number of points, IF bandwidth, and averaging
    fprintf(vna, 'SING');
    pause(4);

    % Output the data
    fprintf('\n%s %s%s','Transferring', Snames(n,:), '...')
    fprintf(vna, 'OUTPDATA');

    dataTran = char(fread(vna))';
    fprintf('done.\n')

    % Convert character data to numbers
    dataNums = textscan(dataTran,'%f%f','Delimiter',',');

    S(:,n) = dataNums{1} + j*dataNums{2};

end
newS(2,:) = S(1,:)
% Set to sweep continuously
fprintf(vna, 'CONT');

fclose(vna);

% Make S12 and S22 zero in the s2p file (they are converted to log so ones
% here will make them zero in the file)
S(:,3) = ones(length(S(:,1)),1);
S(:,4) = ones(length(S(:,1)),1);

subplot(1,2,1)
plot(freq/1e9,20*log10(abs(S(:,1))),'-b','linewidth',2);
hold on
plot([freq(1) freq(end)]/1e9,[0 0],'-r','linewidth',2);
xlabel('Frequency (GHz)');
ylabel('|S_{11}| (dB)');
ylim([-SCAL*REFP+REFV SCAL*(10-REFP)+REFV])
yticks((-round(SCAL)*REFP+REFV):round(SCAL):(round(SCAL)*(10-REFP)+REFV))
set(gca,'FontSize', 14);
grid on
box on

subplot(1,2,2)
plot(freq/1e9,20*log10(abs(S(:,3))),'-b','linewidth',2);
hold on
plot([freq(1) freq(end)]/1e9,[0 0],'-r','linewidth',2);
xlabel('Frequency (GHz)');
ylabel('|S_{21}| (dB)');
ylim([-SCAL*REFP+REFV SCAL*(10-REFP)+REFV])
yticks((-round(SCAL)*REFP+REFV):round(SCAL):(round(SCAL)*(10-REFP)+REFV))
set(gca,'FontSize', 14);
grid on
box on

set(gcf, 'Position', [300, 150, 900, 400]);

% Reshape the data to conform with Matlab's rfwrite function 2x2x#freqs
Sparams = reshape(transpose(S),2,2,numPoints);

% Configure the PDF output file
set(gca,'units','centimeters');
width = 25;
height = 10;
set(gcf, 'PaperUnits','centimeters');
set(gcf, 'PaperSize', [width height]);
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperPosition',[0 0 width height]);

% Write the PDF file to the current directory (change the file name as
% desired)
print(gcf,strcat(outputfile,'.pdf'),'-dpdf','-r300')

% Write the .s2p file(change the file name as desired)
rfwrite(Sparams, freq', strcat(outputfile,'.s2p'),'Format','DB','FrequencyUnit', 'Hz');

% Open the .s2p file and read all of the contents
fid = fopen(strcat(outputfile,'.s2p'),'r');
s2p = textscan(fid,'%s','Delimiter','\n');
fclose(fid);

% Comments for the s2p file
VNAmodel = 'HP 8752C Vector Network Analyzer';
dateCreated = ['Date: ' datestr(datetime)];
SparamComment = ['S-Parameter: S11, S21'];
startFreqComment = ['Start Frequency: ' num2str(startFreq/1e6) ' MHz'];
stopFreqComment = ['Stop Frequency: ' num2str(stopFreq/1e6) ' MHz'];
numPointsComment = ['Number of Points: ' num2str(numPoints)];

comments = {VNAmodel; startFreqComment; SparamComment; stopFreqComment; numPointsComment; dateCreated};

% Add the ! to the beginning of the comments to conform with the
% Touchstone .s2p file format
for c = 1:length(comments)
    comments{c} = ['! ' comments{c}];
end

% Add the comments from the .csv file to the .s2p file
s2p = [s2p{1}(1);comments;s2p{1}(2:end)];

% Open the file for writing, which erases its contents and then write
% the data with comments included to the .s2p file
fid = fopen(strcat(outputfile,'.s2p'),'w');
fprintf(fid,'%s\n',s2p{:});
fclose(fid);

fprintf('\n%s\n  %s\n  %s\n','Files written:',strcat(pwd,'/',outputfile,'.s2p'),strcat(pwd,'/',outputfile,'.pdf'))

