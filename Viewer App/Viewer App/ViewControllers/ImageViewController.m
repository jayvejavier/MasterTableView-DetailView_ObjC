//
//  ImageViewController.m
//  Viewer App
//
//  Created by Jayve Javier on 5/12/21.
//

#import "ImageViewController.h"

@interface ImageViewController () <UIScrollViewDelegate>

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIScrollView *scrollView;

@end

@implementation ImageViewController 

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = @"Detail View";
  
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.imageView.backgroundColor = UIColor.whiteColor;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    NSData * nsData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: self.data]];
    if (nsData == nil)
        return;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.imageView.image = [UIImage imageWithData: nsData];
    });

    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.scrollView.backgroundColor = UIColor.whiteColor;
    [self.scrollView addSubview:self.imageView];
    
    float minScale = self.scrollView.frame.size.width / self.imageView.frame.size.width;
    self.scrollView.minimumZoomScale = minScale;
    self.scrollView.maximumZoomScale = 2.0;
    self.scrollView.contentSize = self.imageView.frame.size;
    self.scrollView.contentMode = UIViewContentModeScaleAspectFit;
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
    
    [self.scrollView.leftAnchor constraintEqualToAnchor:self.scrollView.superview.leftAnchor constant:0].active = YES;
    [self.scrollView.rightAnchor constraintEqualToAnchor:self.scrollView.superview.rightAnchor constant:0].active = YES;
    [self.scrollView.topAnchor constraintEqualToAnchor:self.scrollView.superview.topAnchor constant:0].active = YES;
    [self.scrollView.bottomAnchor constraintEqualToAnchor:self.scrollView.superview.bottomAnchor constant:0].active = YES;
}

-(UIView *) viewForZoomingInScrollView:(UIScrollView *)inScroll {
    return self.imageView;
}

@end
