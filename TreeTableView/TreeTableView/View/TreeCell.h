//
//  TreeCell.h
//  TreeTableView
//
//  Created by HanYong on 2018/3/27.
//  Copyright © 2018年 HanYong. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^ExpendBlock)(UIButton *btn);

@interface TreeCell : UITableViewCell

@property (nonatomic, strong) UIButton *iconView;//图标
@property (nonatomic, strong) UILabel *titleLable;//标题
@property (nonatomic, strong) UIImageView *accessoryImageView;
@property (nonatomic, copy) ExpendBlock expendBlock;
@property (nonatomic, strong)NSIndexPath *indexPath;

-(void)clickIconImageButton:(ExpendBlock)expendBlock;

//赋值
- (void)setCellBasicInfoWithLevel:(NSInteger)level children:(NSInteger )children;

@end
