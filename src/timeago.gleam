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
  let #(seconds, nanoseconds) =
    duration.to_seconds_and_nanoseconds(timestamp.difference(timestamp, now))

  let diff = case seconds < 0 && nanoseconds > 0 {
    True -> seconds + 1
    False -> seconds
  }

  case diff {
    0 -> "just now"
    _ -> {
      let diff_magnitude = int.absolute_value(diff)
      let #(amount, unit) = case diff_magnitude {
        n if n < 60 -> #(n, "second")
        n if n < 3600 -> #(n / 60, "minute")
        n if n < 86_400 -> #(n / 3600, "hour")
        n if n < 2_635_200 -> #(n / 86_400, "day")
        n if n < 31_536_000 -> #(n / 2_635_200, "month")
        n -> #(n / 31_536_000, "year")
      }

      let unit_suffix = case amount {
        1 -> ""
        _ -> "s"
      }

      case diff < 0 {
        True -> "in " <> int.to_string(amount) <> " " <> unit <> unit_suffix
        False -> int.to_string(amount) <> " " <> unit <> unit_suffix <> " ago"
      }
    }
  }
}
