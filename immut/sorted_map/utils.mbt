// Copyright 2024 International Digital Economy Academy
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

/// Create an empty map.
pub fn empty[K, V]() -> Map[K, V] {
  Empty
}

/// Create a map with a single key-value pair.
pub fn singleton[K, V](key : K, value : V) -> Map[K, V] {
  Tree(key, ~value, size=1, Empty, Empty)
}

/// Check if the map contains a key.
/// O(log n).
pub fn contains[K : Compare, V](self : Map[K, V], key : K) -> Bool {
  loop self {
    Empty => false
    Tree(k, l, r, ..) => {
      let c = key.compare(k)
      if c == 0 {
        true
      } else if c < 0 {
        continue l
      } else {
        continue r
      }
    }
  }
}

/// Get the number of key-value pairs in the map.
pub fn size[K, V](self : Map[K, V]) -> Int {
  match self {
    Empty => 0
    Tree(_) as t => t.size
  }
}

pub fn is_empty[K, V](self : Map[K, V]) -> Bool {
  self.size() == 0
}

fn new[K, V](key : K, value : V, l : Map[K, V], r : Map[K, V]) -> Map[K, V] {
  let size = size(l) + size(r) + 1
  Tree(key, ~value, ~size, l, r)
}

/// Get the value associated with a key.
/// O(log n).
pub fn lookup[K : Compare, V](self : Map[K, V], key : K) -> V? {
  loop self {
    Empty => None
    Tree(k, ~value, l, r, ..) => {
      let c = key.compare(k)
      if c == 0 {
        Some(value)
      } else if c < 0 {
        continue l
      } else {
        continue r
      }
    }
  }
}

pub fn op_get[K : Compare, V](self : Map[K, V], key : K) -> V? {
  self.lookup(key)
}

/// Iterate over the key-value pairs in the map.
pub fn each[K, V](self : Map[K, V], f : (K, V) -> Unit) -> Unit {
  match self {
    Empty => ()
    Tree(k, ~value, l, r, ..) => {
      each(l, f)
      f(k, value)
      each(r, f)
    }
  }
}

/// Iterate over the key-value pairs with index.
pub fn eachi[K, V](self : Map[K, V], f : (Int, K, V) -> Unit) -> Unit {
  fn do_eachi(m : Map[K, V], f, i) {
    match m {
      Empty => ()
      Tree(k, ~value, l, r, ..) => {
        do_eachi(l, f, i)
        f(size(l) + i, k, value)
        do_eachi(r, f, size(l) + i + 1)
      }
    }
  }

  do_eachi(self, f, 0)
}

/// Maps over the values in the map.
pub fn map[K, X, Y](self : Map[K, X], f : (X) -> Y) -> Map[K, Y] {
  match self {
    Empty => Empty
    Tree(k, ~value, ~size, l, r) =>
      Tree(k, value=f(value), ~size, map(l, f), map(r, f))
  }
}

/// Maps over the key-value pairs in the map.
pub fn map_with_key[K, X, Y](self : Map[K, X], f : (K, X) -> Y) -> Map[K, Y] {
  match self {
    Empty => Empty
    Tree(k, ~value, l, r, ~size) =>
      Tree(k, value=f(k, value), ~size, map_with_key(l, f), map_with_key(r, f))
  }
}

/// Fold the values in the map.
/// O(n).
pub fn fold[K, V, T](self : Map[K, V], f : (T, V) -> T, ~init : T) -> T {
  foldl_with_key(self, fn(acc, _k, v) { f(acc, v) }, ~init)
}

/// Post-order fold.
/// O(n).
pub fn foldr_with_key[K, V, T](
  self : Map[K, V],
  f : (T, K, V) -> T,
  ~init : T
) -> T {
  fn go(m : Map[K, V], acc) {
    match m {
      Empty => acc
      Tree(k, ~value, l, r, ..) => go(l, f(go(r, acc), k, value))
    }
  }

  go(self, init)
}

/// Pre-order fold.
/// O(n).
pub fn foldl_with_key[K, V, T](
  self : Map[K, V],
  f : (T, K, V) -> T,
  ~init : T
) -> T {
  fn go(m : Map[K, V], acc) {
    match m {
      Empty => acc
      Tree(k, ~value, l, r, ..) => go(r, f(go(l, acc), k, value))
    }
  }

  go(self, init)
}

pub fn debug_write[K : Debug, V : Debug](
  self : Map[K, V],
  buffer : Buffer
) -> Unit {
  buffer.write_string("Map::[")
  let mut first = true
  self.each(
    fn(k, v) {
      if not(first) {
        buffer.write_string(", ")
      }
      first = false
      buffer.write_string("(")
      k.debug_write(buffer)
      buffer.write_string(", ")
      v.debug_write(buffer)
      buffer.write_string(")")
    },
  )
  buffer.write_string("]")
}

fn debug_tree[K : Show, V : Show](self : Map[K, V]) -> String {
  match self {
    Empty => "_"
    Tree(k, ~value, l, r, ..) => {
      let l = debug_tree(l)
      let r = debug_tree(r)
      "(\(k),\(value),\(l),\(r))"
    }
  }
}

/// Build a map from an array of key-value pairs.
/// O(n*log n).
pub fn Map::from_array[K : Compare, V](array : Array[(K, V)]) -> Map[K, V] {
  for i = 0, mp = Map::Empty; i < array.length(); {
    let (k, v) = array[i]
    continue i + 1, mp.insert(k, v)
  } else {
    mp
  }
}

pub fn iter[K, V](self : Map[K, V]) -> Iter[(K, V)] {
  Iter::new(
    fn(yield) {
      let arr = self.to_array()
      for i = 0, len = arr.length(); i < len; i = i + 1 {
        match arr[i] {
          (key, value) => if yield((key, value)) == IterEnd { break IterEnd }
        }
      } else {
        IterContinue
      }
    },
  )
}

/// Return all keys of the map in ascending order.
pub fn keys[K, V](self : Map[K, V]) -> Array[K] {
  self.iter().map(fn { (k, _) => k }).collect()
}

/// Return all elements of the map in the ascending order of their keys.
pub fn elems[K, V](self : Map[K, V]) -> Array[V] {
  self.iter().map(fn { (_, v) => v }).collect()
}

pub fn Map::of[K : Compare, V](array : FixedArray[(K, V)]) -> Map[K, V] {
  for i = 0, mp = Map::Empty; i < array.length(); {
    let (k, v) = array[i]
    continue i + 1, mp.insert(k, v)
  } else {
    mp
  }
}

pub impl[K : Show, V : Show] Show for Map[K, V] with output(self, logger) {
  logger.write_string("@immut/sorted_map.of([")
  self.eachi(
    fn(i, k, v) {
      if i > 0 {
        logger.write_string(", ")
      }
      logger.write_string("(")
      Show::output(k, logger)
      logger.write_string(", ")
      Show::output(v, logger)
      logger.write_string(")")
    },
  )
  logger.write_string("])")
}

pub fn to_string[K : Show, V : Show](self : Map[K, V]) -> String {
  Show::to_string(self)
}
