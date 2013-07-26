//
//  MikeTest.m
//  AlfrescoSDK
//
//  Created by Mike Hatfield on 23/07/2013.
//
//

#import "MikeTest.h"

@interface MikeTest()
@property (nonatomic, strong) NSDictionary *environment;
@end

@implementation MikeTest

- (void)setUp
{
    self.environment = [self setupEnvironmentParameters];
    BOOL success = NO;

    if (self.isCloud)
    {
        success = [self authenticateCloudServer];
    }
    else
    {
        success = [self authenticateOnPremiseServer:nil];
    }
    
    [self resetTestVariables];
    self.setUpSuccess = success;
}

- (void)tearDown
{
    // No-op base class override
}

- (void)testPaging
{
    if (self.setUpSuccess)
    {
        NSString *identifier = @"50004641-844d-4da4-9da3-fe9b6a9d182f"; // localhost HEAD-QA
        identifier = @"workspace://SpacesStore/3a404c1d-4e0e-4b01-91c8-c9da42147eba";   // 3point4
        identifier = @"workspace://SpacesStore/db9c2778-ba33-41ff-9f5f-42a7c342701e";   // 4point0 (old)
        
        AlfrescoDocumentFolderService *documentFolderService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        [documentFolderService retrieveNodeWithIdentifier:identifier completionBlock:^(AlfrescoNode *node, NSError *error) {
            AlfrescoFolder *testFolder = (AlfrescoFolder *)node;
            AlfrescoListingContext *paging = [[AlfrescoListingContext alloc] initWithMaxItems:150 skipCount:0];
            
            [documentFolderService retrieveChildrenInFolder:testFolder listingContext:paging completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) {
                if (pagingResult == nil)
                {
                    self.lastTestSuccessful = NO;
                    self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                }
                else
                {
                    XCTAssertTrue(pagingResult.totalItems > 0, @"Expected children to be returned");
                    NSLog(@"%@: totalItems = %d", NSStringFromSelector(_cmd), pagingResult.totalItems);
                    self.lastTestSuccessful = YES;
                }
                self.callbackCompleted = YES;
            }];
        }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
    
}

@end
