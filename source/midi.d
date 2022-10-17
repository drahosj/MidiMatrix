module midi;

enum TestMessage {
    NOTE_ON_1,
    NOTE_OFF_1,
    NOTE_ON_2,
    NOTE_OFF_2,
    ALL_NOTES_OFF
};

struct Midi {
    ubyte[8] buf;
    int test = 42;
    size_t e;
    size_t s;

    ubyte[] raw() {
        return buf[s .. e];
    }

    string str() {
        if ((raw[0] & 0xf0) == 0x90) {
            return "NOTE_ON";
        } else if ((raw[0] & 0xf0) == 0x80) {
            return "NOTE_OFF";
        } else {
            return "OTHER";
        }
    }

    uint num() {
        return raw[1];
    }

    uint vel() {
        return raw[2];
    }

    uint chan() {
        return raw[0] & 0x0f;
    }

    void setChan(ubyte c) {
        raw[0] |= c & 0x0f;
    }

    this(ubyte[3] c) {
        s = 0;
        e = 3;
        buf[0 .. 3] = c;
    }

    this(TestMessage t) {
        switch (t) with (TestMessage)
        {
            case NOTE_ON_1:
                buf = [0x90, 0x35, 0x40, 0, 0, 0, 0, 0];
                e = 3;
                break;
            case NOTE_OFF_1:
                buf = [0x80, 0x35, 0x40, 0, 0, 0, 0, 0];
                e = 3;
                break;
            case NOTE_ON_2:
                buf = [0x90, 0x36, 0x40, 0, 0, 0, 0, 0];
                e = 3;
                break;
            case NOTE_OFF_2:
                buf = [0x80, 0x36, 0x40, 0, 0, 0, 0, 0];
                e = 3;
                break;
            case ALL_NOTES_OFF:
                buf = [0xb0, 123, 0, 0, 0, 0, 0, 0];
                e = 3;
                break;
            default:
        }
    }
}
