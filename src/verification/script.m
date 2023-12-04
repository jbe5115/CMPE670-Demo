%clear existing variables, close any figure windows, clear the command line
close all
clear all
clc

% Read image
filename = 'mario.pgm'; %CHANGEME
im_orig = imread(filename);
numRows = 64;
numCols = 64;
imgSize = 64 * 64;

% Clear any existing serial ports
delete(instrfind);

% Create the sender serial port
% NOTE: THIS SERIAL PORT MAY NEED TO BE CHANGED!!
serialPort1 = serial('COM11', 'BaudRate', 115200, 'DataBits', 8, 'Parity', ...
    'none', 'StopBit', 1, 'OutputBufferSize', imgSize, 'InputBufferSize', imgSize);

% Create the receiver serial port
% NOTE: THIS SERIAL PORT MAY NEED TO BE CHANGED!!
serialPort2 = serial('COM9', 'BaudRate', 115200, 'DataBits', 8, 'Parity', ...
    'none', 'StopBit', 1, 'OutputBufferSize', imgSize, 'InputBufferSize', imgSize);

% open the sender serial port for reading/writing
fopen(serialPort1);

% open the receiver serial port for reading/writing
fopen(serialPort2);

% send image to the sender
fprintf('Sending image data to sender FPGA... '); tic;
fwrite(serialPort1, im_orig(:), 'uint8'); toc;

% read back image from receiver
fprintf('Reading image data from receiver FPGA... '); tic;
im_final = fread(serialPort2, imgSize, 'uint8'); toc;

% Reshape
im_final = reshape(im_final, [numRows numCols]);

% close the serial ports
fclose(serialPort1);
fclose(serialPort2);

% Analyze and display results
if isequal(im_orig, im_final)
    fprintf('SUCCESS!\n');
    subplot(1,2,1);
    imshow(mat2gray(im_orig));
    title('Original');
    subplot(1,2,2);
    imshow(mat2gray(im_final));
    title('Received');
else
    fprintf('FAILURE!\n');
    subplot(1,2,1);
    imshow(mat2gray(im_orig));
    title('Original');
    subplot(1,2,2);
    imshow(mat2gray(im_final));
    title('Received');
end
