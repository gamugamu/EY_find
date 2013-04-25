//
//  DetectorNotifier.h
//  EY_find
//
//  Created by Abadie, Loïc on 25/04/13.
//  Copyright (c) 2013 Abadie, Loïc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DetectorNotifierDelegate <NSObject>
- (void)imageFound:(unsigned)index intoView:(UIView*)cameRaView;
@end

// Informe le client lorsqu'une image a été detectée. Permet également de controller
// si le client désire encore être informé ou non. Wrapper entre la vue OpenGL
// et la librairie libIR.
@interface DetectorNotifier : NSObject
@property(nonatomic, assign)id<DetectorNotifierDelegate>delegate;

// commence ou arrête la detection d'image.
@property(nonatomic, assign)BOOL shouldDetect;

// DetectorNotifier n'informe qu'une seule fois le delegate lorsqu'il a detecté une
// image. Parce que la caméra peut pointer plusieurs secondes sur la même image, et afin
// d'éviter de recevoir plusieurs callBack similaires tant que la camera pointe sur
// cette image, le client n'est informé qu'une seule fois de cette detection image.
// Si le client désire être  à nouveau renseigné sur cette même image,
// alors il doit invoquer la méthode reset;
// Note: cela ne s'applique pas si une première image est detectée, puis une nouvelle
// différente de la précédente est detectée.
- (void)reset;
@end
