import gleam/int
import gleam/option.{type Option}
import gleam/time/duration
import gleam/time/timestamp.{type Timestamp}

pub fn time_ago(
  timestamp: Timestamp,
  maybe_now: Option(Timestamp),
  _maybe_locale: Option(String),
) -> String {
  let now = option.unwrap(maybe_now, timestamp.system_time())
  let #(amount, unit) =
    duration.approximate(timestamp.difference(timestamp, now))
  let magnitude = int.absolute_value(amount)
  let tense = case amount > 0 {
    True -> Past
    False -> Future
  }

  format(tense, unit, int.to_string(magnitude))
}

type Tense {
  Past
  Future
}

fn format(tense: Tense, unit: duration.Unit, amount: String) {
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
