//
//  ZPTableViewController.m
//  用storyboard自定义等高的cell
//
//  Created by apple on 16/5/18.
//  Copyright © 2016年 apple. All rights reserved.
//

/**
 不管做什么操作（添加、删除、更新、编辑），都必须保证操作后的对象的个数要和列表中的cell的个数相同，否则运行后会崩溃。
 
 在做添加、删除、更新操作的时候要遵循两个步骤：
（1）在对象数组中变更（添加、删除、更新）对象；
（2）刷新被变更（添加、删除、更新）的对象所对应的cell。
 */
#import "ZPTableViewController.h"
#import "ZPDeal.h"
#import "ZPTableViewCell.h"

@interface ZPTableViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *deals;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ZPTableViewController

#pragma mark ————— 懒加载 —————
-(NSMutableArray *)deals
{
    if (_deals == nil)
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"deals" ofType:@"plist"];
        NSArray *dicArray = [NSArray arrayWithContentsOfFile:path];
        
        NSMutableArray *tempArray = [NSMutableArray array];
        for (NSDictionary *dic in dicArray)
        {
            ZPDeal *deal = [ZPDeal dealWithDict:dic];
            [tempArray addObject:deal];
        }
        
        _deals = tempArray;
    }
    
    return _deals;
}

#pragma mark ————— 生命周期 —————
- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark ————— 正常添加对象 —————
- (IBAction)normalAdd
{
    //创建新对象
    ZPDeal *deal = [[ZPDeal alloc] init];
    deal.buyCount = @"20";
    deal.price = @"30";
    deal.title = @"鱼香肉丝";
    deal.icon = @"2c97690e72365e38e3e2a95b934b8dd2";
    
    /**
     数组的addObject方法会直接把新创建的对象放在数组的末尾，而insertObject方法则可以把对象添加到数组的指定位置。
     */
    [self.deals insertObject:deal atIndex:0];
    
    /**
     如果调用reloadData方法，则屏幕上出现一个cell系统就会调用一次创建该行cell所对应的cellForRowAtIndexPath方法，屏幕上出现多少个cell系统就会调用多少次cellForRowAtIndexPath方法。由此可见，调用reloadData方法的作用是刷新整个列表的数据。当只变更（增加、删除、更新）一行cell的时候，系统也会按照上述的逻辑去多次调用cellForRowAtIndexPath方法来刷新整个列表的数据；
     如果调用insertRowsAtIndexPaths方法，则当变更一行cell的时候系统只会调用一次创建该行cell所对应的cellForRowAtIndexPath方法，而创建其他行cell所对应的cellForRowAtIndexPath方法则不会被调用。由此可见，调用insertRowsAtIndexPaths方法的作用是只刷新变更行的数据，而列表中其他行的数据则不会被刷新。
     综上所述，如果只是变更一行cell的话，则应当调用insertRowsAtIndexPaths方法来刷新那行cell，这样比调用reloadData方法会大大节省系统的资源，提高系统的性能。
     */
//    [self.tableView reloadData];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:0], nil] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark ————— 在弹出框上添加对象 —————
- (IBAction)popUpAdd
{
    /**
     UIAlertView和UIActionSheet已经被废弃了，由警告控制器(UIAlertController)来代替它们；
     UIAlertController的UIAlertControllerStyleAlert样式与UIAlertView相同，都是呈现在屏幕中间的菜单选择界面；
     UIAlertController的UIAlertControllerStyleActionSheet样式与UIActionSheet相同，都是从屏幕底下向上钻出来的最后呈现在屏幕底部的菜单选择界面。
     */
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"标题" message:@"信息" preferredStyle:UIAlertControllerStyleAlert];
    
    //在UIAlertController上添加“确定”按钮
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //创建新对象
        ZPDeal *deal = [[ZPDeal alloc] init];
        deal.buyCount = @"55";
        deal.price = [[alertController.textFields objectAtIndex:1] text];
        deal.title = [[alertController.textFields firstObject] text];
        deal.icon = @"5ee372ff039073317a49af5442748071";
        
        //把新对象插入到对象数组中
        [self.deals insertObject:deal atIndex:0];
 
        //单行刷新新增加的对象所对应的cell
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
    }]];
    
    //在UIAlertController上添加“取消”按钮
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    //在UIAlertController上添加“破坏性按钮”按钮
    [alertController addAction:[UIAlertAction actionWithTitle:@"破坏性按钮" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"点击了破坏性按钮");
    }]];
    
    /**
     在UIAlertController中添加文本输入框；
     只有在UIAlertController的样式为UIAlertControllerStyleAlert的时候才能在界面上添加文本输入框了，而当为UIAlertControllerStyleActionSheet样式的时候则不能在界面上添加文本输入框。
     */
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入团购商品的名字";
    }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入团购商品的价格";
    }];
    
    //弹出UIAlertController
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark ————— 点击“删除”按钮 —————
- (IBAction)remove:(id)sender
{
    //删除对象数组中特定位置的对象
    [self.deals removeObjectAtIndex:0];
    
    //删除被删除的对象所对应的cell
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:0], nil] withRowAnimation:UITableViewRowAnimationTop];
}

#pragma mark ————— 点击“更新”按钮 —————
- (IBAction)update
{
    //修改对象
    ZPDeal *deal = [self.deals objectAtIndex:3];
    deal.price = [NSString stringWithFormat:@"%d", 50 + arc4random_uniform(100)];
    
    //单行刷新被修改的对象所对应的cell
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:3 inSection:0], nil] withRowAnimation:UITableViewRowAnimationBottom];
}

#pragma mark ————— 点击“编辑”按钮 —————
- (IBAction)switchMode
{
    [self.tableView setEditing:!self.tableView.isEditing animated:YES];
}

#pragma mark ————— UITableViewDataSource —————
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.deals.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"cellForRowAtIndexPath--%zd", indexPath.row);
    
    ZPTableViewCell *cell = [ZPTableViewCell cellWithTableView:tableView];
    cell.deal = [self.deals objectAtIndex:indexPath.row];
    
    return cell;
}

/**
 在非编辑模式(self.tableView.isEditing == NO)下，只要实现了这个方法，左滑cell就会出现删除按钮；
 在编辑模式(self.tableView.isEditing == YES)下，系统先会调用editingStyleForRowAtIndexPath方法来判断每行cell是删除(UITableViewCellEditingStyleDelete)模式还是插入(UITableViewCellEditingStyleInsert)模式，然后点击cell上面的“加号”或“删除”按钮就会调用这个方法。
 */
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)  //删除操作
    {
        [self.deals removeObjectAtIndex:indexPath.row];
        
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationMiddle];
    }else if (editingStyle == UITableViewCellEditingStyleInsert)  //插入操作
    {
        NSLog(@"点击了加号按钮");
    }
}

#pragma mark ————— UITableViewDelegate —————
/**
 在编辑模式(self.tableView.isEditing == YES)下，系统会调用这个方法来确定每行cell的编辑类型，删除(UITableViewCellEditingStyleDelete)还是插入(UITableViewCellEditingStyleInsert)。
 */
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row % 2 == 0)  //偶数行删除
    {
        return UITableViewCellEditingStyleDelete;
    }else  //奇数行插入
    {
        return UITableViewCellEditingStyleInsert;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
