//
//  ViewController.h
//  Viewer App
//
//  Created by Jayve Javier on 5/10/21.
//

#import <UIKit/UIKit.h>

@interface ParentViewController : UIViewController <NSXMLParserDelegate>
 
@property (nonatomic,strong) NSMutableArray *filesArray;
@property (nonatomic,strong) NSMutableString *xmlValue;
@property (nonatomic,strong) NSMutableDictionary *fileDictionary;
@property (nonatomic,strong) NSMutableDictionary *imageDictionary;
@property (nonatomic,strong) NSMutableDictionary *dummyDictionary;

@end

