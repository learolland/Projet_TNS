%% Etude  et  implémentation  de  la  technique  PSOLA
%%%% Analyse  de  F0  (demander  éventuellement le code  des  algorithmes  disponibles),  
%%%% segmentation  voisé  /  non  voisé,  analyse  des  pitch-marks (frontières  de  pseudo-période),  
%%%% pondération,  resynthèse, influence  de  la  fenêtre  de  pondération, 
%%%% de son positionnement dans la pseudo-période, conséquences spectrales du traitement, 
%%%% qualité du signal resynthétisé...

clear all;
close all;
[Signal, Fs] = audioread('101.wav');

%% Detection voisement
Ts = 1/Fs;
fenetre = floor(0.025/Ts); %nb d'echantillons pour avoir une pseudo-periode de 25ms
nb_fenetres = floor(length(Signal)/fenetre); %nb de fenetre de 25ms
plot_fenetre=zeros(length(Signal),1);
for k=1:length(plot_fenetre)
    if mod(k,fenetre)==0
        plot_fenetre(k)=0.2;
    end
end
% Multiplication de chaque échantillon avec son suivant => détection d'un
% passage à 0 si changement de signe
Signal_decal_1=circshift(Signal,1); %décalage du vecteur d'un ech
Signal_decal_1(1)=0;
Signal_mult = Signal.*Signal_decal_1; %multiplication terme à terme

Mat_Signal_mult = vec2mat(Signal_mult,fenetre)'; %chaque colonne correspond à une fenetre
s = sign(Mat_Signal_mult); 
for i = 1:nb_fenetres
    nb_zeros(i) = sum(s(:,i)==-1); %vecteurs nombre de zero pour chaque fenetre 
end

% figure(1);
% hist(nb_zeros,100);
% title('Histogramme de la répartition des zéros');

% plot(Signal); hold on;
% plot(plot_fenetre); hold off;

%% Seuil des fenêtres non voisées
Signal = Signal/(max(abs(Signal))*1.05); %normalisation des amplitudes

seuil = 38; % s
vect_seuil = nb_zeros<seuil;
vect_seuil = repelem(vect_seuil,fenetre);
vect_seuil = imresize(vect_seuil, [1,length(Signal)])';
Signal_seuil = Signal.*vect_seuil;

Signal_nv= Signal-Signal_seuil;
energie = abs(Signal_nv).^2;
energie_seuil = energie>0.0082;
Signal_nv_v = Signal_nv.*energie_seuil;

Signal_v = Signal_seuil+ Signal_nv_v;


figure(2);
plot(Signal); hold on;
plot(Signal_v); hold off;
title('Seuillage à 38 zeros des sons voisés et energie>0.0082');

