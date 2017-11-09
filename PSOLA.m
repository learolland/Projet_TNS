%% Etude  et  impl�mentation  de  la  technique  PSOLA
%%%% Analyse  de  F0  (demander  �ventuellement le code  des  algorithmes  disponibles),  
%%%% segmentation  vois�  /  non  vois�,  analyse  des  pitch-marks (fronti�res  de  pseudo-p�riode),  
%%%% pond�ration,  resynth�se, influence  de  la  fen�tre  de  pond�ration, 
%%%% de son positionnement dans la pseudo-p�riode, cons�quences spectrales du traitement, 
%%%% qualit� du signal resynth�tis�...

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
% Multiplication de chaque �chantillon avec son suivant => d�tection d'un
% passage � 0 si changement de signe
Signal_decal_1=circshift(Signal,1); %d�calage du vecteur d'un ech
Signal_decal_1(1)=0;
Signal_mult = Signal.*Signal_decal_1; %multiplication terme � terme

Mat_Signal_mult = vec2mat(Signal_mult,fenetre)'; %chaque colonne correspond � une fenetre
s = sign(Mat_Signal_mult); 
for i = 1:nb_fenetres
    nb_zeros(i) = sum(s(:,i)==-1); %vecteurs nombre de zero pour chaque fenetre 
end

% figure(1);
% hist(nb_zeros,100);
% title('Histogramme de la r�partition des z�ros');

% plot(Signal); hold on;
% plot(plot_fenetre); hold off;

%% Seuil des fen�tres non vois�es
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
title('Seuillage � 38 zeros des sons vois�s et energie>0.0082');

