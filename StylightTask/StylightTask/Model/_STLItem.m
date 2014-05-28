// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to STLItem.m instead.

#import "_STLItem.h"

const struct STLItemAttributes STLItemAttributes = {
	.creator = @"creator",
	.imageURL = @"imageURL",
	.name = @"name",
};

const struct STLItemRelationships STLItemRelationships = {
};

const struct STLItemFetchedProperties STLItemFetchedProperties = {
};

@implementation STLItemID
@end

@implementation _STLItem

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"STLItem" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"STLItem";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"STLItem" inManagedObjectContext:moc_];
}

- (STLItemID*)objectID {
	return (STLItemID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic creator;






@dynamic imageURL;






@dynamic name;











@end
