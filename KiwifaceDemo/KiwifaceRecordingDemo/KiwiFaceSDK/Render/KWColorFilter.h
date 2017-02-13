#import "GPUImageFilterGroup.h"
#import "KWRenderProtocol.h"
@class GPUImagePicture;

/** A photo filter based on Photoshop action by Amatorka
    http://amatorka.deviantart.com/art/Amatorka-Action-2-121069631
 */

// Note: If you want to use this effect you have to add lookup_amatorka.png
//       from Resources folder to your application bundle.

//0 - natrue, 1 - sweety, 2 - clean, 3 - peach, 4 - rosy, 5 - urban
typedef NS_ENUM(NSInteger, KWColorType) {
    KWColorTypeNONE = -1,
    KWColorTypeBlueberrt,
    KWColorTypeDreamy,
    KWColorTypeHabana,
    KWColorTypeHappy,
    KWColorTypeHarvest,
    KWColorTypeMisty,
    KWColorTypeSpring
};

@interface KWColorFilter : GPUImageFilterGroup<KWRenderProtocol>

@property (nonatomic, assign)CGImageRef currentImage;

@property (nonatomic, strong)GPUImagePicture *lookupImageSource;

@property (nonatomic, readonly) BOOL needTrackData;

- (instancetype)initWithType:(KWColorType)type;

@end
