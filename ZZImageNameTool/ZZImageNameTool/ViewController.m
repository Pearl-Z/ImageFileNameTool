//
//  ViewController.m
//  ZZImageNameTool
//
//  Created by xcz on 16/7/18.
//  Copyright © 2016年 Pearl-Z. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextView *pathTextView;

@property (weak, nonatomic) IBOutlet UITextField *addPrefixTextField;
@property (weak, nonatomic) IBOutlet UITextField *addSuffixTextField;
@property (weak, nonatomic) IBOutlet UIButton *addButton;


@property (weak, nonatomic) IBOutlet UITextField *deletePreNumTextField;
@property (weak, nonatomic) IBOutlet UIButton *deletePreNumButton;

@property (weak, nonatomic) IBOutlet UITextField *deleteSufNumTextField;
@property (weak, nonatomic) IBOutlet UIButton *deleteSufNumButton;

@property (weak, nonatomic) IBOutlet UITextField *deleteStringTextField;
@property (weak, nonatomic) IBOutlet UIButton *deleteStringButton;

@property (weak, nonatomic) IBOutlet UITextField *batchNumTextField;
@property (weak, nonatomic) IBOutlet UITextField *batchStrTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *batchSegment;
@property (weak, nonatomic) IBOutlet UIButton *batchButton;

@property(nonatomic,strong) NSMutableArray *files; //过滤后的文件名
@property(nonatomic,strong) NSArray *supportSuffix;//支持的后缀名,只有包含的后缀名才会处理,统一使用小写
@property(nonatomic,strong) NSString *NPath;       //新文件夹地址
@property(nonatomic,strong) NSFileManager *mgr;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _pathTextView.layer.borderWidth = 1;
    _pathTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    _mgr = [NSFileManager defaultManager];
    _supportSuffix = @[@"png",@"jpg"];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)checkPath:(NSString *)path{
    
    // 判断路径是否为文件夹
    BOOL dir = NO;
    [_mgr fileExistsAtPath:path isDirectory:&dir];
    if (!dir) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"路径不是文件夹" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
        return NO;
    }
    
    
    
    NSError *error = [NSError new];
    NSLog(@"过滤前--%@",[_mgr contentsOfDirectoryAtPath:path error:&error]);
    
    // 读取文件夹中的内容
    _files = [NSMutableArray arrayWithArray:[_mgr contentsOfDirectoryAtPath:path error:&error]];
    
    // 过滤不支持的后缀名
    NSMutableSet *temp = [NSMutableSet set];
    for (NSString *name in _files) {
        if (![_supportSuffix containsObject:[[name pathExtension] lowercaseString]]) {
            [temp addObject:name];
        }
    }
    for (id name in temp) {
        [_files removeObject:name];
    }
    NSLog(@"过滤后--%@",_files);
    
    
    //创建新文件夹
    _NPath = [path stringByAppendingString:@"_handled"];
    [_mgr removeItemAtPath:_NPath error:nil];
    [_mgr createDirectoryAtPath:_NPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    return YES;
    
}

#pragma mark - 按钮点击
//添加前缀后缀
- (IBAction)addBtnClick {
    if ([self checkPath:_pathTextView.text]) {
        for (NSString *name in self.files) {
            NSString *filePath = [NSString stringWithFormat:@"%@/%@",_pathTextView.text,name];
            
            //添加前缀
            NSString *NFilePath = [NSString stringWithFormat:@"%@/%@%@",_NPath,_addPrefixTextField.text,name];
            
            // 添加后缀
            NFilePath = [NFilePath stringByReplacingCharactersInRange:NSMakeRange(NFilePath.length - [NFilePath pathExtension].length - 1, [NFilePath pathExtension].length+1) withString:[NSString stringWithFormat:@"%@.%@",_addSuffixTextField.text,[NFilePath pathExtension]]];
            
            [_mgr copyItemAtPath:filePath toPath:NFilePath error:nil];
        }
    }
}



//删除文件名前几位字符
- (IBAction)deletePreNumBtnClick {
    if (![_deletePreNumTextField.text integerValue]) {
        return;
    }
    
    if ([self checkPath:_pathTextView.text]) {
        for (NSString *name in self.files) {
            NSString *filePath = [NSString stringWithFormat:@"%@/%@",_pathTextView.text,name];
            
            NSString *NFilePath = [NSString stringWithFormat:@"%@/%@",_NPath,[name substringFromIndex:[_deletePreNumTextField.text integerValue]]];
        
            [_mgr copyItemAtPath:filePath toPath:NFilePath error:nil];
        }
    }
}


//删除文件名后几位字符
- (IBAction)deleteSufNumBtnClick {
    if (![_deleteSufNumTextField.text integerValue]) {
        return;
    }
    
    if ([self checkPath:_pathTextView.text]) {
        for (NSString *name in self.files) {
            
            NSString *filePath = [NSString stringWithFormat:@"%@/%@",_pathTextView.text,name];
            NSString *NFilePath;
            
            // 如果删除的位数超过原来的位数，则不处理
            if (_deleteSufNumTextField.text.integerValue >= name.length - [name pathExtension].length - 1) {
                NFilePath = [NSString stringWithFormat:@"%@/%@",_NPath,name];
            }else{
                NSString *NName = [name stringByReplacingCharactersInRange:NSMakeRange(name.length - [name pathExtension].length - 1 - _deleteSufNumTextField.text.integerValue, _deleteSufNumTextField.text.integerValue) withString:@""];
                NFilePath = [NSString stringWithFormat:@"%@/%@",_NPath,NName];
            }
            [_mgr copyItemAtPath:filePath toPath:NFilePath error:nil];
        }
    }
}

//删除文件名中包含的字符串
- (IBAction)deleteStringBtnClick {
    if ([self checkPath:_pathTextView.text]) {
        for (NSString *name in self.files) {
            
            NSString *filePath = [NSString stringWithFormat:@"%@/%@",_pathTextView.text,name];
            
            NSString *NName = [name stringByReplacingCharactersInRange:NSMakeRange(name.length - [name pathExtension].length - 1, [name pathExtension].length + 1) withString:@""];
            NName = [NName stringByReplacingOccurrencesOfString:_deleteStringTextField.text withString:@""];
            
            NSString *NFilePath = [NSString stringWithFormat:@"%@/%@.%@",_NPath,NName,[name pathExtension]];
            
            [_mgr copyItemAtPath:filePath toPath:NFilePath error:nil];
        }
    }
}

//将文件名处理成统一带编号的形式
- (IBAction)batchBtnClick {
    
    if ([self checkPath:_pathTextView.text]) {
        
        //过滤处理
        NSString *pathExtension = [self.files.firstObject pathExtension];
        for (NSString *name in self.files) {
            if (![[name pathExtension] isEqualToString:pathExtension]) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"处理的文件必须是同一个扩展名，你可以删除原来文件夹中的图片，或者更改配置_supportSuffix" preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                }]];
                [self presentViewController:alertController animated:YES completion:nil];
                return;
            }
        }
        
        for (int i = 1; i<=self.files.count; i++) {
            NSString *name = self.files[i-1];
            NSString *filePath = [NSString stringWithFormat:@"%@/%@",_pathTextView.text,name];
            
            // 添加尺寸后缀
            NSString *sizeStr;
            switch (_batchSegment.selectedSegmentIndex) {
                case 0:
                    sizeStr = @"";
                    break;
                    
                case 1:
                    sizeStr = @"@1x";
                    break;
                    
                case 2:
                    sizeStr = @"@2x";
                    break;
                    
                case 3:
                    sizeStr = @"@3x";
                    break;
                    
                default:
                    break;
            }
            
            // 生成编号
            NSString *numStr = [NSString stringWithFormat:@"%d",i];
            while (numStr.length < _batchNumTextField.text.intValue) {
                numStr = [NSString stringWithFormat:@"0%@",numStr];
            }
            
            NSString *NFilePath = [NSString stringWithFormat:@"%@/%@%@%@.%@",_NPath,_batchStrTextField.text,numStr,sizeStr,name.pathExtension];
            
            [_mgr copyItemAtPath:filePath toPath:NFilePath error:nil];
        }
        
    }
}






@end
