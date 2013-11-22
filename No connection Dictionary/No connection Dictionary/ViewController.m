//
//  ViewController.m
//  No connection Dictionary
//
//  Created by Shinya Hirai on 2013/11/22.
//  Copyright (c) 2013年 Shinya Hirai. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController {
    NSString* _nowSearchStr;
    NSMutableArray* _beforeHistoryArr;
    NSMutableArray* _afterhistoryArr;
}

-(void)viewWillAppear:(BOOL)animated {
    NSLog(@"viewWillAppear");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // TableView
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    // SearchBar
    _searchBar.delegate = self;
    // TODO: 以下２つのプロパティについて調査
    _searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    _searchBar.spellCheckingType = UITextSpellCheckingTypeNo;
    
    // NSUserDefaultsの取得
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
    // KEY_BOOLの内容を取得し、BOOL型変数へ格納
    BOOL isBool = [defaults boolForKey:@"KEY_BOOL"];
    // isBoolがNOの場合、...
    if (!isBool) {
        // KEY_BOOLにYESを設定
        [defaults setBool:YES forKey:@"KEY_BOOL"];
        // 設定を保存
        [defaults synchronize];
        NSLog(@"初回起動時のみ処理");
    }
    _beforeHistoryArr = [[NSMutableArray alloc] init];  // 初期化 0
    _afterhistoryArr = [[NSMutableArray alloc] init];  // 初期化 0
    
}

-(void)viewDidAppear:(BOOL)animated {
    NSLog(@"viewDidAppear");
//    [self unarchive];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark tableview
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Cellの生成と初期化
    static NSString* cellIdentifier = @"Cell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // TODO: cellには検索履歴と必要なら検索した日時を取得して表示する
    cell.textLabel.text = [NSString stringWithFormat:@"test = %ld", (long)indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: cellタップ時にlabelに表示されている履歴(文字列)で検索する
}

#pragma mark -
#pragma mark search bar
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    // サーチボタンが押された時の処理
    // TODO: modalの遷移の仕方をiOS7っぽくする
    UIReferenceLibraryViewController* libraryViewController = [[UIReferenceLibraryViewController alloc] initWithTerm:_searchBar.text];
    [self presentViewController:libraryViewController animated:YES completion:nil];
    // 検索した文字を履歴データとして保存
    _nowSearchStr = [[NSString alloc] init];  // 初期化 0
    _nowSearchStr = _searchBar.text;  // 1
    NSLog(@"_nowSearchStr = %@",_nowSearchStr);
    [_beforeHistoryArr addObject:_nowSearchStr];  // 1 ~
    [self archive];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    // キャンセルボタンが押された時の処理
    [_searchBar resignFirstResponder];
}

#pragma mark -
#pragma mark archive and unarchive
-(void)archive {
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSLog(@"paths = %@",paths);
    NSString* filePath = [paths[0] stringByAppendingString:@"/data.dat"];
//    NSLog(@"filePath = %@",filePath);
    
    [_beforeHistoryArr writeToFile:filePath atomically:YES];
    NSLog(@"_afterHistoryArr = %@",_beforeHistoryArr);
}

-(void)unarchive {
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* filePath = [paths[0] stringByAppendingString:@"/data.dat"];
    
    NSArray *array = [NSArray arrayWithContentsOfFile:filePath];
    NSLog(@"array = %@",array);
    [_afterhistoryArr addObjectsFromArray:array];
    NSLog(@"_afterHistoryArr = %@",_afterhistoryArr);
}

#pragma mark -

@end
