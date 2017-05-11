//
//  KWTextCollectionViewCell.h
//  KWMediaStreamingKitDemo
//
//  Created by 伍科 on 16/12/7.
//  Copyright © 2016年 0dayZh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KWTextCollectionViewCell : UICollectionViewCell

@property(nonatomic ,strong)UIImageView *imageView;
@property(nonatomic ,strong)UILabel *label;

- (id)initWithFrame:(CGRect)frame;

@end
