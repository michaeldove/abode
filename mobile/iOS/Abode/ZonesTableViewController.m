//
//  ZonesTableViewController.m
//  Abode
//
//  Created by Michael Dove on 28/03/2015.
//  Copyright (c) 2015 Michael Dove. All rights reserved.
//

#import "ZonesTableViewController.h"
#import "IrrigationClient.h"
#import "Zone.h"
#import "AbodeCoordinator.h"
#import <ReactiveCocoa/ReactiveCocoa.h>



@interface ZonesTableViewController ()

@property (nonatomic, strong) NSArray *zones;
@property (nonatomic, strong) IrrigationClient *client;
@property (nonatomic, strong) RACSignal *nodeAddressSignal;
@property (nonatomic, strong) RACSignal *viewWillDisappear;
@property (nonatomic, strong) RACSignal *viewWillAppear;

@end

@implementation ZonesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    UITableView *tableView = (UITableView *)self.view;
    tableView.tableFooterView = tableFooterView;
    
    self.viewWillDisappear = [self rac_signalForSelector:@selector(viewWillDisappear:)];
    self.viewWillAppear = [self rac_signalForSelector:@selector(viewWillAppear:)];
    
    self.client = [[IrrigationClient alloc] init];
    self.zones = @[];
    self.nodeAddressSignal = [AbodeCoordinator rac_nodeAddresses];
    RACSignal *clientSignal = [self.nodeAddressSignal map:^id(id hostName) {
        return [[IrrigationClient alloc] initWithHostName:hostName];
    }];
    RACSignal *zoneSignal = [clientSignal flattenMap:^RACStream *(id client) {
        return [client fetchZonesSignal];
    }];
    [zoneSignal subscribeNext:^(id x) {
        UITableView *tableView = (UITableView *)self.view;
        [tableView reloadData];
    }];
    
    
    
    
    [self.nodeAddressSignal subscribeNext:^(id x) {
        NSString *hostName = x;
        // create client
        IrrigationClient *client = [[IrrigationClient alloc] initWithHostName:hostName];
        [self updateListFromClient:client];
        [self startPollingWithClient:client];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.zones.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ZoneCell" forIndexPath:indexPath];
    
    Zone *zone = [self.zones objectAtIndex:indexPath.row];
    // Configure the cell...
    
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:100];
    UILabel *descriptionLabel = (UILabel *)[cell viewWithTag:200];
    UISwitch *onSwitch = (UISwitch *)[cell viewWithTag:300];
    RACSignal *switchChanged = [onSwitch rac_signalForControlEvents:UIControlEventValueChanged];
    [switchChanged subscribeNext:^(id sender) {
        RACSignal *setZoneOnSignal = [self.client setZoneId:zone.zoneId signalWithOn:onSwitch.on];
        [setZoneOnSignal subscribeNext:^(id x) {
        } error:^(NSError *error) {
            NSLog(@"%@", [error localizedDescription]);
        } completed:^{
        }];
    }];
    
    titleLabel.text = zone.name;
    descriptionLabel.text = zone.shortDescription;
    onSwitch.on = zone.on == 1 ? YES : NO;;
    
    return cell;
}


- (void)updateListFromClient:(IrrigationClient *)client {
    RACSignal *zoneSignal = [client fetchZonesSignal];
    [zoneSignal subscribeNext:^(id zones) {
        self.zones = zones;
    } error:^(NSError *error) {
        NSLog(@"%@", [error localizedDescription]);
    } completed:^{
        UITableView *tableView = (UITableView *)self.view;
        [tableView reloadData];
    }];
}

- (void)startPollingWithClient:(IrrigationClient *)client {
    RACSignal *updateEventSignal = [[RACSignal interval:15 onScheduler:[RACScheduler scheduler]]
                                    takeUntil:self.viewWillDisappear];
    [updateEventSignal subscribeNext:^(id x) {
        [self updateListFromClient:client];
    }];
}

@end
