//
//  IR_Config.h
//  EY_find
//
//  Created by Abadie, Loïc on 24/04/13.
//  Copyright (c) 2013 Abadie, Loïc. All rights reserved.
//

#ifndef EY_find_IR_Config_h
#define EY_find_IR_Config_h

#define RATIODETECTION  0.80f   
// la distance maximum entre les correspondances voisines acceptée.
// Plus la valeur est basse, plus les correspondances doivent
// être proches. En général lorsque des correspondances sont
// proches de 0 c'est qu'il y a forte possibilité de reconnaissance
// d'image.

#define NBOFVALIDMATCH  6       
// le nombre minimum de correspondance valides, avant de
// conclure que c'est une image reconnue. Si le nombre de correspondances
// acceptées est trop bas, il y aura plus de risque de fausses reconnaissances.
// En dessous de 4 c'est quasiment impossible, 5 c'est limite. Je pense qu'à
// 6 on a toujours des résultats valides.

#define ISOIDXDIFF      80      
// J'ai remarqué que plus les images sont voisines, plus
// les index entre correspondances sont petits. Donc plus on
// elargit l' ISOIDXDIFF, plus on accepte de correspondances.
// Ca n'influe pas trop sur le résultat de sortie.

#define KRATIO          1.3f    
// KRatio défini le ROI dans l'image (Region of interest). 1 pour l'image totale
// 2 pour la moitié, etc... C'est une optimisation très importante
// car c'est inutile de calculer les bords des images, et plus la
// zone de l'image est petite moins il y a de calculs à faire.
// Ne peut pas être inférieur à 1.

#define KMax_feature 100

#endif
