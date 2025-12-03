clear variables %efface toutes les variables de la mémoire
close all %ferme toutes les fenêtres de figure graphiques
clc %efface le contenu de la console

pos = [1 1]; %initialisation des coordonnées de la souris à x=1 et y=1
c = [0 0]; %définition des coorodnnées du centre du cercle à x=0 et y=0
r = 20; %définition du rayon du cercle
k_cst = 2; %définition de la raideur de base à 2N/m
case_mode = 1; %définition de la variable permettant le choix du mode de raideur, 0 pour raideur constante (k_cst) et 1 pour raideur variable (k_var)

figure_width = 500; %définition de la hauteur de la fenêtre souahitée
figure_height = 500; %définition de la largeur de la fenêtre souhaitée
screen_size = get(0, 'screensize'); %obtention de la taille de l'écran, renvoie [1, 1, ScreenWidth, ScreenHeight]
screen_width = screen_size(3);
screen_height = screen_size(4);
left_position = (screen_width / 2) - (figure_width / 2); %calcul la position centrée
bottom_position = (screen_height / 2) - (figure_height / 2);
centered_position = [left_position, bottom_position, figure_width, figure_height]; %vecteur de position

S.fh = figure( 'units','pixels','position',centered_position,'name','TP 1 Haptic course','numbertitle','off'); %création et configuration de la fenêtre principale
S.case_mode = case_mode; %enregistrer la valeur initiale dans la structure S
S.ax = axes('Units', 'normalized', 'Position', [0.05 0.05 0.90 0.85]); %définit la zone de tracé (axes) dans la figure
S.btn = uicontrol('Style', 'pushbutton', 'String', 'Changer de Mode (k)', 'Units', 'normalized', 'Position', [0.70 0.92 0.25 0.06], 'Callback', @switch_mode_callback); %bouton pour basculer le mode et fonction de rappel
mode_str = sprintf('Mode: %d (%s)', case_mode, get_mode_name(case_mode)); %texte affichant le mode actuel
S.mode_text = uicontrol('Style', 'text', 'String', mode_str, 'Units', 'normalized', 'Position', [0.05 0.92 0.40 0.06], 'HorizontalAlignment', 'left', 'BackgroundColor', get(S.fh, 'Color')); 
guidata(S.fh, S) %enregistre la structure S
figure(1)
circle(c,r); hold on; %appelle la fonction circle pour dessiner le mur circulaire. hold on maintient le graphique pour y ajouter d'autres tracés
xlim([-40 40]); ylim([-40 40]); %définit les limites des axes x et y du graphique de -40 à 40
grid on; %active l'affichage de la grille sur le graphique
axis equal; %force une échelle égale sur les axes 
hold off; %désactive hold on, indiquant que les prochains tracés ne seront pas conservés
legend('cercle'); %ajout de la légende 
guidata(S.fh,S) %enregistre la structure S

function circle(c,r) %fonction qui trace un cercle, elle prend 2 arguments c (centre) et r (rayon)
  ang_step = 0.01; %angle step, bigger values will draw the circle faster but you might notice imperfections (not very smooth)
  ang=0:ang_step:2*pi; %vecteur d'angles allant de 0 à 2pi avec un pas défini
  xp = r*cos(ang); %calcule des coordonnées de x de chaque point du cercle
  yp = r*sin(ang); %calcule des coordonnées de y de chaque point du cercle
  plot(c(1)+xp,c(2)+yp); %trace le cercle en ajoutant les coordonnées du centre (c(1) pour x, c(2) pour y) aux coordonnées des points calculées (xp, yp)
end

function mode_name = get_mode_name(mode) %fonction qui prend 'mode' en entrée et retourne 'mode_name'.
    if mode == 0
        mode_name = 'Constante (k_cst)';
    elseif mode == 1
        mode_name = 'Variable (k_var)';
    else
        mode_name = 'Inconnu';
    end
end

function switch_mode_callback(hObject, eventdata) %fonction de rappel, qui s'execute lors de l'appui du bouton
    S = guidata(hObject); %récupére la structure S
    current_mode = S.case_mode; %récupére la valeur actuelle de case_mode (stockée dans la structure S)
    new_mode = 1 - current_mode; %bascule le mode (0 -> 1, 1 -> 0)
    S.case_mode = new_mode; %mettre à jour la variable dans la structure S
    mode_str = sprintf('Mode: %d (%s)', new_mode, get_mode_name(new_mode)); %mettre à jour le texte affichant le mode
    set(S.mode_text, 'String', mode_str);  
    guidata(hObject, S); %enregistrer les modifications dans guidata
end

while(1) %boucle infinie
  [pos(1), pos(2), ~] = ginput (1); %attend que l'utilisateur clique sur la figure, la position x est stockée dans pos(1), la position y dans pos(2) et le troisième argument est ignoré (~)
  S = guidata(S.fh); %récupère les données mises à jour de guidata (le nouveau mode)
  fprintf('--- Mode Actuel: %d (%s) ---\n', S.case_mode, get_mode_name(S.case_mode)); %mise à jour de l'affichage du mode dans la console
  circle(c, r); hold on; %redessine le cercle et active à nouveau hold on
  plot(pos(1), pos(2), 'r.', "markersize", 20); %ajoute un gros point rouge sur la figure là où l'utilisateur a cliqué
  fprintf('pos: [%f, %f] \n', pos(1), pos(2)); %affiche la position du point cliqué par l'utilisateur dans la console

  vector_cp = pos - c; %vecteur du centre (c) à la position de l'utilisateur (pos)
  d = norm(vector_cp); %distance du centre à l'utilisateur (norme du vecteur vector_cp)
  k_var = 10 - (9/r) * d; %calcul de la raideur variable

  if S.case_mode == 0 %sélection de la raideur (k) en fonction de case_mode
      k = k_cst; %raideur constante
  elseif case_mode == 1
      k = k_var; %raideur variable
  else
      k = 0; %par défaut ou en cas d'erreur
  end

  if d<r %teste si la collision a lieu
      fprintf('collision \n'); %affiche un message de collision dans la console
      u = vector_cp / d; %calcule le vecteur unitaire 
      pv = c + r * u; %calcule la position proxy, ce sont les coordonées du point sur la surface du cercle le plus proche de la position utilisateur.
      F = k * (pv - pos); %calcule du vecteur de force de réaction en utilisant la raideur, elle est proportionnelle à la profondeur de pénétration dans le mur
      force_end = pos + F/2; %calcule le point final d'un vecteur représentant la force de réaction en utilisant une mise à l'échelle de facteur 2 (rq: on peur aussi utiliser k pour avoir le point final sur le cercle)
      fprintf('proxy: [%f, %f] m\n', pv(1), pv(2)); %affiche les coordonnées du proxy dans la console
  else %si la collision n'a pas eu lieu
      fprintf('pas collision \n') %affiche un message d'abscence de collision dans la console
      pv = [NaN NaN]; %initialisation avec des valeurs vides pour éviter un problème car pv non défini si le premier point choisi par l'utilisateur est en dehors du cercle
      F = [0 0]; %les valeurs du vecteur de force de réaction sont nulles
      force_end = [NaN NaN]; %initialisation avec des valeurs vides pour éviter un problème car pv non défini si le premier point choisi par l'utilisateur est en dehors du cercle
      k = 0; %la raideur est nulle
  end

  fprintf('force: [%f, %f] N \n', F(1), F(2)); %affiche le vecteur de force dans la console
  fprintf('Stiffness (k): [%f] N/m\n', k); %affiche la valeur de la raideur dans la console
  plot(pv(1), pv(2), 'b*'); %ajoute une grosse étoile bleue sur la figure à la position du proxy
  plot([pos(1), force_end(1)], [pos(2), force_end(2)], 'g-'); %trace le vecteur de force de la position utilisateur (pos) jusqu'au point force_end par une ligne verte (g-)
  plot(NaN, NaN, 'c'); %trace des points invisibles pour pouvoir ajouter la valeur de k dans la légende
  xlim([-40 40]); ylim([-40 40]); %définit les limites minimales et maximales des axes x et y
  grid on; %active l'affichage de la grille sur le graphique
  axis equal; %force une échelle égale sur les axes 
  legend('cercle', sprintf('point de contact [x= %f, y= %f]', pos(1), pos(2)), sprintf('proxy: [x= %f, y= %f]', pv(1), pv(2)), sprintf('force de réaction [x= %f, y= %f] N', F(1), F(2)), sprintf('raideur k= %f N/m', k)); %ajout de la légende
  hold off; %désactive hold on
  figure(1)
end
