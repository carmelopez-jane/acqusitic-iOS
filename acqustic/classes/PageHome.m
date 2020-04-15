//
//  PageHome.m
//  Acqustic
//
//  Created by Joan López on 25/10/16.
//  Copyright © 2016 Javier Garcés. All rights reserved.
//

#import "PageHome.h"
#import "AppDelegate.h"
#import "Acqustic.h"
#import "Utils.h"
#import "HeaderEdit.h"
#import "Performance.h"
#import "PerformanceCard.h"
#import "WSDataManager.h"
#import "FormBuilder.h"

@interface PageHome ()

@end

@implementation PageHome

@synthesize vHeader, vHeaderSearch, svContent, collectionView, vFilters, btnApplyFilters;

-(BOOL) onPreloadPage:(PageContext *)context {
    PageHome * refThis = self;
    [theApp showBlockView];
    [WSDataManager getPerformances:^(int code, NSDictionary *result, NSDictionary * badges) {
        [theApp hideBlockView];
        if (code == WS_SUCCESS) {
            [self setBadges:badges];
            refThis->allPerformances = [[NSMutableArray alloc] init];
            refThis->performances = [[NSMutableArray alloc] init];
            NSArray * data = (NSArray *)result;
            for (int i=0;i<data.count;i++) {
                Performance * p = [[Performance alloc] initWithDictionary:data[i]];
                [refThis->allPerformances addObject:p];
                [refThis->performances addObject:p];
            }
            [refThis endPreloading:YES];
        } else {
            [theApp stdError:code];
            [refThis endPreloading:NO];
        }
    }];
    return YES;
}

-(void)onEnterPage:(PageContext *)context {
    
    [super onEnterPage:context];

    [self loadNIB:@"PageHome"];

    _ctx = context;

    [self.vHeader setActiveSection:HEADER_SECTION_HOME];
    [self setupBadges:vHeader];
    
    [self setupFilters];
    
    
    // DataSource... Delegate...
    [collectionView setDataSource:self];
    [collectionView setDelegate:self];
    [collectionView registerClass:PerformanceCard.self forCellWithReuseIdentifier:@"PerformanceCard"];
    
    /*
    UICollectionViewFlowLayout *collectionViewLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    collectionViewLayout.sectionInset = UIEdgeInsetsMake(20, 20, 20, 20); //top 20, left, bottom 20, right
     */
    layout = [[UICustomCollectionViewLayout alloc] init];
    layout.delegate = self;
    collectionView.collectionViewLayout = layout;
    self.vHeaderSearch.vClear.hidden = YES;
    [self.vHeaderSearch.tfSearch addTarget:self action:@selector(tfSearchChange:) forControlEvents:UIControlEventEditingChanged];
    PageHome * refThis = self;
    [Utils setOnClick:self.vHeaderSearch.vClear withBlock:^(UIView *sender) {
        [refThis resetSearch];
    }];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor blackColor];
    refreshControl.attributedTitle = nil;
    [refreshControl addTarget:self action:@selector(onRefresh:) forControlEvents:UIControlEventValueChanged];
    [collectionView addSubview:refreshControl];
    collectionView.alwaysBounceVertical = YES;
}
                                    
-(PageContext *)onLeavePage:(NSString *)destPage {
    return [_ctx clone];
}

-(void) setupFilters {
    filters = [[PerformanceFilters alloc] init];
    
    FBItem * item;
    filtersForm = [[FormBuilder alloc] init];
    item = [[FBItem alloc] init:@"Filtrar actuaciones" fieldType:FIELD_TYPE_SECTION];
    [filtersForm add:item];
    item = [[FBItem alloc] init:@"Publicada desde" fieldType:FIELD_TYPE_DATE fieldName:@"publish_date_from"];
    [filtersForm add:item];
    item = [[FBItem alloc] init:@"Actuación a partir de" fieldType:FIELD_TYPE_DATE fieldName:@"performance_date_from"];
    [filtersForm add:item];
    item = [[FBItem alloc] init:@"Tipología" fieldType:FIELD_TYPE_SELECT fieldName:@"typology"];
    item.valuesIndex = @"OFFER_TYPOLOGY_OPTIONS";
    [filtersForm add:item];
    item = [[FBItem alloc] init:@"Zona" fieldType:FIELD_TYPE_SELECT fieldName:@"location_zone"];
    item.valuesIndex = @"OFFER_LOCATIONZONE_OPTIONS";
    [filtersForm add:item];
    /*
    item = [[FBItem alloc] init:@"Tipo de formación" fieldType:FIELD_TYPE_SELECT fieldName:@"memberpreference"];
    item.valuesIndex = @"OFFER_TYPE_GROUP";
    [filtersForm add:item];
     */
    item = [[FBItem alloc] init:@"Cache desde" fieldType:FIELD_TYPE_SELECT fieldName:@"cacheFrom"];
    item.valuesIndex = @"CACHE_RANGES";
    [filtersForm add:item];
    /*
    item = [[FBItem alloc] init:@"Exclusivo Acqustic" fieldType:FIELD_TYPE_BOOLEAN fieldName:@"exclusive_acqustic"];
    [filtersForm add:item];
    */
    item = [[FBItem alloc] init:@"Sólo ofertas PRO" fieldType:FIELD_TYPE_BOOLEAN fieldName:@"only_pro"];
    [filtersForm add:item];

    int height = [filtersForm fillInForm:self.vFilters from:0 withData:filters];

    // Añadimos los botones
    CGRect fr = self.btnApplyFilters.frame;
    fr.origin.y = height + 20;
    self.btnApplyFilters.frame = fr;
    [self.btnApplyFilters addTarget:self action:@selector(applyFilters) forControlEvents:UIControlEventTouchUpInside];
    
    [Utils setOnClick:self.vHeaderSearch.vFilters withBlock:^(UIView *sender) {
        [self toggleFilters];
    }];
    
    self.vResetFilters.lblLabel.text = @"Eliminar filtros";
    [Utils setOnClick:self.vResetFilters withBlock:^(UIView *sender) {
        [self resetFilters];
    }];
    
}

-(void)tfSearchChange:(UITextField *)tf {
    [self doSearch:tf.text];
}


- (void)onRefresh:(UIRefreshControl *)refreshControl
{
    PageHome * refThis = self; dispatch_async(dispatch_get_main_queue()/*dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)*/, ^{

        /*
        [NSThread sleepForTimeInterval:2];//for 2 seconds, prevent scrollview from bouncing back down (which would cover up the refresh view immediately and stop the user from even seeing the refresh text / animation)
         */
        [self refresh];
        dispatch_async(dispatch_get_main_queue(), ^{
            [refreshControl endRefreshing];
            NSLog(@"refresh end");
        });
    });
}


// Section for Item Count...
- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return performances.count;
}
 
// CustomLayoutProtocol
-(CGFloat) collectionView:(UICollectionView *)collectionView heightForItemAt:(NSIndexPath *)indexPath with:(CGFloat)width {
    Performance * p = performances[indexPath.row];
    // Si ya la habíamos calculado, no hace falta volver a hacerlo
    if (p.cardWidth == width && p.cardHeight > 0)
        return p.cardHeight;
    
    p.cardWidth = width;
    
    if (!measureCardFront)
        measureCardFront = [[PerformanceCardFront alloc] initWithFrame:CGRectMake(0,0,width,350)];
    if (!measureCardBack)
        measureCardBack = [[PerformanceCardBack alloc] initWithFrame:CGRectMake(0,0,width,350)];
    int frontCardHeight = [measureCardFront setPerformance:p];
    int backCardHeight = [measureCardBack setPerformance:p];
    
    if (frontCardHeight > backCardHeight) {
        p.cardHeight = frontCardHeight;
    } else {
        p.cardHeight = backCardHeight;
    }
    
    return (long)p.cardHeight;
}

// CollectionViewCell Item Create...
- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    Performance * p = performances[indexPath.row];
    PerformanceCard *cell = (PerformanceCard *)[self.collectionView dequeueReusableCellWithReuseIdentifier:@"PerformanceCard" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[PerformanceCard alloc] initWithFrame:CGRectMake(0,0,p.cardWidth, p.cardHeight)];
    }
    [cell setPerformance:p];
    return cell;
}

- (UICollectionReusableView *) collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    return nil;
}

// Select Item...
- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"did SelectItem %ld-%ld",indexPath.section,indexPath.row);
    
    PerformanceCard *cell = (PerformanceCard *)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    [cell flip];

}

// De Select Item...
- (void) collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
}

-(void) doSearch:(NSString *)text {
    text = [text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (text.length > 0) {
        self.vHeaderSearch.vClear.hidden = NO;
    } else {
        self.vHeaderSearch.vClear.hidden = YES;
    }
    // Si hay más de 1 letras escritas, filtramos
    if (text.length > 1) {
        [performances removeAllObjects];
        for (int i=0;i<allPerformances.count;i++) {
            if ([allPerformances[i] matchesSearch:text])
                [performances addObject:allPerformances[i]];
        }
    } else {
        [performances removeAllObjects];
        for (int i=0;i<allPerformances.count;i++) {
            [performances addObject:allPerformances[i]];
        }
    }
    // Actualizamos
    [self.collectionView reloadData];

}

-(void) resetSearch {
    self.vHeaderSearch.tfSearch.text = @"";
    [performances removeAllObjects];
    for (int i=0;i<allPerformances.count;i++) {
        [performances addObject:allPerformances[i]];
    }
    [self.collectionView reloadData];
}

-(void) refresh {
    PageHome * refThis = self;
    [WSDataManager getPerformances:^(int code, NSDictionary *result, NSDictionary * badges) {
        if (code == WS_SUCCESS) {
            [self setBadges:badges];
            [self setupBadges:self.vHeader];
            /**/
            [self->filters reset];
            [self->filtersForm updateForm:self->filters];
            [refThis->allPerformances removeAllObjects];
            [refThis->performances removeAllObjects];
            NSArray * data = (NSArray *)result;
            for (int i=0;i<data.count;i++) {
                Performance * p = [[Performance alloc] initWithDictionary:data[i]];
                [refThis->allPerformances addObject:p];
                [refThis->performances addObject:p];
            }
            /**/
            // Vamos allá.
            [refThis.collectionView reloadData];
        } else {
            [theApp stdError:code];
        }
    }];

}

-(void) toggleFilters {
    if (self.vFilters.hidden == NO)
        self.vFilters.hidden = YES;
    else
        self.vFilters.hidden = NO;
}

-(void) applyFilters {
    [filtersForm save:filters];
    [self toggleFilters];
    [performances removeAllObjects];
    for (int i=0;i<allPerformances.count;i++) {
        Performance * p = allPerformances[i];
        if ([p checkFilter:filters])
            [performances addObject:p];
    }
    [self.collectionView reloadData];
}

-(void) resetFilters {
    [filters reset];
    [filtersForm updateForm:filters];
    [self applyFilters];
}
@end
