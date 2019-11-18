//
//  FileManagerViewController.m
//  Laboratory
//
//  Created by wangfulin-yfzx on 2019/11/18.
//  Copyright © 2019 zzz-yfzx. All rights reserved.
//

#import "FileManagerViewController.h"

@interface FileManagerViewController ()<UIDocumentPickerDelegate>

@end

@implementation FileManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

#pragma mark - Save file to File app
/*
 * 通过UIActivityViewController将文件数据存入File app中.
 */
- (IBAction)saveFile
{
    // get file data
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"FileApp.md" ofType:nil];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    
    // 注意: 将文件存入沙盒中并不能在File app中访问.
    /*
    NSString *docPath = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory,NSUserDomainMask, YES).firstObject;
    NSString *targetPath = [docPath stringByAppendingPathComponent:filePath.lastPathComponent];
    NSError *err;
    [data writeToFile:targetPath options:NSDataWritingFileProtectionNone error:&err];
    if (err) {
        NSLog(@"err : %@", err.description);
    }
     */
    
    if (!data) return;
    
    UIActivity *activity = [[UIActivity alloc] init];
    // 最后一个参数可以是nil
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[@"Name To Present to User", data] applicationActivities:@[activity]];
    [self presentViewController:activityVC animated:YES completion:nil];
}

#pragma mark - Get file from File app
/*
 * UIDocumentPickerViewController用来访问Files app中所有文件
 */
- (IBAction)showDocumentPickerVC
{
    NSArray *documentTypes = @[@"public.content", @"public.text", @"public.source-code ", @"public.image", @"public.audiovisual-content", @"com.adobe.pdf", @"com.apple.keynote.key", @"com.microsoft.word.doc", @"com.microsoft.excel.xls", @"com.microsoft.powerpoint.ppt"];
    
    UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:documentTypes inMode:UIDocumentPickerModeOpen];
    documentPicker.delegate = self;
    documentPicker.modalPresentationStyle = UIModalPresentationFullScreen;
    
    [self presentViewController:documentPicker animated:YES completion:nil];
}

#pragma mark UIDocumentPickerDelegate
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url {
    
    BOOL fileUrlAuthozied = [url startAccessingSecurityScopedResource];
    if(fileUrlAuthozied){
        NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] init];
        NSError *error;
        __block NSData *fileData;
        [fileCoordinator coordinateReadingItemAtURL:url options:0 error:&error byAccessor:^(NSURL *newURL) {
            
            NSString *fileName = [newURL lastPathComponent];
//            NSString *ext = fileName.pathExtension;
            NSLog(@"%@", fileName);
//            NSString *fileStr = [NSString stringWithContentsOfURL:newURL encoding:NSUTF8StringEncoding error:nil];
            fileData = [NSData dataWithContentsOfURL:newURL];
            
            [self dismissViewControllerAnimated:YES completion:NULL];
        }];
        [url stopAccessingSecurityScopedResource];
        
    }else{
        //Error handling
        
    }
}
@end
