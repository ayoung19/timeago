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
  timeago.time_ago(now, None, None)
  // -> "just now"

  let now = timestamp.system_time()
  timeago.time_ago(timestamp.add(now, duration.minutes(-1)), None, None)
  // -> "1 minute ago"

  let now = timestamp.system_time()
  timeago.time_ago(timestamp.add(now, duration.hours(3)), None, None)
  // -> "in 3 hours"

  let now = timestamp.system_time()
  timeago.time_ago(timestamp.add(now, duration.hours(3)), timestamp.add(now, duration.hours(3)), None)
  // -> "just now"
}
```

Further documentation can be found at <https://hexdocs.pm/timeago>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```
