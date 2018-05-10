//
//  TreeTableView.h
//  TreeTableView
//
//  Created by HanYong on 2018/3/27.
//  Copyright © 2018年 HanYong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Node;

@protocol TreeTableCellDelegate <NSObject>

-(void)cellClick : (Node *)node select:(NSString *)select;

@end

@interface TreeTableView : UITableView

@property (nonatomic , weak) id<TreeTableCellDelegate> treeTableCellDelegate;

-(instancetype)initWithFrame:(CGRect)frame withInitialNodeData : (NSArray *)initialdata allNodeData:(NSArray *)allData select:(NSString *)select;

@end
