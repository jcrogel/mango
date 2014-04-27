//
// Copyright (c) 2012 Jason Kozemczak
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
// documentation files (the "Software"), to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
// and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO
// THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
// ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//


#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import "CKCalendarView.h"

#define BUTTON_MARGIN 2
#define BUTTON_WIDTH 25
#define CALENDAR_MARGIN 5
#define TOP_HEIGHT 30
#define DAYS_HEADER_HEIGHT 22
#define DEFAULT_CELL_WIDTH 43
#define CELL_BORDER_WIDTH 0

#define NSColorFromRGB(rgbValue) [NSColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


@class CALayer;
@class CAGradientLayer;

@interface GradientView : NSView

@property(nonatomic, strong, readonly) CAGradientLayer *gradientLayer;
- (void)setColors:(NSArray *)colors;

@end

@implementation GradientView

- (id)init {
    return [self initWithFrame:CGRectZero];
}

+ (Class)layerClass {
    return [CAGradientLayer class];
}

- (CAGradientLayer *)gradientLayer {
    return (CAGradientLayer *)self.layer;
}

- (void)setColors:(NSArray *)colors {
    NSMutableArray *cgColors = [NSMutableArray array];
    for (NSColor *color in colors) {
        [cgColors addObject:(__bridge id)color.CGColor];
    }
    self.gradientLayer.colors = cgColors;
}

@end


@interface DateButton : NSButton

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSColor *titleColor;
@property (nonatomic, strong) CKDateItem *dateItem;
@property (nonatomic, strong) NSCalendar *calendar;

@end

@implementation DateButton

- (void)setDate:(NSDate *)date {
    _date = date;
    if (date) {
        NSDateComponents *comps = [self.calendar components:NSDayCalendarUnit|NSMonthCalendarUnit fromDate:date];
        [self setTitle:[NSString stringWithFormat:@"%ld", (long)comps.day]];
    } else {
        [self setTitle:@""];
    }
}

@end

@implementation CKDateItem

- (id)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [NSColor colorWithRed:242 green:242 blue:242 alpha:1];
        self.selectedBackgroundColor = [NSColor colorWithRed:136 green:182 blue:219 alpha:1];
        self.textColor = [NSColor colorWithRed:57 green:59 blue:64 alpha:1];
        self.selectedTextColor = [NSColor colorWithRed:242 green:242 blue:242 alpha:1];
    }
    return self;
}

@end

@interface CKCalendarContainer : NSView

@end

@implementation CKCalendarContainer

- (BOOL)isFlipped
{
    return YES;
}

@end

@interface CKCalendarView ()

@property(nonatomic, strong) NSView *highlight;
@property(nonatomic, strong) NSTextField *titleLabel;
@property(nonatomic, strong) NSButton *prevButton;
@property(nonatomic, strong) NSButton *nextButton;
@property(nonatomic, strong) CKCalendarContainer *calendarContainer;
@property(nonatomic, strong) GradientView *daysHeader;
@property(nonatomic, strong) NSArray *dayOfWeekLabels;
@property(nonatomic, strong) NSMutableArray *dateButtons;
@property(nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) NSDate *monthShowing;
@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, strong) NSCalendar *calendar;
@property(nonatomic, assign) CGFloat cellWidth;

@end

@implementation CKCalendarView

@dynamic locale;

- (id)init {
    return [self initWithStartDay:startSunday];
}

- (id)initWithStartDay:(CKCalendarStartDay)firstDay {
    return [self initWithStartDay:firstDay frame:CGRectMake(0, 0, 320, 320)];
}

- (void)_init:(CKCalendarStartDay)firstDay {
    self.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [self.calendar setLocale:[NSLocale currentLocale]];

    self.cellWidth = DEFAULT_CELL_WIDTH;

    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    self.dateFormatter.dateFormat = @"LLLL yyyy";

    self.calendarStartDay = firstDay;
    self.onlyShowCurrentMonth = YES;
    self.adaptHeightToNumberOfWeeksInMonth = YES;

    self.layer.cornerRadius = 6.0f;

    NSView *highlight = [[NSView alloc] initWithFrame:CGRectZero];
    [highlight setWantsLayer:YES];
    highlight.layer.backgroundColor = [NSColor colorWithWhite:1.0 alpha:0.2].CGColor;
    highlight.layer.cornerRadius = 6.0f;
    [self addSubview:highlight];
    self.highlight = highlight;

    // SET UP THE HEADER
    NSTextField *titleLabel = [[NSTextField alloc] initWithFrame:CGRectZero];
    titleLabel.alignment = kCTTextAlignmentCenter;
    titleLabel.backgroundColor = [NSColor clearColor];
    // CHECKME titleLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    [self addSubview:titleLabel];
    self.titleLabel = titleLabel;

    NSButton *prevButton = [[NSButton alloc] init];
    [prevButton setImage:[NSImage imageNamed:@"LeftArrow"]];
    [prevButton setImagePosition:NSImageOnly];
    [[prevButton cell] setImageScaling: NSImageScaleProportionallyUpOrDown];
    [prevButton setBordered:NO];
    [prevButton setTarget:self];
    [prevButton setAction:@selector(_moveCalendarToPreviousMonth) ];
    [self addSubview:prevButton];
    self.prevButton = prevButton;

    NSButton *nextButton = [[NSButton alloc]  init];
    [nextButton setImage:[NSImage imageNamed:@"RightArrow"]];
    [nextButton setImagePosition:NSImageOnly];
    [[nextButton cell] setImageScaling: NSImageScaleProportionallyUpOrDown];
    [nextButton setBordered:NO];
    [nextButton setTarget:self];
    [nextButton setAction:@selector(_moveCalendarToNextMonth) ];
    [self addSubview:nextButton];
    self.nextButton = nextButton;

    // THE CALENDAR ITSELF
    CKCalendarContainer *calendarContainer = [[CKCalendarContainer alloc] initWithFrame:CGRectZero];
    calendarContainer.layer.borderWidth = 1.0f;
    calendarContainer.layer.borderColor = [NSColor blackColor].CGColor;
    //calendarContainer.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    calendarContainer.layer.cornerRadius = 4.0f;
    //calendarContainer.clipsToBounds = YES;
    [self addSubview:calendarContainer];
    self.calendarContainer = calendarContainer;

    GradientView *daysHeader = [[GradientView alloc] initWithFrame:CGRectZero];
    daysHeader.autoresizingMask = NSViewMinXMargin;
    [self.calendarContainer addSubview:daysHeader];
    self.daysHeader = daysHeader;

    NSMutableArray *labels = [NSMutableArray array];
    for (int i = 0; i < 7; ++i) {
        NSTextField *dayOfWeekLabel = [[NSTextField alloc] initWithFrame:CGRectZero];
        [dayOfWeekLabel setEditable:NO];
        dayOfWeekLabel.alignment = kCTTextAlignmentCenter;
        dayOfWeekLabel.backgroundColor = [NSColor clearColor];
        [dayOfWeekLabel setBordered:NO];
        [labels addObject:dayOfWeekLabel];
        [self.calendarContainer addSubview:dayOfWeekLabel];
    }
    self.dayOfWeekLabels = labels;
    [self _updateDayOfWeekLabels];

    // at most we'll need 42 buttons, so let's just bite the bullet and make them now...
    NSMutableArray *dateButtons = [NSMutableArray array];
    for (NSInteger i = 1; i <= 42; i++) {
        DateButton *dateButton = [[DateButton alloc] init];
        dateButton.calendar = self.calendar;
        [dateButton setBordered:NO];
        [dateButton setTarget:self];
        [dateButton setAction:@selector(_dateButtonPressed:)];
        [dateButtons addObject:dateButton];
    }
    self.dateButtons = dateButtons;

    // initialize the thing
    self.monthShowing = [NSDate date];
    [self _setDefaultStyle];
    
    [self layout]; // TODO: this is a hack to get the first month to show properly
}

- (id)initWithStartDay:(CKCalendarStartDay)firstDay frame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _init:firstDay];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    return [self initWithStartDay:startSunday frame:frame];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _init:startSunday];
    }
    return self;
}

- (void)layout {
    
    CGFloat containerWidth = self.bounds.size.width - (CALENDAR_MARGIN * 2);
    self.cellWidth = (floorf(containerWidth / 7.0)) - CELL_BORDER_WIDTH;

    NSInteger numberOfWeeksToShow = 6;
    if (self.adaptHeightToNumberOfWeeksInMonth) {
        numberOfWeeksToShow = [self _numberOfWeeksInMonthContainingDate:self.monthShowing];
    }
    CGFloat containerHeight = (numberOfWeeksToShow * (self.cellWidth + CELL_BORDER_WIDTH) + DAYS_HEADER_HEIGHT);

    CGRect newFrame = self.frame;
    newFrame.size.height = containerHeight + CALENDAR_MARGIN + TOP_HEIGHT;
    self.frame = newFrame;
    self.layer.borderColor = [NSColor redColor].CGColor;

    self.highlight.frame = CGRectMake(1, 1, self.bounds.size.width - 2, 1);

    self.titleLabel.stringValue = [self.dateFormatter stringFromDate:_monthShowing];
    [self.titleLabel setEditable:NO];
    self.titleLabel.frame = CGRectMake(0, 0, self.bounds.size.width, TOP_HEIGHT);
    self.prevButton.frame = CGRectMake(BUTTON_MARGIN, BUTTON_MARGIN, BUTTON_WIDTH, BUTTON_WIDTH);
    self.nextButton.frame = CGRectMake(self.bounds.size.width - BUTTON_WIDTH - 10, BUTTON_MARGIN, BUTTON_WIDTH, BUTTON_WIDTH);

    self.calendarContainer.frame = CGRectMake(CALENDAR_MARGIN, CGRectGetMaxY(self.titleLabel.frame), containerWidth, containerHeight);
    self.daysHeader.frame = CGRectMake(0, 0, self.calendarContainer.frame.size.width, DAYS_HEADER_HEIGHT);

    CGRect lastDayFrame = CGRectZero;
    for (NSTextField *dayLabel in self.dayOfWeekLabels) {
        dayLabel.frame = CGRectMake(CGRectGetMaxX(lastDayFrame) + CELL_BORDER_WIDTH, lastDayFrame.origin.y, self.cellWidth, self.daysHeader.frame.size.height);
        lastDayFrame = dayLabel.frame;
    }

    for (DateButton *dateButton in self.dateButtons) {
        dateButton.date = nil;
        [dateButton removeFromSuperview];
    }

    NSDate *date = [self _firstDayOfMonthContainingDate:self.monthShowing];
    if (!self.onlyShowCurrentMonth) {
        while ([self _placeInWeekForDate:date] != 0) {
            date = [self _previousDay:date];
        }
    }

    NSDate *endDate = [self _firstDayOfNextMonthContainingDate:self.monthShowing];
    if (!self.onlyShowCurrentMonth) {
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        [comps setWeek:numberOfWeeksToShow];
        endDate = [self.calendar dateByAddingComponents:comps toDate:date options:0];
    }

    NSUInteger dateButtonPosition = 0;
    while ([date laterDate:endDate] != date) {
        DateButton *dateButton = [self.dateButtons objectAtIndex:dateButtonPosition];

        dateButton.date = date;
        CKDateItem *item = [[CKDateItem alloc] init];
        if ([self _dateIsToday:dateButton.date]) {
            item.textColor = NSColorFromRGB(0xF2F2F2);
            item.backgroundColor = [NSColor lightGrayColor];
        } else if (!self.onlyShowCurrentMonth && [self _compareByMonth:date toDate:self.monthShowing] != NSOrderedSame) {
            item.textColor = [NSColor lightGrayColor];
        }

        if (self.delegate && [self.delegate respondsToSelector:@selector(calendar:configureDateItem:forDate:)]) {
            [self.delegate calendar:self configureDateItem:item forDate:date];
        }

        if (self.selectedDate && [self date:self.selectedDate isSameDayAsDate:date]) {
            [dateButton setTitleColor:item.selectedTextColor];
            [[dateButton cell] setBackgroundColor: [NSColor colorWithRed:.85 green:.505 blue:.505 alpha:1]];
        } else {
            [dateButton  setTitleColor:item.textColor];
            [[dateButton cell] setBackgroundColor: item.backgroundColor ];
        }

        dateButton.frame = [self _calculateDayCellFrame:date];

        [self.calendarContainer addSubview:dateButton];

        date = [self _nextDay:date];
        dateButtonPosition++;
    }
    
    if ([self.delegate respondsToSelector:@selector(calendar:didLayoutInRect:)]) {
        [self.delegate calendar:self didLayoutInRect:self.frame];
    }
    
    [super layout];
}

/*- (BOOL)isFlipped
{
    return YES;
}*/

- (void)_updateDayOfWeekLabels {
    NSArray *weekdays = [self.dateFormatter shortWeekdaySymbols];
    // adjust array depending on which weekday should be first
    NSUInteger firstWeekdayIndex = [self.calendar firstWeekday] - 1;
    if (firstWeekdayIndex > 0) {
        weekdays = [[weekdays subarrayWithRange:NSMakeRange(firstWeekdayIndex, 7 - firstWeekdayIndex)]
                    arrayByAddingObjectsFromArray:[weekdays subarrayWithRange:NSMakeRange(0, firstWeekdayIndex)]];
    }

    NSUInteger i = 0;
    for (NSString *day in weekdays) {
        [[self.dayOfWeekLabels objectAtIndex:i] setStringValue:[day uppercaseString]];
        i++;
    }
}

- (void)setCalendarStartDay:(CKCalendarStartDay)calendarStartDay {
    _calendarStartDay = calendarStartDay;
    [self.calendar setFirstWeekday:self.calendarStartDay];
    [self _updateDayOfWeekLabels];
    [self setNeedsLayout:YES];
}

- (void)setLocale:(NSLocale *)locale {
    [self.dateFormatter setLocale:locale];
    [self _updateDayOfWeekLabels];
    [self setNeedsLayout:YES];
}

- (NSLocale *)locale {
    return self.dateFormatter.locale;
}

- (NSArray *)datesShowing {
    NSMutableArray *dates = [NSMutableArray array];
    // NOTE: these should already be in chronological order
    for (DateButton *dateButton in self.dateButtons) {
        if (dateButton.date) {
            [dates addObject:dateButton.date];
        }
    }
    return dates;
}

- (void)setMonthShowing:(NSDate *)aMonthShowing {
    _monthShowing = [self _firstDayOfMonthContainingDate:aMonthShowing];
    [self setNeedsLayout:YES];
}

- (void)setOnlyShowCurrentMonth:(BOOL)onlyShowCurrentMonth {
    _onlyShowCurrentMonth = onlyShowCurrentMonth;
    [self setNeedsLayout:YES];
}

- (void)setAdaptHeightToNumberOfWeeksInMonth:(BOOL)adaptHeightToNumberOfWeeksInMonth {
    _adaptHeightToNumberOfWeeksInMonth = adaptHeightToNumberOfWeeksInMonth;
    [self setNeedsLayout:YES];
}

- (void)selectDate:(NSDate *)date makeVisible:(BOOL)visible {
    
    NSMutableArray *datesToReload = [NSMutableArray array];
    if (self.selectedDate) {
        [datesToReload addObject:self.selectedDate];
    }
    if (date) {
        [datesToReload addObject:date];
    }
    self.selectedDate = date;
    [self reloadDates:datesToReload];
    if (visible && date) {
        self.monthShowing = date;
    }
}

- (void)reloadData {
    self.selectedDate = nil;
    [self setNeedsLayout:YES];
}

- (void)reloadDates:(NSArray *)dates {
    // TODO: only update the dates specified
    [self setNeedsLayout:YES];
}

- (void)_setDefaultStyle {
    self.layer.backgroundColor = (__bridge CGColorRef)(NSColorFromRGB(0x393B40));

    [self setTitleFont:[NSFont boldSystemFontOfSize:17.0]];

    [self setDayOfWeekFont:[NSFont boldSystemFontOfSize:12.0]];
    [self setDayOfWeekTextColor:NSColorFromRGB(0x999999)];
    [self setDayOfWeekBottomColor:NSColorFromRGB(0xCCCFD5) topColor:[NSColor whiteColor]];

    [self setDateFont:[NSFont boldSystemFontOfSize:16.0f]];
    [self setDateBorderColor:NSColorFromRGB(0xDAE1E6)];
}

- (CGRect)_calculateDayCellFrame:(NSDate *)date {
    NSInteger numberOfDaysSinceBeginningOfThisMonth = [self _numberOfDaysFromDate:self.monthShowing toDate:date];
    NSInteger row = (numberOfDaysSinceBeginningOfThisMonth + [self _placeInWeekForDate:self.monthShowing]) / 7;
	
    NSInteger placeInWeek = [self _placeInWeekForDate:date];

    return CGRectMake(placeInWeek * (self.cellWidth + CELL_BORDER_WIDTH), (row * (self.cellWidth + CELL_BORDER_WIDTH)) + CGRectGetMaxY(self.daysHeader.frame) + CELL_BORDER_WIDTH, self.cellWidth, self.cellWidth);
}

- (void)_moveCalendarToNextMonth {
    NSDateComponents* comps = [[NSDateComponents alloc] init];
    [comps setMonth:1];
    NSDate *newMonth = [self.calendar dateByAddingComponents:comps toDate:self.monthShowing options:0];
    if ([self.delegate respondsToSelector:@selector(calendar:willChangeToMonth:)] && ![self.delegate calendar:self willChangeToMonth:newMonth]) {
        return;
    } else {
        self.monthShowing = newMonth;
        if ([self.delegate respondsToSelector:@selector(calendar:didChangeToMonth:)] ) {
            [self.delegate calendar:self didChangeToMonth:self.monthShowing];
        }
    }
}

- (void)_moveCalendarToPreviousMonth {
    NSDateComponents* comps = [[NSDateComponents alloc] init];
    [comps setMonth:-1];
    NSDate *newMonth = [self.calendar dateByAddingComponents:comps toDate:self.monthShowing options:0];
    if ([self.delegate respondsToSelector:@selector(calendar:willChangeToMonth:)] && ![self.delegate calendar:self willChangeToMonth:newMonth]) {
        return;
    } else {
        self.monthShowing = newMonth;
        if ([self.delegate respondsToSelector:@selector(calendar:didChangeToMonth:)] ) {
            [self.delegate calendar:self didChangeToMonth:self.monthShowing];
        }
    }
}

- (void)_dateButtonPressed:(id)sender {
    DateButton *dateButton = sender;
    NSDate *date = dateButton.date;
    if ([date isEqualToDate:self.selectedDate]) {
        // deselection..
        if ([self.delegate respondsToSelector:@selector(calendar:willDeselectDate:)] && ![self.delegate calendar:self willDeselectDate:date]) {
            return;
        }
        date = nil;
    } else if ([self.delegate respondsToSelector:@selector(calendar:willSelectDate:)] && ![self.delegate calendar:self willSelectDate:date]) {
        return;
    }

    [self selectDate:date makeVisible:YES];
    [self.delegate calendar:self didSelectDate:date];
    [self setNeedsLayout: YES];
}

#pragma mark - Theming getters/setters

- (void)setTitleFont:(NSFont *)font {
    self.titleLabel.font = font;
}
- (NSFont *)titleFont {
    return self.titleLabel.font;
}

- (void)setTitleColor:(NSColor *)color {
    self.titleLabel.textColor = color;
}
- (NSColor *)titleColor {
    return self.titleLabel.textColor;
}

- (void)setMonthButtonColor:(NSColor *)color {
    [self.prevButton setImage:[CKCalendarView _imageNamed:@"LeftArrow.png" withColor:color]];
    [self.nextButton setImage:[CKCalendarView _imageNamed:@"RightArrow.png" withColor:color]];
}

- (void)setInnerBorderColor:(NSColor *)color {
    self.calendarContainer.layer.borderColor = color.CGColor;
}

- (void)setDayOfWeekFont:(NSFont *)font {
    for (NSTextField *label in self.dayOfWeekLabels) {
        label.font = font;
    }
}
- (NSFont *)dayOfWeekFont {
    return (self.dayOfWeekLabels.count > 0) ? ((NSTextField *)[self.dayOfWeekLabels lastObject]).font : nil;
}

- (void)setDayOfWeekTextColor:(NSColor *)color {
    for (NSTextField *label in self.dayOfWeekLabels) {
        label.textColor = color;
    }
}
- (NSColor *)dayOfWeekTextColor {
    return (self.dayOfWeekLabels.count > 0) ? ((NSTextField *)[self.dayOfWeekLabels lastObject]).textColor : nil;
}

- (void)setDayOfWeekBottomColor:(NSColor *)bottomColor topColor:(NSColor *)topColor {
    [self.daysHeader setColors:[NSArray arrayWithObjects:topColor, bottomColor, nil]];
}

- (void)setDateFont:(NSFont *)font {
    for (DateButton *dateButton in self.dateButtons) {
        dateButton.font = font;
    }
}
- (NSFont *)dateFont {
    return (self.dateButtons.count > 0) ? ((DateButton *)[self.dateButtons lastObject]).font : nil;
}

- (void)setDateBorderColor:(NSColor *)color {
    self.calendarContainer.layer.backgroundColor = color.CGColor;
}
- (NSColor *)dateBorderColor {
    return [NSColor colorWithCIColor: [CIColor colorWithCGColor: self.calendarContainer.layer.backgroundColor]];
}

#pragma mark - Calendar helpers

- (NSDate *)_firstDayOfMonthContainingDate:(NSDate *)date {
    NSDateComponents *comps = [self.calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:date];
    comps.day = 1;
    return [self.calendar dateFromComponents:comps];
}

- (NSDate *)_firstDayOfNextMonthContainingDate:(NSDate *)date {
    NSDateComponents *comps = [self.calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:date];
    comps.day = 1;
    comps.month = comps.month + 1;
    return [self.calendar dateFromComponents:comps];
}

- (BOOL)dateIsInCurrentMonth:(NSDate *)date {
    return ([self _compareByMonth:date toDate:self.monthShowing] == NSOrderedSame);
}

- (NSComparisonResult)_compareByMonth:(NSDate *)date toDate:(NSDate *)otherDate {
    NSDateComponents *day = [self.calendar components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:date];
    NSDateComponents *day2 = [self.calendar components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:otherDate];

    if (day.year < day2.year) {
        return NSOrderedAscending;
    } else if (day.year > day2.year) {
        return NSOrderedDescending;
    } else if (day.month < day2.month) {
        return NSOrderedAscending;
    } else if (day.month > day2.month) {
        return NSOrderedDescending;
    } else {
        return NSOrderedSame;
    }
}

- (NSInteger)_placeInWeekForDate:(NSDate *)date {
    NSDateComponents *compsFirstDayInMonth = [self.calendar components:NSWeekdayCalendarUnit fromDate:date];
    return (compsFirstDayInMonth.weekday - 1 - self.calendar.firstWeekday + 8) % 7;
}

- (BOOL)_dateIsToday:(NSDate *)date {
    return [self date:[NSDate date] isSameDayAsDate:date];
}

- (BOOL)date:(NSDate *)date1 isSameDayAsDate:(NSDate *)date2 {
    // Both dates must be defined, or they're not the same
    if (date1 == nil || date2 == nil) {
        return NO;
    }

    NSDateComponents *day = [self.calendar components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date1];
    NSDateComponents *day2 = [self.calendar components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date2];
    return ([day2 day] == [day day] &&
            [day2 month] == [day month] &&
            [day2 year] == [day year] &&
            [day2 era] == [day era]);
}

- (NSInteger)_numberOfWeeksInMonthContainingDate:(NSDate *)date {
    return [self.calendar rangeOfUnit:NSWeekCalendarUnit inUnit:NSMonthCalendarUnit forDate:date].length;
}

- (NSDate *)_nextDay:(NSDate *)date {
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:1];
    return [self.calendar dateByAddingComponents:comps toDate:date options:0];
}

- (NSDate *)_previousDay:(NSDate *)date {
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:-1];
    return [self.calendar dateByAddingComponents:comps toDate:date options:0];
}

- (NSInteger)_numberOfDaysFromDate:(NSDate *)startDate toDate:(NSDate *)endDate {
    NSInteger startDay = [self.calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSEraCalendarUnit forDate:startDate];
    NSInteger endDay = [self.calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSEraCalendarUnit forDate:endDate];
    return endDay - startDay;
}

+ (NSImage *)_imageNamed:(NSString *)name withColor:(NSColor *)color {
    NSImage *img = [NSImage imageNamed:name];

    CGImageSourceRef imgSrc = CGImageSourceCreateWithData((__bridge CFDataRef)[img TIFFRepresentation], NULL);
    CGImageRef imageRef =  CGImageSourceCreateImageAtIndex(imgSrc, 0, NULL);
    
    NSImage *toSave = [[NSImage alloc] initWithSize:CGSizeMake(img.size.width, img.size.height)];
    [toSave lockFocus];
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    
    [color setFill];

    CGContextTranslateCTM(context, 0, img.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);

    CGContextSetBlendMode(context, kCGBlendModeColorBurn);
    CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
    CGContextDrawImage(context, rect, imageRef);

    CGContextClipToMask(context, rect, imageRef);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context,kCGPathFill);
    
    
    [toSave unlockFocus];

    return toSave;
}

@end
