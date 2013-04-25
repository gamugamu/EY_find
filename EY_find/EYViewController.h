//
//  ViewController.h
//  EY_find
//
//  Created by Abadie, Loïc on 23/04/13.
//  Copyright (c) 2013 Abadie, Loïc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EYRecognizerDelegate.h"

@interface EYViewController : UIViewController
// note: c'est juste une facade. Probablement une autre classe viendra encapsuler
// juste la facade.

@property(nonatomic, assign)id<EYRecognizerDelegate> delegate;
// commence ou arrête la detection d'image.
@property(nonatomic, assign)BOOL shouldDetect;

// EYViewController n'informe qu'une seule fois le delegate lorsqu'il a detecté une
// image. Parce que la caméra peut pointer plusieurs secondes sur la même image, et afin
// d'éviter de recevoir plusieurs callBack similaires tant que la camera pointe sur
// cette image, le client n'est informé qu'une seule fois de cette detection image.
// Si le client désire être  à nouveau renseigné sur cette même image,
// alors il doit invoquer la méthode reset;
// Note: cela ne s'applique pas si une première image est detectée, puis une nouvelle
// différente de la précédente est detectée.
- (void)reset;
@end
