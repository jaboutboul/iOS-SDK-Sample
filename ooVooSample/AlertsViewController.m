//
// AlertsViewController.h
// 
// Created by ooVoo on July 22, 2013
//
// © 2013 ooVoo, LLC.  License under Apache 2.0 license. http://www.apache.org/licenses/LICENSE-2.0.html 
//

#import "AlertsViewController.h"

@interface AlertsViewController ()
@property (nonatomic, strong) UITextView *alertsTextView;
@end

@implementation AlertsViewController

#pragma mark - UIViewController
- (void)viewDidLoad
{
    [super viewDidLoad];    
 
    self.title = @"Alerts";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];

    self.alertsTextView = [[UITextView alloc] initWithFrame:self.view.bounds];
    self.alertsTextView.editable = NO;
    self.alertsTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.alertsTextView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!self.logsController.textViewLogger.textView)
    {
        self.alertsTextView.text = @"\n";
        self.logsController.textViewLogger.textView = self.alertsTextView;
    }
    [self.alertsTextView flashScrollIndicators];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.logsController.textViewLogger.textView = nil;
}

#pragma mark - Actions
- (void)done
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
