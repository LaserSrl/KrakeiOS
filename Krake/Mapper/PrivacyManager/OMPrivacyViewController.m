//
//  OMPrivacyManager.m
//  OrchardGen
//
//  Created by Patrick on 08/04/15.
//  Copyright (c) 2015 Dream Team. All rights reserved.
//

#import "OMPrivacyViewController.h"
#import "OMPrivacyCollectionViewCell.h"
#import "OGLCoreDataMapper.h"
#import "NSString+OrchardMapping.h"
#import "OGLCoreDataMapper.h"
#import <Krake/Krake-Swift.h>

@interface OMPrivacyViewController () <UICollectionViewDataSource,UICollectionViewDelegate, WKUIDelegate, WKNavigationDelegate, UIAdaptivePresentationControllerDelegate>
{
    NSArray *arrPolicy;
    NSMutableDictionary *response;
}
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *undoButton;
@property (weak, nonatomic) IBOutlet UIPageControl *pager;

@property (nonatomic) NSArray* importedObject;

@end

@implementation OMPrivacyViewController

+(OMPrivacyViewController*)generateViewControllerWithObjectID:(id)importedObject{
    NSBundle *bundle = [[NSBundle alloc]initWithURL:[[NSBundle bundleForClass:self.class] URLForResource:@"PrivacyManager" withExtension:@"bundle"]];
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"OMPrivacy" bundle:bundle];
    OMPrivacyViewController *privacyVC = [story instantiateInitialViewController];
    [privacyVC setImportedObject:importedObject];
    dispatch_async(dispatch_get_main_queue(), ^{
        [privacyVC setModalPresentationStyle:UIModalPresentationFormSheet];
    });
    return privacyVC;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    self.presentationController.delegate = self;
    response = [[NSMutableDictionary alloc] init];
    
    NSMutableArray *tmpArray = [[NSMutableArray alloc] initWithCapacity:[self.importedObject count]];
    for (id obj in self.importedObject) {
        id<PolicyProtocol> elem = (id<PolicyProtocol>)[[[OGLCoreDataMapper sharedInstance] managedObjectContext] objectWithID:obj];
        [tmpArray addObject:elem];
    }
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"policyTextInfoPartPriority" ascending:NO];
    arrPolicy = [tmpArray sortedArrayUsingDescriptors:@[sort]];
    [self.collectionView reloadData];
    if (arrPolicy.count == 1) {
        [self.pager setHidden:YES];
    }else{
        self.pager.numberOfPages = arrPolicy.count;
        self.pager.currentPage = 0;
        self.pager.pageIndicatorTintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3];
    }
    [self.nextButton setTitle:Commons.next forState:UIControlStateNormal];
    [[KTheme currentObjc] applyThemeToButton:self.nextButton style:ButtonStylePolicy];
    
    [self.undoButton setTitle:Commons.close forState:UIControlStateNormal];
    [[KTheme currentObjc] applyThemeToButton:self.undoButton style:ButtonStylePolicy];
    
    
    [[KTheme currentObjc] applyThemeToView:self.view style:ViewStylePolicy];
    
    [self.pager setHidden:YES];
    self.collectionView.layer.cornerRadius = 15.0;
    self.collectionView.layer.borderColor = [[KTheme currentObjc] color:ColorStyleTint].CGColor;
    self.collectionView.layer.borderWidth = 2.0;
}

-(BOOL)prefersStatusBarHidden{
    return false;
}

-(void)viewDidLayoutSubviews{
    
    CGSize size;
    switch (arrPolicy.count) {
        case 1:
            size = CGSizeMake(self.collectionView.frame.size.width-16, self.collectionView.frame.size.height-16);
            break;
        case 2:
            size = CGSizeMake(self.collectionView.frame.size.width-16, self.collectionView.frame.size.height/2 - 24);
            break;
        default:{
            size = CGSizeMake(self.collectionView.frame.size.width-16, self.collectionView.frame.size.height/2 - 32);
            break;
        }
    }
    [(UICollectionViewFlowLayout*)[self.collectionView collectionViewLayout] setItemSize:size];
}

-(IBAction)termAccepted:(id)sender{
    
    [[KNetworkAccess sharedInstance] sendPolicies:response viewController:self];
    
}

-(IBAction)changePrivacyIndex:(id)sender{
    NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:self.pager.currentPage inSection:0];
    [self.collectionView scrollToItemAtIndexPath:nextIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

-(IBAction)undoPrivacy:(id)sender{
    
    [[KNetworkAccess sharedInstance] sendPolicies:nil viewController:self];
}

#pragma mark - UICollectionView Delegate

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return arrPolicy.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    OMPrivacyCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    id<PolicyProtocol> elem = [arrPolicy objectAtIndex:indexPath.row];
    
    cell.elem = elem;
    cell.response = response;
    cell.parent = self;
    cell.privacyBody.navigationDelegate = self;
    cell.privacyBody.UIDelegate = self;
    [self checkStatus];
    
    
    return cell;
}


-(void)checkStatus{
    BOOL beToSave = true;
    for (id<PolicyProtocol> elem in arrPolicy) {
        if (elem.policyTextInfoPartUserHaveToAccept.integerValue == 1)
        {
            if (![response[[elem.identifier stringValue]] boolValue] || !response[[elem.identifier stringValue]]) {
                beToSave = false;
                break;
            }
        }
    }
    if (!beToSave){
        [self.nextButton setEnabled:NO];
    }else{
        [self.nextButton setEnabled:YES];
    }
    
    
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset {
    
    CGPoint point = *targetContentOffset;
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    CGFloat visibleWidth = layout.minimumInteritemSpacing + layout.itemSize.width;
    int indexOfItemToSnap = round(point.x / visibleWidth);
    
    
    self.pager.currentPage = indexOfItemToSnap;
}


#pragma mark - WKWebViewDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    
    NSRange httpRange = [[[navigationAction.request URL] description] rangeOfString:@"http://"];
    if(httpRange.location != NSNotFound){
        [[UIApplication sharedApplication] openURL:[navigationAction.request URL] options:[[NSDictionary alloc] init] completionHandler:nil];
        decisionHandler(WKNavigationActionPolicyCancel);
    }
    
    NSRange range   = [[[navigationAction.request URL] description] rangeOfString:@"applewebdata://"];
    if (range.location != NSNotFound){
        decisionHandler(WKNavigationActionPolicyCancel);
    }
    
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)presentationControllerDidDismiss:(UIPresentationController *)presentationController {
    [self undoPrivacy:nil];
}

@end
