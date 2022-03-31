module midi;

enum TestMessage {
    NOTE_ON_1,
    NOTE_OFF_1,
    NOTE_ON_2,
    NOTE_OFF_2
};

struct Midi {
    ubyte[8] buf;
    bool valid = false;
    size_t e;
    size_t s;

    ubyte[] raw() {
        return buf[s .. e];
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
            default:
        }
    }
}
