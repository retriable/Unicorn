//
//  UniDB.h
//  Unicorn
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const UniDBErrorDomain;

@interface UniDB : NSObject

- (BOOL)open:(NSString *)file error:(NSError ** _Nullable)error;

- (BOOL)close;

- (BOOL)executeUpdate:(NSString *)sql arguments:(NSArray * _Nullable)arguments error:(NSError ** _Nullable)error;

- (BOOL)executeUpdate:(NSString *)sql stmtBlock:(void (^)(sqlite3_stmt *stmt, int idx))stmtBlock error:(NSError **)error;

- (BOOL)executeQuery:(NSString *)sql arguments:(NSArray * _Nullable)arguments resultBlock:(void (^)(sqlite3_stmt *stmt, bool *stop))resultBlock error:(NSError ** _Nullable)error;

- (BOOL)executeQuery:(NSString *)sql stmtBlock:(void (^)(sqlite3_stmt *stmt, int idx))stmtBlock resultBlock:(void (^)(sqlite3_stmt *stmt, bool *stop))resultBlock error:(NSError ** _Nullable)error;

- (NSArray *)executeQuery:(NSString *)sql stmtBlock:(void (^)(sqlite3_stmt *stmt, int idx))stmtBlock error:(NSError ** _Nullable)error;

- (NSArray *)executeQuery:(NSString *)sql arguments:(NSArray * _Nullable)arguments error:(NSError ** _Nullable)error;

- (BOOL)beginTransaction;

- (BOOL)commit;

@end

NS_ASSUME_NONNULL_END
