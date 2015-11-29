
import Foundation

public class DateTimeUtils {
    
    public static func getShortDate(date : NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        let dateString = dateFormatter.stringFromDate(date)
        
        return dateString
    }

    public static func getFullDate(date: NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy, hh:mm"
        let dateString = dateFormatter.stringFromDate(date)
        
        return dateString
    }
    public static func timeAgoSince(date: NSDate) -> String {
        
        let calendar = NSCalendar.currentCalendar()
        let now = NSDate()
        let unitFlags: NSCalendarUnit = [.Second, .Minute, .Hour, .Day, .WeekOfYear, .Month, .Year]
        let components = calendar.components(unitFlags, fromDate: date, toDate: now, options: [])
        let shortDay = getShortDate(date)
        if components.year >= 2 {
            return shortDay
        }
        
        if components.year >= 1 {
            return shortDay
        }
        
        if components.month >= 2 {
            return shortDay
        }
        
        if components.month >= 1 {
            return shortDay        }
        
        if components.weekOfYear >= 2 {
            return shortDay
        }
        
        if components.weekOfYear >= 1 {
            return shortDay
        }
        
        if components.day >= 2 {
            return "\(components.day)d"
        }
        
        if components.day >= 1 {
            return "1d"
        }
        
        if components.hour >= 2 {
            return "\(components.hour)h"
        }
        
        if components.hour >= 1 {
            return "1h"
        }
        
        if components.minute >= 2 {
            return "\(components.minute)m"
        }
        
        if components.minute >= 1 {
            return "1m"
        }
        
        if components.second >= 3 {
            return "\(components.second)s"
        }
        
        return "now"
        
    }
    
   }

