//
//  STLCollectionViewCell.h
//  StylightTask
//
//  Created by Bernhard Obereder on 28.05.14.
//  Copyright (c) 2014 Bernhard Obereder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STLCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UILabel *creatorLabel;


@end
