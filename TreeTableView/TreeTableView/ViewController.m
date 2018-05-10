//
//  ViewController.m
//  TreeTableView
//
//  Created by HanYong on 2018/3/27.
//  Copyright © 2018年 HanYong. All rights reserved.
//

#import "ViewController.h"
#import "Node.h"
#import "TreeTableView.h"

@interface ViewController ()<TreeTableCellDelegate>

@property (nonatomic, strong)   NSMutableArray *allPoints;
@property (nonatomic, copy)     NSArray *dataSourceArray;
@property (nonatomic, copy)     NSString *selectId;//已选择节点ID
@property (nonatomic, strong)   Node *selectNode;//已选择节点
@property (nonatomic, strong)   NSMutableArray *initialNodes;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSData *JSONData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NodeTree" ofType:@"json"]];
    _dataSourceArray = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingAllowFragments error:nil];
    
    _selectId = @"test-one-002-01";
    _selectNode = [[Node alloc] init];
    
    //获取节点
    [self initPoints];
}

-(void)cellClick:(Node *)node select:(NSString *)select{
    
    self.selectId = select;
    if (self.selectId.length>0) {
        self.selectNode = node;
    }else{
        self.selectNode = nil;
    }
    NSLog(@"selectNode_name -- %@",self.selectNode.name);
    NSLog(@"selectNode_id -- %@",self.selectNode.nodeId);
}

-(void)initPoints{
    
    _allPoints = [NSMutableArray array];
    _initialNodes = [NSMutableArray array];
    
    //enumerateObjectsUsingBlock遍历数组不精确（此处）obj有可能取出对象
    [_dataSourceArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *NodeDic = (NSDictionary *)_dataSourceArray[idx];
        Node *node = [[Node alloc]initWithNodesNodes:NodeDic[@"node"] children:NodeDic[@"nodes"] depth:0 expand:NO];
        
        [_initialNodes addObject:node];
    }];
    
    //获取所有节点
    [self recursiveAllPoints:_initialNodes];
    
    //根据默认已选取节点 - 设置父节点展开状态
    if (self.selectId.length>0) {
        [self setNodeExpend:_allPoints childNode:self.selectNode];
        
        [_initialNodes enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSLog(@"obj - %@",[_initialNodes[idx] name]);
            [self setNodeDepth:_allPoints rootNode:_initialNodes[idx]];
        }];
    }
    
    //TreeTableView
    TreeTableView *tableview = [[TreeTableView alloc] initWithFrame:CGRectMake(0, 20, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-20) withInitialNodeData:_initialNodes allNodeData:_allPoints select:self.selectId];
    tableview.treeTableCellDelegate = self;
    [self.view addSubview:tableview];
    
}
//递归所有的节点
-(void)recursiveAllPoints:(NSMutableArray *)point_arrM{
    __block int i = 0 ;
    
    [point_arrM enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        Node *parentNode = (Node *)point_arrM[idx];
        
        [_allPoints addObject:parentNode];
        
        i = parentNode.depth;
        
        if (parentNode.hasChild) {
            i = i + 1;
            NSMutableArray *sonPoints = [[NSMutableArray alloc] init];
            [parentNode.children enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                NSDictionary *child = (NSDictionary *)parentNode.children[idx];
                
                Node *node = [[Node alloc] initWithNodesNodes:child[@"node"] children:child[@"nodes"] depth:i expand:NO];
                
                //获取默认节点
                if ([node.nodeId isEqualToString:self.selectId]) {
                    self.selectNode = node;
                }
                
                NSLog(@"all = %@--%@--%@--%@",node.name,node.parentId,node.nodeId,node.children);
                [sonPoints addObject:node];
            }];
            
            //节点含有子节点 - 递归
            [self recursiveAllPoints:sonPoints];
        }else{
            i = 0 ;
            NSLog(@"==============");
        }
    }];
}

//如果存在默认选择节点 - 设置其父节点至根节点为展开状态 - 初始化节点的展开状态
-(void)setNodeExpend:(NSArray *)nodeArray childNode:(Node *)childNode{
    
    if ([childNode.parentId isEqualToString:@"-1"]) {
        return;
    }
    
    [nodeArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        Node *node = (Node *)nodeArray[idx];
        
        if (node.hasChild && [node.nodeId isEqualToString:childNode.parentId]) {
            node.expand = YES;
            [_allPoints replaceObjectAtIndex:idx withObject:node];
            
            [self setNodeExpend:_allPoints childNode:node];
        }
    }];
}

//如果根节点是展开状态 -
-(void)setNodeDepth:(NSArray *)nodeArray rootNode:(Node *)rootNode{
    
    if (!rootNode.expand || [rootNode.nodeId isEqualToString:self.selectId]) {
        return;
    }
    
    [nodeArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        Node *node = (Node *)nodeArray[idx];
        
        if ([node.parentId isEqualToString:rootNode.nodeId] ) {
            
            if (![_initialNodes containsObject:node]) {
                NSInteger index = [_initialNodes indexOfObject:rootNode];
                node.depth = rootNode.depth + 1;
                //此处应用插入方式
                [_initialNodes insertObject:node atIndex:index+1];
//                [_initialNodes addObject:node];
            }
            
            if ([node.children count]>0) {
                //子节点集合
                NSArray *arr = [self creatChildrenNode:node.children depth:node.depth + 1];
                [self setNodeDepth:arr rootNode:node];
            }
        }
        
        //第一步：将父节点的子节点全部追加进去
        
        
    }];
}

-(NSArray *)creatChildrenNode:(NSArray *)children depth:(int)depth{
    NSMutableArray *sonPoints = [[NSMutableArray alloc] init];
    [children enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSDictionary *child = (NSDictionary *)children[idx];
        
        //获取子节点的打开状态 - 生产子节点
        Node *node = [[Node alloc] initWithNodesNodes:child[@"node"] children:child[@"nodes"] depth:depth expand:NO];
        
//        NSLog(@"all = %@--%@--%@--%@",node.name,node.parentId,node.nodeId,node.children);
        [sonPoints addObject:node];
    }];
    
    return sonPoints;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
