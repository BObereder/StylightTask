// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to STLItem.h instead.

#import <CoreData/CoreData.h>


extern const struct STLItemAttributes {
	__unsafe_unretained NSString *creator;
	__unsafe_unretained NSString *imageURL;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *timeStamp;
} STLItemAttributes;

extern const struct STLItemRelationships {
} STLItemRelationships;

extern const struct STLItemFetchedProperties {
} STLItemFetchedProperties;







@interface STLItemID : NSManagedObjectID {}
@end

@interface _STLItem : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (STLItemID*)objectID;





@property (nonatomic, strong) NSString* creator;



//- (BOOL)validateCreator:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* imageURL;



//- (BOOL)validateImageURL:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* timeStamp;



//- (BOOL)validateTimeStamp:(id*)value_ error:(NSError**)error_;






@end

@interface _STLItem (CoreDataGeneratedAccessors)

@end

@interface _STLItem (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveCreator;
- (void)setPrimitiveCreator:(NSString*)value;




- (NSString*)primitiveImageURL;
- (void)setPrimitiveImageURL:(NSString*)value;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSDate*)primitiveTimeStamp;
- (void)setPrimitiveTimeStamp:(NSDate*)value;




@end
