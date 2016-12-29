//
//  ViewController.m
//  ToDoList-App
//
//  Created by NOORUL-MAC on 28/12/16.
//  Copyright © 2016 Noorul Asan. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (strong) NSManagedObject *selected_Todo;
@property (strong) NSMutableArray *todolist;
@end

@implementation ViewController

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.selected_Todo = nil;
    view_EditAdd.alpha = 0.0;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self load_CoreData];
}

#pragma mark - Managed Object Context
- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}


#pragma mark - Load Core data values
-(void)load_CoreData
{
    // Fetch the devices from persistent data store
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Todolist"];
    self.todolist = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    lbl_nodata.alpha = 0.0;
    if (self.todolist.count == 0)
    {
        lbl_nodata.alpha = 1.0;
        //[self addtodolist]; //add dummy todo's for testing
    }
    
    [table_View reloadData];
}


#pragma mark - Add Dummy Values for Testing
-(void)addtodolist
{
    for (int i = 1 ; i < 6; i++)
    {
        NSString *str_Title = [NSString stringWithFormat:@"TEST DATA-%d", i];
        NSString *str_Desc = [NSString stringWithFormat:@"TEST DESCRIPTION-%d", i];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterLongStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
        NSString *str_Date = [dateFormatter stringFromDate:[NSDate date]];
        
        [self addCoreDateValues:YES Title:str_Title Desc:str_Desc Date:str_Date completed:@"N" stats:@"Y"];
    }
}


#pragma mark - Add or Update Core data values
-(void)addCoreDateValues:(BOOL)NewValue Title:(NSString *)str_Title Desc:(NSString *)str_Desc Date:(NSString *)str_Date completed:(NSString *)str_Completed stats:(NSString *)str_Status
{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    if (NewValue == YES)
    {
        // Create a New Todo Values
        NSManagedObject *new_todo_Object = [NSEntityDescription insertNewObjectForEntityForName:@"Todolist" inManagedObjectContext:context];
        [new_todo_Object setValue:str_Title forKey:@"title"];
        [new_todo_Object setValue:str_Desc forKey:@"desc"];
        [new_todo_Object setValue:str_Date forKey:@"datetime"];
        [new_todo_Object setValue:str_Completed forKey:@"completed"];
        [new_todo_Object setValue:str_Status forKey:@"status"];
    }
    else
    {
        // Update existing Todo Values
        [self.selected_Todo setValue:str_Title forKey:@"title"];
        [self.selected_Todo setValue:str_Desc forKey:@"desc"];
        [self.selected_Todo setValue:str_Date forKey:@"datetime"];
        [self.selected_Todo setValue:str_Completed forKey:@"completed"];
        [self.selected_Todo setValue:str_Status forKey:@"status"];
    }
    
    NSError *error = nil;
    // Save the object to persistent store
    if (![context save:&error])
    {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.todolist.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    NSManagedObject *todo_object = [self.todolist objectAtIndex:indexPath.row];
    
    NSString *str_Title_Txt = [[NSString stringWithFormat:@"%@", [todo_object valueForKey:@"title"]]uppercaseString];
    [cell.textLabel setText: str_Title_Txt];
    [cell.detailTextLabel setText:[NSString stringWithFormat:@"Created Date: %@", [todo_object valueForKey:@"datetime"]]];
    [cell.detailTextLabel setFont:[UIFont fontWithName:@"Times New Roman" size:10.0]];
    if ([[todo_object valueForKey:@"completed"] isEqualToString:@"Y"])
    {
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    }
    else
    {
        cell.textLabel.textColor = [UIColor greenColor];
        cell.detailTextLabel.textColor = [UIColor orangeColor];
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete object from database
        [context deleteObject:[self.todolist objectAtIndex:indexPath.row]];
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
            return;
        }
        // Remove device from table view
        [self.todolist removeObjectAtIndex:indexPath.row];
        [table_View deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        lbl_nodata.alpha = 0.0;
        if (self.todolist.count == 0)
        {
            lbl_nodata.alpha = 1.0;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selected_Todo = nil;
    NSManagedObject *selectedTodo = [self.todolist objectAtIndex:indexPath.row]; //[[table_View indexPathForSelectedRow] row]
    self.selected_Todo = selectedTodo;
    [self open_AddEditView:NO];
}


#pragma mark - Show and Hide the AddEditView
-(void)open_AddEditView:(BOOL)AddNew
{
    view_EditAdd.alpha = 1.0;
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    [animation setFromValue:[NSNumber numberWithFloat:0.0f]];
    [animation setToValue:[NSNumber numberWithFloat:1.0f]];
    [animation setDuration:0.2];
    [animation setBeginTime:CACurrentMediaTime()];
    [animation setRemovedOnCompletion:NO];
    [animation setFillMode:kCAFillModeForwards];
    [[view_EditAdd layer] addAnimation:animation forKey:@"scale"];
    
    [btn_AddUpdate setTag:100];
    [btn_AddUpdate setTitle:@"ADD" forState:UIControlStateNormal];
    [txtfld_Title setText:@""];
    [txtfld_Desc setText:@""];
    segctrl_completed.selectedSegmentIndex = 0;
    
    if (AddNew == NO)
    {
        [btn_AddUpdate setTag:200];
        [btn_AddUpdate setTitle:@"UPDATE" forState:UIControlStateNormal];
        
        [txtfld_Title setText:[self.selected_Todo valueForKey:@"title"]];
        [txtfld_Desc setText:[self.selected_Todo valueForKey:@"desc"]];
        NSString *str_txt_segment = [[self.selected_Todo valueForKey:@"completed"] uppercaseString];
        if ([str_txt_segment isEqualToString:@"Y"])
        {
            segctrl_completed.selectedSegmentIndex = 1;
        }
        else
        {
            segctrl_completed.selectedSegmentIndex = 0;
        }
    }
}

-(void)hide_AddEditView
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    [animation setFromValue:[NSNumber numberWithFloat:1.0f]];
    [animation setToValue:[NSNumber numberWithFloat:0.0f]];
    [animation setDuration:0.2];
    [animation setBeginTime:CACurrentMediaTime()];
    [animation setRemovedOnCompletion:NO];
    [animation setFillMode:kCAFillModeForwards];
    [[view_EditAdd layer] addAnimation:animation forKey:@"scale"];
    
    [self performSelector:@selector(hide_ViewEditAdd) withObject:nil afterDelay:0.2];
}

-(void)hide_ViewEditAdd
{
    view_EditAdd.alpha = 0.0;
}


#pragma mark - Button Action - Add New, Save and Close
-(IBAction)AddNew_Todo:(id)sender
{
    [self open_AddEditView:YES];
}

-(IBAction)save_AddEditView:(id)sender
{
    [txtfld_Title resignFirstResponder];
    [txtfld_Desc resignFirstResponder];
    
    UIButton *btn = (UIButton *)sender;
    int btn_tag = (int)btn.tag;

    NSString *str_Title = [NSString stringWithFormat:@"%@", txtfld_Title.text];
    NSString *str_Desc = [NSString stringWithFormat:@"%@", txtfld_Desc.text];
    
    if (str_Title.length > 0 && str_Desc.length > 0)
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterLongStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
        NSString *str_Date = [dateFormatter stringFromDate:[NSDate date]];
        
        NSString *str_Completed = [NSString stringWithFormat:@"N"];
        if (segctrl_completed.selectedSegmentIndex == 1)
        {
            str_Completed = [NSString stringWithFormat:@"Y"];
        }
        if (btn_tag == 200)
        {
            [self addCoreDateValues:NO Title:str_Title Desc:str_Desc Date:str_Date completed:str_Completed stats:@"Y"];
        }
        else
        {
            [self addCoreDateValues:YES Title:str_Title Desc:str_Desc Date:str_Date completed:str_Completed stats:@"Y"];
        }
        [self hide_AddEditView];
        [self load_CoreData];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Message" message:@"Fill the details" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

-(IBAction)close_AddEditView:(id)sender
{
    [self hide_AddEditView];
}

#pragma mark - Text Field Delegates
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Memory Warning Messages
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
