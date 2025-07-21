# timeago

[![Package Version](https://img.shields.io/hexpm/v/timeago)](https://hex.pm/packages/timeago)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/timeago/)

```sh
gleam add timeago@1
```

```gleam
import timeago
import gleam/time/timestamp
import gleam/time/duration

pub fn main() -> Nil {
  let now = timestamp.system_time()
  timeago.new()
  |> timeago.format(now)
  // -> "just now"

  let now = timestamp.system_time()
  timeago.new()
  |> timeago.with_now(timestamp.add(now, duration.minutes(-1)))
  |> timeago.format(now)
  // -> "1 minute ago"

  let now = timestamp.system_time()
  timeago.new()
  |> timeago.with_now(timestamp.add(now, duration.hours(3)))
  |> timeago.format(now)
  // -> "in 3 hours"

  let now = timestamp.system_time()
  timeago.new()
  |> timeago.with_now(timestamp.add(now, duration.hours(3)))
  |> timeago.format(timestamp.add(now, duration.hours(3)))
  // -> "just now"
}
```

Further documentation can be found at <https://hexdocs.pm/timeago>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```
