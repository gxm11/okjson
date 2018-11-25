# patch for rmxp

class StringIO
  attr_reader :string

  def initialize(string = "")
    @string = string
  end

  def putc(c)
    @string << [c].pack("C")
  end

  def print(str)
    @string << str
  end

  def write(str)
    @string << str
  end
end

class String
  def ord
    self.unpack("C")[0]
  end
end

module OkJson
  # in RMXP, c is an int instead of a char
  # replace when c is an int

  def nibble(c)
    if ?0 <= c && c <= ?9
      c - ?0
    elsif ?a <= c && c <= ?z
      c - ?a + 10
    elsif ?A <= c && c <= ?Z
      c - ?A + 10
    else
      raise Error, "invalid hex code #{c}"
    end
  end

  def ucharcopy(t, s, i)
    n = s.length - i
    raise Utf8Error if n < 1
    c0 = s[i]

    # 1-byte, 7-bit sequence?
    if c0 < Utagx
      t.putc(c0)
      return 1
    end

    raise Utf8Error if c0 < Utag2 # unexpected continuation byte?

    raise Utf8Error if n < 2 # need continuation byte
    c1 = s[i + 1]
    raise Utf8Error if c1 < Utagx || Utag2 <= c1

    # 2-byte, 11-bit sequence?
    if c0 < Utag3
      raise Utf8Error if ((c0 & Umask2) << 6 | (c1 & Umaskx)) <= Uchar1max
      t.putc(c0)
      t.putc(c1)
      return 2
    end

    # need second continuation byte
    raise Utf8Error if n < 3

    c2 = s[i + 2]
    raise Utf8Error if c2 < Utagx || Utag2 <= c2

    # 3-byte, 16-bit sequence?
    if c0 < Utag4
      u = (c0 & Umask3) << 12 | (c1 & Umaskx) << 6 | (c2 & Umaskx)
      raise Utf8Error if u <= Uchar2max
      t.putc(c0)
      t.putc(c1)
      t.putc(c2)
      return 3
    end

    # need third continuation byte
    raise Utf8Error if n < 4
    c3 = s[i + 3]
    raise Utf8Error if c3 < Utagx || Utag2 <= c3

    # 4-byte, 21-bit sequence?
    if c0 < Utag5
      u = (c0 & Umask4) << 18 | (c1 & Umaskx) << 12 | (c2 & Umaskx) << 6 | (c3 & Umaskx)
      raise Utf8Error if u <= Uchar3max
      t.putc(c0)
      t.putc(c1)
      t.putc(c2)
      t.putc(c3)
      return 4
    end

    raise Utf8Error
  rescue Utf8Error
    t.write(Ustrerr)
    return 1
  end
end
