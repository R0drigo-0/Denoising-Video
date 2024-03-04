clearvars
close all
clc

MAX_FRAMES = 200;
goodLight = VideoReader("Good_Light.mp4");
badLight = VideoReader("Bad_Light.mp4");

trimGoodLight = VideoWriter("Trim_Good_Light.mp4", "MPEG-4");
trimBadLight = VideoWriter("Trim_Bad_Light.mp4", "MPEG-4");
lowNoiseGoodLight = VideoWriter("Low_Noise_Good_Light.mp4", "MPEG-4");
lowNoiseBadLight = VideoWriter("Low_Noise_Bad_Light.mp4", "MPEG-4");

open(trimGoodLight);
open(trimBadLight);
open(lowNoiseGoodLight);
open(lowNoiseBadLight);

for i = 1:min(MAX_FRAMES, min(goodLight.NumFrames, badLight.NumFrames))
    frameGood = readFrame(goodLight);
    frameBad = readFrame(badLight);
    
    grayscaleFrameGood = rgb2gray(frameGood);
    grayscaleFrameBad = rgb2gray(frameBad);
    
    if i <= 100
        lowNoiseFrameGood = wiener2(grayscaleFrameGood);
        lowNoiseFrameBad = wiener2(grayscaleFrameBad);
        if i == 1
            imwrite(lowNoiseFrameGood, "frame1GoodLow.bmp");
            imwrite(lowNoiseFrameBad, "frame1BadLow.bmp");
        end 
        writeVideo(lowNoiseGoodLight, lowNoiseFrameGood);
        writeVideo(lowNoiseBadLight, lowNoiseFrameBad);
    else
        writeVideo(trimGoodLight, grayscaleFrameGood);
        writeVideo(trimBadLight, grayscaleFrameBad);
    end

    if i == 101
        imFrame101Good = grayscaleFrameGood;
        imFrame101Bad = grayscaleFrameBad;
        close(lowNoiseGoodLight);
        close(lowNoiseBadLight);
    end
end

close(trimGoodLight);
close(trimBadLight);

imwrite(imFrame101Good, "frame101Good.bmp");
imwrite(imFrame101Bad, "frame101Bad.bmp");
%%
P_signal_a1 = max(imFrame101Good(:));
P_signal_a2 = max(imFrame101Bad(:));

sumGoodVideo = zeros(size(imFrame101Good));
sumBadVideo = zeros(size(imFrame101Bad));
tmp = 1;

goodLightReader = VideoReader("Trim_Good_Light.mp4");
badLightReader = VideoReader("Trim_Bad_Light.mp4");
while tmp < 100
    sumGoodVideo = sumGoodVideo + double(readFrame(goodLightReader));
    sumBadVideo = sumBadVideo + double(readFrame(badLightReader));
    tmp = tmp + 1;
end
P_signal_b1 = max(sumGoodVideo, 1);
P_signal_b2 = max(sumBadVideo, 1);

P_noise_a1 = std(double(imFrame101Good(:)));
P_noise_a2 = std(double(imFrame101Bad(:)));

P_noise_b1 = std(double(sumGoodVideo));
P_noise_b2 = std(double(sumBadVideo));

SNR_a1 = 10 * log10(double(P_signal_a1) / double(P_noise_a1));
SNR_a2 = 10 * log10(double(P_signal_a2) / double(P_noise_a2));

SNR_b1 = mean(mean(mean(10 * log10(double(P_signal_b1) ./ double(P_noise_b1)))));
SNR_b2 = mean(mean(mean(10 * log10(double(P_signal_b2) ./ double(P_noise_b2)))));

%Valores mas altos mejor, indican mejor señal y menos ruido
fprintf("SNR good light frame 101 (a1): %.2f dB\n", SNR_a1);
fprintf("SNR bad light frame 101 (a2): %.2f dB\n", SNR_a2);
fprintf("SNR good light 100 frames (b1): %.2f dB\n", SNR_b1);
fprintf("SNR bad light 100 frames (b2): %.2f dB\n", SNR_b2);