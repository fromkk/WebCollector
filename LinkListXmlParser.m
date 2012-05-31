//
//  LinkListXmlParser.m
//  longScreenCapture
//
//  Created by Ueoka Kazuya on 11/10/22.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "LinkListXmlParser.h"

@implementation LinkListXmlParser

@synthesize tmp;
@synthesize linkList;

- (void)parserDidStartDocument:(NSXMLParser *)parser {
    linkList = [[NSMutableArray alloc] init];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    
}

- (void)parser:(NSXMLParser *)parser 
didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName 
	attributes:(NSDictionary *)attributeDict {
    if ( [elementName isEqualToString:@"url"] ) {
        tmp = [[NSMutableString alloc] init];
    }
}

- (void)parser:(NSXMLParser *)parser 
 didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName {
    if ( [elementName isEqualToString:@"url"] && nil != tmp ) {
        [linkList addObject:[tmp stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
}

- (void)parser:(NSXMLParser *)parser 
foundCharacters:(NSString *)string {
    [tmp appendString:string];
}

- (void)parser:(NSXMLParser *)parser 
parseErrorOccurred:(NSError *)parseError {
    NSLog(@"Error:%@", parseError);
}

@end
