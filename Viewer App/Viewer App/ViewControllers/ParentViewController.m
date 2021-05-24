//
//  ViewController.m
//  Viewer App
//
//  Created by Jayve Javier on 5/10/21.
//

#import "ParentViewController.h"
#import "PDFViewController.h"
#import "ImageViewController.h"
#import "Data.h"
#import "Constants.h"

@interface ParentViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *parentTableView;

@end

@implementation ParentViewController

NSString *cellId = @"cellId";
BOOL isAllowToRetrieveImages;
NSNumber *imagesCountToRetrieve;
Data *data;
@synthesize filesArray;
@synthesize xmlValue;
@synthesize fileDictionary;
@synthesize imageDictionary;
@synthesize dummyDictionary;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Parent View";
    
    UIBarButtonItem *btnBack = [[UIBarButtonItem alloc]
                                initWithTitle:@"Done"
                                style:UIBarButtonItemStylePlain
                                target:self
                                action:nil];
    self.navigationController.navigationBar.topItem.backBarButtonItem=btnBack;
    
    self.parentTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    self.parentTableView.backgroundColor = UIColor.blackColor;
    self.parentTableView.dataSource = self;
    self.parentTableView.delegate = self;
    self.parentTableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.parentTableView];
    
    [self.parentTableView.leftAnchor constraintEqualToAnchor:self.parentTableView.superview.leftAnchor constant:0].active = YES;
    [self.parentTableView.rightAnchor constraintEqualToAnchor:self.parentTableView.superview.rightAnchor constant:0].active = YES;
    [self.parentTableView.topAnchor constraintEqualToAnchor:self.parentTableView.superview.topAnchor constant:0].active = YES;
    [self.parentTableView.bottomAnchor constraintEqualToAnchor:self.parentTableView.superview.bottomAnchor constant:0].active = YES;
    
    [self startParsing];

}

- (void)startParsing{
    NSString *xmlPath = [[NSBundle mainBundle] pathForResource:@"contents"
    ofType:@"xml"];
    NSData *xmlData = [NSData dataWithContentsOfFile:xmlPath];
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:xmlData];
    [xmlParser setDelegate:self];
    [xmlParser parse];

    if (isAllowToRetrieveImages && [imagesCountToRetrieve integerValue] != 0) {
        [self fetchImagesInImgur];
    }
    else {
        [self setDummyData];
    }
    
    if (filesArray.count != 0) {
        [self.parentTableView reloadData];
    }
}

- (void)fetchImagesInImgur {
    NSString *albumHash = IMGUR_ALBUM_ID;
    NSString *urlString = [NSString stringWithFormat: @"https://api.imgur.com/3/album/%@/images",albumHash];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *clientIdImgur = IMGUR_CLIENT_ID;
    [request setValue:[@"Client-ID " stringByAppendingString:clientIdImgur] forHTTPHeaderField:@"Authorization"];
    [NSURLRequest requestWithURL:url];
    
    [[NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable nsData, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSError *err;
        NSDictionary *imageJSON = [NSJSONSerialization JSONObjectWithData:nsData options:NSJSONReadingAllowFragments error:&err];
        if (err) {
            NSLog(@"Failed to serialize into JSON: %@", err);
            return;
        }
        
        NSInteger i = 1;
        for (NSDictionary *dataDict in imageJSON[@"data"]) {
            NSString *id = dataDict[@"id"];
            NSString *link = dataDict[@"link"];
            self.imageDictionary = NSMutableDictionary.new;
            self.imageDictionary[@"filename"] = id;
            self.imageDictionary[@"description"] = link;
            [self.filesArray addObject:self->imageDictionary];
            if (i == [imagesCountToRetrieve integerValue]) {
                [self setDummyData];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.parentTableView reloadData];
                });
                return;
            }
            i++;
        }
       
    }] resume];
    NSLog(@"Finished fetching images...");
}

- (void)setDummyData{
    self.dummyDictionary = NSMutableDictionary.new;
    self.dummyDictionary[@"filename"] = @"az123456789ABC";
    self.dummyDictionary[@"description"] = @"This is a dummy file";
    [self.filesArray addObject:self->dummyDictionary];
}

#pragma mark - UITableViewDelegate DataSource and Delegate Method

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    cell.backgroundColor = UIColor.blackColor;
    cell.textLabel.textColor =  [UIColor colorWithWhite:1.0 alpha:0.8];
    cell.detailTextLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor clearColor];
    [cell setSelectedBackgroundView:bgColorView];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator    ;
    
    cell.textLabel.text = [[[filesArray objectAtIndex:indexPath.row] valueForKey:@"filename"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    cell.detailTextLabel.text = [[[filesArray objectAtIndex:indexPath.row] valueForKey:@"description"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.filesArray.count > 0){
        return self.filesArray.count;
    }
    return self.filesArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *filename = [[[filesArray objectAtIndex:indexPath.row] valueForKey:@"filename"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *description = [[[filesArray objectAtIndex:indexPath.row] valueForKey:@"description"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if([filename containsString:@".pdf"]){
        PDFViewController *dvc = [[PDFViewController alloc] init];
        NSArray * name = [filename componentsSeparatedByCharactersInSet:
                              [NSCharacterSet characterSetWithCharactersInString:@"."]];
        dvc.data = name[0];
        [self.navigationController pushViewController:dvc animated:YES];
    }
    else if([description containsString:@"https://i.imgur.com/"]){
        ImageViewController *dvc = [[ImageViewController alloc] init];
        dvc.data = description;
        [self.navigationController pushViewController:dvc animated:YES];
    }
    else {
        // Dummy file, which is located on the last row
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error:"
                                   message:@"File not found"
                                   preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action) {}];

        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger )section {
    return [[UIView alloc] initWithFrame:CGRectZero];
}


#pragma mark - NSXMLParser Delegate Method

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
attributes:(NSDictionary *)attributeDict;{
    if ([elementName isEqualToString:@"pdf-list"]) {
        filesArray = [[NSMutableArray alloc] init];
    }
    if ([elementName isEqualToString:@"pdf-item"]) {
        fileDictionary = [[NSMutableDictionary alloc] init];
    }
    if ([elementName isEqualToString:@"image-list"]) {
        NSString *retrieve_images = [attributeDict objectForKey:@"retrieve_images"];
        if ([retrieve_images isEqual:@"true"]) {
            isAllowToRetrieveImages = YES;
        }
        else{
            isAllowToRetrieveImages = NO;
        }
        
        NSNumber *image_count = [attributeDict objectForKey:@"image_count"];
        if ([image_count intValue] > AVAILABLE_IMAGES) {
            imagesCountToRetrieve = @AVAILABLE_IMAGES;
        }
        else{
            imagesCountToRetrieve = image_count;
        }
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string;{
    if (!xmlValue) {
        xmlValue = [[NSMutableString alloc] initWithString:string];
    }
    else {
        [xmlValue appendString:string];\
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;{
    if ([elementName isEqualToString:@"filename"]
        || [elementName isEqualToString:@"description"]) {

        [fileDictionary setObject:xmlValue forKey:elementName]; // making the fileDictionary with value and key..
    }
    if ([elementName isEqualToString:@"pdf-item"]) {
        [filesArray addObject:fileDictionary]; // creating the filesArray.
    }
    xmlValue = nil;
}

@end

