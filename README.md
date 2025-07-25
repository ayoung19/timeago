# timeago

[![Package Version](https://img.shields.io/hexpm/v/timeago)](https://hex.pm/packages/timeago)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/timeago/)

A lightweight Gleam library for formatting timestamps as human-readable relative time strings (e.g., '5 minutes ago', 'in 2 hours') with support for multiple locales.

## Installation

```sh
gleam add timeago@2
```

## Usage

### Basic Usage

```gleam
import gleam/time/duration
import gleam/time/timestamp
import timeago

pub fn main() {
  let past = timestamp.add(timestamp.system_time(), duration.minutes(-5))

  timeago.new()
  |> timeago.format(past)
  // -> "5 minutes ago"
}
```

### Custom Reference Time

```gleam
import gleam/time/timestamp
import timeago

pub fn main() {
  let assert Ok(reference) = timestamp.parse_rfc3339("2024-01-01T12:00:00Z")
  let assert Ok(past) = timestamp.parse_rfc3339("2024-01-01T11:00:00Z")

  timeago.new()
  |> timeago.with_now(reference)
  |> timeago.format(past)
  // -> "1 hour ago"
}
```

### Localization

The library includes built-in support for multiple languages:

```gleam
import gleam/time/duration
import gleam/time/timestamp
import timeago

pub fn main() {
  let past = timestamp.add(timestamp.system_time(), duration.hours(-2))

  // English (US) - default
  timeago.new()
  |> timeago.format(past)
  // -> "2 hours ago"

  // French
  timeago.new()
  |> timeago.with_locale(timeago.fr)
  |> timeago.format(past)
  // -> "il y a 2 heures"
}
```

### Time Unit Selection

The library automatically selects appropriate time units based on the magnitude of the difference:

```gleam
import gleam/time/duration
import gleam/time/timestamp
import timeago

pub fn main() {
  let now = timestamp.system_time()
  let formatter = timeago.new()

  // Sub-second durations
  formatter |> timeago.format(timestamp.add(now, duration.milliseconds(-500)))
  // -> "just now"

  // Seconds to years
  formatter |> timeago.format(timestamp.add(now, duration.seconds(-45)))
  // -> "45 seconds ago"

  formatter |> timeago.format(timestamp.add(now, duration.days(-3)))
  // -> "3 days ago"

  formatter |> timeago.format(timestamp.add(now, duration.days(365)))
  // -> "in 1 year"
}
```

Further documentation can be found at <https://hexdocs.pm/timeago>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```
