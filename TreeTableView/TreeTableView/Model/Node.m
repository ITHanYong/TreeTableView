//
//  Node.m
//  TreeTableView
//
//  Created by HanYong on 2018/3/27.
//  Copyright © 2018年 HanYong. All rights reserved.
//

#import "Node.h"

@implementation Node

-(instancetype)initWithNodesNodes:(NSDictionary *)nodes children:(NSArray *)children depth:(int)depth expand:(BOOL)expand{
    
    if (self=[self init]) {
        self.nodes = nodes;
        self.children = children;
        self.parentId = [nodes objectForKey:@"parentId"];
        self.nodeId = [nodes objectForKey:@"nodeId"];
        self.name = [nodes objectForKey:@"name"];
        self.hasChild = [[nodes objectForKey:@"hasChild"] boolValue];
        self.depth = depth;
        self.expand = expand;
    }
    return self;
}

@end
