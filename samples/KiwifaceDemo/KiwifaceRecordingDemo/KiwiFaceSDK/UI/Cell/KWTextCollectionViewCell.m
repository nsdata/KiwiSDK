//
//  KWTextCollectionViewCell.m
//  KWMediaStreamingKitDemo
//
//  Created by 伍科 on 16/12/7.
//  Copyright © 2016年 0dayZh. All rights reserved.
//

#import "KWTextCollectionViewCell.h"

@implementation KWTextCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
//                self.backgroundColor = [UIColor purpleColor];
        
        self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(1 , 1, CGRectGetWidth(self.frame) - 2, CGRectGetWidth(self.frame) - 2)];
//        self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
        //        UIImageView *backView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetWidth(self.frame))];
        //        [backView setImage:[UIImage imageNamed:@"yellowBorderBackground"]];
        //        [self.selectedBackgroundView addSubview:backView];
        
        UIImageView* selectedBGView = [[UIImageView alloc] initWithFrame:self.bounds];
        [selectedBGView setImage:[UIImage imageNamed:@"yellowBorderBackground"]];
        self.selectedBackgroundView = selectedBGView;
        
        [self.contentView addSubview:self.imageView];
        
//        self.text = [[UILabel alloc]initWithFrame:CGRectMake(5, CGRectGetMaxY(self.imgView.frame), CGRectGetWidth(self.frame)-10, 20)];
        CGFloat margin = self.imageView.frame.size.height;
       self.label = [[UILabel alloc]initWithFrame:CGRectMake(0, margin + 5, margin,12)];
//        self.label.backgroundColor = [UIColor brownColor];
        self.label.textColor = [UIColor whiteColor];
        self.label.font = [UIFont fontWithName:@"Helvetica" size:8.f];
        self.label.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.label];
        
    }
    return self;
}

@end
