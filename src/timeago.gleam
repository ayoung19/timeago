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

  case unit {
    duration.Nanosecond | duration.Microsecond | duration.Millisecond ->
      "just now"
    _ -> {
      let unit_string = unit_to_string(unit)

      let magnitude = int.absolute_value(amount)

      let unit_string_suffix = case magnitude {
        1 -> ""
        _ -> "s"
      }

      case amount < 0 {
        True ->
          "in "
          <> int.to_string(magnitude)
          <> " "
          <> unit_string
          <> unit_string_suffix
        False ->
          int.to_string(magnitude)
          <> " "
          <> unit_string
          <> unit_string_suffix
          <> " ago"
      }
    }
  }
}

fn unit_to_string(unit: duration.Unit) -> String {
  case unit {
    duration.Nanosecond -> "nanosecond"
    duration.Microsecond -> "microsecond"
    duration.Millisecond -> "millisecond"
    duration.Second -> "second"
    duration.Minute -> "minute"
    duration.Hour -> "hour"
    duration.Day -> "day"
    duration.Week -> "week"
    duration.Month -> "month"
    duration.Year -> "year"
  }
}
