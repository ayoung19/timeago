import gleam/int
import gleam/time/duration
import gleam/time/timestamp.{type Timestamp}
import timeago/locales/en_us.{en_us}
import timeago/tense.{type Tense, Future, Past}

pub type Locale =
  fn(Tense, duration.Unit, String) -> String

pub opaque type TimeAgo {
  TimeAgo(now: Timestamp, locale: Locale)
}

pub fn new() -> TimeAgo {
  TimeAgo(timestamp.system_time(), en_us)
}

pub fn with_now(time_ago: TimeAgo, now: Timestamp) -> TimeAgo {
  TimeAgo(..time_ago, now: now)
}

pub fn with_locale(time_ago: TimeAgo, locale: Locale) -> TimeAgo {
  TimeAgo(..time_ago, locale: locale)
}

pub fn format(time_ago: TimeAgo, timestamp: Timestamp) -> String {
  let #(amount, unit) =
    duration.approximate(timestamp.difference(timestamp, time_ago.now))
  let magnitude = int.absolute_value(amount)
  let tense = case amount > 0 {
    True -> Past
    False -> Future
  }

  time_ago.locale(tense, unit, int.to_string(magnitude))
}
