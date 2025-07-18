import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/time/timestamp
import gleeunit
import timeago

pub fn main() -> Nil {
  gleeunit.main()
}

// Helper to create a range of integers
fn range(start: Int, end: Int) -> List(Int) {
  case start > end {
    True -> []
    False -> [start, ..range(start + 1, end)]
  }
}

// =============================================================================
// WHEN NO REFERENCE TIME IS PROVIDED
// =============================================================================

// Verifies that when no reference time is provided, system time is used
pub fn no_reference_time_test() {
  let now = timestamp.system_time()
  let result = timeago.time_ago(now, None, None)
  assert result == "just now"
}

// =============================================================================
// WHEN DATE IS IN THE PAST
// =============================================================================

// Returns "just now" if the time difference is < 1 second
pub fn past_subsecond_test() {
  // Test various millisecond differences (all < 1 second)
  list.each([0, 100, 500, 999], fn(ms) {
    let past = timestamp.from_unix_seconds_and_nanoseconds(1_546_300_800, 0)
    let now =
      timestamp.from_unix_seconds_and_nanoseconds(1_546_300_800, ms * 1_000_000)
    let result = timeago.time_ago(past, Some(now), None)
    assert result == "just now"
  })
}

// Returns "N second(s) ago" if the time difference is < 1 minute
pub fn past_seconds_test() {
  list.each(range(1, 59), fn(i) {
    let past = timestamp.from_unix_seconds(1_546_300_800)
    let now = timestamp.from_unix_seconds(1_546_300_800 + i)
    let expected = case i {
      1 -> "1 second ago"
      n -> int.to_string(n) <> " seconds ago"
    }
    let result = timeago.time_ago(past, Some(now), None)
    assert result == expected
  })
}

// Returns "N minute(s) ago" if the time difference is < 1 hour
pub fn past_minutes_test() {
  list.each(range(1, 59), fn(i) {
    let past = timestamp.from_unix_seconds(1_546_300_800)
    let now = timestamp.from_unix_seconds(1_546_300_800 + i * 60)
    let expected = case i {
      1 -> "1 minute ago"
      n -> int.to_string(n) <> " minutes ago"
    }
    let result = timeago.time_ago(past, Some(now), None)
    assert result == expected
  })
}

// Returns "N hour(s) ago" if the time difference is < 1 day
pub fn past_hours_test() {
  list.each(range(1, 23), fn(i) {
    let past = timestamp.from_unix_seconds(1_546_300_800)
    let now = timestamp.from_unix_seconds(1_546_300_800 + i * 3600)
    let expected = case i {
      1 -> "1 hour ago"
      n -> int.to_string(n) <> " hours ago"
    }
    let result = timeago.time_ago(past, Some(now), None)
    assert result == expected
  })
}

// Returns "N day(s) ago" if the time difference is < 1 week
pub fn past_days_test() {
  list.each(range(1, 6), fn(i) {
    let past = timestamp.from_unix_seconds(1_546_300_800)
    let now = timestamp.from_unix_seconds(1_546_300_800 + i * 86_400)
    let expected = case i {
      1 -> "1 day ago"
      n -> int.to_string(n) <> " days ago"
    }
    let result = timeago.time_ago(past, Some(now), None)
    assert result == expected
  })
}

// Returns "N week(s) ago" if the time difference is < 1 month (30.4375 days)
pub fn past_weeks_test() {
  list.each(range(1, 4), fn(i) {
    let past = timestamp.from_unix_seconds(1_546_300_800)
    let now = timestamp.from_unix_seconds(1_546_300_800 + i * 604_800)
    let expected = case i {
      1 -> "1 week ago"
      n -> int.to_string(n) <> " weeks ago"
    }
    let result = timeago.time_ago(past, Some(now), None)
    assert result == expected
  })
}

// Returns "N month(s) ago" if the time difference is < 1 year
pub fn past_months_test() {
  list.each(range(1, 11), fn(i) {
    let past = timestamp.from_unix_seconds(1_546_300_800)
    // Using 30.4375 days per month = 2,629,800 seconds
    let now = timestamp.from_unix_seconds(1_546_300_800 + i * 2_629_800)
    let expected = case i {
      1 -> "1 month ago"
      n -> int.to_string(n) <> " months ago"
    }
    let result = timeago.time_ago(past, Some(now), None)
    assert result == expected
  })
}

// Returns "N year(s) ago" if the time difference is >= 1 year
pub fn past_years_test() {
  list.each(range(1, 20), fn(i) {
    let past = timestamp.from_unix_seconds(1_546_300_800)
    let now = timestamp.from_unix_seconds(1_546_300_800 + i * 31_557_600)
    let expected = case i {
      1 -> "1 year ago"
      n -> int.to_string(n) <> " years ago"
    }
    let result = timeago.time_ago(past, Some(now), None)
    assert result == expected
  })
}

// =============================================================================
// WHEN DATE IS IN THE FUTURE
// =============================================================================

// Returns "just now" if the time difference is < 1 second
pub fn future_subsecond_test() {
  // Test various millisecond differences (all < 1 second)
  list.each([0, 100, 500, 999], fn(ms) {
    let now = timestamp.from_unix_seconds_and_nanoseconds(1_546_300_800, 0)
    let future =
      timestamp.from_unix_seconds_and_nanoseconds(1_546_300_800, ms * 1_000_000)
    echo timestamp.difference(future, now)
    let result = timeago.time_ago(future, Some(now), None)
    assert result == "just now"
  })
}

// Returns "in N second(s)" if the time difference is < 1 minute
pub fn future_seconds_test() {
  list.each(range(1, 59), fn(i) {
    let now = timestamp.from_unix_seconds(1_546_300_800)
    let future = timestamp.from_unix_seconds(1_546_300_800 + i)
    let expected = case i {
      1 -> "in 1 second"
      n -> "in " <> int.to_string(n) <> " seconds"
    }
    let result = timeago.time_ago(future, Some(now), None)
    assert result == expected
  })
}

// Returns "in N minute(s)" if the time difference is < 1 hour
pub fn future_minutes_test() {
  list.each(range(1, 59), fn(i) {
    let now = timestamp.from_unix_seconds(1_546_300_800)
    let future = timestamp.from_unix_seconds(1_546_300_800 + i * 60)
    let expected = case i {
      1 -> "in 1 minute"
      n -> "in " <> int.to_string(n) <> " minutes"
    }
    let result = timeago.time_ago(future, Some(now), None)
    assert result == expected
  })
}

// Returns "in N hour(s)" if the time difference is < 1 day
pub fn future_hours_test() {
  list.each(range(1, 23), fn(i) {
    let now = timestamp.from_unix_seconds(1_546_300_800)
    let future = timestamp.from_unix_seconds(1_546_300_800 + i * 3600)
    let expected = case i {
      1 -> "in 1 hour"
      n -> "in " <> int.to_string(n) <> " hours"
    }
    let result = timeago.time_ago(future, Some(now), None)
    assert result == expected
  })
}

// Returns "in N day(s)" if the time difference is < 1 week
pub fn future_days_test() {
  list.each(range(1, 6), fn(i) {
    let now = timestamp.from_unix_seconds(1_546_300_800)
    let future = timestamp.from_unix_seconds(1_546_300_800 + i * 86_400)
    let expected = case i {
      1 -> "in 1 day"
      n -> "in " <> int.to_string(n) <> " days"
    }
    let result = timeago.time_ago(future, Some(now), None)
    assert result == expected
  })
}

// Returns "in N week(s)" if the time difference is < 1 month (30.4375 days)
pub fn future_weeks_test() {
  list.each(range(1, 4), fn(i) {
    let now = timestamp.from_unix_seconds(1_546_300_800)
    let future = timestamp.from_unix_seconds(1_546_300_800 + i * 604_800)
    let expected = case i {
      1 -> "in 1 week"
      n -> "in " <> int.to_string(n) <> " weeks"
    }
    let result = timeago.time_ago(future, Some(now), None)
    assert result == expected
  })
}

// Returns "in N month(s)" if the time difference is < 1 year
pub fn future_months_test() {
  list.each(range(1, 11), fn(i) {
    let now = timestamp.from_unix_seconds(1_546_300_800)
    // Using 30.4375 days per month = 2,629,800 seconds
    let future = timestamp.from_unix_seconds(1_546_300_800 + i * 2_629_800)
    let expected = case i {
      1 -> "in 1 month"
      n -> "in " <> int.to_string(n) <> " months"
    }
    let result = timeago.time_ago(future, Some(now), None)
    assert result == expected
  })
}

// Returns "in N year(s)" if the time difference is >= 1 year
pub fn future_years_test() {
  list.each(range(1, 20), fn(i) {
    let now = timestamp.from_unix_seconds(1_546_300_800)
    let future = timestamp.from_unix_seconds(1_546_300_800 + i * 31_557_600)
    let expected = case i {
      1 -> "in 1 year"
      n -> "in " <> int.to_string(n) <> " years"
    }
    let result = timeago.time_ago(future, Some(now), None)
    assert result == expected
  })
}

// Test using RFC3339 parsed timestamps for better readability
pub fn rfc3339_test_cases() {
  let assert Ok(t1) = timestamp.parse_rfc3339("2019-01-01T00:00:00.000Z")
  let assert Ok(t2) = timestamp.parse_rfc3339("2019-01-01T00:00:00.001Z")
  let assert Ok(t3) = timestamp.parse_rfc3339("2019-01-01T00:00:00.999Z")
  let assert Ok(t4) = timestamp.parse_rfc3339("2019-01-01T00:00:01.000Z")
  let assert Ok(t5) = timestamp.parse_rfc3339("2019-01-01T00:00:59.999Z")
  let assert Ok(t6) = timestamp.parse_rfc3339("2019-01-01T00:01:00.000Z")
  let assert Ok(t7) = timestamp.parse_rfc3339("2019-01-01T01:00:00.000Z")
  let assert Ok(t8) = timestamp.parse_rfc3339("2019-01-02T00:00:00.000Z")
  let assert Ok(t9) = timestamp.parse_rfc3339("2019-02-01T00:00:00.000Z")
  let assert Ok(t10) = timestamp.parse_rfc3339("2020-01-01T00:00:00.000Z")

  // Subsecond differences should be "just now"
  let result1 = timeago.time_ago(t1, Some(t2), None)
  assert result1 == "just now"

  let result2 = timeago.time_ago(t1, Some(t3), None)
  assert result2 == "just now"

  // 1 second difference
  let result3 = timeago.time_ago(t1, Some(t4), None)
  assert result3 == "1 second ago"

  // 59.999 seconds
  let result4 = timeago.time_ago(t1, Some(t5), None)
  assert result4 == "59 seconds ago"

  // 1 minute
  let result5 = timeago.time_ago(t1, Some(t6), None)
  assert result5 == "1 minute ago"

  // 1 hour
  let result6 = timeago.time_ago(t1, Some(t7), None)
  assert result6 == "1 hour ago"

  // 1 day
  let result7 = timeago.time_ago(t1, Some(t8), None)
  assert result7 == "1 day ago"

  // 1 month (31 days in January)
  let result8 = timeago.time_ago(t1, Some(t9), None)
  assert result8 == "1 month ago"

  // 1 year
  let result9 = timeago.time_ago(t1, Some(t10), None)
  assert result9 == "1 year ago"
}
