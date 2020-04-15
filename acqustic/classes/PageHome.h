//
//  PageHome.h
//  Acqustic
//
//  Created by Joan López on 25/10/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "PageBase.h"
#import "HeaderNav.h"
#import "HeaderSearch.h"
#import "acqustic-Swift.h"
#import "PerformanceCardFront.h"
#import "PerformanceCardBack.h"
#import "PerformanceFilters.h"
#import "FormBuilder.h"
#import "FormItemDelete.h"

@interface PageHome : PageBase<UICollectionViewDataSource, UICollectionViewDelegate, CustomLayoutDelegate> {
    PageContext *_ctx;
    UICustomCollectionViewLayout * layout;
    PerformanceCardFront * measureCardFront;
    PerformanceCardBack * measureCardBack;
    NSMutableArray * allPerformances;
    NSMutableArray * performances;
    FormBuilder * filtersForm;
    PerformanceFilters * filters;
}

@property (strong, nonatomic) IBOutlet HeaderNav *vHeader;
@property (strong, nonatomic) IBOutlet HeaderSearch *vHeaderSearch;
@property (strong, nonatomic) IBOutlet UIScrollView *svContent;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UIView *vFilters;
@property (strong, nonatomic) IBOutlet FormItemDelete *vResetFilters;
@property (strong, nonatomic) IBOutlet UIButton *btnApplyFilters;


@end
