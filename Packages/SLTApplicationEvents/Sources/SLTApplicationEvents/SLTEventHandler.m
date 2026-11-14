//
//  SLTEventHandler.m
//  SLTApplicationEvents
//
//

#import <SLTApplicationEvents/SLTEventHandler.h>
#import <SLTCommon/SLTCommon.h>

@interface SLTEventHandler ()
@property (nonatomic) dispatch_queue_t eventQueue;
@property (nonatomic) NSMapTable *eventTable;
@property (nonatomic) os_log_t log;
@end

@implementation SLTEventHandler

+ (instancetype)defaultHandler
{
    static dispatch_once_t once;
    static SLTEventHandler *handler;
    dispatch_once(&once, ^{
        handler = [self new];
    });
    return handler;
}

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        self.eventQueue = dispatch_queue_create("io.github.mihirkohli-hash.StayLit.EventQueue", DISPATCH_QUEUE_SERIAL);
        self.eventTable = [NSMapTable strongToStrongObjectsMapTable];
        self.log = SLTLogCreateWithCategory("ApplicationEvents");
    }
    return self;
}

- (void)dealloc
{
    self.eventQueue = nil;
    self.eventTable = nil;
}


#pragma mark - Event Handling

- (void)handleEventForURL:(NSURL *)URL
{
    if(URL == nil) { return; }
    
    AutoWeak weakSelf = self;
    dispatch_async(self.eventQueue, ^{
        Auto event = [weakSelf eventForURL:URL];
        
        SLTEventHandlerActionBlock actionBlock = [self.eventTable objectForKey:event.name];
        if(actionBlock)
        {
            os_log(self.log, "Handling event:\n%{public}@\nfor URL: %{public}@", event, URL);
            // Perform the action block on main queue, but in sync with the event queue
            dispatch_sync(dispatch_get_main_queue(), ^{
                actionBlock(event);
            });
        }
    });
}

- (nullable SLTEvent *)eventForURL:(nonnull NSURL *)URL
{
    Auto URLComponents = [NSURLComponents componentsWithURL:URL resolvingAgainstBaseURL:YES];
    Auto path = URL.lastPathComponent;
    
    // Destructure NSURLQueryItems into basic dictionary values
    Auto arguments = [NSMutableDictionary dictionary];
    for(NSURLQueryItem *queryItem in URLComponents.queryItems)
    {
        AutoVar value = queryItem.value;
        if(!value)
        {
            // fall back to an empty string if the value is nil
            value = @"";
        }
        arguments[queryItem.name] = value;
    }
    
    return [[SLTEvent alloc] initWithName:path arguments:arguments.count > 0 ? arguments : nil];
}

#pragma mark - Event Registration

- (void)registerActionNamed:(NSString *)actionName block:(SLTEventHandlerActionBlock)block
{
    [self.eventTable setObject:block forKey:actionName];
}

- (void)removeActionNamed:(NSString *)actionName
{
    [self.eventTable removeObjectForKey:actionName];
}

@end
