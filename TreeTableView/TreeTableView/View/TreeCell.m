//
//  TreeCell.m
//  TreeTableView
//
//  Created by HanYong on 2018/3/27.
//  Copyright © 2018年 HanYong. All rights reserved.
//

#import "TreeCell.h"
#define IndentationWidth (20 * kpackWidth)
#define kpackWidth      [UIScreen mainScreen].bounds.size.width/320
#define kWidth          [UIScreen mainScreen].bounds.size.width

@implementation TreeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGFloat but_height = 20 * kpackWidth;
        _iconView = [UIButton buttonWithType:UIButtonTypeCustom];
        _iconView.frame = CGRectMake(but_height/2, 10 * kpackWidth, 16 * kpackWidth,16 * kpackWidth);
        [_iconView setImage:[UIImage imageNamed:@"right.png"] forState:UIControlStateNormal];
        [_iconView setImage:[UIImage imageNamed:@"down.png"] forState:UIControlStateSelected];
        [_iconView addTarget:self action:@selector(expendClick) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_iconView];
        
        self.titleLable = [[UILabel alloc] initWithFrame:CGRectMake(30 * kpackWidth, 8 * kpackWidth, kWidth - 50 * kpackWidth, 20 * kpackWidth)];
        [self addSubview:self.titleLable];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 10)];
        self.accessoryImageView = [[UIImageView alloc] initWithFrame:view.frame];
        [view addSubview:self.accessoryImageView];
        self.accessoryView = view;
    }
    return self;
}

-(void)clickIconImageButton:(ExpendBlock)expendBlock{
    self.expendBlock = expendBlock;
}
-(void)expendClick{
    
    if (self.expendBlock) {
        self.expendBlock(self.iconView);
    }
}


- (void)setCellBasicInfoWithLevel:(NSInteger)level children:(NSInteger )children{
    
    //有自孩子时显示图标
    if (children==0) {
        self.iconView.hidden = YES;
        
    }
    else { //否则不显示
        self.iconView.hidden = NO;
    }
    
    //每一层的布局
    CGFloat left = 10+level*30;
    
    //头像的位置
    CGRect  iconViewFrame = self.iconView.frame;
    
    iconViewFrame.origin.x = left;
    
    self.iconView.frame = iconViewFrame;
    
    //title的位置
    CGRect titleFrame = self.titleLable.frame;
    
    titleFrame.origin.x = 40+left;
    
    self.titleLable.frame = titleFrame;
    
}


@end
