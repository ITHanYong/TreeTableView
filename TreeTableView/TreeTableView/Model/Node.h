//
//  Node.h
//  TreeTableView
//
//  Created by HanYong on 2018/3/27.
//  Copyright © 2018年 HanYong. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  每个节点类型
 */
@interface Node : NSObject

@property (nonatomic, copy) NSString        *parentId;       //父节点的id，如果为-1表示该节点为根节点
@property (nonatomic, copy) NSString        *nodeId;         //该节点的id
@property (nonatomic, copy) NSString        *name;           //该节点的名称
@property (nonatomic, assign) int           depth;           //该节点的深度
@property (nonatomic, assign) BOOL          expand;          //该节点是否处于展开状态
@property (nonatomic, assign) BOOL          hasChild;     //该节点是否含有子节点
@property (nonatomic, copy) NSArray       *children;       //子节点
@property (nonatomic, copy) NSDictionary  *nodes;       //该节点的信息 = parentId + nodeId + name + hasChild

/**
 *快速实例化该对象模型
 */
-(instancetype)initWithNodesNodes:(NSDictionary *)nodes children:(NSArray *)children depth:(int)depth expand:(BOOL)expand;
@end
