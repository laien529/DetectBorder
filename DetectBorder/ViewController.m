//
//  ViewController.m
//  DetectBorder
//
//  Created by chengsc on 2022/2/11.
//

#import "ViewController.h"
#import <Vision/Vision.h>

@interface ViewController ()

@property(nonatomic, weak)IBOutlet UIImageView *orgImageView;
@property(nonatomic, weak)IBOutlet UIImageView *borderedImageView;

@property(nonatomic, strong) UIImage *orgImage;
@property(nonatomic, strong) UIImage *borderedImage;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    _orgImage = [UIImage imageNamed:@"front"];
//    _borderedImage = [UIImage imageNamed:@""];
    UIImage *inputImage = [UIImage imageNamed:@"front.jpg"];
    VNDetectContoursRequest *detectRequest = [VNDetectContoursRequest new];
    detectRequest.revision = VNCoreMLRequestRevision1;
    detectRequest.contrastAdjustment = 1.0;
    detectRequest.detectsDarkOnLight = YES;
    detectRequest.maximumImageDimension = 512;
    
    CIImage *inputCGImage = [CIImage imageWithCGImage:inputImage.CGImage];
    VNImageRequestHandler *imageHandler = [[VNImageRequestHandler alloc] initWithCIImage:inputCGImage options:@{}];
    NSError *error;
    BOOL detectResult = [imageHandler performRequests:@[detectRequest] error:&error];
    
    if (detectResult) {
        VNContoursObservation *observation = detectRequest.results.firstObject;
        NSInteger poinsCount = observation.contourCount;
        UIImage *processImage = [self drawBorder:observation input:inputImage.CGImage];
    } else {
        NSLog(@"detect error:%@", error.description);
    }
}

- (UIImage*)drawBorder:(VNContoursObservation*)observation input:(CGImageRef)inputCGImage {
    CGSize size = CGSizeMake(CGImageGetWidth(inputCGImage), CGImageGetHeight(inputCGImage));
    UIGraphicsImageRenderer *render = [[UIGraphicsImageRenderer alloc] initWithSize:size];
    return  [render imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
        CGContextRef context = rendererContext.CGContext;
        CGAffineTransform flipVertical = CGAffineTransformMake(1,0, 0,-1, 0, size.height);
        CGContextConcatCTM(context, flipVertical);
        CGContextDrawImage(context, CGRectMake(0, 0,size.width , size.height), inputCGImage);
    }];
}

@end
