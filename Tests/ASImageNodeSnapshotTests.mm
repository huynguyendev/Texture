//
//  ASImageNodeSnapshotTests.mm
//  Texture
//
//  Copyright (c) Facebook, Inc. and its affiliates.  All rights reserved.
//  Changes after 4/13/2017 are: Copyright (c) Pinterest, Inc.  All rights reserved.
//  Licensed under Apache 2.0: http://www.apache.org/licenses/LICENSE-2.0
//

#import "ASSnapshotTestCase.h"

#import <AsyncDisplayKit/AsyncDisplayKit.h>

@interface ASImageNodeSnapshotTests : ASSnapshotTestCase
@end

@implementation ASImageNodeSnapshotTests

- (void)setUp
{
  [super setUp];
  self.recordMode = NO;
}

- (UIImage *)testImage
{
  NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"logo-square"
                                                                    ofType:@"png"
                                                               inDirectory:@"TestResources"];
  return [UIImage imageWithContentsOfFile:path];
}

- (void)testRenderLogoSquare
{
  // trivial test case to ensure ASSnapshotTestCase works
  ASImageNode *imageNode = [[ASImageNode alloc] init];
  imageNode.image = [self testImage];
  ASDisplayNodeSizeToFitSize(imageNode, CGSizeMake(100, 100));

  ASSnapshotVerifyNode(imageNode, nil);
}

- (void)testForcedScaling
{
  CGSize forcedImageSize = CGSizeMake(100, 100);
  
  ASImageNode *imageNode = [[ASImageNode alloc] init];
  imageNode.forcedSize = forcedImageSize;
  imageNode.image = [self testImage];
  
  // Snapshot testing requires that node is formally laid out.
  imageNode.style.width = ASDimensionMake(forcedImageSize.width);
  imageNode.style.height = ASDimensionMake(forcedImageSize.height);
  ASDisplayNodeSizeToFitSize(imageNode, forcedImageSize);
  ASSnapshotVerifyNode(imageNode, @"first");
  
  imageNode.style.width = ASDimensionMake(200);
  imageNode.style.height = ASDimensionMake(200);
  ASDisplayNodeSizeToFitSize(imageNode, CGSizeMake(200, 200));
  ASSnapshotVerifyNode(imageNode, @"second");
  
  XCTAssert(CGImageGetWidth((CGImageRef)imageNode.contents) == forcedImageSize.width * imageNode.contentsScale &&
            CGImageGetHeight((CGImageRef)imageNode.contents) == forcedImageSize.height * imageNode.contentsScale,
            @"Contents should be 100 x 100 by contents scale.");
}

- (void)testTintColorOnNodePropertyAlwaysTemplate
{
  UIImage *test = [self testImage];
  ASImageNode *node = [[ASImageNode alloc] init];
  node.image = [test imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
  node.tintColor = UIColor.redColor;
  ASDisplayNodeSizeToFitSize(node, test.size);
  // Tint color should change view
  ASSnapshotVerifyNode(node, @"red_tint");

  node.tintColor = UIColor.blueColor;
  // Tint color should change view
  ASSnapshotVerifyNode(node, @"blue_tint");
}

- (void)testTintColorOnNodePropertyAutomatic
{
  UIImage *test = [self testImage];
  ASImageNode *node = [[ASImageNode alloc] init];
  node.image = test;
  // Tint color should not change view since it depends on being contained within certain views
  // for automatic rendering to utilize tint color.
  node.tintColor = UIColor.redColor;
  ASDisplayNodeSizeToFitSize(node, test.size);
  ASSnapshotVerifyNode(node, nil);
}

- (void)testTintColorOnNodePropertyAlwaysOriginal
{
  UIImage *test = [self testImage];
  ASImageNode *node = [[ASImageNode alloc] init];
  node.image = [test imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
  // Tint color should not have changed since the image render mode is original
  node.tintColor = UIColor.redColor;
  ASDisplayNodeSizeToFitSize(node, test.size);
  ASSnapshotVerifyNode(node, nil);
}

- (void)testTintColorOnNodePropertyAlwaysTemplateLayerBackedNode
{
  // Test support for layerBacked image node tinting
  UIImage *test = [self testImage];
  ASImageNode *node = [[ASImageNode alloc] init];
  [node setLayerBacked:YES];
  node.tintColor = UIColor.redColor;
  node.image = [test imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
  ASDisplayNodeSizeToFitSize(node, test.size);
  ASSnapshotVerifyNode(node, nil);
}


- (void)testTintColorInheritsFromSupernodeLayerBacked
{
   // Test support for layerBacked image node tinting
  ASDisplayNode *container = [[ASDisplayNode alloc] init];
  [container setLayerBacked:YES];
  container.tintColor = UIColor.redColor;
  UIImage *test = [self testImage];
  ASImageNode *node = [[ASImageNode alloc] init];
  [node setLayerBacked:YES];
  node.tintColor = UIColor.redColor;
  node.image = [test imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
  [container addSubnode:node];
  container.style.preferredSize = test.size;
  ASDisplayNodeSizeToFitSize(node, test.size);
  ASSnapshotVerifyNode(node, nil);
}

- (void)testTintColorInheritsFromSupernodeViewBacked
{
  // Test support for layerBacked image node tinting
  ASDisplayNode *container = [[ASDisplayNode alloc] init];
  [container setLayerBacked:NO];
  container.tintColor = UIColor.redColor;
  UIImage *test = [self testImage];
  ASImageNode *node = [[ASImageNode alloc] init];
  [node setLayerBacked:YES];
  node.image = [test imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
  [container addSubnode:node];
  container.style.preferredSize = test.size;
  ASDisplayNodeSizeToFitSize(node, test.size);
  ASSnapshotVerifyNode(node, nil);
}

- (void)testRoundedCornerBlock
{
  UIGraphicsBeginImageContext(CGSizeMake(100, 100));
  [[UIColor blueColor] setFill];
  UIRectFill(CGRectMake(0, 0, 100, 100));
  UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  UIImage *rounded = ASImageNodeRoundBorderModificationBlock(2, [UIColor redColor])(result);
  ASImageNode *node = [[ASImageNode alloc] init];
  node.image = rounded;
  ASDisplayNodeSizeToFitSize(node, rounded.size);
  ASSnapshotVerifyNode(node, nil);
}

@end
