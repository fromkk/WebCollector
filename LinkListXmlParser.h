//
//  LinkListXmlParser.h
//  longScreenCapture
//
//  Created by Ueoka Kazuya on 11/10/22.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LinkListXmlParser : NSXMLParser <NSXMLParserDelegate> {
    NSMutableArray *linkList;
    NSMutableString *tmp;
}
@property (nonatomic, retain) NSMutableArray *linkList;
@property (nonatomic, retain) NSMutableString *tmp;

@end
