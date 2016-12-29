//
//  ViewController.h
//  ToDoList-App
//
//  Created by NOORUL-MAC on 28/12/16.
//  Copyright © 2016 Noorul Asan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface ViewController : UIViewController<UITextFieldDelegate>
{
    IBOutlet UILabel *lbl_nodata;
    
    IBOutlet UITableView *table_View;
    
    IBOutlet UIView *view_EditAdd;
    IBOutlet UITextField *txtfld_Title;
    IBOutlet UITextField *txtfld_Desc;
    IBOutlet UISegmentedControl *segctrl_completed;
    IBOutlet UIButton *btn_AddUpdate;
}

@end

