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

/// Convert Char to String
/// @intrinsic %char.to_string
pub fn to_string(self : Char) -> String {
  let bytes = Bytes::new(4)
  let len = bytes.set_utf16_char(0, self)
  bytes.sub_string(0, len)
}

pub impl Show for Char with output(self, logger) {
  fn to_hex_digit(i : Int) -> Char {
    if i < 10 {
      Char::from_int('0'.to_int() + i)
    } else {
      Char::from_int('a'.to_int() + (i - 10))
    }
  }

  logger.write_char('\'')
  match self {
    '\'' | '\\' => {
      logger.write_char('\\')
      logger.write_char(self)
    }
    '\n' => logger.write_string("\\n")
    '\r' => logger.write_string("\\r")
    '\b' => logger.write_string("\\b")
    '\t' => logger.write_string("\\t")
    _ => {
      let code = self.to_int()
      if code < 0x20 {
        logger.write_char('\\')
        logger.write_char('x')
        logger.write_char(to_hex_digit(code / 16))
        logger.write_char(to_hex_digit(code % 16))
      } else {
        logger.write_char(self)
      }
    }
  }
  logger.write_char('\'')
}

test "to_string" {
  @test.eq!('a'.to_string(), "a")
}

/// Write a valid MoonBit syntax representation of a character to a buffer,
/// with quotes added and special characters escaped.
pub fn debug_write(self : Char, buf : Buffer) -> Unit {
  fn to_hex_digit(i : Int) -> Char {
    if i < 10 {
      Char::from_int('0'.to_int() + i)
    } else {
      Char::from_int('a'.to_int() + (i - 10))
    }
  }

  buf.write_char('\'')
  match self {
    '\'' | '\\' => {
      buf.write_char('\\')
      buf.write_char(self)
    }
    '\n' => buf.write_string("\\n")
    '\r' => buf.write_string("\\r")
    '\b' => buf.write_string("\\b")
    '\t' => buf.write_string("\\t")
    _ => {
      let code = self.to_int()
      if code < 0x20 {
        buf.write_char('\\')
        buf.write_char('x')
        buf.write_char(to_hex_digit(code / 16))
        buf.write_char(to_hex_digit(code % 16))
      } else {
        buf.write_char(self)
      }
    }
  }
  buf.write_char('\'')
}

test "debug_write" {
  fn repr(chr) {
    let buf = Buffer::new(size_hint=0)
    debug_write(chr, buf)
    buf.to_string()
  }

  @test.eq!(repr('a'), "'a'")
  @test.eq!(repr('\''), "'\\''")
  @test.eq!(repr('"'), "'\"'")
  @test.eq!(repr('\\'), "'\\\\'")
  @test.eq!(repr('\n'), "'\\n'")
  @test.eq!(repr('\r'), "'\\r'")
  @test.eq!(repr('\b'), "'\\b'")
  @test.eq!(repr('\t'), "'\\t'")
  @test.eq!(repr(Char::from_int(0)), "'\\x00'")
}

pub fn hash(self : Char) -> Int {
  self.to_int()
}

pub fn hash_combine(self : Char, hasher : Hasher) -> Unit {
  hasher.combine_char(self)
}
