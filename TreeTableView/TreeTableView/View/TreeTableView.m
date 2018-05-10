//
//  TreeTableView.m
//  TreeTableView
//
//  Created by HanYong on 2018/3/27.
//  Copyright © 2018年 HanYong. All rights reserved.
//

#import "TreeTableView.h"
#import "Node.h"
#import "TreeCell.h"
#define kpackWidth [UIScreen mainScreen].bounds.size.width/320

@interface TreeTableView ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, copy) NSArray *allData;//传递过来已经组织好的数据（全量数据）
@property (nonatomic, copy) NSArray *initialdata;
@property (nonatomic, strong) NSMutableArray *tempData;//用于存储数据源（部分数据）

@property (nonatomic, copy) NSString *selectId;

@end

@implementation TreeTableView

-(instancetype)initWithFrame:(CGRect)frame withInitialNodeData:(NSArray *)initialdata allNodeData:(NSArray *)allData select:(NSString *)select{
    self = [super initWithFrame:frame style:UITableViewStyleGrouped];
    if (self) {
        
        self.estimatedRowHeight = 0;
        self.estimatedSectionHeaderHeight = 0;
        self.estimatedSectionFooterHeight = 0;
        self.dataSource = self;
        self.delegate = self;
        _allData = allData;
        _initialdata = initialdata;
        _tempData = [self createTempData:_initialdata];
        _selectId = select;
    }
    return self;
}

/**
 * 初始化数据源
 */
-(NSMutableArray *)createTempData : (NSArray *)data{
    NSMutableArray *tempArray = [NSMutableArray array];
    for (int i=0; i<data.count; i++) {
        Node *node = [_initialdata objectAtIndex:i];
        
        [tempArray addObject:node];
    }
    return tempArray;
}


#pragma mark - UITableViewDataSource

#pragma mark - Required

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _tempData.count;
}

-(void)btnClick:(UIButton *)button{
    TreeCell *cell = (TreeCell *)[[button superview] superview];
    // 获取cell的indexPath
    NSIndexPath *indexPath = [self indexPathForCell:cell];
    NSLog(@"点击的是第%ld行按钮",indexPath.row);
    
    //先修改数据源
    Node *parentNode = [_tempData objectAtIndex:indexPath.row];
    parentNode.expand = !parentNode.expand;
    
    NSUInteger startPosition = indexPath.row+1;
    NSUInteger endPosition = startPosition;
    BOOL expand = NO;
    for (int i=0; i<_allData.count; i++) {
        Node *node = [_allData objectAtIndex:i];
        
        if ([node.parentId isEqualToString: parentNode.nodeId]) {

            if (parentNode.expand) {
                [_tempData insertObject:node atIndex:endPosition];
                expand = YES;
                endPosition++;
            }else{
                expand = NO;
                endPosition = [self removeAllNodesAtParentNode:parentNode];
                break;
            }
        }
    }
    //获得需要修正的indexPath
    NSMutableArray *indexPathArray = [NSMutableArray array];
    for (NSUInteger i=startPosition; i<endPosition; i++) {
        NSIndexPath *tempIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [indexPathArray addObject:tempIndexPath];
    }
    
    button.selected = expand;
    [_tempData replaceObjectAtIndex:indexPath.row withObject:parentNode];
    
    //插入或者删除相关节点
    if (expand) {
        [self insertRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationNone];
    }else{
        [self deleteRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *NODE_CELL_ID = @"node_cell_id";
    
    TreeCell *cell = [tableView dequeueReusableCellWithIdentifier:NODE_CELL_ID];
    if (!cell) {
        cell = [[TreeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NODE_CELL_ID];
    }
    
    Node *node = [_tempData objectAtIndex:indexPath.row];
    
    // cell有缩进的方法
//    cell.indentationLevel = node.depth; // 缩进级别
//    cell.indentationWidth = 30.f; // 每个缩进级别的距离
    
    cell.titleLable.text = node.name;
    
    if (node.expand) {
        cell.iconView.selected = YES;
    }else{
        cell.iconView.selected = NO;
    }
    
    if ([self.selectId isEqualToString: node.nodeId]) {
        cell.accessoryImageView.image = [UIImage imageNamed:@"select"];
    }else{
        cell.accessoryImageView.image = nil;
    }
    
    cell.selectionStyle = UITableViewCellAccessoryNone;
    
    //设置cell的样式 - 布局
    [cell setCellBasicInfoWithLevel:node.depth children:node.hasChild];
    
    //点击展开按钮
    [cell clickIconImageButton:^(UIButton *btn) {
        
        [self btnClick:btn];
    }];
    
    return cell;
}


#pragma mark - Optional
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return floorf(36 * kpackWidth);;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

#pragma mark - UITableViewDelegate

#pragma mark - Optional
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    TreeCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    //此处传递选择参数
    Node *parentNode = [_tempData objectAtIndex:indexPath.row];
    
    if ([self.selectId isEqualToString:parentNode.nodeId]) {
        self.selectId = @"";
        cell.accessoryImageView.image = nil;
    }else{
        self.selectId = parentNode.nodeId;
        cell.accessoryImageView.image = [UIImage imageNamed:@"select"];
    }
    
    if (_treeTableCellDelegate && [_treeTableCellDelegate respondsToSelector:@selector(cellClick:select:)]) {
        [_treeTableCellDelegate cellClick:parentNode select:self.selectId];
    }
    
    [tableView reloadData];
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    TreeCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryImageView.image = nil;
    self.selectId = @"";
}

//设置分割线边距
-(void)tableView:(UITableView *)tableView willDisplayCell:(nonnull UITableViewCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    [cell setSeparatorInset:UIEdgeInsetsZero];
}

/**
 *  删除该父节点下的所有子节点（包括孙子节点）
 *
 *  @param parentNode 父节点
 *
 *  @return 该父节点下一个相邻的统一级别的节点的位置
 */
-(NSUInteger)removeAllNodesAtParentNode : (Node *)parentNode{
    NSUInteger startPosition = [_tempData indexOfObject:parentNode];
    NSUInteger endPosition = startPosition;
    for (NSUInteger i=startPosition+1; i<_tempData.count; i++) {
        Node *node = [_tempData objectAtIndex:i];
        endPosition++;
        if (node.depth <= parentNode.depth) {
            break;
        }
        if(endPosition == _tempData.count-1){
            endPosition++;
            node.expand = NO;
            break;
        }
        node.expand = NO;
    }
    if (endPosition>startPosition) {
        [_tempData removeObjectsInRange:NSMakeRange(startPosition+1, endPosition-startPosition-1)];
    }
    return endPosition;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
