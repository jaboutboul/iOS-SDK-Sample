//
// SettingsViewController.m
// 
// Created by ooVoo on July 22, 2013
//
// © 2013 ooVoo, LLC.  License under Apache 2.0 license. http://www.apache.org/licenses/LICENSE-2.0.html 
//

#import "SettingsViewController.h"
#import "PickerInputTableViewCell.h"
#import "ooVooController.h"

typedef enum
{
    CameraRow = 0,
    NUMBER_OF_SETTINGS_ROWS
}
SettingsRow;

NSString * const kSettingNamesArray[] =
{
    @"Camera",
};


@interface SettingsViewController () <UIPickerViewDataSource, UIPickerViewDelegate>
{
    NSUInteger currentValues[NUMBER_OF_SETTINGS_ROWS];
}

@property (nonatomic, strong) NSArray *namesForRow;

@end

@implementation SettingsViewController

#pragma mark - UIViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Settings";
    [self loadCurrentValues];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return NUMBER_OF_SETTINGS_ROWS;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    PickerInputTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[PickerInputTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = kSettingNamesArray[indexPath.row];
    
    NSUInteger currentIndex = currentValues[indexPath.row];
    
    NSArray *names = self.namesForRow[indexPath.row];
    if (currentIndex < [names count])
    {
        cell.detailTextLabel.text = self.namesForRow[indexPath.row][currentIndex];
    }
    else
    {
        cell.detailTextLabel.text = @"N/A";
    }
    
    cell.picker.tag = indexPath.row;
    cell.picker.dataSource = self;

    if ([names count] > 1)
    {
        cell.picker.delegate = self;
        cell.selectedRow = currentIndex;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    else
    {
        cell.picker.delegate = nil;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
   return [NSString stringWithFormat:@"SDK Version: %@", [ooVooController sharedController].sdkVersion];
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
{
    return [self.namesForRow[pickerView.tag] count];
}

#pragma mark - UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
{
    return self.namesForRow[pickerView.tag][row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    SettingsRow settingRow = pickerView.tag;
    currentValues[settingRow] = row;
    [self applyChangeForRow:settingRow];
    [self.tableView reloadData];
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:settingRow inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
}

#pragma mark - SDK
- (void)loadCurrentValues
{
    ooVooController *ooVoo = [ooVooController sharedController];

    currentValues[CameraRow] = [ooVoo currentCamera];
}

- (NSArray *)namesForRow
{
    if (!_namesForRow)
    {
        ooVooController *ooVoo = [ooVooController sharedController];
        _namesForRow = @[[ooVoo cameraNames]];
    }
    
    return _namesForRow;
}

- (void)applyChangeForRow:(SettingsRow)row
{
    ooVooController *ooVoo = [ooVooController sharedController];

    switch (row)
    {
        case CameraRow:
            [ooVoo selectCamera:currentValues[CameraRow]];
            break;

        default:
            break;
    }
}

@end
