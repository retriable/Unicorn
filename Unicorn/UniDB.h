//
//  UniDB.h
//  Unicorn
//


#import <sqlite3.h>
#import <Foundation/Foundation.h>

extern NSString *const UniDBErrorDomain;

@interface UniDB : NSObject

- (BOOL)open:(NSString *)file error:(NSError **)error;

- (BOOL)close;

- (BOOL)executeUpdate:(NSString *)sql arguments:(NSArray *)arguments error:(NSError **)error;

- (BOOL)executeUpdate:(NSString *)sql stmtBlock:(void (^)(sqlite3_stmt *stmt, int idx))stmtBlock error:(NSError **)error;

- (BOOL)executeQuery:(NSString *)sql arguments:(NSArray *)arguments resultBlock:(void (^)(sqlite3_stmt *stmt, bool *stop))resultBlock error:(NSError **)error;

- (BOOL)executeQuery:(NSString *)sql stmtBlock:(void (^)(sqlite3_stmt *stmt, int idx))stmtBlock resultBlock:(void (^)(sqlite3_stmt *stmt, bool *stop))resultBlock error:(NSError **)error;

- (NSArray *)executeQuery:(NSString *)sql stmtBlock:(void (^)(sqlite3_stmt *stmt, int idx))stmtBlock error:(NSError **)error;

- (NSArray *)executeQuery:(NSString *)sql arguments:(NSArray *)arguments error:(NSError **)error;

- (BOOL)beginTransaction;

- (BOOL)commit;

@end
