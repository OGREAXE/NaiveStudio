//
//  NCMainViewCell.m
//  NaiveStudio
//
//  Created by Liang,Zhiyuan(GIS) on 2018/2/26.
//  Copyright © 2018年 Liang,Zhiyuan(GIS). All rights reserved.
//

#import "NCMainViewCell.h"

@interface NCMainViewCell()

@property (nonatomic) UIImageView * seperator;

@end

@implementation NCMainViewCell
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIImageView * seperator = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-1, self.bounds.size.width, 1)];
        seperator.backgroundColor = [UIColor colorWithRed:200/255.0 green:199/255.0 blue:204/255.0 alpha:1.0];
        [self.contentView addSubview:seperator];
        self.seperator = seperator;
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    self.seperator.frame = CGRectMake(0, self.bounds.size.height, self.bounds.size.width, 1);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
@end
