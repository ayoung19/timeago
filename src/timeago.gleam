//// A library for formatting timestamps as human-readable relative time strings.
//// 
//// This library provides a simple way to convert timestamps into relative time
//// expressions like "5 minutes ago" or "in 2 hours". It supports multiple
//// locales and allows customization of the reference time.
//// 
//// ## Basic Usage
//// 
//// ```gleam
//// import gleam/time/duration
//// import gleam/time/timestamp
//// import timeago
//// 
//// // Format a timestamp from 5 minutes ago
//// let past = timestamp.add(timestamp.system_time(), duration.minutes(-5))
//// timeago.new() |> timeago.format(past)
//// // -> "5 minutes ago"
//// ```

import gleam/int
import gleam/string
import gleam/time/duration.{
  type Unit, Day, Hour, Microsecond, Millisecond, Minute, Month, Nanosecond,
  Second, Week, Year,
}
import gleam/time/timestamp.{type Timestamp}

/// Configuration for formatting relative time strings.
/// 
/// Encapsulates the reference time and locale settings used when formatting
/// timestamps. Use the builder pattern with `new()`, `with_now()`, and
/// `with_locale()` to configure instances.
pub opaque type TimeAgo {
  TimeAgo(now: Timestamp, locale: Locale)
}

/// Creates a new TimeAgo formatter with default settings.
/// 
/// Uses the current system time as the reference point and the English (US)
/// locale for formatting.
/// 
/// ## Examples
/// 
/// ```gleam
/// import gleam/time/duration
/// import gleam/time/timestamp
/// import timeago
/// 
/// timeago.new()
/// |> timeago.format(timestamp.add(timestamp.system_time(), duration.minutes(-5)))
/// // -> "5 minutes ago"
/// ```
pub fn new() -> TimeAgo {
  TimeAgo(timestamp.system_time(), en_us)
}

/// Sets a custom reference time for calculating relative differences.
/// 
/// By default, TimeAgo uses the current system time when created. This allows
/// you to specify a different reference point for testing, calculating from
/// specific moments, or maintaining consistency across operations.
/// 
/// ## Examples
/// 
/// ```gleam
/// import gleam/time/timestamp
/// import timeago
/// 
/// let assert Ok(reference) = timestamp.parse_rfc3339("2024-01-01T12:00:00Z")
/// let assert Ok(past) = timestamp.parse_rfc3339("2024-01-01T11:00:00Z")
/// 
/// timeago.new()
/// |> timeago.with_now(reference)
/// |> timeago.format(past)
/// // -> "1 hour ago"
/// ```
pub fn with_now(time_ago: TimeAgo, now: Timestamp) -> TimeAgo {
  TimeAgo(..time_ago, now: now)
}

/// Sets a custom locale function for formatting output strings.
/// 
/// The locale function determines how relative time is expressed in different
/// languages.
/// 
/// ## Examples
/// 
/// ```gleam
/// import gleam/time/duration
/// import gleam/time/timestamp
/// import timeago
/// 
/// // Using the built-in French locale
/// timeago.new()
/// |> timeago.with_locale(timeago.fr)
/// |> timeago.format(timestamp.add(timestamp.system_time(), duration.hours(-2)))
/// // -> "il y a 2 heures"
/// ```
pub fn with_locale(time_ago: TimeAgo, locale: Locale) -> TimeAgo {
  TimeAgo(..time_ago, locale: locale)
}

/// Formats a timestamp as a human-readable relative time string.
/// 
/// Calculates the difference between the given timestamp and the reference time
/// (set via `with_now()` or defaulting to the current time), then formats it
/// using the configured locale.
/// 
/// The output automatically adjusts for singular/plural forms and selects
/// appropriate time units based on the magnitude of the difference.
/// 
/// ## Examples
/// 
/// ```gleam
/// import gleam/time/duration
/// import gleam/time/timestamp
/// import timeago
/// 
/// let now = timestamp.system_time()
/// 
/// // Past times
/// timeago.new()
/// |> timeago.format(timestamp.add(now, duration.seconds(-5)))
/// // -> "5 seconds ago"
/// 
/// timeago.new()
/// |> timeago.format(timestamp.add(now, duration.minutes(-1)))
/// // -> "1 minute ago"
/// 
/// // Future times
/// timeago.new()
/// |> timeago.format(timestamp.add(now, duration.hours(2)))
/// // -> "in 2 hours"
/// 
/// timeago.new()
/// |> timeago.format(timestamp.add(now, duration.days(1)))
/// // -> "in 1 day"
/// 
/// timeago.new()
/// |> timeago.format(timestamp.add(now, duration.milliseconds(-500)))
/// // -> "just now"
/// ```
pub fn format(time_ago: TimeAgo, timestamp: Timestamp) -> String {
  let #(amount, unit) =
    duration.approximate(timestamp.difference(timestamp, time_ago.now))
  let magnitude = int.absolute_value(amount)
  let tense = case amount > 0 {
    True -> Past
    False -> Future
  }

  time_ago.locale(tense, unit, magnitude)
}

/// Represents the temporal direction of a time difference.
/// 
/// Used to determine whether a timestamp is in the past or future relative
/// to a reference time.
pub type Tense {
  /// Indicates that the timestamp occurred before the reference time.
  /// Results in formatting like "X ago".
  Past

  /// Indicates that the timestamp will occur after the reference time.
  /// Results in formatting like "in X".
  Future
}

/// A function that formats relative time strings for a specific language and locale.
/// 
/// Receives tense (past/future), unit (seconds, minutes, etc.), and amount,
/// then returns a formatted string like "5 minutes ago" or "in 2 hours".
pub type Locale =
  fn(Tense, Unit, Int) -> String

fn replace_percent_d_with_int(s: String, i: Int) -> String {
  string.replace(s, "%d", int.to_string(i))
}

pub fn en_us(tense: Tense, unit: Unit, amount: Int) -> String {
  case tense, unit, amount {
    _, Nanosecond, _ | _, Microsecond, _ | _, Millisecond, _ -> "just now"
    Past, Second, 1 -> "1 second ago"
    Past, Second, a -> "%d seconds ago" |> replace_percent_d_with_int(a)
    Past, Minute, 1 -> "1 minute ago"
    Past, Minute, a -> "%d minutes ago" |> replace_percent_d_with_int(a)
    Past, Hour, 1 -> "1 hour ago"
    Past, Hour, a -> "%d hours ago" |> replace_percent_d_with_int(a)
    Past, Day, 1 -> "1 day ago"
    Past, Day, a -> "%d days ago" |> replace_percent_d_with_int(a)
    Past, Week, 1 -> "1 week ago"
    Past, Week, a -> "%d weeks ago" |> replace_percent_d_with_int(a)
    Past, Month, 1 -> "1 month ago"
    Past, Month, a -> "%d months ago" |> replace_percent_d_with_int(a)
    Past, Year, 1 -> "1 year ago"
    Past, Year, a -> "%d years ago" |> replace_percent_d_with_int(a)
    Future, Second, 1 -> "in 1 second"
    Future, Second, a -> "in %d seconds" |> replace_percent_d_with_int(a)
    Future, Minute, 1 -> "in 1 minute"
    Future, Minute, a -> "in %d minutes" |> replace_percent_d_with_int(a)
    Future, Hour, 1 -> "in 1 hour"
    Future, Hour, a -> "in %d hours" |> replace_percent_d_with_int(a)
    Future, Day, 1 -> "in 1 day"
    Future, Day, a -> "in %d days" |> replace_percent_d_with_int(a)
    Future, Week, 1 -> "in 1 week"
    Future, Week, a -> "in %d weeks" |> replace_percent_d_with_int(a)
    Future, Month, 1 -> "in 1 month"
    Future, Month, a -> "in %d months" |> replace_percent_d_with_int(a)
    Future, Year, 1 -> "in 1 year"
    Future, Year, a -> "in %d years" |> replace_percent_d_with_int(a)
  }
}

pub fn fr(tense: Tense, unit: Unit, amount: Int) -> String {
  case tense, unit, amount {
    _, Nanosecond, _ | _, Microsecond, _ | _, Millisecond, _ -> "à l'instant"
    Past, Second, 1 -> "il y a 1 seconde"
    Past, Second, a -> "il y a %d secondes" |> replace_percent_d_with_int(a)
    Past, Minute, 1 -> "il y a 1 minute"
    Past, Minute, a -> "il y a %d minutes" |> replace_percent_d_with_int(a)
    Past, Hour, 1 -> "il y a 1 heure"
    Past, Hour, a -> "il y a %d heures" |> replace_percent_d_with_int(a)
    Past, Day, 1 -> "il y a 1 jour"
    Past, Day, a -> "il y a %d jours" |> replace_percent_d_with_int(a)
    Past, Week, 1 -> "il y a 1 semaine"
    Past, Week, a -> "il y a %d semaines" |> replace_percent_d_with_int(a)
    Past, Month, 1 -> "il y a 1 mois"
    Past, Month, a -> "il y a %d mois" |> replace_percent_d_with_int(a)
    Past, Year, 1 -> "il y a 1 an"
    Past, Year, a -> "il y a %d ans" |> replace_percent_d_with_int(a)
    Future, Second, 1 -> "dans 1 seconde"
    Future, Second, a -> "dans %d secondes" |> replace_percent_d_with_int(a)
    Future, Minute, 1 -> "dans 1 minute"
    Future, Minute, a -> "dans %d minutes" |> replace_percent_d_with_int(a)
    Future, Hour, 1 -> "dans 1 heure"
    Future, Hour, a -> "dans %d heures" |> replace_percent_d_with_int(a)
    Future, Day, 1 -> "dans 1 jour"
    Future, Day, a -> "dans %d jours" |> replace_percent_d_with_int(a)
    Future, Week, 1 -> "dans 1 semaine"
    Future, Week, a -> "dans %d semaines" |> replace_percent_d_with_int(a)
    Future, Month, 1 -> "dans 1 mois"
    Future, Month, a -> "dans %d mois" |> replace_percent_d_with_int(a)
    Future, Year, 1 -> "dans 1 an"
    Future, Year, a -> "dans %d ans" |> replace_percent_d_with_int(a)
  }
}
