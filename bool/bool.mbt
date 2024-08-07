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

pub trait Boolean {
  to_bool(Self) -> Bool
}

pub fn Bool::to_bool(self : Bool) -> Bool {
  self
}

pub fn to_int(self : Bool) -> Int {
  if self {
    1
  } else {
    0
  }
}

pub fn to_int64(self : Bool) -> Int64 {
  if self {
    1L
  } else {
    0L
  }
}

pub fn hash(self : Bool) -> Int {
  self.to_int()
}

pub fn hash_combine(self : Bool, hasher : Hasher) -> Unit {
  hasher.combine_bool(self)
}
