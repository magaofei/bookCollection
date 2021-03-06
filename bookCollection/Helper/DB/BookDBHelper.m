//
//  BookDBHelper.m
//  bookCollection
//
//  Created by MAMIAN on 2017/1/5.
//  Copyright © 2017年 Gaofei Ma. All rights reserved.
//

#import "BookDBHelper.h"
#import <FMDB/FMDB.h>

@implementation BookDBHelper

+ (NSString *)dbFolder {
    NSString *docsdir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *path = [docsdir stringByAppendingString:@"/db"];
    
    return path;
}

+ (NSString *)dbPath {
    NSString *path = [[[self class] dbFolder] stringByAppendingString:@"/book.sqlite"];
    return path;
}

+ (void)buildDataBase {
    if (![[NSFileManager defaultManager] fileExistsAtPath:[[self class] dbFolder]]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[[self class] dbFolder] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    FMDatabase *db = [FMDatabase databaseWithPath:[[self class] dbPath]];
    if (![db open]) {
        return;
    }
    
    BOOL succ = [[self class] createTableWithDB:db];
    if (succ) {
        NSLog(@"init sql done");
    } else {
        NSLog(@"init sql fail");
    }
    [db close];
}

+ (BOOL)createTableWithDB:(FMDatabase *)db {
    BOOL succ = YES;
    NSArray *array = [[self class] createTableSqls];
    NSInteger count = [array count];
    for (NSInteger i = 0; i < count; i++) {
        NSString *sql = [array objectAtIndex:i];
        if (![db executeUpdate:sql]) {
            succ = NO;
            break;
        }
    }
    return succ;
}

+ (NSArray *)createTableSqls {
    // 注意书写，不可有偏差
    return @[
             @"CREATE TABLE `TB_BOOK_ENTITY`  (\
             `id`  INTEGER PRIMARY KEY AUTOINCREMENT,\
             `doubanId`  INTEGER UNIQUE,\
             `isbn10`    TEXT,\
             `isbn13`    TEXT,\
             `title`     TEXT,\
             `doubanUrl` TEXT,\
             `image`     TEXT,\
             `publisher` TEXT,\
             `pubdate`   TEXT,\
             `price`     TEXT,\
             `summary`   TEXT,\
             `author_intro`  TEXT\
             );",
             
             @"CREATE TABLE `TB_BOOK_TRANSLATOR` (\
             `bookId`    INTEGER,\
             `name`  TEXT,\
             `count`  INTEGER\
             );",
             
             @"CREATE TABLE `TB_BOOK_TAG`  (\
             `bookId`    INTEGER,\
             `name`      TEXT,\
             `count`     INTEGER\
             );",
             
             @"CREATE TABLE `TB_BOOK_AUTHOR`  (\
             `bookId`   INTEGER,\
             `name`     TEXT\
             );"
             ];
    
}

// 抹掉数据并重新创建数据库
+ (void)resetDataBase {
    [[NSFileManager defaultManager] removeItemAtPath:[[self class] dbFolder] error:nil];
    [[self class] buildDataBase];
}


@end
