o% ========================================================================
% Antenne Patch Microstrip – 2.4 GHz
% Auteur : Ghassan (gg2574) | Date : 29-Jan-2026
% ========================================================================
clear; close all; clc;

%% === 1. Paramètres cibles ===
f0 = 2.4e9;          % Fréquence cible
h_sub = 0.0016;      % Épaisseur substrat (1.6 mm)
er = 4.65;           % εr ajusté à 4.65 (FR4 typique)

%% === 2. Calcul précis de la longueur du patch ===
c = 3e8;
Leff = c / (2 * f0 * sqrt(er));  % Longueur effective théorique

% Résolution itérative pour L (formule Hammerstad)
L = Leff * 0.92;  % estimation initiale
for i = 1:15
    delta_L = 0.412 * h_sub * ((er + 0.3)*(L/h_sub + 0.264)) / ((er - 0.258)*(L/h_sub + 0.8));
    L_new = Leff - 2*delta_L;
    if abs(L_new - L)/L < 1e-6, break; end
    L = L_new;
end

% Correction empirique pour atteindre exactement 2.4 GHz
L = L - 0.00045 - 0.00009 - 0.000031;

%% === 3. Création de l'antenne (Antenna Toolbox) ===
feed_x = 0.0075;
antenna = patchMicrostrip(...
    'Length', L,...
    'Width', L,...
    'GroundPlaneLength', L + 0.012,...
    'GroundPlaneWidth', L + 0.012,...
    'FeedOffset', [feed_x, 0],...
    'Substrate', dielectric('EpsilonR', er, 'Thickness', h_sub, 'Name', 'FR4')...
);

fprintf('Patch length: %.2f mm | Target: 2.4 GHz\n', L*1e3);

%% === 4. Maillage COARSE pour S11 (rapide) ===
mesh(antenna, 'MaxEdgeLength', 0.005);

%% === 5. Simulation S11 ===
freq_s11 = linspace(2.3e9, 2.5e9, 51);
s11 = sparameters(antenna, freq_s11);
s11_dB = squeeze(db(s11.Parameters(1,1,:)));  % prendre uniquement S11

[~, idx_min] = min(s11_dB);
f_res = freq_s11(idx_min);

%% === 6. Maillage FIN pour rayonnement ===
mesh(antenna, 'MaxEdgeLength', 0.002);

%% === 7. Calcul Directivity ===
[~, ~, Dmax] = pattern(antenna, f0, 'Type', 'directivity');

%% === 8. Bandwidth (-10 dB) ===
idx_bw = find(s11_dB <= -10);
if ~isempty(idx_bw)
    BW = freq_s11(idx_bw(end)) - freq_s11(idx_bw(1));
else
    BW = NaN;
end

%% === 9. Résultats en console ===
fprintf('\n=== RESULTATS ===\n');
fprintf('Resonance: %.3f GHz | S11: %.2f dB\n', f_res/1e9, s11_dB(idx_min));
fprintf('Directivité: %.2f dBi\n', Dmax);
if ~isnan(BW)
    fprintf('Bandwidth (-10 dB): %.1f MHz\n', BW/1e6);
else
    fprintf('Bandwidth: < resolution\n');
end

%% === 10. FIGURE 1: Géométrie 3D ===
figure('Name','Fig 1: Geometry','NumberTitle','off','Color','k');
show(antenna);
title('Antenna Geometry','Color','w');

%% === 11. FIGURE 2: S11 vs Frequency ===
figure('Name','Fig 2: |S11| vs Frequency','NumberTitle','off','Color','k');
plot(freq_s11/1e9, s11_dB, 'LineWidth', 1.8,'Color','c'); hold on;  % cyan line for visibility
yline(-10, '--r', '-10 dB');
plot(f_res/1e9, s11_dB(idx_min), 'ro', 'MarkerSize',8,'LineWidth',2);
xlabel('Frequency (GHz)','Color','w');
ylabel('|S_{11}| (dB)','Color','w');
title('|S_{11}| vs Frequency','Color','w');
grid on; set(gca,'Color','k','XColor','w','YColor','w','GridColor','w');

%% === 12. FIGURE 3: Impédance + Plan de Smith ===
freq_imp = linspace(2.3e9, 2.5e9, 101);
Zin = impedance(antenna, freq_imp);

figure('Name','Fig 3: Impedance & Smith Chart','NumberTitle','off','Color','k');
subplot(2,1,1);
plot(freq_imp/1e9, real(Zin), 'b', 'LineWidth',1.2); hold on;
plot(freq_imp/1e9, imag(Zin), 'r--','LineWidth',1.2);
xlabel('Frequency (GHz)','Color','w'); ylabel('Impedance (\Omega)','Color','w');
legend('R','X','Location','best'); grid on; title('Input Impedance','Color','w');
set(gca,'Color','k','XColor','w','YColor','w','GridColor','w');

subplot(2,1,2);
smithplot(s11);
set(gca,'Color','k'); 
set(gcf,'Color','k');

%% === 13 à 17. Rayonnement, E/H plane, Directivity, Gain, Courant ===
figure('Name','Fig 4: 3D Radiation Pattern','NumberTitle','off','Color','k'); 
pattern(antenna,f0); title('3D Radiation Pattern','Color','w');

figure('Name','Fig 5a: E-plane','NumberTitle','off','Color','k'); 
pattern(antenna,f0,0:2:360,90,'Type','directivity'); title('E-plane (phi=0°)','Color','w');

figure('Name','Fig 5b: H-plane','NumberTitle','off','Color','k'); 
pattern(antenna,f0,0:2:360,0,'Type','directivity'); title('H-plane (phi=90°)','Color','w');

figure('Name','Fig 6: Directivity','NumberTitle','off','Color','k'); 
pattern(antenna,f0,'Type','directivity'); title(sprintf('Directivity: %.2f dBi', Dmax),'Color','w');

figure('Name','Fig 7: Gain','NumberTitle','off','Color','k'); 
pattern(antenna,f0,'Type','gain'); title('Gain (with losses)','Color','w');

figure('Name','Fig 8: Surface Current','NumberTitle','off','Color','k'); 
current(antenna,f0); title('Surface Current at 2.4 GHz','Color','w');
