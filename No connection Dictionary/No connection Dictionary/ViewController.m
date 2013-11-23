//                                                                             / \
//  ViewController.m                                                          /   \
//  No connection Dictionary                                                 /     \
//                                                                           ここ選択すると  TODOコロン ~  で記述したコメントを見ることができる
//  Created by Shinya Hirai on 2013/11/22.　　　　　　　　　　　　　　　　　　　　　#pragma mark を記述したところでグループ分けをしてくれるので見やすくなる
//  Copyright (c) 2013年 Shinya Hirai. All rights reserved.
//


/*
 【ネットに繋がなくても使える辞書アプリ】
 このアプリは、インターネットに接続されていなくても使える辞書アプリです。
 Wi-fiがないと携帯が使えない海外なんかで活躍するでしょう。
 
 【コード説明】
 データの保存には、iOSでのデータ保存に特化した専用の上位フレームワーク[Core Data]を使用。
 かなりハードルが高いがTableViewとの相性が良い。
 
 コード内のコメントに多々出てくる  // TODOコロン ~  という記述の仕方で右上に書いてあるコメントの部分を
 タップするとTODO管理ができる。
 
 #pragma mark -
 #pragma mark コメント
 という記述は同じく右上のバーの部分をタップして見た時に、コードのグループ分けがされた状態で表示される。
 
 
 */

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController {
    NSString* _nowSearchStr;
    NSMutableArray* _beforeHistoryArr;
    NSMutableArray* _afterhistoryArr;
}

- (NSManagedObject *)checkDupulicationInEntity:(NSString *) entityName withKey:(NSString *)keyString withValue:(NSString *)valueString{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:entityName];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@", keyString, valueString];
    [fetchRequest setPredicate:predicate];
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSArray *results = [appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    if (results.count > 0) {
        return [results objectAtIndex:0];
    }
    
    return NULL;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    /*
     Core Dataに保存する処理
     */
     AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    // _nowSearchStrがnil,nullではなく、文字の長さが0ではなければ、要するに空でなければCore Dataに保存し、tableviewに履歴として表示
    if (![_nowSearchStr isEqual:[NSNull null]] && [_nowSearchStr length] > 0) {
        
        // エンティティはHistoryという名前のNSManagedObjectのサブクラス。
        NSManagedObjectContext *context = [appDelegate managedObjectContext];
        NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"History" inManagedObjectContext:context];
        
        // 検索した日時のデータと検索したワードをCore Dataに保存
        [newManagedObject setValue:[NSDate date] forKey:@"added"];
        [newManagedObject setValue:_nowSearchStr forKey:@"history"];
        
        // Save the context.
        NSError *error = nil;
        if (![context save:&error]) {
            // もしエラーなら内容を表示
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } else {
            NSLog(@"save to coredata");
        }
    } else {
        NSLog(@"検索窓は空");
    }
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
    
    // アプリが初めて起動された時だけこのif文を通し、アラートビューを使ってThanksメッセージを表示する。
    // NSUserDefaultsの取得
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // KEY_BOOLの内容を取得し、BOOL型変数へ格納
    BOOL isBool = [defaults boolForKey:@"KEY_BOOL"];
    // isBoolがNOの場合、...
    if (!isBool) {
        
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"ようこそ！"
                                                            message:@"nowifi辞書は、留学や海外旅行などで海外にでているとき等、ネット環境が整っていない場面でもわからない単語をその場でサクサク検索ができるアプリです。"
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"サクサク検索", nil];
        [alertView show];
        
        // KEY_BOOLにYESを設定
        [defaults setBool:YES forKey:@"KEY_BOOL"];
        // 設定を保存
        [defaults synchronize];
        NSLog(@"アプリをダウンロードして初回起動時のみ処理");
    }
    
    // Core Data 用
    _objectChanges = [NSMutableArray array];
    _sectionChanges = [NSMutableArray array];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark tableview

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections] [section];
    return [sectionInfo numberOfObjects];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Cellの生成と初期化
    static NSString* cellIdentifier = @"Cell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];

    // TODO: cellには検索履歴と必要なら検索した日時を取得して表示する ※Done
    cell.textLabel.text = [object valueForKey:@"history"];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: cellタップ時にlabelに表示されている履歴(文字列)で検索する
    NSString* string = 
}

#pragma mark -
#pragma mark search bar
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    // サーチボタンが押された時の処理
    // TODO: modalの遷移の仕方をiOS7っぽくする
    UIReferenceLibraryViewController* libraryViewController = [[UIReferenceLibraryViewController alloc] initWithTerm:_searchBar.text];
    [self presentViewController:libraryViewController animated:YES completion:nil];
    // 検索した文字を履歴データとして保存
    _nowSearchStr = [[NSString alloc] init];
    _nowSearchStr = _searchBar.text;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    NSLog(@"textdidbegin");
    CGSize screenSize = [[UIScreen mainScreen] applicationFrame].size;
	[UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
	_searchBar.frame = CGRectMake(0, screenSize.height - 240, 320, 44);
	_tableView.frame = CGRectMake(0, 0, 320, screenSize.height - 240);
	[UIView commitAnimations];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    // キャンセルボタンが押された時の処理
    [_searchBar resignFirstResponder];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    CGSize screenSize = [[UIScreen mainScreen] applicationFrame].size;
	_searchBar.frame = CGRectMake(0, screenSize.height - 24, 320, 44);
	_tableView.frame = CGRectMake(0, 0, 320, screenSize.height - 24);
	[UIView commitAnimations];
}

#pragma mark -
#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"History" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"added" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

/*
 // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
 {
 // In the simplest, most efficient, case, reload the table view.
 [self.tableView reloadData];
 }
 */

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [[object valueForKey:@"timeStamp"] description];
}

@end
