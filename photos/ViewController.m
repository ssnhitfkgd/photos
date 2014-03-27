//
//  ViewController.m
//  photos
//
//  Created by wangyong on 13-10-15.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "ViewController.h"
#import "UIImageView+MJWebCache.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"
#import "TFHpple.h"
@interface ViewController ()
{
    NSArray *_urls;
    NSMutableArray *_downloadImages;
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // 0.图片链接

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://blog.csdn.net/yanzi1225627/article/details/22222735"]];
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSArray *imagesData =  [self parseData:response];
    _urls = [self downLoadPicture:imagesData];
    
    int count = _urls.count;
    // 1.封装图片数据
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count; i++) {
        // 替换为中等尺寸图片
        NSString *url = [_urls[i] stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"bmiddle"];
        MJPhoto *photo = [[MJPhoto alloc] init];
        photo.url = [NSURL URLWithString:url]; // 图片路径
        UIImageView *imageView = [UIImageView new];
        //[imageView setImageURL:photo.url placeholder:nil];
        photo.srcImageView = imageView; // 来源于哪个UIImageView
        [photos addObject:photo];
    }
    
    // 2.显示相册
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = 0; // 弹出相册时显示的第一张图片是？
    browser.photos = photos; // 设置所有的图片
   // [browser show];
    [self addChildViewController:browser];

    [self.view addSubview:browser.view];
}

- (void)tapImage:(UITapGestureRecognizer *)tap
{
    int count = _urls.count;
    // 1.封装图片数据
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i<count; i++) {
        // 替换为中等尺寸图片
        NSString *url = [_urls[i] stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"bmiddle"];
        MJPhoto *photo = [[MJPhoto alloc] init];
        photo.url = [NSURL URLWithString:url]; // 图片路径
        UIImageView *imageVIewer = [UIImageView new];
        [imageVIewer setImageURL:photo.url placeholder:nil];
        photo.srcImageView = imageVIewer; // 来源于哪个UIImageView
        [photos addObject:photo];
    }
    
    // 2.显示相册
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = tap.view.tag; // 弹出相册时显示的第一张图片是？
    browser.photos = photos; // 设置所有的图片
    [browser show];
}

//解析html数据
- (NSArray*)parseData:(NSData*) data
{
    TFHpple *doc = [[TFHpple alloc] initWithHTMLData:data];
    
    //在页面中查找img标签
    NSArray *images = [doc searchWithXPathQuery:@"//img"];
    return images;
}


//下载图片的方法
- (NSMutableArray*)downLoadPicture:(NSArray *)images
{
    //创建存放UIImage的数组
    _downloadImages = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [images count]; i++){
        NSString *prefix = [[[images objectAtIndex:i] objectForKey:@"src"] substringToIndex:4];
        NSString *url = [[images objectAtIndex:i] objectForKey:@"src"];
        
        //判断图片的下载地址是相对路径还是绝对路径，如果是以http开头，则是绝对地址，否则是相对地址
        if ([prefix isEqualToString:@"http"] == NO){
            url = [@"http://blog.csdn.net/yanzi1225627/article/details/22222735" stringByAppendingPathComponent:url];
        }
        
        [_downloadImages addObject:url];

        NSLog(@"下载图片的URL:%@", url);
    }
    return _downloadImages;
}



@end
