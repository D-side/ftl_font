require "bit-struct"

class FtlFont
  class FontSection < BitStruct
    unsigned :fixed, 32
    octets :unknown1, 64
    unsigned :character_count, 16
    unsigned :character_length, 16
    unsigned :section_size, 32
    octets :unknown2, 32
    # 192 bits = 24 bytes total
    # character_count entries of Character right after that

    # Considering moving FtlFont#characters in here,
    # since it's part of this section in fact.
    # But it has variable length, and bit-struct does not
    # support this with anything but "rest" (the rest
    # of the payload), while its length is *inside*
    # the payload (#section_size)!
  end
end
