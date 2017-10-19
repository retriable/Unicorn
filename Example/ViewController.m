//
//  ViewController.m
//  Example
//
//  Created by emsihyo on 2017/1/11.

#import "ViewController.h"
#import <sys/time.h>
#import "Article.h"

static inline void Benchmark(void (^block)(void), void (^complete)(double ms)) {
    struct timeval t0, t1;
    gettimeofday(&t0, NULL);
    block();
    gettimeofday(&t1, NULL);
    double ms = (double)(t1.tv_sec - t0.tv_sec) * 1e3 + (double)(t1.tv_usec - t0.tv_usec) * 1e-3;
    complete(ms);
}

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"::::\nlibary path:\n%@\n::::",[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject]);
    NSMutableDictionary *userJsonDict=[[NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"user" ofType:@"json"]] options:0 error:nil] mutableCopy];
    NSMutableDictionary *articleJsonDict = [@{
                                       @"id":@"12345",
                                       @"title":@"title",
                                       @"intro":@"intro",
                                       @"score":@"0",
                                       } mutableCopy];
    articleJsonDict[@"author"]=[userJsonDict mutableCopy];
    int start = 100000;
    int count = 3000;
    NSMutableArray *articleJsonDicts = [NSMutableArray arrayWithCapacity:count];
    NSMutableArray *userJosnDicts=[NSMutableArray arrayWithCapacity:count];
    for (int i = start; i < 100000+count; i++) {
        NSMutableDictionary *userDict = [userJsonDict mutableCopy];
        userDict[@"id"] = @(i);
        userDict[@"public_repos"] = @(arc4random()%count);
        userDict[@"public_gists"] = @(arc4random()%count);
        userDict[@"followers"] = @(arc4random()%count);
        userDict[@"following"] = @(arc4random()%count);
        userDict[@"date"] = @([[NSDate date] timeIntervalSince1970]-arc4random()%count);
        [userJosnDicts addObject:userDict];
        NSMutableDictionary *jsonDict = [articleJsonDict mutableCopy];
        jsonDict[@"id"] = @(i+count);
        jsonDict[@"author"]=userDict;
        [articleJsonDicts addObject:jsonDict];
    }
    Benchmark(^{
        [User uni_modelsWithJsonDictionaries:userJosnDicts];
//        [Article uni_modelsWithJsonDictionaries:articleJsonDicts];
    }, ^(double ms) {
        NSLog(@"\n::::\n%.2f\n::::", ms);
    });
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
