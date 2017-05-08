//
//  PLSEditVideoCell.m
//  PLShortVideoKitDemo
//
//  Created by suntongmian on 17/3/20.
//  Copyright © 2017年 Pili Engineering, Qiniu Inc. All rights reserved.
//

#import "PLSEditVideoCell.h"

@implementation PLSEditVideoCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        _iconImageView.layer.cornerRadius = 30;
        [self addSubview:_iconImageView];
        
        _iconPromptLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_iconImageView.frame)+8, CGRectGetMaxX(_iconImageView.bounds), 15)];
        _iconPromptLabel.textAlignment = 1;
        _iconPromptLabel.font = [UIFont systemFontOfSize:11];
        _iconPromptLabel.textColor = [UIColor whiteColor];
        [self addSubview:_iconPromptLabel];
        
    }
    return self;
}

@end
