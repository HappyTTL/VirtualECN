clear all;
clc

Features1 = importdata('5features_dataSet_NewReno_S1_1.txt');
Features2 = importdata('5features_dataSet_Cubic_S1_1.txt');
Features3 = importdata('5features_dataSet_NewReno_S2_1.txt');
Features4 = importdata('5features_dataSet_Cubic_S2_1.txt');
Features5 = importdata('5features_dataSet_Cubic_S3_1.txt');
Features6 = importdata('5features_dataSet_NewReno_S3_1.txt');
% Features7 = importdata('5features_dataSet_NewReno_S1_OnOff_Det_1.txt');
% Features8 = importdata('5features_dataSet_NewReno_S1_OnOff_Exp_1.txt');
% Features9 = importdata('5features_dataSet_Cubic_S1_OnOff_Exp_1.txt');

Features = [Features1; Features2; Features3; Features4; Features5; Features6];

Sample = Features(:,6);
Congestion = Features(find(Sample == 1),:);
NoCongestion = Features(find(Sample == 0),:);

figure(1);
cdfplot(Congestion(:,5));
% scatter(Congestion(:,4), Congestion(:,5) ,'*', 'r');
hold on;
% scatter(NoCongestion(:,4), NoCongestion(:,5), 'o', 'g');
cdfplot(NoCongestion(:,5));