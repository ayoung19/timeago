import gleam/time/duration
import timeago/tense.{type Tense, Future, Past}

pub fn en_us(tense: Tense, unit: duration.Unit, amount: String) -> String {
  case tense, unit, amount {
    _, duration.Nanosecond, _
    | _, duration.Microsecond, _
    | _, duration.Millisecond, _
    -> "just now"
    Past, duration.Second, "1" -> "1 second ago"
    Past, duration.Second, s -> s <> " seconds ago"
    Past, duration.Minute, "1" -> "1 minute ago"
    Past, duration.Minute, s -> s <> " minutes ago"
    Past, duration.Hour, "1" -> "1 hour ago"
    Past, duration.Hour, s -> s <> " hours ago"
    Past, duration.Day, "1" -> "1 day ago"
    Past, duration.Day, s -> s <> " days ago"
    Past, duration.Week, "1" -> "1 week ago"
    Past, duration.Week, s -> s <> " weeks ago"
    Past, duration.Month, "1" -> "1 month ago"
    Past, duration.Month, s -> s <> " months ago"
    Past, duration.Year, "1" -> "1 year ago"
    Past, duration.Year, s -> s <> " years ago"
    Future, duration.Second, "1" -> "in 1 second"
    Future, duration.Second, s -> "in " <> s <> " seconds"
    Future, duration.Minute, "1" -> "in 1 minute"
    Future, duration.Minute, s -> "in " <> s <> " minutes"
    Future, duration.Hour, "1" -> "in 1 hour"
    Future, duration.Hour, s -> "in " <> s <> " hours"
    Future, duration.Day, "1" -> "in 1 day"
    Future, duration.Day, s -> "in " <> s <> " days"
    Future, duration.Week, "1" -> "in 1 week"
    Future, duration.Week, s -> "in " <> s <> " weeks"
    Future, duration.Month, "1" -> "in 1 month"
    Future, duration.Month, s -> "in " <> s <> " months"
    Future, duration.Year, "1" -> "in 1 year"
    Future, duration.Year, s -> "in " <> s <> " years"
  }
}
